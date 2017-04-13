//
//  WYShareResponse.h
//  分享原生SDK集成Demo
//
//  Created by 王俨 on 17/3/20.
//  Copyright © 2017年 wangyan. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, WXShareScene) {
    WXShareSceneSession  = 0,        /**< 聊天界面    */
    WXShareSceneTimeline = 1,        /**< 朋友圈      */
    WXShareSceneFavorite = 2,        /**< 收藏       */
};

typedef NS_ENUM(NSInteger, QQShareScene) {
    QQShareSceneSession = 0,        /**< 聊天界面    */
    QQShareSceneQZone   = 1,        /**< 朋友圈      */
};

typedef NS_ENUM(NSInteger, WeiboShareScene) {
    WeiboShareSceneSession  = 0,    /**< 聊天界面    */
    WeiboShareSceneTimeline = 1,    /**< 朋友圈   */
};

////////////////////////////////////////  WYShareResponse  /////////////////////////////////////////////
@interface WYShareResponse : NSObject

@property (nonatomic, assign, getter=isSucess, readonly) BOOL success;
@property (nonatomic, copy, readonly) NSString *errorStr;

+ (instancetype)shareResponseWithSucess:(BOOL)success errorStr:(NSString *)errorStr;

@end
