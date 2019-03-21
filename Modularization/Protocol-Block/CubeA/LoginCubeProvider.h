//
//  Cube_Login.h
//  Modularization
//
//  Created by CYKJ on 2019/3/21.
//  Copyright © 2019年 D. All rights reserved.


#import <Foundation/Foundation.h>
#import "LoginCubeProtocol.h"

@interface LoginCubeProvider : NSObject <LoginCubeProtocol>

+ (instancetype)sharedInstance;

@end
