//
//  MMNotifacation.m
//  18-0813
//
//  Created by MoMo on 2018/8/14.
//  Copyright © 2018年 MoMo. All rights reserved.
//

#import "MMNotification.h"

@interface MMNotification()<NSMachPortDelegate>

@end

@implementation MMNotification
- (instancetype)init {
    if (self = [super init]) {
        self.notifications = [NSMutableArray array];
        self.lock = [[NSLock alloc] init];
        self.port = [[NSMachPort alloc] init];
        self.thread = [NSThread mainThread];
        [self.port setDelegate:self];
        [[NSRunLoop currentRunLoop] addPort:self.port
                                    forMode:NSRunLoopCommonModes];
    }
    return self;
}

// 处理端口的代理方法
- (void)handleMachMessage:(void *)msg {
    [self.lock lock];
    while ([self.notifications count]) {
        NSNotification *notifi = [self.notifications objectAtIndex:0];
        [self.notifications removeObject:notifi];
        [self.lock unlock];
        [self dealNotification:notifi];
        [self.lock lock];
    }
    [self.lock unlock];
}

// 处理通知数据
- (void)dealNotification:(NSNotification *)notification {
    
    if (![[NSThread currentThread] isMainThread]) {
        [self.lock lock];
        [self.notifications addObject:notification];
        [self.lock unlock];
        [self.port sendBeforeDate:[NSDate date]
                       components:nil
                             from:nil
                         reserved:0];
    } else {
        // 在此处理通知
        NSLog(@"Receive notification，Current thread = %@", [NSThread currentThread]);
        NSLog(@"Process notification");
    }
}
@end
