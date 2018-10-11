//
//  ViewController.m
//  JLRunTimePractice
//
//  Created by 时信互联 on 2018/9/21.
//  Copyright © 2018年 Jacklin. All rights reserved.
//

#import "ViewController.h"

@interface Father: NSObject
@property (nonatomic, strong) NSString *name;
@end

@implementation Father

@end

@interface Son: Father

@property (nonatomic, copy) NSArray *toys;

@end

@implementation Son

@end

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    {
        Son *son = [Son new];
        son.name = @"Sark";
        son.toys = @[@"1", @"2"];
        NSLog(@"1");
        
    }
    
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
