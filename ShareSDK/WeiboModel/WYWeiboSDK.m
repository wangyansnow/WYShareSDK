//
//  WYWeiboSDK.m
//  分享原生SDK集成Demo
//
//  Created by 王俨 on 2017/4/13.
//  Copyright © 2017年 wangyan. All rights reserved.
//

#import "WYWeiboSDK.h"
#import "WeiboUser.h"
#import "WYWeiboToken.h"
#import "WeiboSDK.h"
#import "WYShareResponse.h"
#import "WYShareDefine.h"
#import "WYParamObj.h"

static NSString *const kWeiboRedirectURI = @"http://www.sina.com";

@interface WYWeiboSDK ()<WeiboSDKDelegate>

@property (nonatomic, copy) void(^finished)(WYShareResponse *response);
@property (nonatomic, copy) void(^weiboLoginFinished)(WeiboUser *weiboUser, WYWeiboToken *weiboToken, NSError *error);

@end

@implementation WYWeiboSDK

+ (instancetype)defalutWeiboSDK {
    
    static WYWeiboSDK *_instance;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [self new];
    });
    
    return _instance;
}

#pragma mark - public
+ (void)wy_registerWeiboApp:(NSString *)wbAppKey {
#if DEBUG
    [WeiboSDK enableDebugMode:YES];
#endif
    [WeiboSDK registerApp:wbAppKey];
}

+ (NSNumber *)wy_handleOpenURL:(NSURL *)url {
    WYWeiboSDK *weiboSDK = [self defalutWeiboSDK];
    BOOL result = [WeiboSDK handleOpenURL:url delegate:weiboSDK];
    
    return @(result);
}

#pragma mark - 微博分享
+ (void)wy_weiboShareText:(WYParamObj *)paramObj {
    
    WY_IgnoredDeprecatedWarning(HasWeiboInstall);
    [[self defalutWeiboSDK] setFinished:paramObj.shareFinished];
    
    WBMessageObject *message = [WBMessageObject message];
    message.text = paramObj.param1;
    
    [WeiboSDK sendRequest:[self weiboRequestWithMessage:message scene:(WeiboShareScene)[paramObj.param2 integerValue]]];
}

+ (void)wy_weiboShareImage:(WYParamObj *)paramObj {
    
    WY_IgnoredDeprecatedWarning(HasWeiboInstall);
    [[self defalutWeiboSDK] setFinished:paramObj.shareFinished];
    WBMessageObject *message = [WBMessageObject message];
    
    WBImageObject *imageObj = [WBImageObject object];
    imageObj.imageData = paramObj.param1;
    
    message.imageObject = imageObj;
    
    [WeiboSDK sendRequest:[self weiboRequestWithMessage:message scene:(WeiboShareScene)[paramObj.param2 integerValue]]];
}

+ (void)wy_weiboShareWeb:(WYParamObj *)paramObj {
    
    WY_IgnoredDeprecatedWarning(HasWeiboInstall);
    [[self defalutWeiboSDK] setFinished:paramObj.shareFinished];
    
    WBMessageObject *message = [WBMessageObject message];
    WBWebpageObject *webpage = [WBWebpageObject object];
    webpage.objectID = @"";
    webpage.title = paramObj.param2;
    webpage.description = paramObj.param3;
    webpage.thumbnailData = paramObj.param4;
    webpage.webpageUrl = paramObj.param1;
    message.mediaObject = webpage;
    
    [WeiboSDK sendRequest:[self weiboRequestWithMessage:message scene:(WeiboShareScene)[paramObj.param5 integerValue]]];
}

+ (void)wy_weiboShareMusic:(WYParamObj *)paramObj {
    
    WY_IgnoredDeprecatedWarning(HasWeiboInstall);
    [[self defalutWeiboSDK] setFinished:paramObj.shareFinished];
    
    WBMessageObject *message = [WBMessageObject message];
    
    WBMusicObject *musicObject = [WBMusicObject object];
    musicObject.objectID = @"";
    musicObject.title = paramObj.param3;
    musicObject.description = paramObj.param4;
    musicObject.thumbnailData = paramObj.param5;
    musicObject.musicUrl = paramObj.param1;
    musicObject.musicStreamUrl = paramObj.param2;
    
    message.mediaObject = musicObject;
    [WeiboSDK sendRequest:[WBSendMessageToWeiboRequest requestWithMessage:message]];
}

+ (void)wy_weiboShareVideo:(WYParamObj *)paramObj {
    
    WY_IgnoredDeprecatedWarning(HasWeiboInstall);
    [[self defalutWeiboSDK] setFinished:paramObj.shareFinished];
    
    WBMessageObject *message = [WBMessageObject message];
    
    WBVideoObject *videoObject = [WBVideoObject object];
    videoObject.objectID = @"";
    videoObject.title = paramObj.param3;
    videoObject.description = paramObj.param4;
    videoObject.thumbnailData = paramObj.param5;
    videoObject.videoUrl = paramObj.param1;
    videoObject.videoStreamUrl = paramObj.param2;
    
    message.mediaObject = videoObject;
    [WeiboSDK sendRequest:[WBSendMessageToWeiboRequest requestWithMessage:message]];
}

+ (WBBaseRequest *)weiboRequestWithMessage:(WBMessageObject *)message scene:(WeiboShareScene) scene {
    if (scene == WeiboShareSceneSession) { // 会话
        return [WBShareMessageToContactRequest requestWithMessage:message];
    }
    // 朋友圈
    return [WBSendMessageToWeiboRequest requestWithMessage:message];
}

#pragma mark - 微博登录
+ (void)wy_weiboLoginFinished:(WYParamObj *)paramObj {
    
    [[self defalutWeiboSDK] setWeiboLoginFinished:paramObj.weiboLoginFinished];
    
    WBAuthorizeRequest *request = [WBAuthorizeRequest request];
    request.redirectURI = kWeiboRedirectURI;
    request.scope = @"all";
    request.userInfo = @{@"SSO_From": @"minyanViewController",
                         @"action": @"loginBtnClick"};
    [WeiboSDK sendRequest:request];
}

#pragma mark - WeiboSDKDelegate
- (void)didReceiveWeiboResponse:(WBBaseResponse *)response {
    if ([response isKindOfClass:[WBSendMessageToWeiboResponse class]]) { // 微博分享
        WYShareResponse *res = [WYShareResponse shareResponseWithSucess:(response.statusCode == WeiboSDKResponseStatusCodeSuccess) errorStr:@"微博分享错误"];
        BLOCK_EXECRELEASE(_finished, res);
    } else if ([response isKindOfClass:[WBAuthorizeResponse class]]) { // 微博SSO授权登录
        if (response.statusCode == WeiboSDKResponseStatusCodeSuccess) {
            
            NSString *uid = response.userInfo[@"uid"];
            NSString *accessToken = response.userInfo[@"access_token"];
            WYWeiboToken *weiboToken = [WYWeiboToken modelWithDict:response.userInfo];
            
            [WBHttpRequest requestForUserProfile:uid withAccessToken:accessToken andOtherProperties:nil queue:nil withCompletionHandler:^(WBHttpRequest *httpRequest,  WeiboUser *user, NSError *error) {
                
                BLOCK_EXECRELEASE(self.weiboLoginFinished, user, weiboToken, error);
            }];
        } else {
            NSError *error = [NSError errorWithDomain:@"微博授权失败" code:-100 userInfo:response.userInfo];
            BLOCK_EXECRELEASE(self.weiboLoginFinished, nil, nil, error);
        }
    }
}

- (void)didReceiveWeiboRequest:(WBBaseRequest *)request {}

@end
