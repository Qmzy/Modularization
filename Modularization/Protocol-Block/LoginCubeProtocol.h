//
//  LoginCube.h
//  Modularization
//
//  Created by CYKJ on 2019/3/21.
//  Copyright © 2019年 D. All rights reserved.


#import <Foundation/Foundation.h>

@protocol LoginCubeProtocol <NSObject>

- (void)doUpdateAllUserServiceInfoWithParams:(NSDictionary *)params;

@end
