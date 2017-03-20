//
//  WYWXUserInfo.m
//  分享原生SDK集成Demo
//
//  Created by 王俨 on 17/3/17.
//  Copyright © 2017年 wangyan. All rights reserved.
//

#import "WYWXUserinfo.h"
#import "WYShareDefine.h"

@implementation WYWXUserinfo

+ (void)wy_fetchWXUserinfoWithAccessToken:(NSString *)accessToken openId:(NSString *)openId finished:(void(^)(WYWXUserinfo *wxUserinfo, NSError *error))finished {
    
    NSString *userInfoURL = [NSString stringWithFormat:@"https://api.weixin.qq.com/sns/userinfo?access_token=%@&openid=%@", accessToken, openId];
    
    [[[NSURLSession sharedSession] dataTaskWithURL:[NSURL URLWithString:userInfoURL] completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (error || !data) {
            BLOCK_EXEC(finished, nil, error);
            return;
        }
        
        NSError *jsonError;
        id obj = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:&jsonError];
        if (jsonError) {
            BLOCK_EXEC(finished, nil, error);
            return;
        }
        
        if ([obj[@"errcode"] integerValue] == 40003) {
            error = [NSError errorWithDomain:obj[@"errmsg"] code:[obj[@"errcode"] integerValue] userInfo:nil];
            BLOCK_EXEC(finished, nil, error);
            return;
        }
        
        WYWXUserinfo *userinfo = [WYWXUserinfo modelWithDict:obj];
        BLOCK_EXEC(finished, userinfo, nil);
    }] resume];
}

@end
