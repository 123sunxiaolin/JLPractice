//
//  UIVIewExtension.h
//  JLFloatingPanel
//
//  Created by Jacklin on 2019/12/28.
//  Copyright © 2019 Jacklin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol JLLayoutGuideProvider <NSObject>
@optional

@property (nonatomic, strong, readonly) id topAnchor;
@property (nonatomic, strong, readonly) id bottomAnchor;

@end

@interface JLLayoutGuide : NSObject<JLLayoutGuideProvider>

- (instancetype)initWithTop:(id)top bottom:(id)bottom;

@end

@interface UIView (Extension)

- (CGRect)presentationFrame;
- (void)disableAutoLayout;
- (void)enableAutoLayout;

+ (void)performWithLinearWithStartTime:(NSTimeInterval)startTime
                      relativeDuration:(NSTimeInterval)relativeDuration
                            animations:(dispatch_block_t)animations;

@end

@interface UIViewController (Extension)

- (UIEdgeInsets)layoutInsets;
- (JLLayoutGuide *)layoutGuide;

@end

@interface UISpringTimingParameters (Extension)

- (instancetype)initWithDampingRatio:(CGFloat)dampingRatio
                   frequencyResponse:(CGFloat)frequencyResponse;

- (instancetype)initWithDampingRatio:(CGFloat)dampingRatio
                   frequencyResponse:(CGFloat)frequencyResponse
                     initialVelocity:(CGVector)initialVelocity;

@end

@interface UITraitCollection (Extension)

- (BOOL)shouldUpdateLayoutWithPreviousCollection:(UITraitCollection *)previousCollection;

@end

@interface UIScrollView (Extension)

- (CGPoint)contentOffsetZero;
- (BOOL)isLocked;

@end

@interface UIVIewExtension : NSObject

@end

NS_ASSUME_NONNULL_END
