//
//  WYShareDefine.h
//  分享原生SDK集成Demo
//
//  Created by 王俨 on 16/9/5.
//  Copyright © 2016年 wangyan. All rights reserved.
//

#ifndef WYShareDefine_h
#define WYShareDefine_h

static NSString *const kMusicURL = @"http://music.huoxing.com/upload/20130330/1364651263157_1085.mp3";

static NSString *kWechatMusicURL = @"http://y.qq.com/i/song.html#p=7B22736F6E675F4E616D65223A22E4B880E697A0E68980E69C89222C22736F6E675F5761704C69766555524C223A22687474703A2F2F74736D7573696334382E74632E71712E636F6D2F586B30305156342F4141414130414141414E5430577532394D7A59344D7A63774D4C6735586A4C517747335A50676F47443864704151526643473444442F4E653765776B617A733D2F31303130333334372E6D34613F7569643D3233343734363930373526616D703B63743D3026616D703B636869643D30222C22736F6E675F5769666955524C223A22687474703A2F2F73747265616D31342E71716D757369632E71712E636F6D2F33303130333334372E6D7033222C226E657454797065223A2277696669222C22736F6E675F416C62756D223A22E4B880E697A0E68980E69C89222C22736F6E675F4944223A3130333334372C22736F6E675F54797065223A312C22736F6E675F53696E676572223A22E5B494E581A5222C22736F6E675F576170446F776E4C6F616455524C223A22687474703A2F2F74736D757369633132382E74632E71712E636F6D2F586C464E4D313574414141416A41414141477A4C36445039536A457A525467304E7A38774E446E752B6473483833344843756B5041576B6D48316C4A434E626F4D34394E4E7A754450444A647A7A45304F513D3D2F33303130333334372E6D70333F7569643D3233343734363930373526616D703B63743D3026616D703B636869643D3026616D703B73747265616D5F706F733D35227D";

// 微博: https://github.com/sinaweibosdk/weibo_ios_sdk
// 微信: https://open.weixin.qq.com/cgi-bin/showdocument?action=dir_list&t=resource/res_list&verify=1&id=open1419317332&token=&lang=zh_CN
// QQ: http://wiki.open.qq.com/wiki/mobile/SDK%E4%B8%8B%E8%BD%BD

#define HasQQInstall \
    if (![QQApiInterface isQQInstalled]) { \
       [[[UIAlertView alloc] initWithTitle:@"温馨提示" message:@"您还没有安装手机QQ" delegate:nil cancelButtonTitle:@"知道了" otherButtonTitles:nil] show]; \
        return; \
    }

#define HasWXInstall \
    if (![WXApi isWXAppInstalled]) { \
        [[[UIAlertView alloc] initWithTitle:@"温馨提示" message:@"您还没有安装微信" delegate:nil cancelButtonTitle:@"知道了" otherButtonTitles:nil] show]; \
        return; \
    }

#define HasWeiboInstall \
    if (![WeiboSDK isWeiboAppInstalled]) { \
       [[[UIAlertView alloc] initWithTitle:@"温馨提示" message:@"您还没有安装微博" delegate:nil cancelButtonTitle:@"知道了" otherButtonTitles:nil] show]; \
        return; \
    }

#define BLOCK_EXEC(block, ...)  \
    if (block) {  \
        dispatch_async(dispatch_get_main_queue(), ^{ \
            block(__VA_ARGS__); \
        }); \
    }; \

#endif /* WYShareDefine_h */
