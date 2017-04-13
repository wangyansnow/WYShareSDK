//
//  AppDelegate.m
//  分享原生SDK集成Demo
//
//  Created by 王俨 on 16/9/3.
//  Copyright © 2016年 wangyan. All rights reserved.
//

#import "AppDelegate.h"
#import "WYShareSDK.h"
#import <TencentOpenAPI/TencentOAuth.h>

#define WXAppId     @"wx99f7a7e9cdac7e24"
#define WXAppSecret @"e310f0d8c2037825f1615140a1e76ae5"
#define QQAppId     @"1104133929"
#define WBAppKey    @"2045436852"


@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    [WYShareSDK wy_registerQQApp:QQAppId];
    [WYShareSDK wy_registerWeiboApp:WBAppKey];
    [WYShareSDK wy_registerWeChatApp:WXAppId wxAppSecret:WXAppSecret];
    
    return YES;
}


- (BOOL)application:(UIApplication *)app openURL:(NSURL *)url options:(NSDictionary<NSString *,id> *)options {
    
    return [WYShareSDK wy_handleOpenURL:url];
}

- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url {
    
    return [WYShareSDK wy_handleOpenURL:url];
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
    return [WYShareSDK wy_handleOpenURL:url];
}

@end
