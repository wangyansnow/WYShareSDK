//
//  WYBaseModel.h
//  分享原生SDK集成Demo
//
//  Created by 王俨 on 17/3/17.
//  Copyright © 2017年 wangyan. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WYBaseModel : NSObject

+ (instancetype)modelWithDict:(NSDictionary *)dict;
+ (instancetype)modelWithSaveKey:(NSString *)key;


- (void)saveModelWithKey:(NSString *)key;
- (void)clearModelWithKey:(NSString *)key;

@end
