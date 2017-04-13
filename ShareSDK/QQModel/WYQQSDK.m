//
//  WYQQSDK.m
//  分享原生SDK集成Demo
//
//  Created by 王俨 on 2017/4/12.
//  Copyright © 2017年 wangyan. All rights reserved.
//

#import "WYQQSDK.h"
#import <TencentOpenAPI/QQApiInterface.h>
#import <TencentOpenAPI/TencentOAuth.h>
#import "WYShareResponse.h"
#import "WYShareDefine.h"
#import "WYQQUserinfo.h"
#import "WYQQToken.h"
#import "WYParamObj.h"

static NSString *const kQQRedirectURI = @"www.qq.com";

@interface WYQQSDK ()<QQApiInterfaceDelegate, TencentSessionDelegate>

@property (nonatomic, strong) TencentOAuth *tencentOAuth;
@property (nonatomic, copy) void(^qqLoginFinished)(WYQQUserinfo *qqUserinfo, WYQQToken *qqToken, NSError *error);
@property (nonatomic, copy) void(^finished)(WYShareResponse *response);

@end

@implementation WYQQSDK

+ (instancetype)defalutQQSDK {
    static WYQQSDK *qqSDK;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        qqSDK = [self new];
    });
    
    return qqSDK;
}

#pragma mark - public
+ (void)wy_registerQQApp:(NSString *)qqAppId {
    // 2.注册QQ
    WYQQSDK *qqSDK = [self defalutQQSDK];
    TencentOAuth *tencentOAuth = [[TencentOAuth alloc] initWithAppId:qqAppId andDelegate:qqSDK];
    tencentOAuth.redirectURI = kQQRedirectURI;
    qqSDK.tencentOAuth = tencentOAuth;
}

+ (NSNumber *)wy_handleOpenURL:(NSURL *)url {
    return [[self defalutQQSDK] wy_handleOpenURL:url];
}

+ (void)wy_QQLoginFinished:(WYParamObj *)paramObj {
    NSArray *permissions = @[@"get_user_info", @"get_simple_userinfo", @"add_t"];
    WYQQSDK *qqSDK = [self defalutQQSDK];
    qqSDK.qqLoginFinished = paramObj.qqLoginFinished;
    
    [qqSDK.tencentOAuth authorize:permissions inSafari:NO];
}

#pragma mark - 手机QQ分享
+ (void)wy_qqShareText:(WYParamObj *)paramObj {
    
    WY_IgnoredDeprecatedWarning(HasQQInstall);
    [[self defalutQQSDK] setFinished:paramObj.shareFinished];
    
    QQApiTextObject *textObj = [QQApiTextObject objectWithText:paramObj.param1];
    SendMessageToQQReq *textReq = [SendMessageToQQReq reqWithContent:textObj];
    
    [QQApiInterface sendReq:textReq];
}

+ (void)wy_qqShareImage:(WYParamObj *)paramObj {
    
    WY_IgnoredDeprecatedWarning(HasQQInstall);
    [[self defalutQQSDK] setFinished:paramObj.shareFinished];
    
    QQApiImageObject *imgObj = [QQApiImageObject objectWithData:paramObj.param1
                                               previewImageData:paramObj.param2
                                                          title:paramObj.param3
                                                   description :paramObj.param4];
    SendMessageToQQReq *req = [SendMessageToQQReq reqWithContent:imgObj];
    
    [QQApiInterface sendReq:req];
}

+ (void)wy_qqShareWeb:(WYParamObj *)paramObj {
    
    WY_IgnoredDeprecatedWarning(HasQQInstall);
    [[self defalutQQSDK] setFinished:paramObj.shareFinished];
    
    QQApiNewsObject *newsObject = [QQApiNewsObject objectWithURL:[NSURL URLWithString:paramObj.param1] title:paramObj.param4 description:paramObj.param2 previewImageData:paramObj.param3 targetContentType:QQApiURLTargetTypeNews];
    
    SendMessageToQQReq *newsReq = [SendMessageToQQReq reqWithContent:newsObject];
    
    [self qqSendRequest:newsReq scene:(QQShareScene)[paramObj.param5 integerValue]];
}

+ (void)wy_qqShareMusic:(WYParamObj *)paramObj {
    
    WY_IgnoredDeprecatedWarning(HasQQInstall);
    [[self defalutQQSDK] setFinished:paramObj.shareFinished];
    
    QQApiAudioObject *audioObject;
    if (paramObj.param3) {
        // 2.分享预览图URL地址 / 也可以是NSData
        audioObject = [QQApiAudioObject objectWithURL:[NSURL URLWithString:paramObj.param2] title:paramObj.param5 description:paramObj.param6 previewImageURL:[NSURL URLWithString:paramObj.param3]];
    } else if (paramObj.param4) {
        audioObject = [QQApiAudioObject objectWithURL:[NSURL URLWithString:paramObj.param2] title:paramObj.param5 description:paramObj.param6 previewImageData:paramObj.param4];
    }
    
    // 4.设置播放流媒体地址
    [audioObject setFlashURL:[NSURL URLWithString:paramObj.param1]];
    
    SendMessageToQQReq *req = [SendMessageToQQReq reqWithContent:audioObject];
    [self qqSendRequest:req scene:(QQShareScene)[paramObj.param7 integerValue]];
}

+ (void)qqSendRequest:(QQBaseReq *)req scene:(QQShareScene)scene {
    if (scene == QQShareSceneSession) { // 会话
        [QQApiInterface sendReq:req];
        return;
    }
    // 朋友圈
    [QQApiInterface SendReqToQZone:req];
}

#pragma mark - private
- (NSNumber *)wy_handleOpenURL:(NSURL *)url {
    BOOL result = [TencentOAuth HandleOpenURL:url] || [QQApiInterface handleOpenURL:url delegate:self];
    return @(result);
}

#pragma mark - QQApiInterfaceDelegate
- (void)onResp:(id)resp {
    if ([resp isKindOfClass:[QQBaseResp class]]) { // QQ分享
        QQBaseResp *qqresp = (QQBaseResp *)resp;
        if (_finished) {
            WYShareResponse *response = [WYShareResponse shareResponseWithSucess:([qqresp.result intValue] == 0) errorStr:qqresp.errorDescription];
            BLOCK_EXECRELEASE(_finished, response);
        }
    }
}

- (void)onReq:(QQBaseReq *)req {}

#pragma mark - TencentSessionDelegate
- (void)tencentDidLogin {
    if (self.tencentOAuth.accessToken.length > 0) {
        // 1.获取用户信息
        [self.tencentOAuth getUserInfo];
        
    } else {
        NSError *error = [NSError errorWithDomain:@"登录QQ失败" code:100 userInfo:nil];
        BLOCK_EXECRELEASE(self.qqLoginFinished, nil, nil, error);
    }
}

- (void)tencentDidNotLogin:(BOOL)cancelled {
    
    NSString *errorDomain = cancelled ? @"用户取消登录" : @"登录QQ失败";
    NSError *error = [NSError errorWithDomain:errorDomain code:100 userInfo:nil];
    BLOCK_EXECRELEASE(self.qqLoginFinished, nil, nil, error);
}

- (void)tencentDidNotNetWork {
    
    NSError *error = [NSError errorWithDomain:@"无网络连接，请设置网络" code:100 userInfo:nil];
    BLOCK_EXECRELEASE(self.qqLoginFinished, nil, nil, error);
}

- (void)getUserInfoResponse:(APIResponse *)response {
    
    WYQQToken *qqToken = [WYQQToken new];
    qqToken.openId = self.tencentOAuth.openId;
    qqToken.expirationDate = self.tencentOAuth.expirationDate;
    qqToken.accessToken = self.tencentOAuth.accessToken;
    
    if (response.retCode == URLREQUEST_SUCCEED && response.detailRetCode == kOpenSDKErrorSuccess) {
        
        WYQQUserinfo *qqUserinfo = [WYQQUserinfo modelWithDict:response.jsonResponse];
        BLOCK_EXECRELEASE(self.qqLoginFinished, qqUserinfo, qqToken, nil);
        
    } else {
        NSString *errorStr = [NSString stringWithFormat:@"登录授权成功，获取用户信息失败 ==> %@", response.errorMsg];
        NSError *error = [NSError errorWithDomain:errorStr code:200 userInfo:nil];
        BLOCK_EXECRELEASE(self.qqLoginFinished, nil, qqToken, error);
    }
}

- (void)isOnlineResponse:(NSDictionary *)response {}


@end
