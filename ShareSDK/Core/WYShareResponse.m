//
//  WYShareResponse.m
//  分享原生SDK集成Demo
//
//  Created by 王俨 on 17/3/20.
//  Copyright © 2017年 wangyan. All rights reserved.
//

#import "WYShareResponse.h"

@implementation WYShareResponse

+ (instancetype)shareResponseWithSucess:(BOOL)success errorStr:(NSString *)errorStr {
    WYShareResponse *response = [[WYShareResponse alloc] init];
    response->_success = success;
    response->_errorStr = errorStr;
    return response;
}

@end
