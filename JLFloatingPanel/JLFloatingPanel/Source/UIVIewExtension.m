//
//  UIVIewExtension.m
//  JLFloatingPanel
//
//  Created by Jacklin on 2019/12/28.
//  Copyright © 2019 Jacklin. All rights reserved.
//

#import "UIVIewExtension.h"

@implementation UIVIewExtension

@end


@implementation JLLayoutGuide {
    id _top;
    id _bottom;
}

- (instancetype)initWithTop:(id)top bottom:(id)bottom {
    if (self = [super init]) {
        _top = top;
        _bottom = bottom;
    }
    return self;
}

- (id)topAnchor {
    return _top;
}

- (id)bottomAnchor {
    return _bottom;
}

@end

@implementation UIViewController (Extension)

- (UIEdgeInsets)layoutInsets {
    if (@available(iOS 11.0, *)) {
        return self.view.safeAreaInsets;
    } else {
        return UIEdgeInsetsMake(self.topLayoutGuide.length,
                                0,
                                self.bottomLayoutGuide.length,
                                0);
    }
}

- (JLLayoutGuide *)layoutGuide {
    if (@available(iOS 11.0, *)) {
        return [[JLLayoutGuide alloc] initWithTop:self.view.safeAreaLayoutGuide.topAnchor
                                           bottom:self.view.safeAreaLayoutGuide.bottomAnchor];
    } else {
        if (@available(iOS 9.0, *)) {
            return [[JLLayoutGuide alloc] initWithTop:self.topLayoutGuide.bottomAnchor
                                               bottom:self.bottomLayoutGuide.topAnchor];
        }
        return [[JLLayoutGuide alloc] initWithTop:self bottom:self];
    }
}

@end

@implementation UISpringTimingParameters (Extension)

- (instancetype)initWithDampingRatio:(CGFloat)dampingRatio
                   frequencyResponse:(CGFloat)frequencyResponse {
    return [self initWithDampingRatio:dampingRatio
                    frequencyResponse:frequencyResponse
                      initialVelocity:CGVectorMake(0, 0)];
}

- (instancetype)initWithDampingRatio:(CGFloat)dampingRatio
                   frequencyResponse:(CGFloat)frequencyResponse
                     initialVelocity:(CGVector)initialVelocity {
    CGFloat mass = 1.0;
    CGFloat stiffness = pow(2 * M_PI / frequencyResponse, 2) * mass;
    CGFloat damp = 4 * M_PI * dampingRatio * mass / frequencyResponse;
    return [self initWithMass:mass stiffness:stiffness damping:damp initialVelocity:initialVelocity];
}

@end


@implementation UITraitCollection (Extension)

- (BOOL)shouldUpdateLayoutWithPreviousCollection:(UITraitCollection *)previousCollection {
    return previousCollection.horizontalSizeClass != self.horizontalSizeClass
    || previousCollection.verticalSizeClass != self.verticalSizeClass
    || previousCollection.preferredContentSizeCategory != self.preferredContentSizeCategory
    || previousCollection.layoutDirection != self.layoutDirection;
}

@end
