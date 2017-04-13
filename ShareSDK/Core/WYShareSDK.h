//
//  WYShareSDK.h
//  分享原生SDK集成Demo
//
//  Created by 王俨 on 16/9/4.
//  Copyright © 2016年 wangyan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WYShareResponse.h"

@class WYWXToken, WYWXUserinfo, WYQQToken, WYQQUserinfo, WeiboUser, WYWeiboToken;
@interface WYShareSDK : NSObject


#pragma mark - register
+ (void)wy_registerWeChatApp:(NSString *)wxAppId wxAppSecret:(NSString *)wxAppSecret;
+ (void)wy_registerQQApp:(NSString *)qqAppId;
+ (void)wy_registerWeiboApp:(NSString *)wbAppKey;

+ (BOOL)wy_handleOpenURL:(NSURL *)url;

#pragma mark - ShareMethods
#pragma mark - 微信分享 [文字不可以分享到朋友圈]
+ (void)wy_weChatShareText:(NSString *)text
               finished:(void(^)(WYShareResponse *response))finished;

+ (void)wy_weChatShareThumbImage:(UIImage *)thumbImage
                originalImage:(NSData *)originalImageData
                        scene:(WXShareScene)scene
                     finished:(void(^)(WYShareResponse *response))finished;

+ (void)wy_weChatShareWebURL:(NSString *)url
                description:(NSString *)description
                 thumbImage:(UIImage *)thumbImage
                     title:(NSString *)title
                      scene:(WXShareScene)scene
                   finished:(void(^)(WYShareResponse *response))finished;

+ (void)wy_weChatShareMusicURL:(NSString *)musicUrl
               musicDataURL:(NSString *)musicDataUrl
                 thumbImage:(UIImage *)thumbImage
                      title:(NSString *)title
                description:(NSString *)description
                      scene:(WXShareScene)scene
                   finished:(void(^)(WYShareResponse *response))finished;

+ (void)wy_weChatShareVideoURL:(NSString *)videoUrl
                 thumbImage:(UIImage *)thumbImage
                      title:(NSString *)title
                description:(NSString *)description
                      scene:(WXShareScene)scene
                   finished:(void(^)(WYShareResponse *response))finished;


#pragma mark - 手机QQ分享  [只有`新闻`(网页)和音乐可以分享到朋友圈]
+ (void)wy_qqShareText:(NSString *)text
            finshed:(void(^)(WYShareResponse *response))finished;

+ (void)wy_qqShareImage:(NSData *)previewImageData
       originalImage:(NSData *)originalImageData
               title:(NSString *)title
         description:(NSString *)description
            finished:(void(^)(WYShareResponse *response))finished;

+ (void)wy_qqShareWebURL:(NSString *)url
            description:(NSString *)description
             thumbImage:(NSData *)thumbImageData
                 title:(NSString *)title
                  scene:(QQShareScene)scene
               finished:(void(^)(WYShareResponse *response))finished;

/// 分享音乐到QQ previewImageUrl 和 previewImageData只需要有一个即可
+ (void)wy_qqShareMusicURL:(NSString *)flashUrl
                jumpURL:(NSString *)jumpUrl
        previewImageURL:(NSString *)previewImageUrl
       previewImageData:(NSData *)previewImageData
                  title:(NSString *)title
            description:(NSString *)description
                  scene:(QQShareScene)scene
               finished:(void(^)(WYShareResponse *response))finished;

#pragma mark - 微博分享
+ (void)wy_weiboShareText:(NSString *)text
               scene:(WeiboShareScene)scene
            finished:(void(^)(WYShareResponse *response))finished;

+ (void)wy_weiboShareImage:(NSData *)imageData
                scene:(WeiboShareScene)scene
              finshed:(void(^)(WYShareResponse *response))finished;

+ (void)wy_weiboShareWebURL:(NSString *)url
                   title:(NSString *)title
            description:(NSString *)description
             thumbImage:(NSData *)thumbImageData
                  scene:(WeiboShareScene)scene
               finished:(void(^)(WYShareResponse *response))finished;
/// 只支持分享 `音乐🎵` 到朋友圈
+ (void)wy_weiboShareMusicURL:(NSString *)url
                 streamURL:(NSString *)streamUrl
                     title:(NSString *)title
               description:(NSString *)description
             thumbnailData:(NSData *)thumbnailData
                  finished:(void(^)(WYShareResponse *response))finished;

/// 只支持分享 `视频📺` 到朋友圈
+ (void)wy_weiboShareVideoURL:(NSString *)url
                 streamURL:(NSString *)streamUrl
                     title:(NSString *)title
               description:(NSString *)description
             thumbnailData:(NSData *)thumbnailData
                  finished:(void(^)(WYShareResponse *response))finished;

#pragma mark - 三方登录
+ (void)wy_weChatLoginFinished:(void(^)(WYWXUserinfo *wxUserinfo, WYWXToken *wxToken, NSError *error))finished;
+ (void)wy_weChatRefreshAccessToken:(void(^)(WYWXToken *wxToken, NSError *error))finished;

+ (void)wy_QQLoginFinished:(void(^)(WYQQUserinfo *qqUserinfo, WYQQToken *qqToken, NSError *error))finished;

+ (void)wy_weiboLoginFinished:(void(^)(WeiboUser *weiboUser, WYWeiboToken *weiboToken, NSError *error))finished;

@end
