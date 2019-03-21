//
//  Cube_Login.m
//  Modularization
//
//  Created by CYKJ on 2019/3/21.
//  Copyright © 2019年 D. All rights reserved.


#import "LoginCubeProvider.h"
#import "Cube.h"
#import "LoginCubeProtocol.h"


@implementation LoginCubeProvider

+ (void)load
{
    [[Cube sharedCube] registProtocol:@protocol(LoginCubeProtocol) withGenerationBlock:^id{
        return [self sharedInstance];
    }];
}

+ (instancetype)sharedInstance
{
    static LoginCubeProvider * provider;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        provider = [[LoginCubeProvider alloc] init];
    });
    return provider;
}

- (void)doUpdateAllUserServiceInfoWithParams:(NSDictionary *)params
{
    NSLog(@"Cube Login 组件收到信息");
}

@end
