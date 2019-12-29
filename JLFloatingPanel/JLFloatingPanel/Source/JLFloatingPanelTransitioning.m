//
//  JLFloatingPanelTransitioning.m
//  JLFloatingPanel
//
//  Created by Jacklin on 2019/12/29.
//  Copyright © 2019 Jacklin. All rights reserved.
//

#import "JLFloatingPanelTransitioning.h"
#import "JLFloatingPanelController.h"
#import "JLFloatingPanelPassThroughView.h"
#import "JLFloatingPanelBackdropView.h"

@implementation JLFloatingPanelModalTransition

- (id<UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented presentingController:(UIViewController *)presenting sourceController:(UIViewController *)source {
    return [[JLFloatingPanelModalPresentTransition alloc] init];
}

- (id<UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed {
    return [[JLFloatingPanelModalDismissTransition alloc] init];
}

- (UIPresentationController *)presentationControllerWithPresentedViewController:(UIViewController *)presentedViewController presentingViewController:(UIViewController *)presentingViewController sourceViewController:(UIViewController *)sourceViewController {
    return [[JLFloatingPanelPresentationController alloc] initWithPresentedViewController:presentedViewController presentingViewController:presentingViewController];
}

@end

@implementation JLFloatingPanelPresentationController

- (void)presentationTransitionWillBegin {
    // Must call here even if duplicating on in containerViewWillLayoutSubviews()
    // Because it let the floating panel present correctly with the presentation animation
    [self addFloatingPanel];
}

- (void)presentationTransitionDidEnd:(BOOL)completed {
    // For non-animated presentation
    UIViewController *vc = self.presentedViewController;
    if ([vc isKindOfClass:[JLFloatingPanelController class]]
        && [(JLFloatingPanelController *)vc position] == JLFloatingPanelPositionHidden) {
        [(JLFloatingPanelController *)vc showWithAnimated:false completion:nil];
    }
}

- (void)dismissalTransitionDidEnd:(BOOL)completed {
    if ([self.presentedViewController isKindOfClass:[JLFloatingPanelController class]]) {
        JLFloatingPanelController *fpc = (JLFloatingPanelController *)self.presentedViewController;
        if (fpc.position != JLFloatingPanelPositionHidden) {
            [fpc hideWithAnimated:NO completion:nil];
        }
        if (fpc.view.superview) {
            [fpc.view removeFromSuperview];
        }
    }
}

- (void)containerViewWillLayoutSubviews {
    if (![self.presentedViewController isKindOfClass:[JLFloatingPanelController class]]) return;
    /*
     * Layout the views managed by `FloatingPanelController` here for the
     * sake of the presentation and dismissal modally from the controller.
     */
    [self addFloatingPanel];
    
    JLFloatingPanelController *fpc = (JLFloatingPanelController *)self.presentedViewController;
    // Forward touch events to the presenting view controller
    if ([fpc.view isKindOfClass:[JLFloatingPanelPassThroughView class]]) {
        JLFloatingPanelPassThroughView *ptView = (JLFloatingPanelPassThroughView *)fpc.view;
        ptView.eventForwardingView = self.presentingViewController.view;
    }
    fpc.backdropView.dismissalTapGestureRecognizer.enabled = YES;
}

#pragma mark - Private
- (void)addFloatingPanel {
    UIView *containerView = self.containerView;
    UIViewController *vc = self.presentedViewController;
    if (containerView
        && [vc isKindOfClass:[JLFloatingPanelController class]]) {
        JLFloatingPanelController *fpc = (JLFloatingPanelController *)vc;
        [containerView addSubview:fpc.view];
        fpc.view.frame = containerView.bounds;
        fpc.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    }
}

@end

@implementation JLFloatingPanelModalPresentTransition

- (NSTimeInterval)transitionDuration:(nullable id<UIViewControllerContextTransitioning>)transitionContext {
    UIViewController *vc = [transitionContext viewControllerForKey:UITransitionContextToViewKey];
    if (![vc isKindOfClass:[JLFloatingPanelController class]]) return 0;
    JLFloatingPanelController *fpc = (JLFloatingPanelController *)vc;
    if (@available(iOS 10.0, *)) {
        UIViewPropertyAnimator *animator = [fpc.behavior addAnimatorWithFpc:fpc toPosition:fpc.layout.initialPostion];
        return animator.duration;
    } else {
        return 0.25;
    }
}

- (void)animateTransition:(nonnull id<UIViewControllerContextTransitioning>)transitionContext {
    UIViewController *vc = [transitionContext viewControllerForKey:UITransitionContextToViewKey];
    if (![vc isKindOfClass:[JLFloatingPanelController class]]) return;
    JLFloatingPanelController *fpc = (JLFloatingPanelController *)vc;
    [fpc showWithAnimated:YES completion:^{
        [transitionContext completeTransition:!transitionContext.transitionWasCancelled];
    }];
}

@end

#pragma mark - Dismiss
@implementation JLFloatingPanelModalDismissTransition

- (NSTimeInterval)transitionDuration:(nullable id<UIViewControllerContextTransitioning>)transitionContext {
    UIViewController *vc = [transitionContext viewControllerForKey:UITransitionContextToViewKey];
    if (![vc isKindOfClass:[JLFloatingPanelController class]]) return 0;
    JLFloatingPanelController *fpc = (JLFloatingPanelController *)vc;
    if (@available(iOS 10.0, *)) {
        UIViewPropertyAnimator *animator = [fpc.behavior removeAnimatorWithFpc:fpc fromPosition:fpc.layout.initialPostion];
        return animator.duration;
    } else {
        return 0.25;
    }
}

- (void)animateTransition:(nonnull id<UIViewControllerContextTransitioning>)transitionContext {
    UIViewController *vc = [transitionContext viewControllerForKey:UITransitionContextToViewKey];
    if (![vc isKindOfClass:[JLFloatingPanelController class]]) return;
    JLFloatingPanelController *fpc = (JLFloatingPanelController *)vc;
    [fpc hideWithAnimated:YES completion:^{
        [transitionContext completeTransition:!transitionContext.transitionWasCancelled];
    }];
}

@end


