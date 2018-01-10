//
//  ViewController.m
//  JLUnitTest
//
//  Created by perfect on 2018/1/7.
//  Copyright © 2018年 JackLin. All rights reserved.
//

#import "ViewController.h"
#import "DALabeledCircularProgressView.h"

@interface ViewController ()

@property (strong, nonatomic) DALabeledCircularProgressView *progressView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    self.progressView = [[DALabeledCircularProgressView alloc] initWithFrame:CGRectMake(140.0f, 100.0f, 100.0f, 100.0f)];
    self.progressView.roundedCorners = YES;
    self.progressView.trackTintColor = [UIColor cyanColor];
    self.progressView.thicknessRatio = 0.1f;
    self.progressView.progressTintColor = [UIColor yellowColor];
    [self.view addSubview:self.progressView];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        CGFloat progress = 0.6f;
        self.progressView.indeterminate = YES;
        [self.progressView setProgress:progress animated:YES];
        self.progressView.progressLabel.text = [NSString stringWithFormat:@"%.2f", progress];
    });
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
