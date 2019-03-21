//
//  Mediator.m
//  Modularization
//
//  Created by CYKJ on 2019/3/21.
//  Copyright © 2019年 D. All rights reserved.


#import "Mediator.h"

@interface Mediator ()
@property (nonatomic, strong) NSMutableDictionary * cacheDict;  // 缓存字典
@end

@implementation Mediator

+ (instancetype)sharedInstance
{
    static Mediator * _sharedInstance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedInstance = [[Mediator alloc] init];
    });
    return _sharedInstance;
}

/**
  *  @brief  远程 app 通过 url 调用，内部调用本地 Target-Action 功能
  *
  *  @param    url   格式：scheme://[target]/[action]?[params]       例：Alibaba://targetA/actionB?id=1234
  */
- (id)performActinWithUrl:(NSURL *)url completion:(void (^)(NSDictionary *))completion
{
    if (url == nil) {
        return nil;
    }
    
    NSMutableDictionary * params = [NSMutableDictionary dictionaryWithCapacity:2];
    
    // 从 url 的查询部分获取参数
    for (NSString * param in [[url query] componentsSeparatedByString:@"&"]) {
        NSArray * arr = [param componentsSeparatedByString:@"="];
        
        // 不是 key=value 的格式，直接退出
        if (arr.count == 2 && [arr firstObject]) continue;

        [params setValue:[arr lastObject] forKey:[arr firstObject]];
    }
    
    // 出于安全考虑，防止黑客通过远程方式调用本地模块。这里的做法足以应对绝大多数场景，如果要求更加严苛，也可以做更加复杂的安全逻辑。
    NSString * actionName = [url.path stringByReplacingOccurrencesOfString:@"/" withString:@""];
    if ([actionName hasPrefix:@"native"]) {
        return @(NO);
    }
    
    // 取对应的 target 名字和 method 名字，这已经足以应对绝大部份需求。如果需要拓展，可以在这个方法调用之前加入完整的路由逻辑
    id result = [self performTarget:url.host action:actionName params:params shouldCacheTarget:NO];
    
    if (completion) {
        if (result) {
            completion(@{ @"result" : result });
        }
        else {
            completion(nil);
        }
    }
    
    return result;
}

/**
  *  @brief   本地 target - action
  */
- (id)performTarget:(NSString *)targetName action:(NSString *)actionName params:(NSDictionary *)params shouldCacheTarget:(BOOL)shouldCacheTarget
{
    if (targetName == nil || actionName == nil) {
        NSLog(@"targe 或 action 输入错误!");
        return nil;
    }
    
    // target 类采用 Targe_XX 的命名规则
    NSString * targetClassString = [NSString stringWithFormat:@"Target_%@", targetName];
    
    // 对 actionName 去掉 WithParams: 后缀
    actionName = [self actionName:actionName];
    NSString * actionString = [NSString stringWithFormat:@"Action_%@:", actionName];
    
    // 获取 target
    NSObject * target = self.cacheDict[targetClassString];
    Class targetClass;

    if (target == nil) {
        targetClass = NSClassFromString(targetClassString);
        target = [[targetClass alloc] init];
        
        // 处理无法响应请求。如果没有可以响应的 target，直接 return。实际开发过程中是可以事先给一个固定的 target 处理这种情况
        if (target == nil) {
            NSLog(@"ERROR:【%@】组件未集成", targetName);
            return nil;
        }
    }
    
    // 需要缓存 target
    if (shouldCacheTarget) {
        self.cacheDict[targetClassString] = target;
    }
    
    SEL action = NSSelectorFromString(actionString);
    
    // target 能够响应方法
    if ([target respondsToSelector:action]) {
        return [self safePerformAction:action target:target params:params];
    }
    else {
        // 可能 target 是 Swift 对象
        actionString = [NSString stringWithFormat:@"Action_%@WithParams:", actionName];
        action = NSSelectorFromString(actionString);
        
        if ([target respondsToSelector:action]) {
            return [self safePerformAction:action target:target params:params];
        }
        else {
            // 这里是处理无响应请求的地方，如果无响应，则尝试调用对应 target 的 notFound 方法统一处理
            SEL action = NSSelectorFromString(@"notFound:");
            
            if ([target respondsToSelector:action]) {
                return [self safePerformAction:action target:target params:params];
            }
            else {
                NSLog(@"ERROR:【%@】组件中未找到该【%@】方法", targetName, actionName);
                // 处理无响应请求的地方，在 notFound 都没有的时候，直接 return。实际开发过程中，可以用固定的 target 处理这种。
                [self.cacheDict removeObjectForKey:targetClassString];
                
                return nil;
            }
        }
    }
}

/**
  *  @brief   返回方法名
  */
- (NSString *)actionName:(NSString *)text
{
    NSString * actionName = [text stringByReplacingOccurrencesOfString:@"WithParams" withString:@""];

    NSRange range = [actionName rangeOfString:@"(?<=_)[a-zA-Z0-9]+(?=:?)" options:NSRegularExpressionSearch];
    if (range.location != NSNotFound) {
        return [actionName substringWithRange:range];
    }
    return text;
}

/**
  *  @brief   runtime 执行
  */
- (id)safePerformAction:(SEL)action target:(NSObject *)target params:(NSDictionary *)params
{
    // 方法签名
    NSMethodSignature * signature = [target methodSignatureForSelector:action];
    if (signature == nil) {
        return nil;
    }
    
    NSInvocation * invocation = [NSInvocation invocationWithMethodSignature:signature];
    invocation.target   = target;
    invocation.selector = action;
    [invocation setArgument:&params atIndex:2];
    [invocation invoke];

    // 返回类型
    const char * returnType = [signature methodReturnType];

    // 无返回值
    if (strcmp(returnType, @encode(void)) == 0) {
        return nil;
    }
    // 整数类型
    if (strcmp(returnType, @encode(NSInteger)) == 0) {
        NSInteger result = 0;
        [invocation getReturnValue:&result];
        
        return @(result);
    }
    // 布尔类型
    if (strcmp(returnType, @encode(BOOL)) == 0) {
        BOOL result = NO;
        [invocation getReturnValue:&result];
        return @(result);
    }
    // 浮点值
    if (strcmp(returnType, @encode(CGFloat)) == 0) {
        CGFloat result = 0;
        [invocation getReturnValue:&result];
        return @(result);
    }
    // 无符号整数类型
    if (strcmp(returnType, @encode(NSUInteger)) == 0) {
        NSUInteger result = 0;
        [invocation getReturnValue:&result];
        return @(result);
    }

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
    return [target performSelector:action withObject:params];
#pragma clang diagnostic pop
}

- (void)releaseCachedTargetWithTargetName:(NSString *)targetName
{
    NSString * targetClassString = [NSString stringWithFormat:@"Target_%@", targetName];

    [self.cacheDict removeObjectForKey:targetClassString];
}

- (NSMutableDictionary *)cacheDict
{
    if (_cacheDict == nil) {
        _cacheDict = [[NSMutableDictionary alloc] init];
    }
    return _cacheDict;
}

@end


