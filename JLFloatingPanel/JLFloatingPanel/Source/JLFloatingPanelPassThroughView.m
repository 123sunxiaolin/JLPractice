//
//  JLFloatingPanelPassThroughView.m
//  JLFloatingPanel
//
//  Created by Jacklin on 2019/12/28.
//  Copyright © 2019 Jacklin. All rights reserved.
//

#import "JLFloatingPanelPassThroughView.h"

@implementation JLFloatingPanelPassThroughView

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    UIView *hitView = [super hitTest:point withEvent:event];
    if (hitView == self) {
        return [self.eventForwardingView hitTest:point withEvent:event];
    }
    return hitView;
}

@end
