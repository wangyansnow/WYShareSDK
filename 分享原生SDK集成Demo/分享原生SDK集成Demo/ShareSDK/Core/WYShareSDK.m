//
//  WYShareSDK.m
//  分享原生SDK集成Demo
//
//  Created by 王俨 on 16/9/4.
//  Copyright © 2016年 wangyan. All rights reserved.
//

#import "WYShareSDK.h"
#import "WYShareDefine.h"
#import "WYParamObj.h"

static NSString *const kWYWXSDK = @"WYWXSDK";       ///< 微信分享/登录 类名
static NSString *const kWYQQSDK = @"WYQQSDK";       ///< QQ分享/登录 类名
static NSString *const kWYWeiboSDK = @"WYWeiboSDK"; ///< 微博分享/登录 类名


@implementation WYShareSDK

+ (instancetype)defaultShareSDK {
    static id instance;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[WYShareSDK alloc] init];
    });
    
    return instance;
}

+ (void)wy_registerWeChatApp:(NSString *)wxAppId wxAppSecret:(NSString *)wxAppSecret {
    
    WYParamObj *paramObj = [WYParamObj new];
    paramObj.param1 = wxAppId;
    paramObj.param2 = wxAppSecret;
    
    WY_IgnoredPerformSelectorUndeclaredWarning([self target:kWYWXSDK selector:@selector(wy_registerWeChatApp:) params:paramObj]);
}

+ (void)wy_registerQQApp:(NSString *)qqAppId {
    
    WY_IgnoredPerformSelectorUndeclaredWarning([self target:kWYQQSDK selector:@selector(wy_registerQQApp:) params:qqAppId]);
}

+ (void)wy_registerWeiboApp:(NSString *)wbAppKey {
    // 3.注册Weibo
    WY_IgnoredPerformSelectorUndeclaredWarning([self target:kWYWeiboSDK selector:@selector(wy_registerWeiboApp:) params:wbAppKey]);
}

+ (BOOL)wy_handleOpenURL:(NSURL *)url {
    SEL selector;
    WY_IgnoredPerformSelectorUndeclaredWarning(selector = @selector(wy_handleOpenURL:));
    
    return [[self target:kWYWXSDK selector:selector params:url] boolValue] || [[self target:kWYWeiboSDK selector:selector params:url] boolValue]  || [[self target:kWYQQSDK selector:selector params:url] boolValue];
}


#pragma mark - private
+ (id)target:(NSString *)className selector:(SEL)selector params:(id)paramObj {
    Class cls = NSClassFromString(className);
    if (!cls) {
        NSAssert(NO, ([NSString stringWithFormat:@"%@转化成类失败", className]));
        return nil;
    }
    
    if (![cls respondsToSelector:selector]) {
        NSAssert(NO, ([NSString stringWithFormat:@"%@ 方法不存在", NSStringFromSelector(selector)]));
        return nil;
    }
    
    WY_IgnoredPerformSelectorLeakWarning(return [cls performSelector:selector withObject:paramObj];);
}

#pragma mark - ShareMethods
#pragma mark - 微信分享
+ (void)wy_weChatShareText:(NSString *)text
               finished:(void(^)(WYShareResponse *response))finished {
    
    WYParamObj *paramObj = [WYParamObj new];
    paramObj.param1 = text;
    
    paramObj.shareFinished = finished;
    WY_IgnoredPerformSelectorUndeclaredWarning([self target:kWYWXSDK selector:@selector(wy_weChatShareText:) params:paramObj]);
}

+ (void)wy_weChatShareThumbImage:(UIImage *)thumbImage
                originalImage:(NSData *)originalImageData
                        scene:(WXShareScene)scene
                     finished:(void(^)(WYShareResponse *response))finished {
    
    WYParamObj *paramObj = [WYParamObj new];
    paramObj.param1 = thumbImage;
    paramObj.param2 = originalImageData;
    paramObj.param3 = @(scene);
    
    paramObj.shareFinished = finished;
    WY_IgnoredPerformSelectorUndeclaredWarning([self target:kWYWXSDK selector:@selector(wy_weChatShareImage:) params:paramObj]);
}

+ (void)wy_weChatShareWebURL:(NSString *)url
              description:(NSString *)description
               thumbImage:(UIImage *)thumbImage
                    title:(NSString *)title
                    scene:(WXShareScene)scene
                 finished:(void(^)(WYShareResponse *response))finished {
    
    WYParamObj *paramObj = [WYParamObj new];
    paramObj.param1 = url;
    paramObj.param2 = description;
    paramObj.param3 = thumbImage;
    paramObj.param4 = title;
    paramObj.param5 = @(scene);
    
    paramObj.shareFinished = finished;
    WY_IgnoredPerformSelectorUndeclaredWarning([self target:kWYWXSDK selector:@selector(wy_weChatShareImage:) params:paramObj]);
}

+ (void)wy_weChatShareMusicURL:(NSString *)musicUrl
               musicDataURL:(NSString *)musicDataUrl
                 thumbImage:(UIImage *)thumbImage
                      title:(NSString *)title
                description:(NSString *)description
                      scene:(WXShareScene)scene
                   finished:(void(^)(WYShareResponse *response))finished {
    
    WYParamObj *paramObj = [WYParamObj new];
    paramObj.param1 = musicUrl;
    paramObj.param2 = musicDataUrl;
    paramObj.param3 = thumbImage;
    paramObj.param4 = title;
    paramObj.param5 = description;
    paramObj.param6 = @(scene);
    
    paramObj.shareFinished = finished;
    WY_IgnoredPerformSelectorUndeclaredWarning([self target:kWYWXSDK selector:@selector(wy_weChatShareImage:) params:paramObj]);
}

+ (void)wy_weChatShareVideoURL:(NSString *)videoUrl
                 thumbImage:(UIImage *)thumbImage
                      title:(NSString *)title
                description:(NSString *)description
                      scene:(WXShareScene)scene
                   finished:(void(^)(WYShareResponse *response))finished {
    
    WYParamObj *paramObj = [WYParamObj new];
    paramObj.param1 = videoUrl;
    paramObj.param2 = thumbImage;
    paramObj.param3 = title;
    paramObj.param4 = description;
    paramObj.param5 = @(scene);
    
    paramObj.shareFinished = finished;
    WY_IgnoredPerformSelectorUndeclaredWarning([self target:kWYWXSDK selector:@selector(wy_weChatShareImage:) params:paramObj]);
}

#pragma mark - 手机QQ分享
+ (void)wy_qqShareText:(NSString *)text
            finshed:(void(^)(WYShareResponse *response))finished {
    
    WYParamObj *paramObj = [WYParamObj new];
    paramObj.param1 = text;
    paramObj.shareFinished = finished;
    
    WY_IgnoredPerformSelectorUndeclaredWarning([self target:kWYQQSDK selector:@selector(wy_qqShareText:) params:paramObj]);
}

+ (void)wy_qqShareImage:(NSData *)previewImageData
       originalImage:(NSData *)originalImageData
               title:(NSString *)title
         description:(NSString *)description
            finished:(void(^)(WYShareResponse *response))finished {
    
    WYParamObj *paramObj = [WYParamObj new];
    paramObj.param1 = previewImageData;
    paramObj.param2 = originalImageData;
    paramObj.param3 = title;
    paramObj.param4 = description;
    paramObj.shareFinished = finished;
    
    WY_IgnoredPerformSelectorUndeclaredWarning([self target:kWYQQSDK selector:@selector(wy_qqShareImage:) params:paramObj]);
}

+ (void)wy_qqShareWebURL:(NSString *)url
          description:(NSString *)description
           thumbImage:(NSData *)thumbImageData
                title:(NSString *)title
                scene:(QQShareScene)scene
             finished:(void(^)(WYShareResponse *response))finished {
    
    WYParamObj *paramObj = [WYParamObj new];
    paramObj.param1 = url;
    paramObj.param2 = description;
    paramObj.param3 = thumbImageData;
    paramObj.param4 = title;
    paramObj.param5 = @(scene);
    paramObj.shareFinished = finished;
    
    WY_IgnoredPerformSelectorUndeclaredWarning([self target:kWYQQSDK selector:@selector(wy_qqShareWeb:) params:paramObj]);
}

+ (void)wy_qqShareMusicURL:(NSString *)flashUrl  // 音乐播放的网络流媒体地址
                jumpURL:(NSString *)jumpUrl
        previewImageURL:(NSString *)previewImageUrl
       previewImageData:(NSData *)previewImageData
                  title:(NSString *)title
            description:(NSString *)description
                  scene:(QQShareScene)scene
               finished:(void(^)(WYShareResponse *response))finished {
    
    WYParamObj *paramObj = [WYParamObj new];
    paramObj.param1 = flashUrl;
    paramObj.param2 = jumpUrl;
    paramObj.param3 = previewImageUrl;
    paramObj.param4 = previewImageData;
    paramObj.param5 = title;
    paramObj.param6 = description;
    paramObj.param7 = @(scene);
    paramObj.shareFinished = finished;
    
    WY_IgnoredPerformSelectorUndeclaredWarning([self target:kWYQQSDK selector:@selector(wy_qqShareMusic:) params:paramObj]);
}

#pragma mark - 微博分享
+ (void)wy_weiboShareText:(NSString *)text
                 scene:(WeiboShareScene)scene
              finished:(void(^)(WYShareResponse *response))finished {
    
    WYParamObj *paramObj = [WYParamObj new];
    paramObj.param1 = text;
    paramObj.param2 = @(scene);
    paramObj.shareFinished = finished;
    
    WY_IgnoredPerformSelectorUndeclaredWarning([self target:kWYWeiboSDK selector:@selector(wy_weiboShareText:) params:paramObj]);
}

+ (void)wy_weiboShareImage:(NSData *)imageData
                  scene:(WeiboShareScene)scene
                finshed:(void(^)(WYShareResponse *response))finished {
    
    WYParamObj *paramObj = [WYParamObj new];
    paramObj.param1 = imageData;
    paramObj.param2 = @(scene);
    paramObj.shareFinished = finished;
    
    WY_IgnoredPerformSelectorUndeclaredWarning([self target:kWYWeiboSDK selector:@selector(wy_weiboShareImage:) params:paramObj]);
}

+ (void)wy_weiboShareWebURL:(NSString *)url
                   title:(NSString *)title
             description:(NSString *)description
              thumbImage:(NSData *)thumbImageData
                   scene:(WeiboShareScene)scene
                finished:(void(^)(WYShareResponse *response))finished {
    
    WYParamObj *paramObj = [WYParamObj new];
    paramObj.param1 = url;
    paramObj.param2 = title;
    paramObj.param3 = description;
    paramObj.param4 = thumbImageData;
    paramObj.param5 = @(scene);
    paramObj.shareFinished = finished;
    
    WY_IgnoredPerformSelectorUndeclaredWarning([self target:kWYWeiboSDK selector:@selector(wy_weiboShareText:) params:paramObj]);
}


+ (void)wy_weiboShareMusicURL:(NSString *)url
                 streamURL:(NSString *)streamUrl
                     title:(NSString *)title
               description:(NSString *)description
             thumbnailData:(NSData *)thumbnailData
                  finished:(void(^)(WYShareResponse *response))finished {
    
    WYParamObj *paramObj = [WYParamObj new];
    paramObj.param1 = url;
    paramObj.param2 = streamUrl;
    paramObj.param3 = title;
    paramObj.param4 = description;
    paramObj.param5 = thumbnailData;
    paramObj.shareFinished = finished;
    
    WY_IgnoredPerformSelectorUndeclaredWarning([self target:kWYWeiboSDK selector:@selector(wy_weiboShareText:) params:paramObj]);
}

+ (void)wy_weiboShareVideoURL:(NSString *)url
                 streamURL:(NSString *)streamUrl
                     title:(NSString *)title
               description:(NSString *)description
             thumbnailData:(NSData *)thumbnailData
                  finished:(void(^)(WYShareResponse *response))finished {
    
    WYParamObj *paramObj = [WYParamObj new];
    paramObj.param1 = url;
    paramObj.param2 = streamUrl;
    paramObj.param3 = title;
    paramObj.param4 = description;
    paramObj.param5 = thumbnailData;
    paramObj.shareFinished = finished;
    
    WY_IgnoredPerformSelectorUndeclaredWarning([self target:kWYWeiboSDK selector:@selector(wy_weiboShareText:) params:paramObj]);
}

#pragma mark - 三方登录
+ (void)wy_weChatLoginFinished:(void(^)(WYWXUserinfo *wxUserinfo, WYWXToken *wxToken, NSError *error))finished {
    
    WYParamObj *paramObj = [WYParamObj new];
    paramObj.wxLoginFinished = finished;
    
    WY_IgnoredPerformSelectorUndeclaredWarning([self target:kWYWXSDK selector:@selector(wy_weChatLoginFinished:) params:paramObj]);
}

+ (void)wy_weChatRefreshAccessToken:(void(^)(WYWXToken *wxToken, NSError *error))finished {
    
    WYParamObj *paramObj = [WYParamObj new];
    paramObj.wxRefreshTokenFinished = finished;
    WY_IgnoredPerformSelectorUndeclaredWarning([self target:kWYWXSDK selector:@selector(wy_weChatRefreshAccessToken:) params:paramObj]);
    
}

+ (void)wy_QQLoginFinished:(void(^)(WYQQUserinfo *qqUserinfo, WYQQToken *qqToken, NSError *error))finished {
    
    WYParamObj *paramObj = [WYParamObj new];
    paramObj.qqLoginFinished = finished;
    WY_IgnoredPerformSelectorUndeclaredWarning([self target:kWYQQSDK selector:@selector(wy_QQLoginFinished:) params:paramObj]);
}

+ (void)wy_weiboLoginFinished:(void(^)(WeiboUser *weiboUser, WYWeiboToken *weiboToken, NSError *error))finished {
    
    WYParamObj *paramObj = [WYParamObj new];
    paramObj.weiboLoginFinished = finished;
    WY_IgnoredPerformSelectorUndeclaredWarning([self target:kWYWeiboSDK selector:@selector(wy_weiboLoginFinished:) params:paramObj]);
}

@end
