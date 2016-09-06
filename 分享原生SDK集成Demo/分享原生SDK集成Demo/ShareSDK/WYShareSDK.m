//
//  WYShareSDK.m
//  分享原生SDK集成Demo
//
//  Created by 王俨 on 16/9/4.
//  Copyright © 2016年 wangyan. All rights reserved.
//

#import "WYShareSDK.h"
#import "WXApi.h"
#import <TencentOpenAPI/QQApiInterface.h>
#import <TencentOpenAPI/TencentOAuth.h>
#import "WeiboSDK.h"
#import "WYShareDefine.h"

#define WXAppId    @"wx7074076f395c69d9"
#define QQAppId    @"1103515189"
#define WBAppId    @"2273722657"
#define kUMENG_WXAppSecret   @"2db8c8e74a1cec2edfde87711bf3eff7"
#define kUMENG_QQAppKey      @"ZkGVW2gmcpF3ls7E"

////////////////////////////////////////  WYShareResponse  /////////////////////////////////////////////
@implementation WYShareResponse

+ (instancetype)shareResponseWithSucess:(BOOL)success errorStr:(NSString *)errorStr {
    WYShareResponse *response = [[WYShareResponse alloc] init];
    response->_success = success;
    response->_errorStr = errorStr;
    return response;
}

@end

////////////////////////////////////////  WYShareSDK   ////////////////////////////////////////////
@interface WYShareSDK ()<WXApiDelegate, QQApiInterfaceDelegate, WeiboSDKDelegate>

@property (nonatomic, copy) void(^finished)(WYShareResponse *response);

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

+ (void)initialShareSDK {
    // 1.注册微信
    [WXApi registerApp:WXAppId];
    
    // 2.注册QQ
    TencentOAuth *auth = [[TencentOAuth alloc] initWithAppId:QQAppId andDelegate:nil];
    NSLog(@"auth = %@", auth);
    
    // 3.注册Weibo
    [WeiboSDK enableDebugMode:YES];
    [WeiboSDK registerApp:WBAppId];
}

+ (BOOL)handleOpenURL:(NSURL *)url {
    return [[self defaultShareSDK] handleOpenURL:url];
}

- (BOOL)handleOpenURL:(NSURL *)url {
    return [WXApi handleOpenURL:url delegate:self] || [WeiboSDK handleOpenURL:url delegate:self] || [QQApiInterface handleOpenURL:url delegate:self];
}

#pragma mark - QQApiInterfaceDelegate/WXApiDelegate
- (void)onResp:(id)resp {
    if ([resp isKindOfClass:[BaseResp class]]) { // 微信分享
        BaseResp *wxresp = (BaseResp *)resp;
        if (_finished) {
            WYShareResponse *response = [WYShareResponse shareResponseWithSucess:(wxresp.errCode == 0) errorStr:wxresp.errStr];
            _finished(response);
        }
        
    } else if ([resp isKindOfClass:[QQBaseResp class]]) { // QQ分享
        QQBaseResp *qqresp = (QQBaseResp *)resp;
        if (_finished) {
            WYShareResponse *response = [WYShareResponse shareResponseWithSucess:(qqresp.type == 0) errorStr:qqresp.errorDescription];
            _finished(response);
        }
    }
}

#pragma mark - WeiboSDKDelegate
- (void)didReceiveWeiboResponse:(WBBaseResponse *)response {
    long code = response.statusCode;
    NSLog(@"微博分享 statusCode = %zd, userInfo = %@", code, response.requestUserInfo);
    if (_finished) {
        WYShareResponse *res = [WYShareResponse shareResponseWithSucess:(response.statusCode == 0) errorStr:@"微博分享错误"];
        _finished(res);
    }
}

#pragma mark - ShareMethods
#pragma mark - 微信分享
+ (void)weChatShareText:(NSString *)text
               finished:(void(^)(WYShareResponse *response))finished {
    HasWXInstall
    [[self defaultShareSDK] setFinished:finished];
    SendMessageToWXReq *textReq = [[SendMessageToWXReq alloc] init];
    
    textReq.bText = YES;
    textReq.text = text;
    textReq.scene = WXSceneSession;
    
    [WXApi sendReq:textReq];
}

+ (void)weChatShareThumbImage:(UIImage *)thumbImage
                originalImage:(NSData *)originalImageData
                        scene:(WXShareScene)scene
                     finished:(void(^)(WYShareResponse *response))finished {
    HasWXInstall
    [[self defaultShareSDK] setFinished:finished];
    WXMediaMessage *message = [WXMediaMessage message];
    [message setThumbImage:thumbImage];
    
    WXImageObject *imageObject = [WXImageObject object];
    imageObject.imageData = originalImageData;
    
    message.mediaObject = imageObject;
    
    SendMessageToWXReq *imageReq = [[SendMessageToWXReq alloc] init];
    imageReq.bText = NO;
    imageReq.message = message;
    imageReq.scene = scene;
    [WXApi sendReq:imageReq];
}

+ (void)weChatShareWebURL:(NSString *)url
              description:(NSString *)description
               thumbImage:(UIImage *)thumbImage
                    title:(NSString *)title
                    scene:(WXShareScene)scene
                 finished:(void(^)(WYShareResponse *response))finished {
    HasWXInstall
    [[self defaultShareSDK] setFinished:finished];
    WXMediaMessage *message = [WXMediaMessage message];
    message.title = title;
    message.description = description;
    [message setThumbImage:thumbImage];
    
    WXWebpageObject *webpageObject = [WXWebpageObject object];
    webpageObject.webpageUrl = url;
    message.mediaObject = webpageObject;
    
    SendMessageToWXReq *webReq = [[SendMessageToWXReq alloc] init];
    webReq.bText = NO;
    webReq.message = message;
    webReq.scene = scene;
    [WXApi sendReq:webReq];
}

+ (void)weChatShareMusicURL:(NSString *)musicUrl
               musicDataURL:(NSString *)musicDataUrl
                 thumbImage:(UIImage *)thumbImage
                      title:(NSString *)title
                description:(NSString *)description
                      scene:(WXShareScene)scene
                   finished:(void(^)(WYShareResponse *response))finished {
    HasWXInstall
    [[self defaultShareSDK] setFinished:finished];
    
    WXMediaMessage *message = [WXMediaMessage message];
    message.title = title;
    message.description = description;
    [message setThumbImage:thumbImage];
    
    WXMusicObject *musicObj = [WXMusicObject object];
    musicObj.musicUrl = musicUrl;  // 音乐url
    musicObj.musicDataUrl = musicDataUrl;  // 音乐数据url
    message.mediaObject = musicObj;
    
    SendMessageToWXReq *req = [[SendMessageToWXReq alloc] init];
    req.bText = NO;
    req.message = message;
    req.scene = scene;
    
    [WXApi sendReq:req];
    
}

+ (void)weChatShareVideoURL:(NSString *)videoUrl
                 thumbImage:(UIImage *)thumbImage
                      title:(NSString *)title
                description:(NSString *)description
                      scene:(WXShareScene)scene
                   finished:(void(^)(WYShareResponse *response))finished {
    HasWXInstall
    [[self defaultShareSDK] setFinished:finished];
    
    WXMediaMessage *message = [WXMediaMessage message];
    message.title = title;
    message.description = description;
    [message setThumbImage:thumbImage];
    
    WXVideoObject *videoObj = [WXVideoObject object];
    videoObj.videoUrl = videoUrl;
    message.mediaObject = videoObj;
    
    SendMessageToWXReq *req = [[SendMessageToWXReq alloc] init];
    req.bText = NO;
    req.message = message;
    req.scene = scene;
    
    [WXApi sendReq:req];
}

#pragma mark - 手机QQ分享
+ (void)qqShareText:(NSString *)text
            finshed:(void(^)(WYShareResponse *response))finished {
    HasQQInstall
    [[self defaultShareSDK] setFinished:finished];
    QQApiTextObject *textObj = [QQApiTextObject objectWithText:text];
    SendMessageToQQReq *textReq = [SendMessageToQQReq reqWithContent:textObj];
    
    [QQApiInterface sendReq:textReq];
}

+ (void)qqShareImage:(NSData *)previewImageData
       originalImage:(NSData *)originalImageData
               title:(NSString *)title
         description:(NSString *)description
            finished:(void(^)(WYShareResponse *response))finished {
    HasQQInstall
    [[self defaultShareSDK] setFinished:finished];
    QQApiImageObject *imgObj = [QQApiImageObject objectWithData:previewImageData
                                               previewImageData:originalImageData
                                                          title:title
                                                   description :description];
    SendMessageToQQReq *req = [SendMessageToQQReq reqWithContent:imgObj];
    
    [QQApiInterface sendReq:req];
}

+ (void)qqShareWebURL:(NSString *)url
          description:(NSString *)description
           thumbImage:(NSData *)thumbImageData
                title:(NSString *)title
                scene:(QQShareScene)scene
             finished:(void(^)(WYShareResponse *response))finished {
    HasQQInstall
    [[self defaultShareSDK] setFinished:finished];
    
    QQApiNewsObject *newsObject = [QQApiNewsObject objectWithURL:[NSURL URLWithString:url] title:title description:description previewImageData:thumbImageData targetContentType:QQApiURLTargetTypeNews];
    
    SendMessageToQQReq *newsReq = [SendMessageToQQReq reqWithContent:newsObject];

    [self qqSendRequest:newsReq scene:scene];
}

+ (void)qqShareMusicURL:(NSString *)flashUrl  // 音乐播放的网络流媒体地址
                jumpURL:(NSString *)jumpUrl
        previewImageURL:(NSString *)previewImageUrl
       previewImageData:(NSData *)previewImageData
                  title:(NSString *)title
            description:(NSString *)description
                  scene:(QQShareScene)scene
               finished:(void(^)(WYShareResponse *response))finished {
    HasQQInstall
    [[self defaultShareSDK] setFinished:finished];
    
    QQApiAudioObject *audioObject;
    if (previewImageUrl) {
        // 2.分享预览图URL地址 / 也可以是NSData
        audioObject = [QQApiAudioObject objectWithURL:[NSURL URLWithString:jumpUrl] title:title description:description previewImageURL:[NSURL URLWithString:previewImageUrl]];
    } else if (previewImageData) {
        audioObject = [QQApiAudioObject objectWithURL:[NSURL URLWithString:jumpUrl] title:title description:description previewImageData:previewImageData];
    }
    
    // 4.设置播放流媒体地址
    [audioObject setFlashURL:[NSURL URLWithString:flashUrl]];
    
    SendMessageToQQReq *req = [SendMessageToQQReq reqWithContent:audioObject];
    [self qqSendRequest:req scene:scene];
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
    
    [[self defaultShareSDK] setFinished:finished];
    
    WBMessageObject *message = [WBMessageObject message];
    message.text = text;
    
    [WeiboSDK sendRequest:[self weiboRequestWithMessage:message scene:scene]];
}

+ (void)weiboShareImage:(NSData *)imageData
                  scene:(WeiboShareScene)scene
                finshed:(void(^)(WYShareResponse *response))finished {
    
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

+ (WBBaseRequest *)weiboRequestWithMessage:(WBMessageObject *)message scene:(WeiboShareScene) scene {
    if (scene == WeiboShareSceneSession) { // 会话
        return [WBShareMessageToContactRequest requestWithMessage:message];
    }
    // 朋友圈
    return [WBSendMessageToWeiboRequest requestWithMessage:message];
}

@end
