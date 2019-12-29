//
//  JLFloatingPanelTransitioning.h
//  JLFloatingPanel
//
//  Created by Jacklin on 2019/12/29.
//  Copyright © 2019 Jacklin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface JLFloatingPanelTransitioning : NSObject
- (id <UIViewControllerAnimatedTransitioning>)animationControllerForPresentedViewController:(UIViewController *)presentedViewController
                                                                   presentingViewController:(UIViewController *)presentingViewController sourceViewController:(UIViewController *)sourceViewController;

- (id <UIViewControllerAnimatedTransitioning>)animationControllerForDismissedViewController:(UIViewController *)dismissedViewController;

- (UIPresentationController *)presentationControllerWithPresentedViewController:(UIViewController *)presentedViewController
                                                       presentingViewController:(UIViewController *)presentingViewController sourceViewController:(UIViewController *)sourceViewController;

@end

@interface JLFloatingPanelPresentationController : UIPresentationController

@end

@interface JLFloatingPanelModalPresentTransition : NSObject <UIViewControllerAnimatedTransitioning>

@end

@interface JLFloatingPanelModalDismissTransition : NSObject <UIViewControllerAnimatedTransitioning>

@end

NS_ASSUME_NONNULL_END
