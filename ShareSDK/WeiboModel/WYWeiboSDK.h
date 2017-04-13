//
//  WYWeiboSDK.h
//  分享原生SDK集成Demo
//
//  Created by 王俨 on 2017/4/13.
//  Copyright © 2017年 wangyan. All rights reserved.
//

#import <Foundation/Foundation.h>

@class WYParamObj;
@interface WYWeiboSDK : NSObject

+ (void)wy_registerWeiboApp:(NSString *)wbAppKey;
+ (NSNumber *)wy_handleOpenURL:(NSURL *)url;

#pragma mark - 微博分享
+ (void)wy_weiboShareText:(WYParamObj *)paramObj;

+ (void)wy_weiboShareImage:(WYParamObj *)paramObj;

+ (void)wy_weiboShareWeb:(WYParamObj *)paramObj;
/// 只支持分享 `音乐🎵` 到朋友圈
+ (void)wy_weiboShareMusic:(WYParamObj *)paramObj;

/// 只支持分享 `视频📺` 到朋友圈
+ (void)wy_weiboShareVideo:(WYParamObj *)paramObj;

#pragma mark - 微博登录
+ (void)wy_weiboLoginFinished:(WYParamObj *)paramObj;

@end
