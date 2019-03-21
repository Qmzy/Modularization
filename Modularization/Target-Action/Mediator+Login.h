//
//  Mediator+Login.h
//  Modularization
//
//  Created by CYKJ on 2019/3/21.
//  Copyright © 2019年 D. All rights reserved.


#import "Mediator.h"

@interface Mediator (Login)

/**
  *  @brief   更新用户信息
  *  @param   params    结构：{   @"serviceType" : NSNumber   // 业务类型   }
  */
- (void)Mediator_doUpdateAllUserServiceInfoWithParams:(NSDictionary *)params;

@end
