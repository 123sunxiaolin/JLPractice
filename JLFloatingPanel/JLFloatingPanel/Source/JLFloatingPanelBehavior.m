//
//  JLFloatingPanelBehavior.m
//  JLFloatingPanel
//
//  Created by Jacklin on 2019/12/28.
//  Copyright © 2019 Jacklin. All rights reserved.
//

#import "JLFloatingPanelBehavior.h"
#import "UIVIewExtension.h"

static CGFloat const kVelocityThreshold = 8.f;

@implementation JLFloatingPanelDefaultBehavior

- (BOOL)shouldProjectMomentumWithFpc:(JLFloatingPanelController *)fpc proposedTargetPosition:(JLFloatingPanelPosition)proposedTargetPosition {
    return NO;
}

- (CGFloat)momentumProjectionRateWithFpc:(JLFloatingPanelController *)fpc {
    return UIScrollViewDecelerationRateNormal;
}

- (CGFloat)redirectionalProgressWithFpc:(JLFloatingPanelController *)fpc fromPosition:(JLFloatingPanelPosition)fromPosition toPosition:(JLFloatingPanelPosition)toPosition {
    return 0.5;
}

- (UIViewPropertyAnimator *)interactionAnimatorWithFpc:(JLFloatingPanelController *)fpc targetPosition:(JLFloatingPanelPosition)targetPosition velocity:(CGVector)velocity  API_AVAILABLE(ios(10.0)){
    if (@available(iOS 10.0, *)) {
        UIViewPropertyAnimator *animator = [[UIViewPropertyAnimator alloc] initWithDuration:0
                                                                           timingParameters:[self timeingCurveWithVelocity:velocity]];
        animator.interruptible = NO; // Prevent a propagation of the animation(spring etc) to a content view
        return animator;
    }
    return nil;
}

- (UIViewPropertyAnimator *)addAnimatorWithFpc:(JLFloatingPanelController *)fpc toPosition:(JLFloatingPanelPosition)toPosition  API_AVAILABLE(ios(10.0)){
    return [[UIViewPropertyAnimator alloc] initWithDuration:0.25 curve:UIViewAnimationCurveEaseInOut animations:nil];
}

- (UIViewPropertyAnimator *)removeAnimatorWithFpc:(JLFloatingPanelController *)fpc fromPosition:(JLFloatingPanelPosition)fromPosition  API_AVAILABLE(ios(10.0)){
     return [[UIViewPropertyAnimator alloc] initWithDuration:0.25 curve:UIViewAnimationCurveEaseInOut animations:nil];
}

- (UIViewPropertyAnimator *)moveAnimatorWithFpc:(JLFloatingPanelController *)fpc fromPosition:(JLFloatingPanelPosition)fromPosition toPosition:(JLFloatingPanelPosition)toPosition  API_AVAILABLE(ios(10.0)){
    return [[UIViewPropertyAnimator alloc] initWithDuration:0.25 curve:UIViewAnimationCurveEaseInOut animations:nil];
}

- (CGFloat)removalVelocity {
    return 10.f;
}

- (CGFloat)removalProgress {
    return 0.5;
}

- (UIViewPropertyAnimator *)removalInteractionAnimatorWithFpc:(JLFloatingPanelController *)fpc velocity:(CGVector)velocity  API_AVAILABLE(ios(10.0)){
    NSLog(@"velocity = %@", NSStringFromCGVector(velocity));
    UISpringTimingParameters *timing = [[UISpringTimingParameters alloc] initWithDampingRatio:1.0 frequencyResponse:0.3 initialVelocity:velocity];
    return [[UIViewPropertyAnimator alloc] initWithDuration:0 timingParameters:timing];
}

#pragma mark - Private
- (id <UITimingCurveProvider>)timeingCurveWithVelocity:(CGVector)velocity {
    CGFloat damping = [self getDampingWithVelocity:velocity];
    if (@available(iOS 10.0, *)) {
        return [[UISpringTimingParameters alloc] initWithDampingRatio:damping
                                                    frequencyResponse:0.3
                                                      initialVelocity:velocity];
    } else {
        return nil;
    }
    
}

- (CGFloat)getDampingWithVelocity:(CGVector)velocity {
    return fabs(velocity.dy) > kVelocityThreshold ? 0.7 : 1.0;
}

@end
