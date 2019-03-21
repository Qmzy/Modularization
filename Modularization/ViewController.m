//
//  ViewController.m
//  Modularization
//
//  Created by CYKJ on 2019/3/21.
//  Copyright © 2019年 D. All rights reserved.


#import "ViewController.h"

#import "Mediator+Login.h"

#import "Cube.h"
#import "LoginCubeProtocol.h"


@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [[Mediator sharedInstance] Mediator_doUpdateAllUserServiceInfoWithParams:nil];
    
    id<LoginCubeProtocol> obj = [[Cube sharedCube] instanceWithProtocol:@protocol(LoginCubeProtocol)];
    [obj doUpdateAllUserServiceInfoWithParams:nil];
}


@end
