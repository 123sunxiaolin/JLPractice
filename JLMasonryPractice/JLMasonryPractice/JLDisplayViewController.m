//
//  JLDisplayViewController.m
//  JLMasonryPractice
//
//  Created by perfect on 2017/3/17.
//  Copyright © 2017年 JackLin. All rights reserved.
//

#import "JLDisplayViewController.h"

@interface JLDisplayViewController ()
@property (nonatomic, strong) Class viewClass;
@end

@implementation JLDisplayViewController

- (instancetype)initWithTitle:(NSString *)title viewClass:(Class)viewClass{
    self = [super init];
    if (!self) {
        return nil;
    }
    self.title = title;
    self.viewClass = viewClass;
    return self;
}

- (void)loadView{
    self.view = [[self.viewClass alloc] init];
    self.view.backgroundColor = [UIColor whiteColor];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
