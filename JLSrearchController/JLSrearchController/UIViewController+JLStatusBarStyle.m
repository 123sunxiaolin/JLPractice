//
//  UIViewController+JLStatusBarStyle.m
//  JLSrearchController
//
//  Created by perfect on 2017/5/22.
//  Copyright © 2017年 JackLin. All rights reserved.
//

#import "UIViewController+JLStatusBarStyle.h"
#import <objc/runtime.h>

@implementation UIViewController (JLStatusBarStyle)
static const char * JKR_STATUS_BAR_LIGHT_KEY = "JKR_STATUS_LIGHT";

- (void)setJl_lightStatusBar:(BOOL)jkr_lightStatusBar {
    objc_setAssociatedObject(self, JKR_STATUS_BAR_LIGHT_KEY, [NSNumber numberWithInt:jkr_lightStatusBar], OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    [self preferredStatusBarStyle];
    [self setNeedsStatusBarAppearanceUpdate];
}

- (BOOL)jl_lightStatusBar {
    return objc_getAssociatedObject(self, JKR_STATUS_BAR_LIGHT_KEY) ? [objc_getAssociatedObject(self, JKR_STATUS_BAR_LIGHT_KEY) boolValue] : NO;
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return self.jl_lightStatusBar ? UIStatusBarStyleLightContent : UIStatusBarStyleDefault;
}

@end
