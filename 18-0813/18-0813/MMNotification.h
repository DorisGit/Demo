//
//  MMNotifacation.h
//  18-0813
//
//  Created by MoMo on 2018/8/14.
//  Copyright © 2018年 MoMo. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MMNotification : NSObject
/** 通知队列 */
@property (nonatomic, strong) NSMutableArray *notifications;
/** 锁 */
@property (nonatomic, strong) NSLock *lock;
/** 要通知的目标线程 */
@property (nonatomic, strong) NSThread *thread;
/** 用于向目标线程发送通知的端口 */
@property (nonatomic, strong) NSPort *port;

- (void)dealNotification:(NSNotification *)notification;
@end
