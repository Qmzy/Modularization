//
//  WTModuleLogin.m
//  Modularization
//
//  Created by CYKJ on 2019/3/21.
//  Copyright © 2019年 D. All rights reserved.


#import "WTModuleLogin.h"
#import "WTModuleLifecycle.h"

@implementation WTModuleLogin

+ (void)load
{
    // 注册 protocol - class 映射
    [WTModuleLifecycle registerModuleClass:self config:@{} priority:100];
}

- (instancetype)initWithConfiguration:(NSDictionary *)configuration
{
    if (self = [super init]) {
        
    }
    return self;
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    NSLog(@"WTModule Login 组件收到信息");
    
    return YES;
}

@end
