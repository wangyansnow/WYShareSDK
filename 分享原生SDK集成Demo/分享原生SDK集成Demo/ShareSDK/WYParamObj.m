//
//  WYParamObj.m
//  分享原生SDK集成Demo
//
//  Created by 王俨 on 2017/4/12.
//  Copyright © 2017年 wangyan. All rights reserved.
//

#import "WYParamObj.h"

@implementation WYParamObj

+ (instancetype)paramWithObjects:(id)firstObj, ... {
    NSLog(@"%@", firstObj);
    
    WYParamObj *obj = [self new];
    obj.param1 = firstObj;
    id nextParam;
    
    NSMutableArray *arrM = [NSMutableArray array];
    va_list arg_list;
    va_start(arg_list, firstObj);
    while ((nextParam = va_arg(arg_list, id))) {
        [arrM addObject:nextParam];
    }
    
    NSInteger count = arrM.count;
    if (count < 5) {
        for (NSInteger i = count; i< 5; i++){
            [arrM addObject:@""];
        }
    }
    
    obj.param2 = arrM[0];
    obj.param3 = arrM[1];
    obj.param4 = arrM[2];
    obj.param5 = arrM[3];
    obj.param6 = arrM[4];
    
    return obj;
}

@end
