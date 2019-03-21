//
//  Mediator.h
//  Modularization
//
//  Created by CYKJ on 2019/3/21.
//  Copyright © 2019年 D. All rights reserved.
//
//  see：https://casatwy.com/iOS-Modulization.html      Github：https://github.com/casatwy/CTMediator


#import <UIKit/UIKit.h>

/**
  *  @brief    组件 Category 的方法以 Mediator_ 为前缀；组件对外的类以 Target_ 为前缀，类中方法以 Action_ 为前缀。在中间件按照这个规则查找 action
  */
@interface Mediator : NSObject

+ (instancetype)sharedInstance;
+ (instancetype)init NS_UNAVAILABLE;
+ (instancetype)new NS_UNAVAILABLE;

/**
  *  @brief   远程 app 调用入口
  */
- (id)performActinWithUrl:(NSURL *)url
               completion:(void(^)(NSDictionary * info))completion;

/**
  *  @brief   本地组件调用入口，为远程调用提供服务
  */
- (id)performTarget:(NSString *)targetName
             action:(NSString *)actionName
             params:(NSDictionary *)params
  shouldCacheTarget:(BOOL)shouldCacheTarget;

/**
  *  @brief   移除缓存中 key = targetName 对应的数据
  */
- (void)releaseCachedTargetWithTargetName:(NSString *)targetName;

@end
