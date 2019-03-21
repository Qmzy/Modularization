//
//  Mediator+Login.m
//  Modularization
//
//  Created by CYKJ on 2019/3/21.
//  Copyright © 2019年 D. All rights reserved.


#import "Mediator+Login.h"

NSString * const kCTMediatorTargetLogin = @"Login";  // 模块名

@implementation Mediator (Login)

- (void)Mediator_doUpdateAllUserServiceInfoWithParams:(NSDictionary *)params
{
    [self performTarget:kCTMediatorTargetLogin
                 action:NSStringFromSelector(_cmd)
                 params:params
      shouldCacheTarget:NO];
}

@end
