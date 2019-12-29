//
//  JLFloatingPanelSurfaceView.h
//  JLFloatingPanel
//
//  Created by Jacklin on 2019/12/28.
//  Copyright © 2019 Jacklin. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface JLFloatingPanelSurfaceContentView : UIView

@end

/*
 A view that presents a surface interface in a floating panel.
 */
@class JLGrabberHandleView;
@interface JLFloatingPanelSurfaceView : UIView

/// // Must not call setNeedsLayout()
@property (nonatomic, assign) CGFloat bottomOverflow;

/*
 The height of the grabber bar area
 */
@property (nonatomic, assign, readonly) CGFloat topGrabberBarHeight;

/*
 A GrabberHandleView object displayed at the top of the surface view.
 
 To use a custom grabber handle, hide this and then add the custom one
 to the surface view at appropirate coordinates.
 */
@property (nonatomic, strong) JLGrabberHandleView *grabberHandleView;

/*
 A root view of a content view controller
 */
@property (nonatomic, weak) UIView *contentView;

/*
 The radius to use when drawing top rounded corners.
 */
@property (nonatomic, assign) CGFloat cornerRadius;

/*
 A Boolean indicating whether the surface shadow is displayed.
 */
@property (nonatomic, assign) BOOL shadowHidden;

/*
 The color of the surface shadow.
 */
@property (nonatomic, strong) UIColor *shadowColor;

/*
 The offset (in points) of the surface shadow.
 */
@property (nonatomic, assign) CGSize shadowOffset;

/*
 The opacity of the surface shadow.
 */
@property (nonatomic, assign) CGFloat shadowOpacity;

/*
 The blur radius (in points) used to render the surface shadow.
 */
@property (nonatomic, assign) CGFloat shadowRadius;

/*
 The color of the surface border.
 */
@property (nonatomic, strong) UIColor *borderColor;

/*
 The width of the surface border.
 */
@property (nonatomic, assign) CGFloat borderWidth;

- (void)addContentView:(UIView *)contentView;

@end

NS_ASSUME_NONNULL_END
