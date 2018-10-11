//
//  ViewController.m
//  TestRunloop
//
//  Created by 时信互联 on 2018/10/11.
//  Copyright © 2018年 Jacklin. All rights reserved.
//

#import "ViewController.h"
#import "RunloopSource.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    [self performSelector:@selector(signalSource)];
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)signalSource{
    
    RunloopSource *source = [[RunloopSource alloc] init];
    [source addToCurrentRunloop];
}





@end
