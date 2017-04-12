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
#import "WYParamObj.h"

#import "WYWXSDK.h"

static NSString *const kWYWXSDK = @"WYWXSDK"; ///< 微信分享类名

static NSString *const kQQRedirectURI = @"www.qq.com";
static NSString *const kWeiboRedirectURI = @"http://www.sina.com";

@interface WYShareSDK ()<WXApiDelegate, QQApiInterfaceDelegate, WeiboSDKDelegate, TencentSessionDelegate>

@property (nonatomic, copy) void(^finished)(WYShareResponse *response);
@property (nonatomic, copy) void(^wxLoginFinished)(WYWXUserinfo *wxUserinfo, WYWXToken *wxToken, NSError *error);
@property (nonatomic, copy) void(^qqLoginFinished)(WYQQUserinfo *qqUserinfo, WYQQToken *qqToken, NSError *error);
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
    
    [self target:kWYWXSDK selector:@selector(wy_registerWeChatApp:) params:paramObj];
}

+ (id)target:(NSString *)className selector:(SEL)selector params:(WYParamObj *)paramObj {
    Class cls = NSClassFromString(className);
    if (!cls) {
        NSAssert(NO, ([NSString stringWithFormat:@"%@转化成类失败", className]));
        return nil;
    }
    
    if (![cls respondsToSelector:selector]) {
        NSAssert(NO, ([NSString stringWithFormat:@"%@ 方法不存在", NSStringFromSelector(selector)]));
        return nil;
    }

    WY_IgnoredPerformSelectorLeakWarnings(return [cls performSelector:selector withObject:paramObj];);
}

+ (void)registerQQApp:(NSString *)qqAppId {
    // 2.注册QQ
    WYShareSDK *shareSDK = [self defaultShareSDK];
    TencentOAuth *tencentOAuth = [[TencentOAuth alloc] initWithAppId:qqAppId andDelegate:shareSDK];
    tencentOAuth.redirectURI = kQQRedirectURI;
    shareSDK.tencentOAuth = tencentOAuth;
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
    
    WYParamObj *paramObj = [WYParamObj new];
    paramObj.param1 = url;
    SEL selector = @selector(wy_handleOpenURL:);
    
    return [[WYShareSDK target:kWYWXSDK selector:selector params:paramObj] boolValue] || [WeiboSDK handleOpenURL:url delegate:self]  || [TencentOAuth HandleOpenURL:url] || [QQApiInterface handleOpenURL:url delegate:self];
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
            BLOCK_EXECRELEASE(_finished, response);
        }
        
    } else if ([resp isKindOfClass:[QQBaseResp class]]) { // QQ分享
        QQBaseResp *qqresp = (QQBaseResp *)resp;
        if (_finished) {
            WYShareResponse *response = [WYShareResponse shareResponseWithSucess:([qqresp.result intValue] == 0) errorStr:qqresp.errorDescription];
            BLOCK_EXECRELEASE(_finished, response);
        }
    }
}

#pragma mark - TencentSessionDelegate
- (void)tencentDidLogin {
    if (self.tencentOAuth.accessToken.length > 0) {
        // 1.获取用户信息
        [self.tencentOAuth getUserInfo];
        
    } else {
        NSError *error = [NSError errorWithDomain:@"登录QQ失败" code:100 userInfo:nil];
        BLOCK_EXECRELEASE(self.qqLoginFinished, nil, nil, error);
    }
}

- (void)tencentDidNotLogin:(BOOL)cancelled {
    
    NSString *errorDomain = cancelled ? @"用户取消登录" : @"登录QQ失败";
    NSError *error = [NSError errorWithDomain:errorDomain code:100 userInfo:nil];
    BLOCK_EXECRELEASE(self.qqLoginFinished, nil, nil, error);
}

- (void)tencentDidNotNetWork {
    
    NSError *error = [NSError errorWithDomain:@"无网络连接，请设置网络" code:100 userInfo:nil];
    BLOCK_EXECRELEASE(self.qqLoginFinished, nil, nil, error);
}

- (void)getUserInfoResponse:(APIResponse *)response {
    
    WYQQToken *qqToken = [WYQQToken new];
    qqToken.openId = self.tencentOAuth.openId;
    qqToken.expirationDate = self.tencentOAuth.expirationDate;
    qqToken.accessToken = self.tencentOAuth.accessToken;
    
    if (response.retCode == URLREQUEST_SUCCEED && response.detailRetCode == kOpenSDKErrorSuccess) {

        WYQQUserinfo *qqUserinfo = [WYQQUserinfo modelWithDict:response.jsonResponse];
        BLOCK_EXECRELEASE(self.qqLoginFinished, qqUserinfo, qqToken, nil);
        
    } else {
        NSString *errorStr = [NSString stringWithFormat:@"登录授权成功，获取用户信息失败 ==> %@", response.errorMsg];
        NSError *error = [NSError errorWithDomain:errorStr code:200 userInfo:nil];
        BLOCK_EXECRELEASE(self.qqLoginFinished, nil, qqToken, error);
    }
}

#pragma mark - private
- (void)wy_handleWXLoginResponse:(SendAuthResp *)resp {
    if (resp.errCode != 0)  {
        NSError *error = [NSError errorWithDomain:@"微信客户端授权失败" code:resp.errCode userInfo:nil];
        BLOCK_EXECRELEASE(_wxLoginFinished, nil, nil, error);
        return;
    };
    
    NSString *urlStr = [NSString stringWithFormat:@"https://api.weixin.qq.com/sns/oauth2/access_token?appid=%@&secret=%@&code=%@&grant_type=authorization_code", self.wxAppId, self.wxAppSecret, resp.code];
    
    [[[NSURLSession sharedSession] dataTaskWithURL:[NSURL URLWithString:urlStr] completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        
        if (error || !data) {
            NSString *errorStr = [NSString stringWithFormat:@"获取Token失败，%@", error.domain];
            error = [NSError errorWithDomain:errorStr code:error.code userInfo:error.userInfo];
            BLOCK_EXECRELEASE(_wxLoginFinished, nil, nil, error);
            return;
        }
        
        NSError *jsonError;
        id obj = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:&jsonError];
        if (jsonError) {
            BLOCK_EXECRELEASE(_wxLoginFinished, nil, nil, error);
            return;
        }
        
        self.wxToken = [WYWXToken modelWithDict:obj];
        [self.wxToken saveModelWithKey:WYWXTokenKey];
        
        [WYWXUserinfo wy_fetchWXUserinfoWithAccessToken:self.wxToken.access_token openId:self.wxToken.openid finished:^(WYWXUserinfo *wxUserinfo, NSError *error) {
            if (error) {
                NSString *errorStr = [NSString stringWithFormat:@"获取用户详细信息失败,%@", error.domain];
                error = [NSError errorWithDomain:errorStr code:error.code userInfo:error.userInfo];
                BLOCK_EXECRELEASE(_wxLoginFinished, nil, self.wxToken, error);
                return;
            }

            BLOCK_EXECRELEASE(_wxLoginFinished, wxUserinfo, self.wxToken, nil);
        }];
    }] resume];
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
    [self target:kWYWXSDK selector:@selector(wy_weChatShareText:) params:paramObj];
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
    [self target:kWYWXSDK selector:@selector(wy_weChatShareImage:) params:paramObj];
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
    [self target:kWYWXSDK selector:@selector(wy_weChatShareImage:) params:paramObj];
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
    [self target:kWYWXSDK selector:@selector(wy_weChatShareImage:) params:paramObj];
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
    [self target:kWYWXSDK selector:@selector(wy_weChatShareImage:) params:paramObj];
}

#pragma mark - 手机QQ分享
+ (void)qqShareText:(NSString *)text
            finshed:(void(^)(WYShareResponse *response))finished {
    WY_IgnoredDeprecatedWarnings(HasQQInstall);
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
    WY_IgnoredDeprecatedWarnings(HasQQInstall);
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
    WY_IgnoredDeprecatedWarnings(HasQQInstall);
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
    WY_IgnoredDeprecatedWarnings(HasQQInstall);
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
    WY_IgnoredDeprecatedWarnings(HasWeiboInstall);
    [[self defaultShareSDK] setFinished:finished];
    
    WBMessageObject *message = [WBMessageObject message];
    message.text = text;
    
    [WeiboSDK sendRequest:[self weiboRequestWithMessage:message scene:scene]];
}

+ (void)weiboShareImage:(NSData *)imageData
                  scene:(WeiboShareScene)scene
                finshed:(void(^)(WYShareResponse *response))finished {
    
    WY_IgnoredDeprecatedWarnings(HasWeiboInstall);
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
    
    WY_IgnoredDeprecatedWarnings(HasWeiboInstall);
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
    WY_IgnoredDeprecatedWarnings(HasWeiboInstall);
    
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
    WY_IgnoredDeprecatedWarnings(HasWeiboInstall);
    
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
    WY_IgnoredDeprecatedWarnings(HasWXInstall);
    
    [WYWXSDK wy_weChatLoginFinished:finished];
}

+ (void)wy_weChatRefreshAccessToken:(void(^)(WYWXToken *wxToken, NSError *error))finished {
    WYShareSDK *shareSDK = [self defaultShareSDK];
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

+ (void)wy_QQLoginFinished:(void(^)(WYQQUserinfo *qqUserinfo, WYQQToken *qqToken, NSError *error))finished {
    NSArray *permissions = @[@"get_user_info", @"get_simple_userinfo", @"add_t"];
    WYShareSDK *shareSDK = [self defaultShareSDK];
    shareSDK.qqLoginFinished = finished;
    
    [shareSDK.tencentOAuth authorize:permissions inSafari:NO];
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

#pragma mark - getter
- (WYWXToken *)wxToken {
    if (!_wxToken) {
        _wxToken = [WYWXToken modelWithSaveKey:WYWXTokenKey];
    }
    return _wxToken;
}

@end
