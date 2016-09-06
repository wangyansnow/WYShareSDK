//
//  AppDelegate.m
//  分享原生SDK集成Demo
//
//  Created by 王俨 on 16/9/3.
//  Copyright © 2016年 wangyan. All rights reserved.
//

#import "AppDelegate.h"
//#import "WXApi.h"
//#import <TencentOpenAPI/QQApiInterface.h>
//#import <TencentOpenAPI/TencentOAuth.h>
//#import "WeiboSDK.h"
#import "WYShareSDK.h"

#define WXAppId    @"wx7074076f395c69d9"
#define QQAppId    @"1103515189"
#define WBAppId    @"2273722657"
#define kUMENG_WXAppSecret   @"2db8c8e74a1cec2edfde87711bf3eff7"
#define kUMENG_QQAppKey      @"ZkGVW2gmcpF3ls7E"


@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    [WYShareSDK initialShareSDK];
    
    return YES;
}


- (BOOL)application:(UIApplication *)app openURL:(NSURL *)url options:(NSDictionary<NSString *,id> *)options {
    
    return [WYShareSDK handleOpenURL:url];
}

- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url {
    
    return [WYShareSDK handleOpenURL:url];
}


@end
