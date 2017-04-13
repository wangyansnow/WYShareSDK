//
//  WYParamObj.h
//  分享原生SDK集成Demo
//
//  Created by 王俨 on 2017/4/12.
//  Copyright © 2017年 wangyan. All rights reserved.
//

#import <Foundation/Foundation.h>

@class WYShareResponse, WYQQToken, WYQQUserinfo, WYWeiboToken, WYWXToken, WeiboUser, WYWXUserinfo;
@interface WYParamObj : NSObject

@property (nonatomic, strong) id param1;
@property (nonatomic, strong) id param2;
@property (nonatomic, strong) id param3;
@property (nonatomic, strong) id param4;
@property (nonatomic, strong) id param5;
@property (nonatomic, strong) id param6;
@property (nonatomic, strong) id param7;

@property (nonatomic, copy) void(^shareFinished)(WYShareResponse *response);

@property (nonatomic, copy) void(^wxLoginFinished)(WYWXUserinfo *wxUserinfo, WYWXToken *wxToken, NSError *error);
@property (nonatomic, copy) void(^wxRefreshTokenFinished)(WYWXToken *wxToken, NSError *error);

@property (nonatomic, copy) void(^qqLoginFinished)(WYQQUserinfo *qqUserinfo, WYQQToken *qqToken, NSError *error);
@property (nonatomic, copy) void(^weiboLoginFinished)(WeiboUser *weiboUser, WYWeiboToken *weiboToken, NSError *error);

@end

