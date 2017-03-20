//
//  WYWXUserInfo.h
//  分享原生SDK集成Demo
//
//  Created by 王俨 on 17/3/17.
//  Copyright © 2017年 wangyan. All rights reserved.
//

#import "WYBaseModel.h"

typedef NS_ENUM(int, WYWXUserinfoSex) {
    WYWXUserinfoSexMale   = 1, // 男性
    WYWXUserinfoSexFemale = 2, // 女性
};

@interface WYWXUserinfo : WYBaseModel

/** 普通用户的标识，对当前开发者帐号唯一 */
@property (nonatomic, copy) NSString *openid;
/** 普通用户昵称 */
@property (nonatomic, copy) NSString *nickname;
/** 普通用户个人资料填写的省份 */
@property (nonatomic, copy) NSString *province;
/** 普通用户个人资料填写的城市 */
@property (nonatomic, copy) NSString *city;
/** 国家，如中国为CN */
@property (nonatomic, copy) NSString *country;
/** 用户头像，最后一个数值代表正方形头像大小（有0、46、64、96、132数值可选，0代表640*640正方形头像），用户没有头像时该项为空 */
@property (nonatomic, copy) NSString *headimgurl;
/** 用户统一标识。针对一个微信开放平台帐号下的应用，同一用户的unionid是唯一的。*/
@property (nonatomic, copy) NSString *unionid;
/** 用户特权信息，json数组，如微信沃卡用户为（chinaunicom） */
@property (nonatomic, strong) NSArray *privilege;
@property (nonatomic, assign) WYWXUserinfoSex sex;


+ (void)wy_fetchWXUserinfoWithAccessToken:(NSString *)accessToken openId:(NSString *)openId finished:(void(^)(WYWXUserinfo *wxUserinfo, NSError *error))finished;

@end
