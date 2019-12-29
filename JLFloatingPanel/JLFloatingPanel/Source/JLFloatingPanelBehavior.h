//
//  JLFloatingPanelBehavior.h
//  JLFloatingPanel
//
//  Created by Jacklin on 2019/12/28.
//  Copyright © 2019 Jacklin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "JLFloatingPanelPosition.h"

NS_ASSUME_NONNULL_BEGIN

@class JLFloatingPanelController;
@protocol JLFloatingPanelBehavior <NSObject>
@optional

/// Asks the behavior if the floating panel should project a momentum of a user interaction to move the proposed position.
///
/// The default implementation of this method returns true. This method is called for a layout to support all positions(tip, half and full).
/// Therefore, `proposedTargetPosition` can only be `FloatingPanelPosition.tip` or `FloatingPanelPosition.full`.
- (BOOL)shouldProjectMomentumWithFpc:(JLFloatingPanelController *)fpc
              proposedTargetPosition:(JLFloatingPanelPosition)proposedTargetPosition;

/// Returns a deceleration rate to calculate a target position projected a dragging momentum.
///
/// The default implementation of this method returns the normal deceleration rate of UIScrollView.
- (CGFloat)momentumProjectionRateWithFpc:(JLFloatingPanelController *)fpc;

/// Returns the progress to redirect to the previous position.
///
/// The progress is represented by a floating-point value between 0.0 and 1.0, inclusive, where 1.0 indicates the floating panel is impossible to move to the next position. The default value is 0.5. Values less than 0.0 and greater than 1.0 are pinned to those limits.
- (CGFloat)redirectionalProgressWithFpc:(JLFloatingPanelController *)fpc
                           fromPosition:(JLFloatingPanelPosition)fromPosition
                             toPosition:(JLFloatingPanelPosition)toPosition;

/// Returns a UIViewPropertyAnimator object to project a floating panel to a position on finger up if the user dragged.
///
/// - Attention:
/// By default, it returns a non-interruptible animator to prevent a propagation of the animation to a content view.
/// However returning an interruptible animator is working well depending on a content view and it can be better
/// than using a non-interruptible one.
- (UIViewPropertyAnimator *)interactionAnimatorWithFpc:(JLFloatingPanelController *)fpc
                                        targetPosition:(JLFloatingPanelPosition)targetPosition
                                              velocity:(CGVector)velocity API_AVAILABLE(ios(10.0));

/// Returns a UIViewPropertyAnimator object to add a floating panel to a position.
///
/// Its animator instance will be used to animate the surface view in `FloatingPanelController.addPanel(toParent:belowView:animated:)`.
/// Default is an animator with ease-in-out curve and 0.25 sec duration.
- (UIViewPropertyAnimator *)addAnimatorWithFpc:(JLFloatingPanelController *)fpc
                                    toPosition:(JLFloatingPanelPosition)toPosition API_AVAILABLE(ios(10.0));

/// Returns a UIViewPropertyAnimator object to remove a floating panel from a position.
///
/// Its animator instance will be used to animate the surface view in `FloatingPanelController.removePanelFromParent(animated:completion:)`.
/// Default is an animator with ease-in-out curve and 0.25 sec duration.
- (UIViewPropertyAnimator *)removeAnimatorWithFpc:(JLFloatingPanelController *)fpc
                                     fromPosition:(JLFloatingPanelPosition)fromPosition API_AVAILABLE(ios(10.0));

/// Returns a UIViewPropertyAnimator object to move a floating panel from a position to a position.
///
/// Its animator instance will be used to animate the surface view in `FloatingPanelController.move(to:animated:completion:)`.
/// Default is an animator with ease-in-out curve and 0.25 sec duration.
- (UIViewPropertyAnimator *)moveAnimatorWithFpc:(JLFloatingPanelController *)fpc
                                   fromPosition:(JLFloatingPanelPosition)fromPosition
                                     toPosition:(JLFloatingPanelPosition)toPosition API_AVAILABLE(ios(10.0));

/// Asks the behavior whether the rubber band effect is enabled in moving over a given edge of the surface view.
///
/// This method allows the behavior to activate the rubber band effect to a given edge of the surface view. By default, the effect is disabled.
- (UIViewPropertyAnimator *)removalInteractionAnimatorWithFpc:(JLFloatingPanelController *)fpc
                                                     velocity:(CGVector)velocity API_AVAILABLE(ios(10.0));

/// Returns a y-axis velocity to invoke a removal interaction at the bottom position.
///
/// Default is 10.0. This method is called when FloatingPanelController.isRemovalInteractionEnabled is true.
@property (nonatomic, assign, readonly) CGFloat removalVelocity;

/// Returns the threshold of the transition to invoke a removal interaction at the bottom position.
///
/// The progress is represented by a floating-point value between 0.0 and 1.0, inclusive, where 1.0 indicates the floating panel is impossible to invoke the removal interaction. The default value is 0.5. Values less than 0.0 and greater than 1.0 are pinned to those limits. This method is called when FloatingPanelController.isRemovalInteractionEnabled is true.
@property (nonatomic, assign, readonly) CGFloat removalProgress;

/// Asks the behavior whether the rubber band effect is enabled in moving over a given edge of the surface view.
///
/// This method allows the behavior to activate the rubber band effect to a given edge of the surface view. By default, the effect is disabled.
- (BOOL)allowsRubberBandingWithRectEdge:(UIRectEdge)edge;

@end

@interface JLFloatingPanelDefaultBehavior : NSObject<JLFloatingPanelBehavior>

@end

NS_ASSUME_NONNULL_END
