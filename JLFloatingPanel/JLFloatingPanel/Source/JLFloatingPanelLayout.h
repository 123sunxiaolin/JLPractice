//
//  JLFloatingPanelLayout.h
//  JLFloatingPanel
//
//  Created by Jacklin on 2019/12/28.
//  Copyright © 2019 Jacklin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JLFloatingPanelLayoutProtocol.h"

NS_ASSUME_NONNULL_BEGIN

@interface JLLayoutSegment : NSObject

@property (nonatomic, strong) NSNumber *lower;
@property (nonatomic, strong) NSNumber *upper;

+ (instancetype)segmentWithLower:(NSNumber * __nullable)lower upper:(NSNumber  * __nullable)upper;

@end

@interface JLFloatingPanelDefaultLayout : NSObject <JLFloatingPanelLayout>

@end

@interface JLFloatingPanelDefaultLandscapeLayout : NSObject<JLFloatingPanelFullScreenLayout>

@end

@class JLFloatingPanelController,
JLFloatingPanelSurfaceView,
JLFloatingPanelBackdropView;
@protocol JLFloatingPanelBehavior;

@interface JLFloatingPanelLayoutAdapter : NSObject

@property (nonatomic, weak) id <JLFloatingPanelLayout> layout;
@property (nonatomic, weak) JLFloatingPanelController *panelController;
@property (nonatomic, assign, readonly) UIEdgeInsets adjustedContentInsets;

@property (nonatomic, assign, readonly) JLFloatingPanelPosition topMostState;
@property (nonatomic, assign, readonly) JLFloatingPanelPosition bottomMostState;

@property (nonatomic, assign, readonly) CGFloat topY;
@property (nonatomic, assign, readonly) CGFloat bottomY;
@property (nonatomic, assign, readonly) CGFloat topMaxY;
@property (nonatomic, assign, readonly) CGFloat bottomMaxY;

@property (nonatomic, copy, readonly) NSSet <NSNumber *>* supportedPositions;

- (void)updateHeight;
- (BOOL)isVaildWithPosition:(JLFloatingPanelPosition)position;
- (JLLayoutSegment *)segmentWithPosY:(CGFloat)posY forward:(BOOL)forward;

- (void)activateFixedLayout;
- (void)activateLayoutWithPosition:(JLFloatingPanelPosition)position;
- (void)activateInteractiveLayoutWithPosition:(JLFloatingPanelPosition)position;
- (void)prepareLayoutInViewController:(JLFloatingPanelController *)panelController;
- (CGFloat)positionYForPosition:(JLFloatingPanelPosition)position;
- (void)startInteractionWithState:(JLFloatingPanelPosition)position offSet:(CGPoint)offset;
- (void)endInteractionWithPosition:(JLFloatingPanelPosition)position;

- (void)updateInteractiveTopConstraintWithDiff:(CGFloat)diff
                               allowsTopBuffer:(BOOL)allowsTopBuffer
                                      behavior:(id <JLFloatingPanelBehavior>)behavior;

- (instancetype)initWithSurfaceView:(JLFloatingPanelSurfaceView *)surfaceView
                       backdropView:(JLFloatingPanelBackdropView *)backdropView
                             layout:(id <JLFloatingPanelLayout>)lauout;

@end

NS_ASSUME_NONNULL_END
