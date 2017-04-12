//
//  WYWXSDK.h
//  分享原生SDK集成Demo
//
//  Created by 王俨 on 2017/4/11.
//  Copyright © 2017年 wangyan. All rights reserved.
//

#import "WYWXUserinfo.h"
#import "WYWXToken.h"
#import "WYShareResponse.h"
#import <UIKit/UIKit.h>

@class WYParamObj;
@interface WYWXSDK : NSObject

+ (void)wy_registerWeChatApp:(WYParamObj *)paramObj;
+ (NSNumber *)wy_handleOpenURL:(WYParamObj *)paramObj;

+ (void)wy_weChatLoginFinished:(WYParamObj *)paramObj;
+ (void)wy_weChatRefreshAccessToken:(WYParamObj *)paramObj;

#pragma mark - 微信分享 [文字不可以分享到朋友圈]
+ (void)wy_weChatShareText:(WYParamObj *)paramObj;
+ (void)wy_weChatShareImage:(WYParamObj *)paramObj;
+ (void)wy_weChatShareWeb:(WYParamObj *)paramObj;
+ (void)wy_weChatShareMusic:(WYParamObj *)paramObj;
+ (void)wy_weChatShareVideo:(WYParamObj *)paramObj;

@end
