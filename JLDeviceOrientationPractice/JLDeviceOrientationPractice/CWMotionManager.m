//
//  CWMotionManager.m
//  CubeWare
//
//  Created by perfect on 2017/8/21.
//  Copyright © 2017年 shixinyun. All rights reserved.
//

#import "CWMotionManager.h"
#import <CoreMotion/CoreMotion.h>

NSTimeInterval defaultTimeInterval(){
    return 2.f;
}

CGFloat dedfaultThreshold(){
    return 0.88;
}

@interface CWMotionManager()

/**
 重力感应设备管理器
 */
@property (nonatomic, strong)  CMMotionManager *motionManager;

/**
 当前设备方向
 */
@property (nonatomic, assign) UIDeviceOrientation currentDeviceOperation;

@end

@implementation CWMotionManager

+ (CWMotionManager *)defaultManager{
    
    static CWMotionManager *instance = nil;
    static dispatch_once_t predicate;
    dispatch_once(&predicate, ^{
        instance = [[self alloc] init];
    });
    return instance;
}

- (CMMotionManager *)motionManager{
    if (!_motionManager) {
        _motionManager = [[CMMotionManager alloc] init];
    }
    return _motionManager;
}

- (void)dealloc{
    self.motionManager = nil;
}

- (void)startUpdateMotionWithCompletion:(void (^)(UIDeviceOrientation))completion{
    
    if ([self.motionManager isAccelerometerAvailable]) {
        [self.motionManager setGyroUpdateInterval:self.updateTimeInterval ? self.updateTimeInterval : defaultTimeInterval()];
        [self.motionManager startAccelerometerUpdatesToQueue:[NSOperationQueue currentQueue] withHandler:^(CMAccelerometerData * _Nullable accelerometerData, NSError * _Nullable error) {
            if (error) {
                
                NSLog(@"motion error :%@", error);
                
            }else{
                
                double x = accelerometerData.acceleration.x;
                double y = accelerometerData.acceleration.y;
                
                if (fabs(y) >= fabs(x)){
                    if (y >= 0){
                        //Down
                        NSLog(@"motion -> down");
                        
                        if (completion) {
                            completion(UIDeviceOrientationPortraitUpsideDown);
                        }
                        
                    }
                    else{
                        //Portrait
                        
                         NSLog(@"motion -> Portrait");
                        
                        if (completion) {
                             completion(UIDeviceOrientationPortrait);
                        }
                        
                    }
                    
                }else{
                    
                    if (x >= 0){
                        //Right
                        
                        NSLog(@"motion -> Right");
                        
                        if (completion) {
                            completion(UIDeviceOrientationLandscapeRight);
                        }
                        
                    }else{
                        
                        //Left
                        NSLog(@"motion -> Left");
                        
                        if (completion) {
                            completion(UIDeviceOrientationLandscapeLeft);
                        }
                    }
                }
                
            }
        }];
        
    }
}

- (void)startMonitorDeviceOrientationWithCompletion:(void (^)(UIDeviceOrientation deviceOrientation))completion{
    
    if ([self.motionManager isDeviceMotionAvailable]) {
        
        [self.motionManager setGyroUpdateInterval:self.updateTimeInterval ? self.updateTimeInterval : defaultTimeInterval()];
        [self.motionManager startDeviceMotionUpdatesToQueue:[NSOperationQueue currentQueue] withHandler:^(CMDeviceMotion * _Nullable motion, NSError * _Nullable error) {
            
            if (error) {
                
                NSLog(@"motion error :%@", error);
                
            }else{
                
                double x = motion.gravity.x;
                double y = motion.gravity.y;
                CGFloat currentThreshold = self.threshold > 0 ? self.threshold : dedfaultThreshold();
                
                if (y < 0) {
                    
                    if (fabs(y) > currentThreshold) {
                        if (_currentDeviceOperation != UIDeviceOrientationPortrait) {
                            _currentDeviceOperation = UIDeviceOrientationPortrait;
                            
                            NSLog(@"motion -> Portrait");
                            
                            if (completion) {
                                completion(UIDeviceOrientationPortrait);
                            }
                        }
                    }
                }else{
                    
                    if (y > currentThreshold) {
                        if (_currentDeviceOperation != UIDeviceOrientationPortraitUpsideDown) {
                            _currentDeviceOperation = UIDeviceOrientationPortraitUpsideDown;
                            
                            //Down
                            NSLog(@"motion -> down");
                            
                            if (completion) {
                                completion(UIDeviceOrientationPortraitUpsideDown);
                            }
                        }
                    }
                }
                
                if (x < 0 ) {
                    if (fabs(x) > currentThreshold) {
                        if (_currentDeviceOperation != UIDeviceOrientationLandscapeLeft) {
                            _currentDeviceOperation = UIDeviceOrientationLandscapeLeft;
                            //Left
                            NSLog(@"motion -> Left");
                            
                            if (completion) {
                                completion(UIDeviceOrientationLandscapeLeft);
                            }
                        }
                    }
                }else{
                    if (x > currentThreshold){
                        
                        if (_currentDeviceOperation != UIDeviceOrientationLandscapeRight) {
                            _currentDeviceOperation = UIDeviceOrientationLandscapeRight;
                            
                            //Right
                            
                            NSLog(@"motion -> Right");
                            
                            if (completion) {
                                completion(UIDeviceOrientationLandscapeRight);
                            }
                            
                        }
                    }
                }
            }
        }];
        
    }
        
}

- (void)stopUpdate{
    
    if ([self.motionManager isAccelerometerActive]) {
        [self.motionManager stopAccelerometerUpdates];
    }
    
}

@end
