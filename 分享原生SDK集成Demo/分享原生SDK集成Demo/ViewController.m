//
//  ViewController.m
//  分享原生SDK集成Demo
//
//  Created by 王俨 on 16/9/3.
//  Copyright © 2016年 wangyan. All rights reserved.
//

#import "ViewController.h"
#import "WXApi.h"
#import "WeiboSDK.h"
#import <TencentOpenAPI/QQApiInterface.h>
#import "WYShareDefine.h"
#import "WYShareSDK.h"


@interface ViewController ()

@end

@implementation ViewController {
    /**0是会话   1是朋友圈 */
    int _qqScene;
    int _wxScene;
    int _wbScene;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    NSLog(@"");
}

#pragma mark - 分享场景切换
- (IBAction)qqSceneBtnClick:(UISegmentedControl *)sender {
    _qqScene = (int)sender.selectedSegmentIndex;
}

- (IBAction)wxSceneBtnClick:(UISegmentedControl *)sender {
    _wxScene = (int)sender.selectedSegmentIndex;
}

- (IBAction)wbSceneBtnClick:(UISegmentedControl *)sender {
    _wbScene = (int)sender.selectedSegmentIndex;
}

#pragma mark - ShareMethods
#pragma mark - 手机QQ分享 [只有`新闻`(网页)和音乐可以分享到朋友圈]
- (IBAction)qqTextShare {
    HasQQInstall
    
    QQApiTextObject *textObj = [QQApiTextObject objectWithText:@"qq分享"];
    SendMessageToQQReq *textReq = [SendMessageToQQReq reqWithContent:textObj];
    [QQApiInterface sendReq:textReq];
}

- (IBAction)qqImageShare {
    HasQQInstall
    
    //开发者分享图片数据
    NSData *imgData = UIImagePNGRepresentation([UIImage imageNamed:@"LaunchImage_iOS_40_confident"]);
    QQApiImageObject *imgObj = [QQApiImageObject objectWithData:imgData
                                               previewImageData:imgData
                                                          title:@"title"
                                                   description :@"description"];
    SendMessageToQQReq *req = [SendMessageToQQReq reqWithContent:imgObj];
    //将内容分享到qq
    [QQApiInterface sendReq:req];
}

- (IBAction)qqWebShare {
    HasQQInstall
    
    NSString *url = @"https://www.wanglibao.com/";
    UIImage *previewImage = [UIImage imageNamed:@"ic_account_tyj"];
    NSData *previewData = UIImagePNGRepresentation(previewImage);
    
    QQApiNewsObject *newsObject = [QQApiNewsObject objectWithURL:[NSURL URLWithString:url] title:@"qq news share" description:@"news short description" previewImageData:previewData targetContentType:QQApiURLTargetTypeNews];
    
    SendMessageToQQReq *newsReq = [SendMessageToQQReq reqWithContent:newsObject];
    [self qqSendRequest:newsReq];
}

- (IBAction)qqMusicShare {
    HasQQInstall
    
    // 1.分享跳转URL
    NSString *url = @"https://www.wanglibao.com/";
    // 2.分享预览图URL地址 / 也可以是NSData
    NSString *previewImageUrl = @"http://mvimg1.meitudata.com/55ba2780b95628196.jpg";
    // 3.音乐播放的网络流媒体地址
    NSString *flashURL = kMusicURL;
    
    QQApiAudioObject *audioObject = [QQApiAudioObject objectWithURL:[NSURL URLWithString:url] title:@"title" description:@"description" previewImageURL:[NSURL URLWithString:previewImageUrl]];
    // 4.设置播放流媒体地址
    [audioObject setFlashURL:[NSURL URLWithString:flashURL]];
    
    SendMessageToQQReq *req = [SendMessageToQQReq reqWithContent:audioObject];
    [self qqSendRequest:req];
}

- (void)qqSendRequest:(QQBaseReq *)req {
    if (_qqScene == 0) { // 会话
        [QQApiInterface sendReq:req];
        return;
    }
    // 朋友圈
    [QQApiInterface SendReqToQZone:req];
}

#pragma mark - 微信分享 [文字不可以分享到朋友圈]
- (IBAction)weChatTextShare {
    HasWXInstall
    
    SendMessageToWXReq *textReq = [[SendMessageToWXReq alloc] init];
    
    textReq.bText = YES;
    textReq.text = @"王俨 send to wechat";
    textReq.scene = WXSceneSession;
    
    [WXApi sendReq:textReq];
}

- (IBAction)weChatImageShare {
    HasWXInstall
    
    WXMediaMessage *message = [WXMediaMessage message];
    [message setThumbImage:[UIImage imageNamed:@"ic_account_tyj"]];
    
    WXImageObject *imageObject = [WXImageObject object];
    NSString *path = [[NSBundle mainBundle] pathForResource:@"LaunchImage_iOS_40_confident.png" ofType:nil];
    imageObject.imageData = [NSData dataWithContentsOfFile:path];
    
    message.mediaObject = imageObject;
    
    SendMessageToWXReq *imageReq = [[SendMessageToWXReq alloc] init];
    imageReq.bText = NO;
    imageReq.message = message;
    imageReq.scene = _wxScene;
    [WXApi sendReq:imageReq];
}

- (IBAction)weChatWebShare {
    HasWXInstall
    
    WXMediaMessage *message = [WXMediaMessage message];
    message.title = @"标题";
    message.description = @"描述";
    [message setThumbImage:[UIImage imageNamed:@"ic_account_tyj"]];
    
    WXWebpageObject *webpageObject = [WXWebpageObject object];
    webpageObject.webpageUrl = @"https://www.wanglibao.com/";
    message.mediaObject = webpageObject;
    
    SendMessageToWXReq *webReq = [[SendMessageToWXReq alloc] init];
    webReq.bText = NO;
    webReq.message = message;
    webReq.scene = _wxScene;
    [WXApi sendReq:webReq];
}

- (IBAction)weChatMusicShare {
    HasWXInstall
    
    WXMediaMessage *message = [WXMediaMessage message];
    message.title = @"音乐title";
    message.description = @"音乐description";
    [message setThumbImage:[UIImage imageNamed:@"ic_account_tyj"]];
    
    WXMusicObject *musicObj = [WXMusicObject object];
    musicObj.musicUrl = kWechatMusicURL;  // 音乐网页url
    musicObj.musicDataUrl = @"http://stream20.qqmusic.qq.com/32464723.mp3";  // 音乐数据url
    message.mediaObject = musicObj;
    
    SendMessageToWXReq *req = [[SendMessageToWXReq alloc] init];
    req.bText = NO;
    req.message = message;
    req.scene = _wxScene;
    
    [WXApi sendReq:req];
}

- (IBAction)weChatVideoShare {
    HasWXInstall
    
    WXMediaMessage *message = [WXMediaMessage message];
    message.title = @"视频 title";
    message.description = @"视频 description";
    [message setThumbImage:[UIImage imageNamed:@"ic_account_tyj"]];
    
    WXVideoObject *videoObj = [WXVideoObject object];
    videoObj.videoUrl = @"http://v.youku.com/v_show/id_XNTUxNDY1NDY4.html";
    message.mediaObject = videoObj;
    
    SendMessageToWXReq *req = [[SendMessageToWXReq alloc] init];
    req.bText = NO;
    req.message = message;
    req.scene = _wxScene;
    
    [WXApi sendReq:req];
}

#pragma mark - 微博分享
- (IBAction)weiboTextShare {
    HasWeiboInstall
    
    WBMessageObject *message = [WBMessageObject message];
    message.text = @"王的俨的分享的的的";
    
    [WeiboSDK sendRequest:[self weiboRequestWithMessage:message]];
}

- (IBAction)weiboImageShare {
    HasWeiboInstall
    
    WBMessageObject *message = [WBMessageObject message];
    
    WBImageObject *imageObj = [WBImageObject object];
    UIImage *previewImage = [UIImage imageNamed:@"ic_account_tyj"];
    imageObj.imageData = UIImagePNGRepresentation(previewImage);
    
    message.imageObject = imageObj;
    
    [WeiboSDK sendRequest:[self weiboRequestWithMessage:message]];
}

- (IBAction)weiboWebShare {
    HasWeiboInstall
    
    WBMessageObject *message = [WBMessageObject message];
    WBWebpageObject *webpage = [WBWebpageObject object];
    webpage.objectID = @"";
    webpage.title = @"网利宝--全民淘金";
    webpage.description = @"微博分享内容--网利宝";
    UIImage *previewImage = [UIImage imageNamed:@"ic_account_tyj"];
    webpage.thumbnailData = UIImagePNGRepresentation(previewImage);
    webpage.webpageUrl = @"https://www.wanglibao.com";
    message.mediaObject = webpage;
    
    [WeiboSDK sendRequest:[self weiboRequestWithMessage:message]];
}

/// 只支持朋友圈内分享
- (IBAction)weiboMusicShare {
    HasWeiboInstall
    
    WBMessageObject *message = [WBMessageObject message];
    
    WBMusicObject *musicObject = [WBMusicObject object];
    musicObject.objectID = @"";
    musicObject.title = @"微博音乐分享";
    musicObject.description = @"王俨分享的音乐到微博的详细描述description";
    musicObject.thumbnailData = UIImagePNGRepresentation([UIImage imageNamed:@"ic_account_tyj"]);
    musicObject.musicUrl = @"http://stream20.qqmusic.qq.com/32464723.mp3";
    musicObject.musicStreamUrl = @"http://stream20.qqmusic.qq.com/32464723.mp3";
    
    message.mediaObject = musicObject;
    [WeiboSDK sendRequest:[WBSendMessageToWeiboRequest requestWithMessage:message]];
}

/// 只支持朋友圈内分享
- (IBAction)weiboVideoShare {
    HasWeiboInstall
    
    WBMessageObject *message = [WBMessageObject message];
    
    WBVideoObject *videoObject = [WBVideoObject object];
    videoObject.objectID = @"";
    videoObject.title = @"视频分享";
    videoObject.description = @"这个视频很好看";
    videoObject.thumbnailData = UIImagePNGRepresentation([UIImage imageNamed:@"ic_account_tyj"]);
    videoObject.videoUrl = @"http://v.youku.com/v_show/id_XNTUxNDY1NDY4.html";
    videoObject.videoStreamUrl = videoObject.videoUrl;
    
    message.mediaObject = videoObject;
    [WeiboSDK sendRequest:[WBSendMessageToWeiboRequest requestWithMessage:message]];
}

- (WBBaseRequest *)weiboRequestWithMessage:(WBMessageObject *)message {
    if (_wbScene == 0) { // 会话
        return [WBShareMessageToContactRequest requestWithMessage:message];
    }
    // 朋友圈
    return [WBSendMessageToWeiboRequest requestWithMessage:message];
}

- (IBAction)shareSDKBtnClick {
    [WYShareSDK weChatShareText:@"分享一个" finished:^(WYShareResponse *response) {
        if (response.isSucess) {
            NSLog(@"分享成功");
            return;
        }
        NSLog(@"分享失败 error = %@", response.errorStr);
    }];
}

#pragma mark - 三方登录
- (IBAction)wxLoginBtnClick {
    [WYShareSDK wy_weChatLoginFinished:^(WYWXUserinfo *wxUserinfo, WYWXToken *wxToken, NSError *error) {
        if (error) {
            NSLog(@"error = %@", error);
            return;
        }
        
        NSLog(@"wxToken = %@", wxToken);
        NSLog(@"wxUserinfo = %@", wxUserinfo);
    }];
}

- (IBAction)qqLoginBtnClick {
    
}

- (IBAction)refreshWxTokenBtnClick {
    [WYShareSDK wy_weChatRefreshAccessToken:^(WYWXToken *wxToken, NSError *error) {
        NSLog(@"error = %@", error);
        NSLog(@"wxToken = %@", wxToken);
    }];
}





@end
