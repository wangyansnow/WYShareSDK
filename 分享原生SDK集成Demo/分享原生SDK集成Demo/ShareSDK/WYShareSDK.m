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

static NSString *const kQQRedirectURI = @"www.qq.com";

@interface WYShareSDK ()<WXApiDelegate, QQApiInterfaceDelegate, WeiboSDKDelegate, TencentSessionDelegate>

@property (nonatomic, copy) void(^finished)(WYShareResponse *response);
@property (nonatomic, copy) void(^wxLoginFinished)(WYWXUserinfo *wxUserinfo, WYWXToken *wxToken, NSError *error);
@property (nonatomic, copy) void(^qqLoginFinished)(WYQQUserinfo *qqUserinfo, NSError *error);


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
    WYShareSDK *shareSDK = [self defaultShareSDK];
    shareSDK.wxAppId = wxAppId;
    shareSDK.wxAppSecret = wxAppSecret;
    
    // 1.注册微信
    [WXApi registerApp:wxAppId];
}
+ (void)registerQQApp:(NSString *)qqAppId {
    // 2.注册QQ
    WYShareSDK *shareSDK = [WYShareSDK defaultShareSDK];
    shareSDK.tencentOAuth = [[TencentOAuth alloc] initWithAppId:qqAppId andDelegate:self];
    shareSDK.tencentOAuth.redirectURI = kQQRedirectURI;    
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
    return [WXApi handleOpenURL:url delegate:self] || [WeiboSDK handleOpenURL:url delegate:self] || [QQApiInterface handleOpenURL:url delegate:self] || [TencentOAuth HandleOpenURL:url];
}

#pragma mark - QQApiInterfaceDelegate/WXApiDelegate
- (void)onResp:(id)resp {
    if ([resp isKindOfClass:[BaseResp class]]) { // 微信
        if ([resp isKindOfClass:[SendAuthResp class]] ) { // 微信登录
            [self wy_handleWXLoginResponse:resp];
            return;
        }
        
        BaseResp *wxresp = (BaseResp *)resp;
        if (_finished) {
            WYShareResponse *response = [WYShareResponse shareResponseWithSucess:(wxresp.errCode == 0) errorStr:wxresp.errStr];
            _finished(response);
        }
        
    } else if ([resp isKindOfClass:[QQBaseResp class]]) { // QQ分享
        QQBaseResp *qqresp = (QQBaseResp *)resp;
        if (_finished) {
            WYShareResponse *response = [WYShareResponse shareResponseWithSucess:([qqresp.result intValue] == 0) errorStr:qqresp.errorDescription];
            _finished(response);
        }
    }
}

#pragma mark - TencentSessionDelegate
- (void)tencentDidLogin {
    if (self.tencentOAuth.accessToken.length > 0) {
        NSString *accessToken = self.tencentOAuth.accessToken; // 3个月有效期
        NSString *openId = self.tencentOAuth.openId;
        NSDate *expirationDate =  self.tencentOAuth.expirationDate;
        NSLog(@"accessToken = %@", accessToken);
        NSLog(@"openId = %@", openId);
        NSLog(@"expirationDate = %@", expirationDate);
        
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        [userDefaults setObject:accessToken forKey:@"accessToken"];
        [userDefaults setObject:openId forKey:@"openId"];
        [userDefaults setObject:expirationDate forKey:@"expirationDate"];
        
        // 1.获取用户信息
        [self.tencentOAuth getUserInfo];
        
    } else {
        NSLog(@"登录不成功，没有获取到accessToken");
    }
}

- (void)tencentDidNotLogin:(BOOL)cancelled {
    if (cancelled) {
        NSLog(@"用户取消登录");
    } else {
        NSLog(@"登录失败");
    }
}

- (void)tencentDidNotNetWork {
    NSLog(@"无网络连接，请设置网络");
}

- (void)getUserInfoResponse:(APIResponse *)response {
    if (response.retCode == URLREQUEST_SUCCEED && response.detailRetCode == kOpenSDKErrorSuccess) {
        NSLog(@"获取用户信息成功");
        NSLog(@"userinfo = %@", response.jsonResponse);
    } else {
        NSLog(@"获取用户信息失败， errorMsg = %@", response.errorMsg);
        NSLog(@"jsonResponseError = %@", response.jsonResponse);
    }
}

#pragma mark - private
- (void)wy_handleWXLoginResponse:(SendAuthResp *)resp {
    if (resp.errCode != 0)  {
        NSError *error = [NSError errorWithDomain:@"微信客户端授权失败" code:resp.errCode userInfo:nil];
        BLOCK_EXEC(_wxLoginFinished, nil, nil, error);
        return;
    };
    
    NSString *urlStr = [NSString stringWithFormat:@"https://api.weixin.qq.com/sns/oauth2/access_token?appid=%@&secret=%@&code=%@&grant_type=authorization_code", self.wxAppId, self.wxAppSecret, resp.code];
    
    [[[NSURLSession sharedSession] dataTaskWithURL:[NSURL URLWithString:urlStr] completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        
        if (error || !data) {
            NSString *errorStr = [NSString stringWithFormat:@"获取Token失败，%@", error.domain];
            error = [NSError errorWithDomain:errorStr code:error.code userInfo:error.userInfo];
            BLOCK_EXEC(_wxLoginFinished, nil, nil, error);
            return;
        }
        
        NSError *jsonError;
        id obj = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:&jsonError];
        if (jsonError) {
            BLOCK_EXEC(_wxLoginFinished, nil, nil, error);
            return;
        }
        
        self.wxToken = [WYWXToken modelWithDict:obj];
        [self.wxToken saveModelWithKey:WYWXTokenKey];
        
        [WYWXUserinfo wy_fetchWXUserinfoWithAccessToken:self.wxToken.access_token openId:self.wxToken.openid finished:^(WYWXUserinfo *wxUserinfo, NSError *error) {
            if (error) {
                NSString *errorStr = [NSString stringWithFormat:@"获取用户详细信息失败,%@", error.domain];
                error = [NSError errorWithDomain:errorStr code:error.code userInfo:error.userInfo];
                BLOCK_EXEC(_wxLoginFinished, nil, self.wxToken, error);
                return;
            }

            BLOCK_EXEC(_wxLoginFinished, wxUserinfo, self.wxToken, nil);
        }];
    }] resume];
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
    
    HasWeiboInstall
    [[self defaultShareSDK] setFinished:finished];
    
    WBMessageObject *message = [WBMessageObject message];
    message.text = text;
    
    [WeiboSDK sendRequest:[self weiboRequestWithMessage:message scene:scene]];
}

+ (void)weiboShareImage:(NSData *)imageData
                  scene:(WeiboShareScene)scene
                finshed:(void(^)(WYShareResponse *response))finished {
    
    HasWeiboInstall
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
    
    HasWeiboInstall
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
    HasWeiboInstall
    
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
    HasWeiboInstall
    
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
    HasWXInstall
    
    [[self defaultShareSDK] setWxLoginFinished:finished];
    
    // 1.构造SendAuthReq结构体
    SendAuthReq *req = [SendAuthReq new];
    req.scope = @"snsapi_userinfo";
    req.state = @"123";
    
    // 2.应用向微信终端发送一个SendAuthReq消息结构
    [WXApi sendReq:req];
}

+ (void)wy_weChatRefreshAccessToken:(void(^)(WYWXToken *wxToken, NSError *error))finished {
    WYShareSDK *shareSDK = [WYShareSDK defaultShareSDK];
    NSString *refreshURL = [NSString stringWithFormat:@"https://api.weixin.qq.com/sns/oauth2/refresh_token?appid=%@&grant_type=refresh_token&refresh_token=%@", shareSDK.wxAppId, shareSDK.wxToken.refresh_token];
    
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
        
        shareSDK.wxToken = [WYWXToken modelWithDict:obj];
        BLOCK_EXEC(finished, shareSDK.wxToken, nil);
    }] resume];
}

+ (void)wy_QQLoginFinished:(void(^)(WYQQUserinfo *qqUserinfo, NSError *error))finished {
    NSArray *permissions = @[@"get_user_info", @"get_simple_userinfo", @"add_t"];
    WYShareSDK *shareSDK = [WYShareSDK defaultShareSDK];
    
    
    [shareSDK.tencentOAuth authorize:permissions inSafari:NO];
}

#pragma mark - getter
- (WYWXToken *)wxToken {
    if (!_wxToken) {
        _wxToken = [WYWXToken modelWithSaveKey:WYWXTokenKey];
    }
    return _wxToken;
}

@end
