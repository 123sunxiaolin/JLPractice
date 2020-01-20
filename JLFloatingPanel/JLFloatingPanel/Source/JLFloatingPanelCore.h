//
//  JLFloatingPanelCore.h
//  JLFloatingPanel
//
//  Created by Jacklin on 2019/12/29.
//  Copyright © 2019 Jacklin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "JLFloatingPanelPosition.h"

NS_ASSUME_NONNULL_BEGIN

@class JLFloatingPanelCore;
@interface JLFloatingPanelPanGestureRecognizer : UIPanGestureRecognizer

@property (nonatomic, weak) JLFloatingPanelCore *floatingPanel;

@end

@class JLFloatingPanelLayoutAdapter,
       JLFloatingPanelController,
       JLFloatingPanelSurfaceView,
       JLFloatingPanelBackdropView,
       JLFloatingPanelController;

@protocol JLFloatingPanelBehavior, JLFloatingPanelLayout;
@interface JLFloatingPanelCore : NSObject

// MUST be a weak reference to prevent UI freeze on the presentation modally
@property (nonatomic, weak) JLFloatingPanelController *viewcontroller;

@property (nonatomic, strong, nullable) UIViewPropertyAnimator *animator API_AVAILABLE(ios(10.0));

@property (nonatomic, strong, readonly) JLFloatingPanelSurfaceView *surfaceView;
@property (nonatomic, strong, readonly) JLFloatingPanelBackdropView *backdropView;
@property (nonatomic, strong) JLFloatingPanelLayoutAdapter *layoutAdapter;
@property (nonatomic, strong) id <JLFloatingPanelBehavior> behavior;

@property (nonatomic, weak) UIScrollView *scrollView;
@property (nonatomic, assign) JLFloatingPanelPosition state;
@property (nonatomic, assign) BOOL isDecelerating;
@property (nonatomic, assign) BOOL interactionInProgress;
@property (nonatomic, assign) BOOL isRemovalInteractionEnabled;
@property (nonatomic, assign, readonly) BOOL isBottomState;

@property (nonatomic, strong) JLFloatingPanelPanGestureRecognizer *panGestureRecognizer;

- (instancetype)initWithFpc:(JLFloatingPanelController *)fpc
                     layout:(id <JLFloatingPanelLayout>)layout
                   behavior:(id <JLFloatingPanelBehavior>)behavior;

- (void)moveToPosition:(JLFloatingPanelPosition)position animated:(BOOL)animated completion:(dispatch_block_t _Nullable)completion;

@end



NS_ASSUME_NONNULL_END
