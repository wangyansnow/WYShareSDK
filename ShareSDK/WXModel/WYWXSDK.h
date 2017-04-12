//
//  WYWXSDK.h
//  分享原生SDK集成Demo
//
//  Created by 王俨 on 2017/4/11.
//  Copyright © 2017年 wangyan. All rights reserved.
//

#import "WYWXUserinfo.h"
#import "WYWXToken.h"

@interface WYWXSDK : NSObject

+ (void)wy_registerWeChatApp:(NSString *)wxAppId wxAppSecret:(NSString *)wxAppSecret;
+ (BOOL)wy_handleOpenURL:(NSURL *)url;

+ (void)wy_weChatLoginFinished:(void(^)(WYWXUserinfo *wxUserinfo, WYWXToken *wxToken, NSError *error))finished;
+ (void)wy_weChatRefreshAccessToken:(void(^)(WYWXToken *wxToken, NSError *error))finished;

@end
