//
//  WYShareSDK.h
//  分享原生SDK集成Demo
//
//  Created by 王俨 on 16/9/4.
//  Copyright © 2016年 wangyan. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, WXShareScene) {
    WXShareSceneSession  = 0,        /**< 聊天界面    */
    WXShareSceneTimeline = 1,        /**< 朋友圈      */
    WXShareSceneFavorite = 2,        /**< 收藏       */
};

typedef NS_ENUM(NSInteger, QQShareScene) {
    QQShareSceneSession = 0,        /**< 聊天界面    */
    QQShareSceneQZone   = 1,        /**< 朋友圈      */
};

typedef NS_ENUM(NSInteger, WeiboShareScene) {
    WeiboShareSceneSession  = 0,    /**< 聊天界面    */
    WeiboShareSceneTimeline = 1,    /**< 朋友圈   */
};

////////////////////////////////////////  WYShareResponse  /////////////////////////////////////////////
@interface WYShareResponse : NSObject

@property (nonatomic, assign, getter=isSucess, readonly) BOOL success;
@property (nonatomic, copy, readonly) NSString *errorStr;

+ (instancetype)shareResponseWithSucess:(BOOL)success errorStr:(NSString *)errorStr;

@end


////////////////////////////////////////  WYShareSDK   ////////////////////////////////////////////
@interface WYShareSDK : NSObject

+ (void)registerWeChatApp:(NSString *)wxAppId;
+ (void)registerQQApp:(NSString *)qqAppId;
+ (void)registerWeiboApp:(NSString *)wbAppKey;

+ (BOOL)handleOpenURL:(NSURL *)url;

#pragma mark - ShareMethods
#pragma mark - 微信分享 [文字不可以分享到朋友圈]
+ (void)weChatShareText:(NSString *)text
               finished:(void(^)(WYShareResponse *response))finished;

+ (void)weChatShareThumbImage:(UIImage *)thumbImage
                originalImage:(NSData *)originalImageData
                        scene:(WXShareScene)scene
                     finished:(void(^)(WYShareResponse *response))finished;

+ (void)weChatShareWebURL:(NSString *)url
                description:(NSString *)description
                 thumbImage:(UIImage *)thumbImage
                     title:(NSString *)title
                      scene:(WXShareScene)scene
                   finished:(void(^)(WYShareResponse *response))finished;

+ (void)weChatShareMusicURL:(NSString *)musicUrl
               musicDataURL:(NSString *)musicDataUrl
                 thumbImage:(UIImage *)thumbImage
                      title:(NSString *)title
                description:(NSString *)description
                      scene:(WXShareScene)scene
                   finished:(void(^)(WYShareResponse *response))finished;

+ (void)weChatShareVideoURL:(NSString *)videoUrl
                 thumbImage:(UIImage *)thumbImage
                      title:(NSString *)title
                description:(NSString *)description
                      scene:(WXShareScene)scene
                   finished:(void(^)(WYShareResponse *response))finished;


#pragma mark - 手机QQ分享  [只有`新闻`(网页)和音乐可以分享到朋友圈]
+ (void)qqShareText:(NSString *)text
            finshed:(void(^)(WYShareResponse *response))finished;

+ (void)qqShareImage:(NSData *)previewImageData
       originalImage:(NSData *)originalImageData
               title:(NSString *)title
         description:(NSString *)description
            finished:(void(^)(WYShareResponse *response))finished;

+ (void)qqShareWebURL:(NSString *)url
            description:(NSString *)description
             thumbImage:(NSData *)thumbImageData
                 title:(NSString *)title
                  scene:(QQShareScene)scene
               finished:(void(^)(WYShareResponse *response))finished;

/// 分享音乐到QQ previewImageUrl 和 previewImageData只需要有一个即可
+ (void)qqShareMusicURL:(NSString *)flashUrl
                jumpURL:(NSString *)jumpUrl
        previewImageURL:(NSString *)previewImageUrl
       previewImageData:(NSData *)previewImageData
                  title:(NSString *)title
            description:(NSString *)description
                  scene:(QQShareScene)scene
               finished:(void(^)(WYShareResponse *response))finished;

#pragma mark - 微博分享
+ (void)weiboShareText:(NSString *)text
               scene:(WeiboShareScene)scene
            finished:(void(^)(WYShareResponse *response))finished;

+ (void)weiboShareImage:(NSData *)imageData
                scene:(WeiboShareScene)scene
              finshed:(void(^)(WYShareResponse *response))finished;

+ (void)weiboShareWebURL:(NSString *)url
                   title:(NSString *)title
            description:(NSString *)description
             thumbImage:(NSData *)thumbImageData
                  scene:(WeiboShareScene)scene
               finished:(void(^)(WYShareResponse *response))finished;
/// 只支持分享 `音乐🎵` 到朋友圈
+ (void)weiboShareMusicURL:(NSString *)url
                 streamURL:(NSString *)streamUrl
                     title:(NSString *)title
               description:(NSString *)description
             thumbnailData:(NSData *)thumbnailData
                  finished:(void(^)(WYShareResponse *response))finished;

/// 只支持分享 `视频📺` 到朋友圈
+ (void)weiboShareVideoURL:(NSString *)url
                 streamURL:(NSString *)streamUrl
                     title:(NSString *)title
               description:(NSString *)description
             thumbnailData:(NSData *)thumbnailData
                  finished:(void(^)(WYShareResponse *response))finished;



@end
