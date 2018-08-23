//
//  ViewController.m
//  18-0816-KVO
//
//  Created by MoMo on 2018/8/16.
//  Copyright © 2018年 MoMo. All rights reserved.
//

#import "ViewController.h"
#import "Person.h"

@interface ViewController ()
/** person */
@property (nonatomic, strong) Person *person;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    [self demo1];
}



- (void)demo1 {
    Person *person = [[Person alloc] init];
    person.name = @"aa";
    dispatch_async(dispatch_get_global_queue(QOS_CLASS_BACKGROUND, 0), ^{
        [person addObserver:self forKeyPath:@"name" options:NSKeyValueObservingOptionNew context:nil];
        NSLog(@"%s--%@",__func__,[NSThread currentThread]);
    });
    
    self.person = person;
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    self.person.name = @"bb";
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    
    
    NSLog(@"%s--%@",__func__,[NSThread currentThread]);
    NSLog(@"%@--%@--%@--%@",keyPath,object,change,context);
    if ([keyPath isEqual:@"name"]) {
        NSLog(@"old price: %@",[change objectForKey:@"old"]);
        NSLog(@"new price: %@",[change objectForKey:@"new"]);
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    
    [self.person removeObserver:self forKeyPath:@"name"];
}


@end
