//
//  WYBaseModel.m
//  分享原生SDK集成Demo
//
//  Created by 王俨 on 17/3/17.
//  Copyright © 2017年 wangyan. All rights reserved.
//

#import "WYBaseModel.h"
#import <objc/runtime.h>

@implementation WYBaseModel

+ (instancetype)modelWithDict:(NSDictionary *)dict {
    WYBaseModel *model = [self new];
    
    if ([dict isKindOfClass:[NSDictionary class]]) {
        [model setValuesForKeysWithDictionary:dict];
    }
    
    return model;
}

+ (instancetype)modelWithSaveKey:(NSString *)key {
    if (!key) return nil;
    
    NSDictionary *dict = [[NSUserDefaults standardUserDefaults] objectForKey:key];
    if (!dict) return nil;
    
    return [self modelWithDict:dict];
}

- (void)saveModelWithKey:(NSString *)key {
    if (!key) return;
    
    NSDictionary *dict = [self modelDict];
    if (!dict) return;
    
    [[NSUserDefaults standardUserDefaults] setObject:dict forKey:key];
}

- (void)clearModelWithKey:(NSString *)key {
    if (!key) return;
    
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:key];
}

#pragma mark - KVC
- (void)setValue:(id)value forUndefinedKey:(NSString *)key {}
- (void)setNilValueForKey:(NSString *)key {}
- (void)setValue:(id)value forKey:(NSString *)key {
    if ([value isKindOfClass:[NSNull class]]) {
        return;
    }
    
    [super setValue:value forKey:key];
}

- (NSString *)description {
    NSDictionary *dict = [self modelDict];
    
    if (!dict) return [super description];
    
    if (![NSJSONSerialization isValidJSONObject:dict]) return [super description];
    
    NSError *jsonError;
    NSData *data = [NSJSONSerialization dataWithJSONObject:dict options:NSJSONWritingPrettyPrinted error:&jsonError];
    if (jsonError || data.length == 0) return [super description];
    
    NSString *str = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    return str;
}

#pragma mark - private
- (NSDictionary *)modelDict {
    
    unsigned int outCount;
    Ivar *ivars = class_copyIvarList([self class], &outCount);
    NSMutableDictionary *dictM = [NSMutableDictionary dictionaryWithCapacity:outCount];
    
    for (int i = 0; i< outCount; i++){
        Ivar ivar = ivars[i];
        
        const char *ivarName = ivar_getName(ivar);
        NSString *ivarNameStr = [[NSString alloc] initWithUTF8String:ivarName];
        
        const char *ivarType = ivar_getTypeEncoding(ivar);
        NSString *ivarTypeStr = [[NSString alloc] initWithUTF8String:ivarType];
        
        BOOL isSupportPlistDict = [kSupportPlistDict[ivarTypeStr] boolValue];
        if (!isSupportPlistDict) {
            BOOL isArrOrDict = [kDictOrArrDict[ivarTypeStr] boolValue];
            if (!isArrOrDict) continue;
            
            id value = [self valueForKey:ivarNameStr];
            if (!value || ![NSJSONSerialization isValidJSONObject:value])  continue;
            dictM[ivarNameStr] = value;
            continue;
        }
        
        id value = [self valueForKey:ivarNameStr];
        if (value) {
            dictM[ivarNameStr] = value;
        }
    }
    
    free(ivars);
    
    return dictM;
}

#pragma mark - private
static NSDictionary *kSupportPlistDict;
static NSDictionary *kDictOrArrDict;
+ (void)load {
    kSupportPlistDict = @{@"B": @1, @"C": @1, @"c": @1, @"S": @1, @"i": @1, @"I": @1, @"f": @1, @"@\"NSString\"": @1, @"d": @1, @"q": @1, @"Q": @1, @"@\"NSDate\"": @1, @"NSData": @1, @"s": @1};
    
    kDictOrArrDict = @{@"@\"NSArray\"": @1, @"@\"NSMutableArray\"": @1, @"@\"NSDictionary\"": @1, @"@\"NSMutableDictionary\"": @1,};
}

@end
