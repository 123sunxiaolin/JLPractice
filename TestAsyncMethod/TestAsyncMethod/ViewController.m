//
//  ViewController.m
//  TestAsyncMethod
//
//  Created by perfect on 2018/3/7.
//  Copyright © 2018年 JackLin. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

- (IBAction)onClickAsyncMainQueue:(id)sender;
- (IBAction)onClickAsyncGlobalQueu:(id)sender;
- (IBAction)onClickAsyncOperationQueue:(id)sender;
@property (weak, nonatomic) IBOutlet UILabel *leftLabel;
@property (weak, nonatomic) IBOutlet UILabel *rightLabel;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.leftLabel.text = @"关于是阿AV和v 因为FVF氨基酸的后加上的很多很多多喝水较好的是的收到就好舌尖上的是但是金黄色的华盛顿";
    self.rightLabel.text = @"vcvshvvcshdvchdcvshchsvdchvsh";
    
    [self testInvocation];
}

#pragma mark - Invocation

- (void)testInvocation{
    
    SEL selector = @selector(testArguments:args2:);
    NSLog(@"selector encode type = %s", @encode(SEL));
    NSMethodSignature *signature = [self methodSignatureForSelector:selector];
    NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:signature];
    invocation.selector = selector;
    invocation.target = self;
    
    NSString *arg1 = @"1111";
    NSString *arg2 = @"2222";
    [invocation setArgument:&arg1 atIndex:2];
    [invocation setArgument:&arg2 atIndex:3];
    
    [invocation retainArguments];
    [invocation invoke];
    
    if (signature.methodReturnLength > 0) {
        NSString *returnValue = nil;
        [invocation getReturnValue:&returnValue];
        NSLog(@"return Vlaue = %@", returnValue);
        
    }
    
}

- (NSString *)testArguments:(NSString *)args1 args2:(NSString *)args2{
    NSLog(@"%@ - %@", args1, args2);
    return [NSString stringWithFormat:@"%@ - %@", args1, args2];
}

#pragma mark - Asynchrous
- (void)asyncMainQueue{
    // 0 2 1 3 主队列里只包含一个线程，遵循先进先出的逻辑，即使带有sleep，也遵循队列的顺序
    dispatch_async(dispatch_get_main_queue(), ^{
        
        dispatch_async(dispatch_get_main_queue(), ^{
            sleep(1);
            NSLog(@"1");
        });
        NSLog(@"2");
        dispatch_async(dispatch_get_main_queue(), ^{
            //sleep(1);
            NSLog(@"3");
        });
    });
    sleep(1);
    NSLog(@"0");
}

- (void)asyncGlobalQueue{
    //async thread  2 3 0 1  global_Queue 执行顺序与添加队列先后顺序无关，是随机顺序，当存在sleep时，带有sleep的后执行
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            //sleep(1);
            NSLog(@"async-1, current = %@", [NSThread currentThread]);
        });
        NSLog(@"async-2, current = %@", [NSThread currentThread]);
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            //sleep(1);
            NSLog(@"async-3, current = %@", [NSThread currentThread]);
        });
    });
    //sleep(1);
    NSLog(@"async-0, current = %@", [NSThread currentThread]);
}

- (void)asyncOperationQueue{
    //0 2 1 3 始终遵循先进先出的规律，默认是按照顺序执行的，通过设置依赖改变执行顺序
    NSOperationQueue *operationQueue = [[NSOperationQueue alloc] init];
    operationQueue.maxConcurrentOperationCount = 2;
    [operationQueue addOperationWithBlock:^{
        
        [operationQueue addOperationWithBlock:^{
            sleep(1);
            NSLog(@"operation-1, current = %@", [NSThread currentThread]);
        }];
        
        NSLog(@"operation-2, current = %@", [NSThread currentThread]);
        
        [operationQueue addOperationWithBlock:^{
            NSLog(@"operation-3, current = %@", [NSThread currentThread]);
        }];
    }];
    NSLog(@"operation-0, current = %@", [NSThread currentThread]);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (IBAction)onClickAsyncMainQueue:(id)sender {
    [self asyncMainQueue];
}

- (IBAction)onClickAsyncGlobalQueu:(id)sender {
    [self asyncGlobalQueue];
}

- (IBAction)onClickAsyncOperationQueue:(id)sender {
    [self asyncOperationQueue];
}


@end
