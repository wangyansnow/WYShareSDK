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
#import "WYShareResponse.h"
#import "WYShareDefine.h"

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
+ (void)wy_registerWeChatApp:(NSString *)wxAppId wxAppSecret:(NSString *)wxAppSecret {
    [WXApi registerApp:wxAppId];
    
    WYWXSDK *wxSDK = [self defaultWXSDK];
    wxSDK.wxAppId = wxAppId;
    wxSDK.wxAppSecret = wxAppSecret;
}

+ (BOOL)wy_handleOpenURL:(NSURL *)url {
    return [[self defaultWXSDK] wy_handleOpenURL:url];
}

+ (void)wy_weChatLoginFinished:(void(^)(WYWXUserinfo *wxUserinfo, WYWXToken *wxToken, NSError *error))finished {
    WY_IgnoredDeprecatedWarnings(HasWXInstall);
    
    [[self defaultWXSDK] setWxLoginFinished:finished];
    
    // 1.构造SendAuthReq结构体
    SendAuthReq *req = [SendAuthReq new];
    req.scope = @"snsapi_userinfo";
    req.state = @"123";
    
    // 2.应用向微信终端发送一个SendAuthReq消息结构
    [WXApi sendReq:req];
}
+ (void)wy_weChatRefreshAccessToken:(void(^)(WYWXToken *wxToken, NSError *error))finished {
    WYWXSDK *wxSDK = [self defaultWXSDK];
    NSString *refreshURL = [NSString stringWithFormat:@"https://api.weixin.qq.com/sns/oauth2/refresh_token?appid=%@&grant_type=refresh_token&refresh_token=%@", wxSDK.wxAppId, wxSDK.wxToken.refresh_token];
    
    [[[NSURLSession sharedSession] dataTaskWithURL:[NSURL URLWithString:refreshURL] completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (error || !data) {
            BLOCK_EXEC(finished, nil, error);
            return;
        }
        
        NSError *jsonError;
        id obj = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&error];
        if (jsonError) {
            BLOCK_EXEC(finished, nil, jsonError);
            return;
        }
        
        if (obj[@"errcode"]) {
            error = [NSError errorWithDomain:obj[@"errmsg"] code:[obj[@"errcode"] integerValue] userInfo:nil];
            BLOCK_EXEC(finished, nil, error);
            return;
        }
        
        wxSDK.wxToken = [WYWXToken modelWithDict:obj];
        BLOCK_EXEC(finished, wxSDK.wxToken, nil);
    }] resume];
}

#pragma mark - WXApiDelegate
- (void)onResp:(BaseResp *)resp {
    if ([resp isKindOfClass:[SendAuthResp class]] ) { // 微信登录
        [self wy_handleWXLoginResponse:(SendAuthResp *)resp];
        return;
    }
    
    BaseResp *wxresp = (BaseResp *)resp;
    if (_finished) {
        WYShareResponse *response = [WYShareResponse shareResponseWithSucess:(wxresp.errCode == 0) errorStr:wxresp.errStr];
        BLOCK_EXECRELEASE(_finished, response);
    }
}

#pragma mark - private
- (BOOL)wy_handleOpenURL:(NSURL *)url {
    return [WXApi handleOpenURL:url delegate:self];
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

@end
