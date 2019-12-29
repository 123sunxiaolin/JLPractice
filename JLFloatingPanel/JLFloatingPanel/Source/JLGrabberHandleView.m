//
//  JLGrabberHandleView.m
//  JLFloatingPanel
//
//  Created by Jacklin on 2019/12/28.
//  Copyright © 2019 Jacklin. All rights reserved.
//

#import "JLGrabberHandleView.h"

CGFloat const GrabberHandleViewWidth = 36.f;
CGFloat const GrabberHandleViewHeight = 5.f;

@implementation JLGrabberHandleView

- (instancetype)init {
    if (self = [super init]) {
        self.frame = CGRectMake(0, 0, GrabberHandleViewWidth, GrabberHandleViewHeight);
        [self renderUI];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self renderUI];
    }
    return self;
}

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    UIView *hitTestView = [super hitTest:point withEvent:event];
    return hitTestView == self ? nil : hitTestView;
}

#pragma mark - Private
- (void)renderUI {
    self.backgroundColor = [UIColor colorWithRed:0.76 green:0.77 blue:0.76 alpha:1.0];
    self.layer.masksToBounds = YES;
    self.layer.cornerRadius = self.frame.size.height;
}

@end
