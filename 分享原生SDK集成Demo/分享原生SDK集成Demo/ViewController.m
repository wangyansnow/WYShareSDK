//
//  ViewController.m
//  分享原生SDK集成Demo
//
//  Created by 王俨 on 16/9/3.
//  Copyright © 2016年 wangyan. All rights reserved.
//

#import "ViewController.h"
#import "WYShareSDK.h"
#import "WYShareDefine.h"

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

#define WYShareFinished(response) \
    if (response.isSucess) { \
        NSLog(@"分享成功"); \
        return; \
    } \
    NSLog(@"分享失败 error = %@", response.errorStr);

#pragma mark - ShareMethods
#pragma mark - 手机QQ分享 [只有`新闻`(网页)和音乐可以分享到朋友圈]
- (IBAction)qqTextShare {
    [WYShareSDK wy_qqShareText:@"qq分享" finshed:^(WYShareResponse *response) {
        WYShareFinished(response);
    }];
}

- (IBAction)qqImageShare {
    //开发者分享图片数据
    NSData *imgData = UIImagePNGRepresentation([UIImage imageNamed:@"LaunchImage_iOS_40_confident"]);
    [WYShareSDK wy_qqShareImage:imgData originalImage:imgData title:@"title" description:@"description" finished:^(WYShareResponse *response) {
        WYShareFinished(response);
    }];
}

- (IBAction)qqWebShare {
    NSString *url = @"https://www.wanglibao.com/";
    UIImage *previewImage = [UIImage imageNamed:@"ic_account_tyj"];
    NSData *previewData = UIImagePNGRepresentation(previewImage);
    
    [WYShareSDK wy_qqShareWebURL:url description:@"news short description" thumbImage:previewImage title:@"qq news share" scene:_qqScene finished:^(WYShareResponse *response) {
        WYShareFinished(response);
    }];
}

- (IBAction)qqMusicShare {
    // 1.分享跳转URL
    NSString *url = @"https://www.wanglibao.com/";
    // 2.分享预览图URL地址 / 也可以是NSData
    NSString *previewImageUrl = @"http://mvimg1.meitudata.com/55ba2780b95628196.jpg";
    // 3.音乐播放的网络流媒体地址
    NSString *flashURL = kMusicURL;
    
    [WYShareSDK wy_qqShareMusicURL:flashURL jumpURL:url previewImageURL:previewImageUrl previewImageData:nil title:@"title" description:@"description" scene:_qqScene finished:^(WYShareResponse *response) {
        WYShareFinished(response);
    }];
}

#pragma mark - 微信分享 [文字不可以分享到朋友圈]
- (IBAction)weChatTextShare {
    [WYShareSDK wy_weChatShareText:@"王俨 send to wechat" finished:^(WYShareResponse *response) {
        WYShareFinished(response);
    }];
}

- (IBAction)weChatImageShare {
    NSString *path = [[NSBundle mainBundle] pathForResource:@"LaunchImage_iOS_40_confident.png" ofType:nil];
    
    [WYShareSDK wy_weChatShareThumbImage:[UIImage imageNamed:@"ic_account_tyj"] originalImage:[NSData dataWithContentsOfFile:path] scene:_wxScene finished:^(WYShareResponse *response) {
        WYShareFinished(response);
    }];
}

- (IBAction)weChatWebShare {
    [WYShareSDK wy_weChatShareWebURL:@"https://www.wanglibao.com/" description:@"description" thumbImage:[UIImage imageNamed:@"ic_account_tyj"] title:@"title" scene:_wxScene finished:^(WYShareResponse *response) {
        WYShareFinished(response);
    }];
}

- (IBAction)weChatMusicShare {
    [WYShareSDK wy_weChatShareMusicURL:kWechatMusicURL musicDataURL:@"http://stream20.qqmusic.qq.com/32464723.mp3" thumbImage:[UIImage imageNamed:@"ic_account_tyj"] title:@"音乐title" description:@"音乐description" scene:_wxScene finished:^(WYShareResponse *response) {
        WYShareFinished(response);
    }];
}

- (IBAction)weChatVideoShare {
    [WYShareSDK wy_weChatShareVideoURL:@"http://v.youku.com/v_show/id_XNTUxNDY1NDY4.html" thumbImage:[UIImage imageNamed:@"ic_account_tyj"] title:@"视频 title" description:@"视频 description" scene:_wxScene finished:^(WYShareResponse *response) {
        WYShareFinished(response);
    }];
}

#pragma mark - 微博分享
- (IBAction)weiboTextShare {
    [WYShareSDK wy_weiboShareText:@"王的俨的分享的的的" scene:_wbScene finished:^(WYShareResponse *response) {
        WYShareFinished(response);
    }];
}

- (IBAction)weiboImageShare {
    UIImage *previewImage = [UIImage imageNamed:@"ic_account_tyj"];
    [WYShareSDK wy_weiboShareImage:UIImagePNGRepresentation(previewImage) scene:_wbScene finshed:^(WYShareResponse *response) {
        WYShareFinished(response);
    }];
}

- (IBAction)weiboWebShare {
    UIImage *previewImage = [UIImage imageNamed:@"ic_account_tyj"];
    [WYShareSDK wy_weiboShareWebURL:@"https://www.wanglibao.com" title:@"title" description:@"description" thumbImage:UIImagePNGRepresentation(previewImage) scene:_wbScene finished:^(WYShareResponse *response) {
        WYShareFinished(response);
    }];
}

/// 只支持朋友圈内分享
- (IBAction)weiboMusicShare {
    [WYShareSDK wy_weiboShareMusicURL:@"http://stream20.qqmusic.qq.com/32464723.mp3" streamURL:@"http://stream20.qqmusic.qq.com/32464723.mp3" title:@"微博音乐分享" description:@"王俨分享的音乐到微博的详细描述description" thumbnailData:UIImagePNGRepresentation([UIImage imageNamed:@"ic_account_tyj"]) finished:^(WYShareResponse *response) {
        WYShareFinished(response);
    }];
}

/// 只支持朋友圈内分享
- (IBAction)weiboVideoShare {
    NSString *videoUrl = @"http://v.youku.com/v_show/id_XNTUxNDY1NDY4.html";
    [WYShareSDK wy_weiboShareVideoURL:videoUrl streamURL:videoUrl title:@"视频分享" description:@"这个视频很好看" thumbnailData:UIImagePNGRepresentation([UIImage imageNamed:@"ic_account_tyj"]) finished:^(WYShareResponse *response) {
        WYShareFinished(response);
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
    [WYShareSDK wy_QQLoginFinished:^(WYQQUserinfo *qqUserinfo, WYQQToken *qqToken, NSError *error) {
        if (error) {
            NSLog(@"error = %@", error);
            return;
        }
        
        NSLog(@"qqToken = %@", qqToken);
        NSLog(@"qqUserinfo = %@", qqUserinfo);
    }];
}

- (IBAction)refreshWxTokenBtnClick {
    [WYShareSDK wy_weChatRefreshAccessToken:^(WYWXToken *wxToken, NSError *error) {
        NSLog(@"error = %@", error);
        NSLog(@"wxToken = %@", wxToken);
    }];
}

- (IBAction)weiboLoginBtnClick:(UIButton *)sender {
    [WYShareSDK wy_weiboLoginFinished:^(WeiboUser *weiboUser, WYWeiboToken *weiboToken, NSError *error) {
        NSLog(@"error = %@", error);
        NSLog(@"weiboToken = %@", weiboToken);
        NSLog(@"weiboUser = %@", weiboUser);
    }];
}

#pragma mark - dealloc
- (void)dealloc {
    NSLog(@"♻️ Dealloc %@", NSStringFromClass([self class]));
}


@end
