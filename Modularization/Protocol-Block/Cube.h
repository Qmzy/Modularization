//
//  Cube.h
//  Modularization
//
//  Created by CYKJ on 2019/3/21.
//  Copyright © 2019年 D. All rights reserved.


#import <Foundation/Foundation.h>

/**
  *   @brief   Cube，用于组件注册或调用组件间方法
  *
  *   @discussion  协议是放在底层，对任何模块都没有依赖
  *                                cube 更多的是在做一个功能的解耦，对外提供的功能以协议的方式，外部依赖协议就可以。另外一些页面的解耦是通过 openUrl 的方式。
  */
@interface Cube : NSObject

+ (instancetype)sharedCube;
- (instancetype)init NS_UNAVAILABLE;

/**
  *  @brief  注册一个 Cube
  *
  *  @param   protocol   必须在 Cube 目录下
  *  @param   block         block 内需要返回一个实例
  */
- (void)registProtocol:(Protocol *)protocol withGenerationBlock:(id (^)(void))block;

/**
  *  @brief   通过 protocol 获得一个实例
  *
  *  @param    protocol   对应的协议
  *  @return    对应的实例。有可能为 nil，需要判断
  */
- (id)instanceWithProtocol:(Protocol *)protocol;

@end
