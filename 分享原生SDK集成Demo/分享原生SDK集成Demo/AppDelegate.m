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

#define WXAppId     @"wxd69cc042cbd89299"
#define WXAppSecret @""
#define QQAppId     @"1104133929"
#define WBAppKey    @"2273722657"



@interface AppDelegate ()



@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    [WYShareSDK registerQQApp:QQAppId];
    [WYShareSDK registerWeiboApp:WBAppKey];
    [WYShareSDK registerWeChatApp:WXAppId wxAppSecret:WXAppSecret];
    
    return YES;
}


- (BOOL)application:(UIApplication *)app openURL:(NSURL *)url options:(NSDictionary<NSString *,id> *)options {
    
    return [WYShareSDK handleOpenURL:url];
}

- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url {
    
    return [WYShareSDK handleOpenURL:url];
}


@end
