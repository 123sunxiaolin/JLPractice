//
//  JLFloatingPanelLayout.h
//  JLFloatingPanel
//
//  Created by Jacklin on 2019/12/28.
//  Copyright © 2019 Jacklin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "JLFloatingPanelPosition.h"

typedef NS_ENUM(NSInteger, JLFloatingPanelLayoutReference) {
    JLFloatingPanelLayoutReferenceFromSafeArea = 0,
    JLFloatingPanelLayoutReferenceFromSuperview
};

@protocol JLFloatingPanelLayout <NSObject>
@optional

/// Returns the initial position of a floating panel.
@property (nonatomic, assign, readonly) JLFloatingPanelPosition initialPostion;

///  Returns a set of FloatingPanelPosition objects to tell the applicable
///  positions of the floating panel controller.
///  By default, it returns full, half and tip positions.
@property (nonatomic, copy, readonly) NSSet<NSNumber *> * _Nullable supportedPositions;

/// Return the interaction buffer to the top from the top position. Default is 6.0.
@property (nonatomic, assign, readonly) CGFloat topInteractionBuffer;

/// Return the interaction buffer to the bottom from the bottom position. Default is 6.0.
///
/// - Important:
/// The specified buffer is ignored when `FloatingPanelController.isRemovalInteractionEnabled` is set to true.
@property (nonatomic, assign, readonly) CGFloat bottomInteractionBuffer;

@property (nonatomic, assign, readonly) JLFloatingPanelLayoutReference positionReference;

/// Returns a CGFloat value to determine a Y coordinate of a floating panel for each position(full, half, tip and hidden).
///
/// Its returning value indicates a different inset for each position.
/// For full position, a top inset from a safe area in `FloatingPanelController.view`.
/// For half or tip position, a bottom inset from the safe area.
/// For hidden position, a bottom inset from `FloatingPanelController.view`.
/// If a position isn't supported or the default value is used, return nil.
- (CGFloat)insetForPosition:(JLFloatingPanelPosition)position;

/// Returns X-axis and width layout constraints of the surface view of a floating panel.
/// You must not include any Y-axis and height layout constraints of the surface view
/// because their constraints will be configured by the floating panel controller.
/// By default, the width of a surface view fits a safe area.
- (NSArray<NSLayoutConstraint *> *_Nullable)prepareLayoutWithSurfaceView:(UIView *_Nullable)surfaceView
                                                                  inView:(UIView *_Nullable)view;
/// Returns a CGFloat value to determine the backdrop view's alpha for a position.
///
/// Default is 0.3 at full position, otherwise 0.0.
- (CGFloat)backdropAlphaForPosition:(JLFloatingPanelPosition)potision;
@end

/// FloatingPanelFullScreenLayout
///
/// Use the layout protocol if you configure full, half and tip insets from the superview, not the safe area.
/// It can't be used with FloatingPanelIntrinsicLayout.

@protocol JLFloatingPanelFullScreenLayout <JLFloatingPanelLayout>
@end

/// FloatingPanelIntrinsicLayout
///
/// Use the layout protocol if you want to layout a panel using the intrinsic height.
/// It can't be used with `FloatingPanelFullScreenLayout`.
///
/// - Attention:
///     `insetFor(position:)` must return `nil` for the full position. Because
///     the inset is determined automatically by the intrinsic height.
///     You can customize insets only for the half, tip and hidden positions.
///
/// - Note:
///     By default, the `positionReference` is set to `.fromSafeArea`.
@protocol JLFloatingPanelIntrinsicLayout <JLFloatingPanelLayout>
@end
