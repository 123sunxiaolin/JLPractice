//
//  ViewController.m
//  JLDeviceOrientationPractice
//
//  Created by perfect on 2017/8/22.
//  Copyright © 2017年 JackLin. All rights reserved.
//

#import "ViewController.h"
#import "CWMotionManager.h"

#define UIScreenWidth [UIScreen mainScreen].bounds.size.width
#define UIScreenHeight [UIScreen mainScreen].bounds.size.height

@interface ViewController ()

@property (nonatomic, strong) UIView *testDeviceorientationView;

/**
 记录当前设备的方向
 */
@property (nonatomic, assign) UIDeviceOrientation currentOrientation;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.testDeviceorientationView.center = self.view.center;
    [self.view addSubview:self.testDeviceorientationView];
    
    _currentOrientation = UIDeviceOrientationPortrait;
    
    //开启设备监听
    [self p_startUpdateDevice];

}

- (UIView *)testDeviceorientationView{
    if (!_testDeviceorientationView) {
        _testDeviceorientationView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, UIScreenWidth, 200)];
        _testDeviceorientationView.backgroundColor = [UIColor yellowColor];
        
        UILabel *topLabel = [[UILabel alloc] initWithFrame:CGRectMake(100, 0, 100, 20)];
        topLabel.text = @"上";
        topLabel.backgroundColor = [UIColor redColor];
        topLabel.textColor = [UIColor blueColor];
        [_testDeviceorientationView addSubview:topLabel];
        
        UILabel *leftLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 100, 100, 20)];
        leftLabel.text = @"左";
        leftLabel.backgroundColor = [UIColor redColor];
        leftLabel.textColor = [UIColor blueColor];
        [_testDeviceorientationView addSubview:leftLabel];
        
        UILabel *rightLabel = [[UILabel alloc] initWithFrame:CGRectMake(UIScreenWidth - 80, 100, 100, 20)];
        rightLabel.text = @"右";
        rightLabel.backgroundColor = [UIColor redColor];
        rightLabel.textColor = [UIColor blueColor];
        [_testDeviceorientationView addSubview:rightLabel];
        
        UILabel *bottomLabel = [[UILabel alloc] initWithFrame:CGRectMake(100, 200 - 30, 100, 20)];
        bottomLabel.text = @"下";
        bottomLabel.backgroundColor = [UIColor redColor];
        bottomLabel.textColor = [UIColor blueColor];
        [_testDeviceorientationView addSubview:bottomLabel];
        
    
    }
    return _testDeviceorientationView;
}

#pragma mark - Private
- (void)p_startUpdateDevice{
    
    [[CWMotionManager defaultManager] startMonitorDeviceOrientationWithCompletion:^(UIDeviceOrientation deviceOrientation) {
        if (_currentOrientation != deviceOrientation) {
            
            [self p_resetRemoteViewWithFromOrientation:_currentOrientation];
            _currentOrientation = deviceOrientation;
            
            [self p_setRemoteViewWithToOrientation:deviceOrientation];
        }
        
    }];
}

- (void)p_resetRemoteViewWithFromOrientation:(UIDeviceOrientation)orientation{
    
    CGAffineTransform transform;

    CGFloat originalWidth = CGRectGetWidth(self.testDeviceorientationView.bounds);
    CGFloat orignalHeight = CGRectGetHeight(self.testDeviceorientationView.bounds);
    UIView *remoteView = self.testDeviceorientationView;
    
    __block CGRect frame;
    
    switch (orientation) {
        case UIDeviceOrientationPortrait:{
            //Nothing
        }
            break;
        case UIDeviceOrientationPortraitUpsideDown:{
            
            transform = CGAffineTransformMakeRotation(M_PI);
            [UIView animateWithDuration:0.1 animations:^{
                [remoteView setTransform:transform];
            }];
            
        }
            break;
        case UIDeviceOrientationLandscapeLeft:{
            
            //计算公式：W1/H1 = H2/W2
            frame = CGRectMake(0, 0, UIScreenWidth, UIScreenWidth * originalWidth / orignalHeight);
            transform = CGAffineTransformMakeRotation(M_PI / 2);
            [UIView animateWithDuration:0.1 animations:^{
                [remoteView setTransform:transform];
                //remoteView.frame = frame;
                //remoteView.bounds = frame;
            }];
            
        }
            break;
        case UIDeviceOrientationLandscapeRight:{
            
            //计算公式：W1/H1 = H2/W2
            frame = CGRectMake(0, 0, UIScreenWidth, UIScreenWidth * originalWidth / orignalHeight);
            transform = CGAffineTransformMakeRotation(- M_PI / 2);
            [UIView animateWithDuration:0.1 animations:^{
                [remoteView setTransform:transform];
                //remoteView.bounds = frame;
            }];
        }
            break;
            
        default:
            //Nothing
            break;
    }
}

- (void)p_setRemoteViewWithToOrientation:(UIDeviceOrientation)orientation{
    
    //设置视图方向，默认是从Portrait开始旋转
    CGAffineTransform transform;
    UIView *remoteView = self.testDeviceorientationView;
    CGFloat originalWidth = CGRectGetWidth(remoteView.bounds);
    CGFloat orignalHeight = CGRectGetHeight(remoteView.bounds);
    __block CGRect frame;
    
    CGFloat ratio = MAX(originalWidth, orignalHeight) / MIN(originalWidth, orignalHeight);
    
    switch (orientation) {
        case UIDeviceOrientationPortrait:{
            
            //frame = CGRectMake(0, 0, UIScreenWidth, UIScreenWidth / originalWidth * orignalHeight);
            //[remoteView changeFrame:frame];
            //remoteView.center = self.view.center;
            
            transform = CGAffineTransformMakeRotation(0);
            
            [UIView animateWithDuration:0.1 animations:^{
                
                [remoteView setTransform:transform];
                
            } completion:^(BOOL finished) {
                
                
                frame = CGRectMake(0, 0, UIScreenWidth, UIScreenWidth / ratio);
                //[remoteView changeFrame:frame];
                //remoteView.bounds = frame;
                [remoteView setFrame:frame];
                remoteView.center = self.view.center;
            }];
            
        }
            break;
        case UIDeviceOrientationPortraitUpsideDown:{
            
            transform = CGAffineTransformMakeRotation(M_PI);
            
            [UIView animateWithDuration:0.1 animations:^{
                
                [remoteView setTransform:transform];
                
            } completion:^(BOOL finished) {
                
                
                frame = CGRectMake(0, 0, UIScreenWidth, UIScreenWidth / ratio);
                //[remoteView changeFrame:frame];
                //remoteView.bounds = frame;
                [remoteView setFrame:frame];
                remoteView.center = self.view.center;
            }];
            
        }
            break;
        case UIDeviceOrientationLandscapeLeft:{
            
            transform = CGAffineTransformMakeRotation(M_PI / 2);
            [UIView animateWithDuration:0.1 animations:^{
                
                [remoteView setTransform:transform];
                
            }completion:^(BOOL finished) {
                
                //计算公式：W1/H1 = H2/W2 求H2
                CGFloat height = MIN(UIScreenWidth * ratio, UIScreenHeight);
                frame = CGRectMake(0, 0, UIScreenWidth, height);
                //remoteView.bounds = frame;
                [remoteView setFrame:frame];
                remoteView.center = self.view.center;
                
            }];
            
        }
            break;
        case UIDeviceOrientationLandscapeRight:{
            
            transform = CGAffineTransformMakeRotation(- M_PI / 2);
            [UIView animateWithDuration:0.1 animations:^{
                
                [remoteView setTransform:transform];
                
            }completion:^(BOOL finished) {
                
                //计算公式：W1/H1 = H2/W2 求H2
                CGFloat height = MIN(UIScreenWidth * ratio, UIScreenHeight);
                frame = CGRectMake(0, 0, UIScreenWidth, height);
                [remoteView setFrame:frame];
                remoteView.center = self.view.center;
                
            }];
        }
            break;
            
        default:
            //Nothing
            break;
    }
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
