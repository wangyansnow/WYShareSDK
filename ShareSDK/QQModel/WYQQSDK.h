//
//  WYQQSDK.h
//  分享原生SDK集成Demo
//
//  Created by 王俨 on 2017/4/12.
//  Copyright © 2017年 wangyan. All rights reserved.
//

#import <Foundation/Foundation.h>

@class WYParamObj;
@interface WYQQSDK : NSObject

+ (void)wy_registerQQApp:(NSString *)qqAppId;
+ (NSNumber *)wy_handleOpenURL:(NSURL *)url;

+ (void)wy_QQLoginFinished:(WYParamObj *)paramObj;

#pragma mark - 手机QQ分享  [只有`新闻`(网页)和音乐可以分享到朋友圈]
+ (void)wy_qqShareText:(WYParamObj *)paramObj;

+ (void)wy_qqShareImage:(WYParamObj *)paramObj;

+ (void)wy_qqShareWeb:(WYParamObj *)paramObj;

/// 分享音乐到QQ previewImageUrl 和 previewImageData只需要有一个即可
+ (void)wy_qqShareMusic:(WYParamObj *)paramObj;

@end
