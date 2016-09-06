![WYShareSDK.png](http://upload-images.jianshu.io/upload_images/1679203-34e8f9bb8ffeb33f.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

##1.项目环境搭建
[1]将`ShareSDK`文件夹中的文件拖入到项目中

![ShareSDK_file.png](http://upload-images.jianshu.io/upload_images/1679203-5fcf39625783943c.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

[2]链接所需的系统库
```
1.  CoreText.framework
2.  ImageIO.framework
3.  QuartzCore.framework
4.  CoreGraphics.framework
5.  Security.framework
6.  SystemConfiguration.framework
7.  CoreTelephony.framework
8.  libsqlite3.0.tbd
9.  libsqlite3.tbd
10. libstdc++.tbd
11. libiconv.tbd
12. libiconv.tbd
13. libz.tbd
14. libc++.tbd
```
![Paste_Image.png](http://upload-images.jianshu.io/upload_images/1679203-917fa3e20c0608d6.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

[3]在Xcode中,选择你的工程设置项,选中`TARGETS`一栏,在`info`标签栏的`URL type`添加`URL scheme` 为你在各大平台所注册应用程序的id (如下图所示)

![URLScheme.png](http://upload-images.jianshu.io/upload_images/1679203-5ac45911b04a2c4c.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

[4]针对iOS9的适配.右击项目中的info.plist,然后用Open as -> Source Code的方式打开,增加如下代码:
```
<key>LSApplicationQueriesSchemes</key>
 <array>
  <string>wechat</string>
  <string>weixin</string>
  <string>sinaweibohd</string>
  <string>sinaweibo</string>
  <string>sinaweibosso</string>
  <string>weibosdk</string>
  <string>weibosdk2.5</string>
  <string>mqqapi</string>
  <string>mqq</string>
  <string>mqqOpensdkSSoLogin</string>
  <string>mqqconnect</string>
  <string>mqqopensdkdataline</string>
  <string>mqqopensdkgrouptribeshare</string>
  <string>mqqopensdkfriend</string>
  <string>mqqopensdkapi</string>
  <string>mqqopensdkapiV2</string>
  <string>mqqopensdkapiV3</string>
  <string>mqzoneopensdk</string>
  <string>wtloginmqq</string>
  <string>wtloginmqq2</string>
  <string>mqqwpa</string>
  <string>mqzone</string>
  <string>mqzonev2</string>
  <string>mqzoneshare</string>
  <string>wtloginqzone</string>
  <string>mqzonewx</string>
  <string>mqzoneopensdkapiV2</string>
  <string>mqzoneopensdkapi19</string>
  <string>mqzoneopensdkapi</string>
  <string>mqzoneopensdk</string>
 </array>
<!--  让iOS9 退回到以前可以支持http请求  -->
 <key>NSAppTransportSecurity</key>
 <dict>
  <key>NSAllowsArbitraryLoads</key>
  <true/>
 </dict>
```

[5]选中项目设置,在`Build Settings`中的`Other Linker Flags`中增加`-fobj-arc`和`-ObjC`

![Paste_Image.png](http://upload-images.jianshu.io/upload_images/1679203-9eb583d3879d6429.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)
这时编译一下你的项目,如果没有报错,恭喜你环境搭建成功

##2.分享的代码使用
在`AppDelegate`中注册 微信/QQ/和微博
```
#import "AppDelegate.h"
#import "WYShareSDK.h"

/** 在三大平台注册的应用ID */
#define WXAppId    @"wx7074076f395c69d9"
#define QQAppId    @"1103515189"
#define WBAppKey    @"2273722657"

@interface AppDelegate ()

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    [WYShareSDK registerQQApp:QQAppId];
    [WYShareSDK registerWeiboApp:WBAppKey];
    [WYShareSDK registerWeChatApp:WXAppId];
    
    return YES;
}

- (BOOL)application:(UIApplication *)app openURL:(NSURL *)url options:(NSDictionary<NSString *,id> *)options {
    
    return [WYShareSDK handleOpenURL:url];
}

- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url {
    
    return [WYShareSDK handleOpenURL:url];
}

@end
```

在需要分享的地方直接导入`WYShareSDK.h`,调用其对应的方法分享到各个平台.例:
```
[WYShareSDK weChatShareText:@"分享一个" finished:^(WYShareResponse *response) {
        if (response.isSucess) {
            NSLog(@"分享成功");
            return;
        }
        NSLog(@"分享失败 error = %@", response.errorStr);
    }];
```
