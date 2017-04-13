//
//  WYShareSDK.m
//  分享原生SDK集成Demo
//
//  Created by 王俨 on 16/9/4.
//  Copyright © 2016年 wangyan. All rights reserved.
//

#import "WYShareSDK.h"
#import <TencentOpenAPI/QQApiInterface.h>
#import <TencentOpenAPI/TencentOAuth.h>
#import "WeiboSDK.h"

#import "WYShareDefine.h"
#import "WYParamObj.h"

static NSString *const kWYWXSDK = @"WYWXSDK"; ///< 微信分享/登录 类名
static NSString *const kWYQQSDK = @"WYQQSDK"; ///< QQ分享/登录 类名

static NSString *const kQQRedirectURI = @"www.qq.com";
static NSString *const kWeiboRedirectURI = @"http://www.sina.com";

@interface WYShareSDK ()<WeiboSDKDelegate>

@property (nonatomic, copy) void(^finished)(WYShareResponse *response);
@property (nonatomic, copy) void(^weiboLoginFinished)(WeiboUser *weiboUser, WYWeiboToken *weiboToken, NSError *error);


@property (nonatomic, copy) NSString *wxAppId;
@property (nonatomic, copy) NSString *wxAppSecret;

@property (nonatomic, strong) TencentOAuth *tencentOAuth;

@end

@implementation WYShareSDK

+ (instancetype)defaultShareSDK {
    static id instance;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[WYShareSDK alloc] init];
    });
    
    return instance;
}

+ (void)registerWeChatApp:(NSString *)wxAppId wxAppSecret:(NSString *)wxAppSecret {
    
    WYParamObj *paramObj = [WYParamObj new];
    paramObj.param1 = wxAppId;
    paramObj.param2 = wxAppSecret;
    
    WY_IgnoredPerformSelectorUndeclaredWarning([self target:kWYWXSDK selector:@selector(wy_registerWeChatApp:) params:paramObj]);
}

+ (void)registerQQApp:(NSString *)qqAppId {
    
    WY_IgnoredPerformSelectorUndeclaredWarning([self target:kWYQQSDK selector:@selector(wy_registerQQApp:) params:qqAppId]);
}
+ (void)registerWeiboApp:(NSString *)wbAppKey {
    // 3.注册Weibo
#if DEBUG
    [WeiboSDK enableDebugMode:YES];
#endif
    [WeiboSDK registerApp:wbAppKey];
}

+ (BOOL)handleOpenURL:(NSURL *)url {
    return [[self defaultShareSDK] handleOpenURL:url];
}

- (BOOL)handleOpenURL:(NSURL *)url {
    
    SEL selector;
    WY_IgnoredPerformSelectorUndeclaredWarning(selector = @selector(wy_handleOpenURL:));
    
    return [[WYShareSDK target:kWYWXSDK selector:selector params:url] boolValue] || [WeiboSDK handleOpenURL:url delegate:self]  || [WYShareSDK target:kWYQQSDK selector:selector params:url];
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

#pragma mark - ShareMethods
#pragma mark - 微信分享
+ (void)weChatShareText:(NSString *)text
               finished:(void(^)(WYShareResponse *response))finished {
    
    WYParamObj *paramObj = [WYParamObj new];
    paramObj.param1 = text;
    
    paramObj.shareFinished = finished;
    WY_IgnoredPerformSelectorUndeclaredWarning([self target:kWYWXSDK selector:@selector(wy_weChatShareText:) params:paramObj]);
}

+ (void)weChatShareThumbImage:(UIImage *)thumbImage
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

+ (void)weChatShareWebURL:(NSString *)url
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

+ (void)weChatShareMusicURL:(NSString *)musicUrl
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

+ (void)weChatShareVideoURL:(NSString *)videoUrl
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
+ (void)qqShareText:(NSString *)text
            finshed:(void(^)(WYShareResponse *response))finished {
    
    WYParamObj *paramObj = [WYParamObj new];
    paramObj.param1 = text;
    paramObj.shareFinished = finished;
    
    WY_IgnoredPerformSelectorUndeclaredWarning([self target:kWYQQSDK selector:@selector(wy_qqShareText:) params:paramObj]);
}

+ (void)qqShareImage:(NSData *)previewImageData
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

+ (void)qqShareWebURL:(NSString *)url
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

+ (void)qqShareMusicURL:(NSString *)flashUrl  // 音乐播放的网络流媒体地址
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

+ (void)qqSendRequest:(QQBaseReq *)req scene:(QQShareScene)scene {
    if (scene == QQShareSceneSession) { // 会话
        [QQApiInterface sendReq:req];
        return;
    }
    // 朋友圈
    [QQApiInterface SendReqToQZone:req];
}

#pragma mark - 微博分享
+ (void)weiboShareText:(NSString *)text
                 scene:(WeiboShareScene)scene
              finished:(void(^)(WYShareResponse *response))finished {
    WY_IgnoredDeprecatedWarning(HasWeiboInstall);
    [[self defaultShareSDK] setFinished:finished];
    
    WBMessageObject *message = [WBMessageObject message];
    message.text = text;
    
    [WeiboSDK sendRequest:[self weiboRequestWithMessage:message scene:scene]];
}

+ (void)weiboShareImage:(NSData *)imageData
                  scene:(WeiboShareScene)scene
                finshed:(void(^)(WYShareResponse *response))finished {
    
    WY_IgnoredDeprecatedWarning(HasWeiboInstall);
    [[self defaultShareSDK] setFinished:finished];
    WBMessageObject *message = [WBMessageObject message];
    
    WBImageObject *imageObj = [WBImageObject object];
    imageObj.imageData = imageData;
    
    message.imageObject = imageObj;
    
    [WeiboSDK sendRequest:[self weiboRequestWithMessage:message scene:scene]];
}

+ (void)weiboShareWebURL:(NSString *)url
                   title:(NSString *)title
             description:(NSString *)description
              thumbImage:(NSData *)thumbImageData
                   scene:(WeiboShareScene)scene
                finished:(void(^)(WYShareResponse *response))finished {
    
    WY_IgnoredDeprecatedWarning(HasWeiboInstall);
    [[self defaultShareSDK] setFinished:finished];
    
    WBMessageObject *message = [WBMessageObject message];
    WBWebpageObject *webpage = [WBWebpageObject object];
    webpage.objectID = @"";
    webpage.title = title;
    webpage.description = description;
    webpage.thumbnailData = thumbImageData;
    webpage.webpageUrl = url;
    message.mediaObject = webpage;
    
    [WeiboSDK sendRequest:[self weiboRequestWithMessage:message scene:scene]];
}


+ (void)weiboShareMusicURL:(NSString *)url
                 streamURL:(NSString *)streamUrl
                     title:(NSString *)title
               description:(NSString *)description
             thumbnailData:(NSData *)thumbnailData
                  finished:(void(^)(WYShareResponse *response))finished {
    WY_IgnoredDeprecatedWarning(HasWeiboInstall);
    
    [[self defaultShareSDK] setFinished:finished];
    WBMessageObject *message = [WBMessageObject message];
    
    WBMusicObject *musicObject = [WBMusicObject object];
    musicObject.objectID = @"";
    musicObject.title = title;
    musicObject.description = description;
    musicObject.thumbnailData = thumbnailData;
    musicObject.musicUrl = url;
    musicObject.musicStreamUrl = streamUrl;
    
    message.mediaObject = musicObject;
    [WeiboSDK sendRequest:[WBSendMessageToWeiboRequest requestWithMessage:message]];
}

+ (void)weiboShareVideoURL:(NSString *)url
                 streamURL:(NSString *)streamUrl
                     title:(NSString *)title
               description:(NSString *)description
             thumbnailData:(NSData *)thumbnailData
                  finished:(void(^)(WYShareResponse *response))finished {
    WY_IgnoredDeprecatedWarning(HasWeiboInstall);
    
    [[self defaultShareSDK] setFinished:finished];
    WBMessageObject *message = [WBMessageObject message];
    
    WBVideoObject *videoObject = [WBVideoObject object];
    videoObject.objectID = @"";
    videoObject.title = title;
    videoObject.description = description;
    videoObject.thumbnailData = thumbnailData;
    videoObject.videoUrl = url;
    videoObject.videoStreamUrl = streamUrl;
    
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
    
    [[self defaultShareSDK] setWeiboLoginFinished:finished];
    
    WBAuthorizeRequest *request = [WBAuthorizeRequest request];
    request.redirectURI = kWeiboRedirectURI;
    request.scope = @"all";
    request.userInfo = @{@"SSO_From": @"minyanViewController",
                         @"action": @"loginBtnClick"};
    [WeiboSDK sendRequest:request];
}

@end
