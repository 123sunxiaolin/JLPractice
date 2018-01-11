//
//  ViewController.m
//  JLAssociatedObjectUtilsDemo
//
//  Created by perfect on 2018/1/10.
//  Copyright © 2018年 JackLin. All rights reserved.
//

#import "ViewController.h"
#import "JLAssociatedObjectUtils.h"

static NSString *const kJLActionHandlerTapGestureKey = @"JLActionHandlerTapGestureKey";
static NSString *const kJLActionHandlerTapBlockKey = @"JLActionHandlerTapBlocKey";

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

#pragma mark - For example
- (void)setTapActionWithBlock:(void (^)(void))block
{
    UITapGestureRecognizer *tapGR = [JLAssociatedObjectUtils JL_getAssociatedObject:self key:kJLActionHandlerTapGestureKey];
    
    if (!tapGR)
    {
        tapGR = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(JL_handleActionForTapGesture:)];
        [self.view addGestureRecognizer: tapGR];
        [JLAssociatedObjectUtils JL_setAssociatedObject:self key:kJLActionHandlerTapGestureKey value:tapGR policy:JLAssociationPolicyRetain];
    }

     [JLAssociatedObjectUtils JL_setAssociatedObject:self key:kJLActionHandlerTapBlockKey value:tapGR policy:JLAssociationPolicyCopy];
}

- (void) JL_handleActionForTapGesture:(UITapGestureRecognizer *)sender
{
    if (sender.state == UIGestureRecognizerStateRecognized)
    {
        void(^action)(void) = [JLAssociatedObjectUtils JL_getAssociatedObject:self key:kJLActionHandlerTapBlockKey];
        
        if (action)
        {
            action();
        }
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
