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

@interface JLFloatingPanelModalTransition : NSObject <UIViewControllerTransitioningDelegate>

@end

@interface JLFloatingPanelPresentationController : UIPresentationController

@end

@interface JLFloatingPanelModalPresentTransition : NSObject <UIViewControllerAnimatedTransitioning>

@end

@interface JLFloatingPanelModalDismissTransition : NSObject <UIViewControllerAnimatedTransitioning>

@end

NS_ASSUME_NONNULL_END
