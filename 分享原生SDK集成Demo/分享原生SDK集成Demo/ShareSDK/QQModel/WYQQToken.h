//
//  WYQQToken.h
//  分享原生SDK集成Demo
//
//  Created by 王俨 on 17/3/21.
//  Copyright © 2017年 wangyan. All rights reserved.
//

#import "WYBaseModel.h"

@interface WYQQToken :WYBaseModel

/** Access Token凭证，用于后续访问各开放接口 3个月有效期 */
@property (nonatomic, copy) NSString *accessToken;
/** 用户授权登录后对该用户的唯一标识 */
@property (nonatomic, copy) NSString *openId;
/** Access Token的失效期 */
@property (nonatomic, strong) NSDate *expirationDate;

@end
