//
//  JLFloatingPanelController.h
//  JLFloatingPanel
//
//  Created by Jacklin on 2019/12/28.
//  Copyright © 2019 Jacklin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JLFloatingPanelBehavior.h"
#import "JLFloatingPanelLayout.h"

NS_ASSUME_NONNULL_BEGIN

@class JLFloatingPanelController;
@protocol JLFloatingPanelControllerDelegate <NSObject>
@optional
// if it returns nil, FloatingPanelController uses the default layout
- (id <JLFloatingPanelLayout>)floatingPanelWithFpc:(JLFloatingPanelController *)fpc
                            layoutForNewCollection:(UITraitCollection *)newCollection;

// if it returns nil, FloatingPanelController uses the default behavior
- (id <JLFloatingPanelBehavior>)floatingPanelWithFpc:(JLFloatingPanelController *)fpc
                            behaviorForNewCollection:(UITraitCollection *)newCollection;

/// Called when the floating panel has changed to a new position. Can be called inside an animation block, so any
/// view properties set inside this function will be automatically animated alongside the panel.
- (void)floatingPanelDidChangePositionWithFpc:(JLFloatingPanelController *)fpc;

/// Asks the delegate if dragging should begin by the pan gesture recognizer.
- (BOOL)floatingPanelShouldBeginDraggingWithFpc:(JLFloatingPanelController *)fpc;


/// any surface frame changes in dragging
- (void)floatingPanelDidMoveWithFpc:(JLFloatingPanelController *)fpc;

// called on start of dragging (may require some time and or distance to move)
- (void)floatingPanelWillBeginDraggingWithFpc:(JLFloatingPanelController *)fpc;

// called on finger up if the user dragged. velocity is in points/second.
- (void)floatingPanelDidEndDraggingWithFpc:(JLFloatingPanelController *)fpc velocity:(CGPoint)velocity targetPosition:(JLFloatingPanelPosition)position;

/// called on finger up as we are moving
- (void)floatingPanelWillBeginDeceleratingWithFpc:(JLFloatingPanelController *)fpc;

/// called when scroll view grinds to a halt
- (void)floatingPanelDidEndDeceleratingWithFpc:(JLFloatingPanelController *)fpc;

// called on start of dragging to remove its views from a parent view controller
- (void)floatingPanelDidEndDraggingToRemoveWithFpc:(JLFloatingPanelController *)fpc velocity:(CGPoint)velocity;

// called when its views are removed from a parent view controller
- (void)floatingPanelDidEndRemoveWithFpc:(JLFloatingPanelController *)fpc;

/// Asks the delegate if the other gesture recognizer should be allowed to recognize the gesture in parallel.
///
/// By default, any tap and long gesture recognizers are allowed to recognize gestures simultaneously.
- (BOOL)floatingPanelWithFpc:(JLFloatingPanelController *)fpc
shouldRecognizeSimultaneouslyWithOtherGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer;

@end

// Constants indicating how safe area insets are added to the adjusted content inset.
typedef NS_ENUM(NSInteger, JLContentInsetAdjustmentBehavior) {
    JLContentInsetAdjustmentBehaviorAlways = 0,
    JLContentInsetAdjustmentBehaviorNever
};

/// A flag used to determine how the controller object lays out the content view when the surface position changes.
typedef NS_ENUM(NSInteger, JLContentMode) {
    /// The option to fix the content to keep the height of the top most position.
    JLContentModeStatic = 0,
    /// The option to scale the content to fit the bounds of the root view by changing the surface position.
    JLContentModeFitToBounds
};

@class JLFloatingPanelBackdropView, JLFloatingPanelSurfaceView;
@interface JLFloatingPanelController : UIViewController

/// The delegate of the floating panel controller object.
@property (nonatomic, weak) id<JLFloatingPanelControllerDelegate> delegate;

/// Returns the surface view managed by the controller object. It's the same as `self.view`.
@property (nonatomic, strong, readonly) JLFloatingPanelSurfaceView *surfaceView;

/// Returns the backdrop view managed by the controller object.
@property (nonatomic, strong, readonly) JLFloatingPanelBackdropView *backdropView;

/// Returns the scroll view that the controller tracks.
@property (nonatomic, weak, readonly) UIScrollView *scrollView;

// The underlying gesture recognizer for pan gestures
@property (nonatomic, strong, readonly) UIPanGestureRecognizer *panGestureRecognizer;

/// The current position of the floating panel controller's contents.
@property (nonatomic, assign, readonly) JLFloatingPanelPosition position;

/// The layout object managed by the controller
@property (nonatomic, strong, readonly) id <JLFloatingPanelLayout> layout;

/// The behavior object managed by the controller
@property (nonatomic, strong, readonly) id <JLFloatingPanelBehavior> behavior;

/// The content insets of the tracking scroll view derived from this safe area
@property (nonatomic, assign, readonly) UIEdgeInsets adjustedContentInsets;

/// The behavior for determining the adjusted content offsets.
///
/// This property specifies how the content area of the tracking scroll view is modified using `adjustedContentInsets`. The default value of this property is FloatingPanelController.ContentInsetAdjustmentBehavior.always.
@property (nonatomic, assign) JLContentInsetAdjustmentBehavior contentInsetAdjustmentBehavior;

/// A Boolean value that determines whether the removal interaction is enabled.
@property (nonatomic, assign) BOOL isRemovalInteractionEnabled;

/// The view controller responsible for the content portion of the floating panel.
@property (nonatomic, strong) UIViewController *contentViewController;

@property (nonatomic, assign) JLContentMode contentMode;

- (instancetype)initWithDelegate:(id <JLFloatingPanelControllerDelegate>)delegate;

/// Sets the view controller responsible for the content portion of the floating panel.
- (void)setContentVC:(UIViewController *)contentViewController;

/// Shows the surface view at the initial position defined by the current layout
- (void)showWithAnimated:(BOOL)animated completion:(dispatch_block_t __nullable)completion;

/// Hides the surface view to the hidden position
- (void)hideWithAnimated:(BOOL)animated completion:(dispatch_block_t __nullable)completion;

/// Adds the view managed by the controller as a child of the specified view controller.
/// - Parameters:
///     - parent: A parent view controller object that displays FloatingPanelController's view. A container view controller object isn't applicable.
///     - belowView: Insert the surface view managed by the controller below the specified view. By default, the surface view will be added to the end of the parent list of subviews.
///     - animated: Pass true to animate the presentation; otherwise, pass false.
- (void)addPanelToParentViewController:(UIViewController *)parent belowView:(UIView *)belowView animated:(BOOL)animated;

/// Removes the controller and the managed view from its parent view controller
/// - Parameters:
///     - animated: Pass true to animate the presentation; otherwise, pass false.
///     - completion: The block to execute after the view controller is dismissed. This block has no return value and takes no parameters. You may specify nil for this parameter.
- (void)removePanelFromParentViewController:(UIViewController *)parent animated:(BOOL)animated completion:(dispatch_block_t __nullable)completion;;

- (void)removePanelFromParentWithAnimated:(BOOL)animated completion:(dispatch_block_t __nullable)completion;

/// Moves the position to the specified position.
/// - Parameters:
///     - to: Pass a FloatingPanelPosition value to move the surface view to the position.
///     - animated: Pass true to animate the presentation; otherwise, pass false.
///     - completion: The block to execute after the view controller has finished moving. This block has no return value and takes no parameters. You may specify nil for this parameter.
- (void)moveToPosition:(JLFloatingPanelPosition)position animated:(BOOL)animated completion:(dispatch_block_t __nullable)completion;

/// Tracks the specified scroll view to correspond with the scroll.
///
/// - Parameters:
///     - scrollView: Specify a scroll view to continuously and seamlessly work in concert with interactions of the surface view or nil to cancel it.
- (void)trackWithScrollView:(UIScrollView *)scrollView;

/// Updates the layout object from the delegate and lays out the views managed
/// by the controller immediately.
///
/// This method updates the `FloatingPanelLayout` object from the delegate and
/// then it calls `layoutIfNeeded()` of the root view to force the view
/// to update the floating panel's layout immediately. It can be called in an
/// animation block.
- (void)updateLayout;

/// Returns the y-coordinate of the point at the origin of the surface view.
- (CGFloat)originYOfSurfaceForPosition:(JLFloatingPanelPosition)position;


@end

@interface UIViewController (Swizzing)

- (void)dismissSwizzling;

@end

NS_ASSUME_NONNULL_END
