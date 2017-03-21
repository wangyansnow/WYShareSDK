//
//  WYQQUserInfo.h
//  分享原生SDK集成Demo
//
//  Created by 王俨 on 17/3/20.
//  Copyright © 2017年 wangyan. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WYQQUserinfo : NSObject

@property (nonatomic, copy) NSString *city;
@property (nonatomic, copy) NSString *figureurl;
@property (nonatomic, copy) NSString *figureurl_1;
@property (nonatomic, copy) NSString *figureurl_2;
@property (nonatomic, copy) NSString *figureurl_qq_1;
@property (nonatomic, copy) NSString *figureurl_qq_2;
@property (nonatomic, copy) NSString *gender;
@property (nonatomic, assign) BOOL is_lost;
@property (nonatomic, assign) BOOL is_yellow_vip;
@property (nonatomic, assign) BOOL is_yellow_year_vip;
@property (nonatomic, assign) int level;
@property (nonatomic, copy) NSString *msg;
@property (nonatomic, copy) NSString *nickname;
@property (nonatomic, copy) NSString *province;
@property (nonatomic, assign) int ret;
@property (nonatomic, assign) int vip;
@property (nonatomic, assign) int yellow_vip_level;

/**
 city = "\U671d\U9633";
 figureurl = "http://qzapp.qlogo.cn/qzapp/1105186451/62E1AA18719C46ABB58EE0770D8872B9/30";
 "figureurl_1" = "http://qzapp.qlogo.cn/qzapp/1105186451/62E1AA18719C46ABB58EE0770D8872B9/50";
 "figureurl_2" = "http://qzapp.qlogo.cn/qzapp/1105186451/62E1AA18719C46ABB58EE0770D8872B9/100";
 "figureurl_qq_1" = "http://q.qlogo.cn/qqapp/1105186451/62E1AA18719C46ABB58EE0770D8872B9/40";
 "figureurl_qq_2" = "http://q.qlogo.cn/qqapp/1105186451/62E1AA18719C46ABB58EE0770D8872B9/100";
 gender = "\U7537";
 "is_lost" = 0;
 "is_yellow_vip" = 0;
 "is_yellow_year_vip" = 0;
 level = 0;
 msg = "";
 nickname = "\U4e0a\U5c71\U6253\U8001\U864e";
 province = "\U5317\U4eac";
 ret = 0;
 vip = 0;
 "yellow_vip_level" = 0;
 
 */

@end
