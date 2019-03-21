//
//  Cube.m
//  Modularization
//
//  Created by CYKJ on 2019/3/21.
//  Copyright © 2019年 D. All rights reserved.


#import "Cube.h"
#import <pthread.h>

@interface Cube()
{
    NSMutableDictionary * _protocol_dict;
    pthread_rwlock_t _protocl_safeLock; // 读写锁
}
@end

@implementation Cube

- (void)dealloc
{
    pthread_rwlock_destroy(&_protocl_safeLock);
}

+ (instancetype)sharedCube
{
    static Cube *_sharedCube;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedCube = [[self alloc] init];
    });
    return _sharedCube;
}

- (instancetype)init
{
    if (self = [super init]) {
        _protocol_dict = [[NSMutableDictionary alloc] init];
        pthread_rwlock_init(&_protocl_safeLock, NULL);
    }
    return self;
}

- (void)registProtocol:(Protocol*)protocol withGenerationBlock:(id (^)(void))block
{
    assert(nil != protocol);
    if (nil == protocol)
        return;
    
    assert(NULL != block);
    if (NULL == block)
        return;
    
    // 写入加锁，key : protocolName，value : block
    pthread_rwlock_wrlock(&_protocl_safeLock);
    [_protocol_dict setObject:block forKey:NSStringFromProtocol(protocol)];
    pthread_rwlock_unlock(&_protocl_safeLock);
}

- (id)instanceWithProtocol:(Protocol*)protocol
{
    id instance = nil;
    id (^generate_instance)(void) = NULL;
    
    assert(nil != protocol);
    if (nil == protocol)
        return nil;
    
    // 读取加锁
    pthread_rwlock_rdlock(&_protocl_safeLock);
    generate_instance = [_protocol_dict objectForKey:NSStringFromProtocol(protocol)];
    pthread_rwlock_unlock(&_protocl_safeLock);
    
    if (NULL != generate_instance)
        instance = generate_instance();
    
    assert(nil == instance || [instance conformsToProtocol:protocol]);
    
    return [instance conformsToProtocol:protocol] ? instance : nil;
}

@end
