//
//  WYWXToken.h
//  分享原生SDK集成Demo
//
//  Created by 王俨 on 17/3/17.
//  Copyright © 2017年 wangyan. All rights reserved.
//

#import "WYBaseModel.h"

extern NSString *const WYWXTokenKey;

@interface WYWXToken : WYBaseModel

/** 接口调用凭证 */
@property (nonatomic, copy) NSString *access_token;
/** 用户刷新access_token */
@property (nonatomic, copy) NSString *refresh_token;
/** 授权用户唯一标识 */
@property (nonatomic, copy) NSString *openid;
/** 用户授权的作用域，使用逗号（,）分隔 */
@property (nonatomic, copy) NSString *scope;
/** access_token接口调用凭证超时时间，单位（秒）*/
@property (nonatomic, assign) NSUInteger expires_in;


@end
