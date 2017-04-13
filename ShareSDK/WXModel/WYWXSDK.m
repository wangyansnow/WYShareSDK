//
//  WYWXSDK.m
//  分享原生SDK集成Demo
//
//  Created by 王俨 on 2017/4/11.
//  Copyright © 2017年 wangyan. All rights reserved.
//

#import "WYWXSDK.h"
#import <UIKit/UIKit.h>
#import "WXApi.h"
#import "WYShareDefine.h"
#import "WYParamObj.h"
#import "WYWXToken.h"
#import "WYWXUserinfo.h"
#import "WYShareResponse.h"

#define HasWXInstall \
    if (![WXApi isWXAppInstalled]) { \
        [[[UIAlertView alloc] initWithTitle:@"温馨提示" message:@"您还没有安装微信" delegate:nil cancelButtonTitle:@"知道了" otherButtonTitles:nil] show]; \
        return; \
    }

@interface WYWXSDK()<WXApiDelegate>

@property (nonatomic, copy) NSString *wxAppId;
@property (nonatomic, copy) NSString *wxAppSecret;

@property (nonatomic, copy) void(^finished)(WYShareResponse *response);
@property (nonatomic, copy) void(^wxLoginFinished)(WYWXUserinfo *wxUserinfo, WYWXToken *wxToken, NSError *error);

@property (nonatomic, strong) WYWXToken *wxToken;

@end

@implementation WYWXSDK

+ (instancetype)defaultWXSDK {
    static WYWXSDK *_instance;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [self new];
    });
    
    return _instance;
}

#pragma mark - public
+ (void)wy_registerWeChatApp:(WYParamObj *)paramObj {
    [WXApi registerApp:paramObj.param1];
    
    WYWXSDK *wxSDK = [self defaultWXSDK];
    wxSDK.wxAppId = paramObj.param1;
    wxSDK.wxAppSecret = paramObj.param2;
}

+ (NSNumber *)wy_handleOpenURL:(NSURL *)url {
    return [[self defaultWXSDK] wy_handleOpenURL:url];
}

#pragma mark - 微信登录
+ (void)wy_weChatLoginFinished:(WYParamObj *)paramObj {
    WY_IgnoredDeprecatedWarning(HasWXInstall);
    
    [[self defaultWXSDK] setWxLoginFinished:paramObj.wxLoginFinished];
    
    // 1.构造SendAuthReq结构体
    SendAuthReq *req = [SendAuthReq new];
    req.scope = @"snsapi_userinfo";
    req.state = @"123";
    
    // 2.应用向微信终端发送一个SendAuthReq消息结构
    [WXApi sendReq:req];
}

+ (void)wy_weChatRefreshAccessToken:(WYParamObj *)paramObj {
    WYWXSDK *wxSDK = [self defaultWXSDK];
    NSString *refreshURL = [NSString stringWithFormat:@"https://api.weixin.qq.com/sns/oauth2/refresh_token?appid=%@&grant_type=refresh_token&refresh_token=%@", wxSDK.wxAppId, wxSDK.wxToken.refresh_token];
    
    [[[NSURLSession sharedSession] dataTaskWithURL:[NSURL URLWithString:refreshURL] completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (error || !data) {
            BLOCK_EXEC(paramObj.wxRefreshTokenFinished, nil, error);
            return;
        }
        
        NSError *jsonError;
        id obj = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&error];
        if (jsonError) {
            BLOCK_EXEC(paramObj.wxRefreshTokenFinished, nil, jsonError);
            return;
        }
        
        if (obj[@"errcode"]) {
            error = [NSError errorWithDomain:obj[@"errmsg"] code:[obj[@"errcode"] integerValue] userInfo:nil];
            BLOCK_EXEC(paramObj.wxRefreshTokenFinished, nil, error);
            return;
        }
        
        wxSDK.wxToken = [WYWXToken modelWithDict:obj];
        BLOCK_EXEC(paramObj.wxRefreshTokenFinished, wxSDK.wxToken, nil);
    }] resume];
}

#pragma mark - 微信分享 [文字不可以分享到朋友圈]
+ (void)wy_weChatShareText:(WYParamObj *)paramObj {
    
    WY_IgnoredDeprecatedWarning(HasWXInstall);
    [[self defaultWXSDK] setFinished:paramObj.shareFinished];
    
    SendMessageToWXReq *textReq = [[SendMessageToWXReq alloc] init];
    
    textReq.bText = YES;
    textReq.text = paramObj.param1;
    textReq.scene = WXSceneSession;
    
    [WXApi sendReq:textReq];
}

+ (void)wy_weChatShareImage:(WYParamObj *)paramObj {
    
    WY_IgnoredDeprecatedWarning(HasWXInstall);
    [[self defaultWXSDK] setFinished:paramObj.shareFinished];
    
    WXMediaMessage *message = [WXMediaMessage message];
    [message setThumbImage:paramObj.param1];
    
    WXImageObject *imageObject = [WXImageObject object];
    imageObject.imageData = paramObj.param2;
    
    message.mediaObject = imageObject;
    
    SendMessageToWXReq *imageReq = [[SendMessageToWXReq alloc] init];
    imageReq.bText = NO;
    imageReq.message = message;
    imageReq.scene = (WXShareScene)[paramObj.param3 integerValue];
    [WXApi sendReq:imageReq];
}

+ (void)wy_weChatShareWeb:(WYParamObj *)paramObj {
    
    WY_IgnoredDeprecatedWarning(HasWXInstall);
    [[self defaultWXSDK] setFinished:paramObj.shareFinished];
    
    WXMediaMessage *message = [WXMediaMessage message];
    message.title = paramObj.param4;
    message.description = paramObj.param2;
    [message setThumbImage:paramObj.param3];
    
    WXWebpageObject *webpageObject = [WXWebpageObject object];
    webpageObject.webpageUrl = paramObj.param1;
    message.mediaObject = webpageObject;
    
    SendMessageToWXReq *webReq = [[SendMessageToWXReq alloc] init];
    webReq.bText = NO;
    webReq.message = message;
    webReq.scene = (WXShareScene)[paramObj.param5 integerValue];
    [WXApi sendReq:webReq];
}

+ (void)wy_weChatShareMusic:(WYParamObj *)paramObj {
    
    WY_IgnoredDeprecatedWarning(HasWXInstall);
    [[self defaultWXSDK] setFinished:paramObj.shareFinished];
    
    WXMediaMessage *message = [WXMediaMessage message];
    message.title = paramObj.param4;
    message.description = paramObj.param5;
    [message setThumbImage:paramObj.param3];
    
    WXMusicObject *musicObj = [WXMusicObject object];
    musicObj.musicUrl = paramObj.param1;  // 音乐url
    musicObj.musicDataUrl = paramObj.param2;  // 音乐数据url
    message.mediaObject = musicObj;
    
    SendMessageToWXReq *req = [[SendMessageToWXReq alloc] init];
    req.bText = NO;
    req.message = message;
    req.scene = (WXShareScene)[paramObj.param6 integerValue];
    
    [WXApi sendReq:req];
    
}

+ (void)wy_weChatShareVideo:(WYParamObj *)paramObj {
    
    WY_IgnoredDeprecatedWarning(HasWXInstall);
    [[self defaultWXSDK] setFinished:paramObj.shareFinished];
    
    WXMediaMessage *message = [WXMediaMessage message];
    message.title = paramObj.param3;
    message.description = paramObj.param4;
    [message setThumbImage:paramObj.param2];
    
    WXVideoObject *videoObj = [WXVideoObject object];
    videoObj.videoUrl = paramObj.param1;
    message.mediaObject = videoObj;
    
    SendMessageToWXReq *req = [[SendMessageToWXReq alloc] init];
    req.bText = NO;
    req.message = message;
    req.scene = (WXShareScene)[paramObj.param5 integerValue];
    
    [WXApi sendReq:req];
}

#pragma mark - WXApiDelegate
- (void)onResp:(BaseResp *)resp {
    if ([resp isKindOfClass:[SendAuthResp class]] ) { // 微信登录
        [self wy_handleWXLoginResponse:(SendAuthResp *)resp];
        return;
    }
    
    // 微信分享
    BaseResp *wxresp = (BaseResp *)resp;
    if (_finished) {
        WYShareResponse *response = [WYShareResponse shareResponseWithSucess:(wxresp.errCode == 0) errorStr:wxresp.errStr];
        BLOCK_EXECRELEASE(_finished, response);
    }
}

#pragma mark - private
- (NSNumber *)wy_handleOpenURL:(NSURL *)url {
    return @([WXApi handleOpenURL:url delegate:self]);
}

- (void)wy_handleWXLoginResponse:(SendAuthResp *)resp {
    if (resp.errCode != 0)  {
        NSError *error = [NSError errorWithDomain:@"微信客户端授权失败" code:resp.errCode userInfo:nil];
        BLOCK_EXECRELEASE(_wxLoginFinished, nil, nil, error);
        return;
    };
    
    NSString *urlStr = [NSString stringWithFormat:@"https://api.weixin.qq.com/sns/oauth2/access_token?appid=%@&secret=%@&code=%@&grant_type=authorization_code", self.wxAppId, self.wxAppSecret, resp.code];
    
    [[[NSURLSession sharedSession] dataTaskWithURL:[NSURL URLWithString:urlStr] completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        
        if (error || !data) {
            NSString *errorStr = [NSString stringWithFormat:@"获取Token失败，%@", error.domain];
            error = [NSError errorWithDomain:errorStr code:error.code userInfo:error.userInfo];
            BLOCK_EXECRELEASE(_wxLoginFinished, nil, nil, error);
            return;
        }
        
        NSError *jsonError;
        id obj = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:&jsonError];
        if (jsonError) {
            BLOCK_EXECRELEASE(_wxLoginFinished, nil, nil, error);
            return;
        }
        
        self.wxToken = [WYWXToken modelWithDict:obj];
        [self.wxToken saveModelWithKey:WYWXTokenKey];
        
        [WYWXUserinfo wy_fetchWXUserinfoWithAccessToken:self.wxToken.access_token openId:self.wxToken.openid finished:^(WYWXUserinfo *wxUserinfo, NSError *error) {
            if (error) {
                NSString *errorStr = [NSString stringWithFormat:@"获取用户详细信息失败,%@", error.domain];
                error = [NSError errorWithDomain:errorStr code:error.code userInfo:error.userInfo];
                BLOCK_EXECRELEASE(_wxLoginFinished, nil, self.wxToken, error);
                return;
            }
            
            BLOCK_EXECRELEASE(_wxLoginFinished, wxUserinfo, self.wxToken, nil);
        }];
    }] resume];
}

#pragma mark - getter
- (WYWXToken *)wxToken {
    if (!_wxToken) {
        _wxToken = [WYWXToken modelWithSaveKey:WYWXTokenKey];
    }
    return _wxToken;
}

@end
