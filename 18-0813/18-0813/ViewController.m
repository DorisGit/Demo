//
//  ViewController.m
//  18-0813
//
//  Created by MoMo on 2018/8/13.
//  Copyright © 2018年 MoMo. All rights reserved.
//

#import "ViewController.h"
#import "TestObject.h"
#import "MMNotification.h"

@interface ViewController ()
/** notifi */
@property (nonatomic, strong) MMNotification *notifi;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    [self demo4];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

// Notification所在的默认线程中捕获发送的通知，然后将其重定向到指定的线程中。
- (void)demo4 {
    static NSString *NOTIFICATION_NAME = @"NOTIFICATION_NAME";

    MMNotification *notifi = [[MMNotification alloc] init];
    self.notifi = notifi;
    NSLog(@"初始化数据，Current thread = %@", [NSThread currentThread]);
    [[NSNotificationCenter defaultCenter] addObserver:self.notifi
                                             selector:@selector(dealNotification:)
                                                 name:NOTIFICATION_NAME
                                               object:nil];
    
    dispatch_async(dispatch_get_global_queue(QOS_CLASS_BACKGROUND, 0), ^{
        [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_NAME object:nil];
        //发送Notification
        NSLog(@"Post notification，Current thread = %@", [NSThread currentThread]);
    });
    
    
}

// 子线程中发出的通知，注册通知观察者监听到通知调用的方法也是在对应的子线程
- (void)demo2 {
    static NSString *NOTIFICATION_NAME = @"NOTIFICATION_NAME";
    dispatch_async(dispatch_get_global_queue(QOS_CLASS_BACKGROUND, 0), ^{
        [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_NAME object:nil];
//        <NSThread: 0x12dd8b810>{number = 3, name = (null)}
    });
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(demo3)
                                                 name:NOTIFICATION_NAME
                                               object:nil];
}

- (void)demo3 {
    NSLog(@"NOTIFICATION_NAME----%@",[NSThread currentThread]);
//    NOTIFICATION_NAME----<NSThread: 0x12dd8b810>{number = 3, name = (null)}
    
    // 为了避免接受通知后在子线程执行UI更新操作，方法调用的时候可以回到主线程再执行相关操作（很多通知的时候不适用，操作过于繁复）
    dispatch_async(dispatch_get_main_queue(), ^{
        NSLog(@"Main----%@",[NSThread currentThread]);
    });
}

// 获取很多对象同时被销毁时占用的cpu时间
- (void)demo1 {
    dispatch_async(dispatch_get_global_queue(QOS_CLASS_BACKGROUND, 0), ^{
        NSMutableArray *t_list = [[NSMutableArray alloc] init];
        for (int i = 0; i < 9999999 * 3; i++) {
            TestObject *ob = [[TestObject alloc] init];
            [t_list addObject:ob];
        }
        NSDate *s_date = [NSDate date];
        t_list = nil;
        NSDate *e_date = [NSDate date];
        NSLog(@"相差的时间是:%d秒",(int)[e_date timeIntervalSinceDate:s_date]);
    });
}

@end
