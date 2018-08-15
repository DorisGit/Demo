//
//  ViewController.m
//  18-0814-lock
//
//  Created by MoMo on 2018/8/14.
//  Copyright © 2018年 MoMo. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()
/**数据 */
@property (nonatomic, copy) NSString *name;
@end

@implementation ViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.name = @"111";
    [self demo6];
}

- (void)setName:(NSString *)name {
    
    // 同步
    @synchronized(self) {
        _name = name;
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)demo3 {
    
    NSLog(@"%s---%@",__func__,[NSThread currentThread]);
}

- (void)demo2 {
    
    NSThread *thread = [[NSThread alloc] initWithTarget:self selector:@selector(demo3) object:nil];
    [thread start];
    
}

- (void)demo4 {
    
    
    // 串行
    dispatch_queue_t queueSerial = dispatch_queue_create("lock.com.cn", DISPATCH_QUEUE_SERIAL);
    
    // 并行
    dispatch_queue_t queueConcurrent = dispatch_queue_create("lock.com.cn", DISPATCH_QUEUE_CONCURRENT);
    
//    dispatch_async(queueSerial, ^{
//        sleep(3);
//        [self demo3];
//    });
    
//    dispatch_async(queueConcurrent, ^{
//        sleep(3);
//        [self demo3];
//    });
//
//    dispatch_sync(queueSerial, ^{
//        sleep(3);
//        [self demo3];
//    });
//
//    dispatch_sync(queueConcurrent, ^{
//        sleep(3);
//        [self demo3];
//    });
    
//    dispatch_barrier_sync(queueSerial, ^{
//
//    });
    
//    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//
//    });
    
//    dispatch_apply(3, queueConcurrent, ^(size_t index) {
//        NSLog(@"dispatch_apply:%d",index);
//        [self demo3];
//    });
//
    dispatch_group_t group = dispatch_group_create();
    dispatch_group_async(group, queueSerial, ^{
        [self demo3];
    });
    dispatch_group_notify(group, dispatch_get_main_queue(), ^{
        [self demo3];
    });
    NSLog(@"%s---%@",__func__,[NSThread currentThread]);
}

- (void)demo5 {
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    // 设置最大maxConcurrentOperationCount 为1，串行执行
    queue.maxConcurrentOperationCount = 1;
    NSBlockOperation *operation1 = [NSBlockOperation blockOperationWithBlock:^{
        NSLog(@"operation1--%@",[NSThread currentThread]);
    }];
    NSInvocationOperation *invocation2 = [[NSInvocationOperation alloc] initWithTarget:self selector:@selector(demo3) object:nil];
    
    NSBlockOperation *operation2 = [NSBlockOperation blockOperationWithBlock:^{
        NSLog(@"operation2--%@",[NSThread currentThread]);
    }];
    // 添加依赖的同时 会只开辟一条新的线程
    [operation1 addDependency:operation2];
    [invocation2 addDependency:operation1];
    
    [queue addOperation:operation1];
    [queue addOperation:invocation2];
    [queue addOperation:operation2];
    
    
    [queue waitUntilAllOperationsAreFinished];
}

- (void)demo6 {
    
}

// @synchronized 加锁保护当前对象当前时间只能被一个线程访问
- (void)demo1 {
//    __weak ViewController *weakSelf = self;
    
    dispatch_async(dispatch_get_global_queue(QOS_CLASS_BACKGROUND, 0), ^{
        self.name = @"123";
        NSLog(@"%@:%@",[NSThread currentThread],self.name);
    });
    
    dispatch_async(dispatch_get_global_queue(QOS_CLASS_BACKGROUND, 0), ^{
        self.name = @"234";
        NSLog(@"%@:%@",[NSThread currentThread],self.name);
    });
    NSLog(@"%@:%@",[NSThread currentThread],self.name);
}

@end
