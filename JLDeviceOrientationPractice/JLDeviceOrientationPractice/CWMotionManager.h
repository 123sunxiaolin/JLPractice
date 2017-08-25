//
//  CWMotionManager.h
//  CubeWare
//
//  Created by perfect on 2017/8/21.
//  Copyright © 2017年 shixinyun. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

/**
 重力感应管理器
 */
@interface CWMotionManager : NSObject

/**
 单例
 */
+ (CWMotionManager *)defaultManager;

/**
 更新频率
 */
@property (nonatomic, assign) NSTimeInterval updateTimeInterval;

/**
 灵敏度
 */
@property (nonatomic, assign) CGFloat threshold;

/**
 开始更新设备的方向(1)
 */
- (void)startUpdateMotionWithCompletion:(void (^)(UIDeviceOrientation deviceOrientation))completion;

/**
  开始监测设备的方向(2)
 */
- (void)startMonitorDeviceOrientationWithCompletion:(void (^)(UIDeviceOrientation deviceOrientation))completion;

/**
 停止更新设备方向
 */
- (void)stopUpdate;

@end
