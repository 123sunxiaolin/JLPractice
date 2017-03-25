//
//  MainViewController.m
//  JLQrCodePractice
//
//  Created by JackLin on 2017/3/24.
//  Copyright © 2017年 JackLin. All rights reserved.
//

#import "MainViewController.h"
#import "JLScanViewController.h"

@interface MainViewController ()
@property (nonatomic, strong) UIButton *scanButton;
@end

@implementation MainViewController

#pragma mark - Life Cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"扫一扫";
    self.view.backgroundColor = [UIColor colorWithWhite:0.9 alpha:0.9];
    [self.view addSubview:self.scanButton];
}

- (void)viewDidLayoutSubviews{
    
    self.scanButton.frame = CGRectMake(0, 0, 100, 50);
    self.scanButton.center = self.view.center;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark - Getters
- (UIButton *)scanButton{
    if (!_scanButton) {
        _scanButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_scanButton setTitle:@"扫一扫" forState:UIControlStateNormal];
        [_scanButton setTitleColor:[UIColor orangeColor] forState:UIControlStateNormal];
        [_scanButton setBackgroundColor:[UIColor lightGrayColor]];
        [_scanButton addTarget:self
                        action:@selector(onClickScanButton:)
              forControlEvents:UIControlEventTouchUpInside];
        [_scanButton.layer setBorderWidth:2.0];
        [_scanButton.layer setCornerRadius:3.0];
        _scanButton.clipsToBounds = YES;
    }
    return _scanButton;
}
#pragma mark - Action
- (void)onClickScanButton:(UIButton *)sender{
    JLScanViewController *scanViewController = [[JLScanViewController alloc] init];
    [self.navigationController pushViewController:scanViewController animated:YES];
}
@end
