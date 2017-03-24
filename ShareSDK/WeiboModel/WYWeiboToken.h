//
//  WYWeiboToken.h
//  分享原生SDK集成Demo
//
//  Created by 王俨 on 17/3/22.
//  Copyright © 2017年 wangyan. All rights reserved.
//

#import "WYBaseModel.h"

@interface WYWeiboToken : WYBaseModel

@property (nonatomic, copy) NSString *accessToken;
@property (nonatomic, strong) NSArray *app;
@property (nonatomic, assign) long long expires_in;
@property (nonatomic, copy) NSString *refresh_token;
@property (nonatomic, assign) long long remind_in;
@property (nonatomic, copy) NSString *scope;
@property (nonatomic, copy) NSString *uid;

@end
