//
//  JLFloatingPanelCore.m
//  JLFloatingPanel
//
//  Created by Jacklin on 2019/12/29.
//  Copyright © 2019 Jacklin. All rights reserved.
//

#import "JLFloatingPanelCore.h"
#import "UIVIewExtension.h"
#import "JLFloatingPanelLayout.h"
#import "JLFloatingPanelSurfaceView.h"
#import "JLFloatingPanelBackdropView.h"
#import "JLFloatingPanelBehavior.h"
#import "JLFloatingPanelController.h"

@implementation JLFloatingPanelPanGestureRecognizer

- (id<UIGestureRecognizerDelegate>)delegate {
    return [super delegate];
}

- (void)setDelegate:(id<UIGestureRecognizerDelegate>)delegate {
    if (![delegate isKindOfClass:[JLFloatingPanelCore class]]) {
        NSException *exception = [NSException exceptionWithName:NSInvalidArgumentException
                                                         reason:@"FloatingPanelController's built-in pan gesture recognizer must have its controller as its delegate."
                                                       userInfo:nil];
        [exception raise];
        return;
    }
    super.delegate = delegate;
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [super touchesBegan:touches withEvent:event];
    if (self.floatingPanel.animator) {
        self.state = UIGestureRecognizerStateBegan;
    }
}

@end

@interface JLFloatingPanelCore()<UIGestureRecognizerDelegate>

@property (nonatomic, assign) CGRect initialFrame;
@property (nonatomic, assign) CGFloat initialTranslationY;
@property (nonatomic, assign) CGPoint initialLocation;

@property (nonatomic, assign) CGPoint initialScrollOffset;
@property (nonatomic, assign) BOOL stopScrollDeceleration;
@property (nonatomic, assign) BOOL scrollBouncable;
@property (nonatomic, assign) BOOL scrollIndictorVisible;

@property (nonatomic, assign, readonly) CGRect grabberAreaFrame;

@property (nonatomic, assign) BOOL disabledBottomAutoLayout;
@property (nonatomic, strong) NSMutableSet <NSLayoutConstraint *> *disabledAutoLayoutItems;

@end

@implementation JLFloatingPanelCore

#pragma mark - Life Cycle
- (instancetype)init {
    if (self = [super init]) {
        [self initializeValues];
    }
    return self;
}

#pragma mark - Public
- (instancetype)initWithFpc:(JLFloatingPanelController *)fpc layout:(id<JLFloatingPanelLayout>)layout behavior:(id<JLFloatingPanelBehavior>)behavior {
    if (self = [super init]) {
        [self initializeValues];
        
        self.viewcontroller = fpc;
        
        _surfaceView = [[JLFloatingPanelSurfaceView alloc] init];
        _surfaceView.backgroundColor = [UIColor whiteColor];
        
        _backdropView = [[JLFloatingPanelBackdropView alloc] init];
        _backdropView.backgroundColor = [UIColor blackColor];
        _backdropView.alpha = 0;
        
        self.layoutAdapter = [[JLFloatingPanelLayoutAdapter alloc] initWithSurfaceView:_surfaceView
                                                                          backdropView:_backdropView
                                                                                layout:layout];
        self.behavior = behavior;
        
        self.panGestureRecognizer = [[JLFloatingPanelPanGestureRecognizer alloc] init];
        if (@available(iOS 11.0, *)) {
            self.panGestureRecognizer.name = @"JLFloatingPanelSurface";
        }
        
        self.panGestureRecognizer.floatingPanel = self;
        [_surfaceView addGestureRecognizer:self.panGestureRecognizer];
        [self.panGestureRecognizer addTarget:self action:@selector(handlePanGesture:)];
        self.panGestureRecognizer.delegate = self;
        
        // Set tap-to-dismiss in the backdrop view
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleBackdropWithTapGesture:)];
        tap.enabled = NO;
        _backdropView.dismissalTapGestureRecognizer = tap;
        [_backdropView addGestureRecognizer:tap];
        
    }
    return self;
}

- (void)moveToPosition:(JLFloatingPanelPosition)position animated:(BOOL)animated completion:(dispatch_block_t)completion {
    [self moveFromPosition:self.state toPosition:position animated:animated completion:completion];
}

- (CGFloat)getBackdropAlphaAtCurrentY:(CGFloat)currentY translation:(CGPoint)translation {
    BOOL forwardY = translation.y > 0;
    JLLayoutSegment *segment = [self.layoutAdapter segmentWithPosY:currentY forward:forwardY];
    JLFloatingPanelPosition lowerPos = self.layoutAdapter.topMostState;
    if (segment.lower) {
        lowerPos = (JLFloatingPanelPosition)segment.lower.integerValue;
    }
    
    JLFloatingPanelPosition upperPos = self.layoutAdapter.bottomMostState;
    if (segment.upper) {
        upperPos = (JLFloatingPanelPosition)segment.upper.integerValue;
    }
    
    JLFloatingPanelPosition previous = forwardY ? lowerPos : upperPos;
    JLFloatingPanelPosition next = forwardY ? upperPos : lowerPos;
    
    CGFloat nextY = [self.layoutAdapter positionYForPosition:next];
    CGFloat previousY = [self.layoutAdapter positionYForPosition:previous];
    
    CGFloat nextAlpha = [self.layoutAdapter.layout backdropAlphaForPosition:next];
    CGFloat previosAlpha = [self.layoutAdapter.layout backdropAlphaForPosition:previous];
    
    if (previousY == next) {
        return previosAlpha;
    } else {
        return previosAlpha + MAX(MIN(1.0, 1.0 - (nextY - currentY) / (nextY - previousY) ), 0.0) * (nextAlpha - previosAlpha);
    }
}

#pragma mark - Private
- (void)initializeValues {
    self.state = JLFloatingPanelPositionHidden;
    self.isRemovalInteractionEnabled = NO;
    self.initialFrame = CGRectZero;
    self.initialTranslationY = 0;
    self.initialLocation = CGPointMake(CGFLOAT_MAX, CGFLOAT_MAX);
    
    self.interactionInProgress = NO;
    self.isDecelerating = NO;
    
    self.initialScrollOffset = CGPointZero;
    self.stopScrollDeceleration = NO;
    self.scrollBouncable = NO;
    self.scrollIndictorVisible = NO;
    
    self.disabledBottomAutoLayout = NO;
    self.disabledAutoLayoutItems = [NSMutableSet set];
    
    
}

- (void)moveFromPosition:(JLFloatingPanelPosition)fromPosition toPosition:(JLFloatingPanelPosition)toPosition animated:(BOOL)animated completion:(dispatch_block_t)completion {
    
    NSAssert([self.layoutAdapter isVaildWithPosition:toPosition], @"Can't move to '%@' position because it's not valid in the layout", @(toPosition));
    if (!self.viewcontroller) {
        if (completion) {
            completion();
        }
        return;
    }
    
    if (self.state != self.layoutAdapter.topMostState) {
        [self lockScrollView];
    }
    
    [self tearDownActiveInteraction];
    
    // need to adapt to lower version system
    if (animated) {
        if (@available(iOS 10.0, *)) {
            UIViewPropertyAnimator *animator;
            if (fromPosition == JLFloatingPanelPositionHidden) {
                animator = [self.behavior addAnimatorWithFpc:self.viewcontroller toPosition:toPosition];
            } else if (toPosition == JLFloatingPanelPositionHidden) {
                animator = [self.behavior removeAnimatorWithFpc:self.viewcontroller fromPosition:fromPosition];
            } else {
                animator = [self.behavior moveAnimatorWithFpc:self.viewcontroller fromPosition:fromPosition toPosition:toPosition];
            }
            __weak typeof(self) weakSelf = self;
            [animator addAnimations:^{
                weakSelf.state = toPosition;
                [weakSelf updateLayoutWithToPosition:toPosition];
            }];
            
            [animator addCompletion:^(UIViewAnimatingPosition finalPosition) {
                weakSelf.animator = nil;
                if (weakSelf.state == weakSelf.layoutAdapter.topMostState) {
                    [weakSelf unlockScrollView];
                } else {
                    [weakSelf lockScrollView];
                }
                if (completion) {
                    completion();
                }
            }];
            
            self.animator = animator;
            [animator startAnimation];
            
        } else {
            // Fallback on earlier versions
            // need to adapt to lower version system
#warning TODO --- 1
        }
    } else {
        self.state = toPosition;
        [self updateLayoutWithToPosition:toPosition];
        if (self.state == self.layoutAdapter.topMostState) {
            [self unlockScrollView];
        } else {
            [self lockScrollView];
        }
    }
    
    if (completion) {
        completion();
    }
}

- (void)lockScrollView {
    
}

- (void)unlockScrollView {
    
}

- (void)tearDownActiveInteraction {
    // Cancel the pan gesture so that panningEnd(with:velocity:) is called
    self.panGestureRecognizer.enabled = NO;
    self.panGestureRecognizer.enabled = YES;
}

- (BOOL)allowScrollPanGestureAtContentOffset:(CGPoint)contentOffset {
    if (self.state == self.layoutAdapter.topMostState) {
        return contentOffset.y <= -30.0 || contentOffset.y > 0;
    }
    return NO;
}

- (void)stopScrollingWithDecelerationAtContentOffset:(CGPoint)contentOffset {
    // Must use setContentOffset(_:animated) to force-stop deceleration
    [self.scrollView setContentOffset:contentOffset animated:NO];
}

- (JLFloatingPanelPosition)targetPositionFromCurrentY:(CGFloat)currentY velocity:(CGPoint)velocity {
    return JLFloatingPanelPositionHidden;
}

- (CGFloat)distanceToTargetPosition:(JLFloatingPanelPosition)targetPosition {
    CGFloat currentY = self.surfaceView.frame.origin.y;
    CGFloat targetY = [self.layoutAdapter positionYForPosition:targetPosition];
    return fabs(currentY - targetY);
}

- (BOOL)shouldStartRemovalAnimationWithVelocityVector:(CGVector)velocityVector {
    return NO;
}

- (void)startRemovalAnimationWithVC:(JLFloatingPanelController *)vc velocityVector:(CGVector)velocityVector completion:(dispatch_block_t)completion {
    
}

- (void)finishRemovalAnimation {
    
}

- (void)startAnimationToTargetPosition:(JLFloatingPanelPosition)targetPosition distance:(CGFloat)distance velocity:(CGPoint)velocity {
    
}

#pragma mark - Gesture Handler

- (BOOL)shouldScrollViewHandleTouchWithScrollView:(UIScrollView *)scrollView point:(CGPoint)point velocity:(CGPoint)velocity {
    // When no scrollView, nothing to handle.
    if (!self.scrollView) return NO;
    
    // For _UISwipeActionPanGestureRecognizer
    if (self.scrollView.gestureRecognizers) {
        for (UIGestureRecognizer *gesture in self.scrollView.gestureRecognizers) {
            @autoreleasepool {
                if (gesture.state == UIGestureRecognizerStateBegan
                    || gesture.state == UIGestureRecognizerStateChanged) {
                    if (gesture != self.scrollView.panGestureRecognizer) {
                        return YES;
                    }
                } else {
                    continue;
                }
            }
        }
    }
    
    if (!(self.state == self.layoutAdapter.topMostState // When not top most(i.e. .full), don't scroll.
         && !self.interactionInProgress                 // When interaction already in progress, don't scroll.
         && self.surfaceView.frame.origin.y == self.layoutAdapter.topY)) {
        return NO;
    }
    
    // When the current and initial point within grabber area, do scroll.
    if (CGRectContainsPoint(self.grabberAreaFrame, point)
        && !CGRectContainsPoint(self.grabberAreaFrame, self.initialLocation)) {
        return YES;
    }
    
    if (!(CGRectContainsPoint(self.grabberAreaFrame, self.initialLocation) // When initialLocation not in scrollView, don't scroll.
        && !CGRectContainsPoint(self.grabberAreaFrame, point))) {          // When point within grabber area, don't scroll.
        return NO;
    }
    
    CGFloat offset = self.scrollView.contentOffset.y - self.scrollView.contentOffsetZero.y;
    // The zero offset must be excluded because the offset is usually zero
    // after a panel moves from half/tip to full.
    if  (offset > 0.0) {
        return YES;
    }
    if (self.scrollView.isDecelerating) {
        return YES;
    }
    if (velocity.y <= 0) {
        return YES;
    }

    return NO;
}

- (void)panningBeganWithLocation:(CGPoint)location {
    // A user interaction does not always start from Began state of the pan gesture
    // because it can be recognized in scrolling a content in a content view controller.
    // So here just preserve the current state if needed.
    NSLog(@"panningBegan -- location =%f", location.y);
    
    self.initialLocation = location;

    if (self.scrollView) {
        if (self.state == self.layoutAdapter.topMostState) {
            if (CGRectContainsPoint(self.grabberAreaFrame, location)) {
                self.initialScrollOffset = self.scrollView.contentOffset;
            }
        } else {
            self.initialScrollOffset = self.scrollView.contentOffset;
        }
    }
}

- (void)panningChangeWithTranslation:(CGPoint)translation {
    
    NSLog(@"panningChange -- translation = %f", translation.y);
    CGFloat preY = self.surfaceView.frame.origin.y;
    CGFloat dy = translation.y - self.initialTranslationY;

    [self.layoutAdapter updateInteractiveTopConstraintWithDiff:dy
                                               allowsTopBuffer:[self allowsTopBufferForTranslationY:dy]
                                                      behavior:self.behavior];
    
    CGFloat currentY = self.surfaceView.frame.origin.y;
    self.backdropView.alpha = [self getBackdropAlphaAtCurrentY:currentY translation:translation];
    [self preserveContentVCLayoutIfNeeded];
    
    if (preY == currentY) return;
    if (self.viewcontroller) {
        if ([self.viewcontroller.delegate respondsToSelector:@selector(floatingPanelDidMoveWithFpc:)]) {
            [self.viewcontroller.delegate floatingPanelDidMoveWithFpc:self.viewcontroller];
        }
    }
}

- (void)panningEndWithTranslation:(CGPoint)translation velocity:(CGPoint)velocity {
    NSLog(@"panningEnd -- translation = %f, velocity = %f", translation.y, velocity.y);
    
    if (self.state == JLFloatingPanelPositionHidden) {
        NSLog(@"Already hidden");
        return;
    }
    
    // Projecting the dragging to the scroll dragging or not
    self.stopScrollDeceleration = self.surfaceView.frame.origin.y > (self.layoutAdapter.topY + (1.0 / self.surfaceView.traitCollection.displayScale));
    if (self.stopScrollDeceleration) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self stopScrollingWithDecelerationAtContentOffset:self.initialScrollOffset];
        });
    }
    
    CGFloat currentY = self.surfaceView.frame.origin.y;
    JLFloatingPanelPosition targetPosition = [self targetPositionFromCurrentY:currentY velocity:velocity];
    CGFloat distance = [self distanceToTargetPosition:targetPosition];
    
    [self endInteractionForTargetPosition:targetPosition];
    
    if (self.isRemovalInteractionEnabled && self.isBottomState) {
        CGVector velocityVector = (distance != 0) ? CGVectorMake(0, MIN(velocity.y/distance, self.behavior.removalVelocity)) : CGVectorMake(0, 0);
        // `velocityVector` will be replaced by just a velocity(not vector) when FloatingPanelRemovalInteraction will be added.
        if (self.viewcontroller && [self shouldStartRemovalAnimationWithVelocityVector:velocityVector]) {
            [self.viewcontroller.delegate floatingPanelDidEndDraggingToRemoveWithFpc:self.viewcontroller
                                                                            velocity:velocity];
            CGVector animationVector = CGVectorMake(fabsf(velocityVector.dx), fabsf(velocityVector.dy));
            __weak typeof(self) weakSelf = self;
            [self startRemovalAnimationWithVC:self.viewcontroller velocityVector:animationVector completion:^{
                [weakSelf finishRemovalAnimation];
            }];
            return;
        }
    }
    
    if (self.viewcontroller) {
        if ([self.viewcontroller.delegate respondsToSelector:@selector(floatingPanelDidEndDraggingWithFpc:velocity:targetPosition:)]) {
            [self.viewcontroller.delegate floatingPanelDidEndDraggingWithFpc:self.viewcontroller
                                                                    velocity:velocity
                                                              targetPosition:targetPosition];
        }
    }
    
    if (self.scrollView
        && !self.stopScrollDeceleration
        && self.surfaceView.frame.origin.y == self.layoutAdapter.topY
        && targetPosition == self.layoutAdapter.topMostState) {
        self.state = targetPosition;
        [self updateLayoutWithToPosition:targetPosition];
        [self unlockScrollView];
        return;
    }
    
    // Workaround: Disable a tracking scroll to prevent bouncing a scroll content in a panel animating
    BOOL isScrollEnabled = self.scrollView.isScrollEnabled;
    if (self.scrollView
        && targetPosition != JLFloatingPanelPositionFull) {
        self.scrollView.scrollEnabled = NO;
    }
    
    [self startAnimationToTargetPosition:targetPosition distance:distance velocity:velocity];
    
    if (self.scrollView
        && targetPosition != JLFloatingPanelPositionFull) {
        self.scrollView.scrollEnabled = isScrollEnabled;
    }
       
}


- (void)startInteractionWithTranslation:(CGPoint)translation location:(CGPoint)location {
    
}

- (void)endInteractionForTargetPosition:(JLFloatingPanelPosition)targetPosition {
    
}

- (BOOL)allowsTopBufferForTranslationY:(CGFloat)translationY {
    CGFloat preY = self.surfaceView.frame.origin.y;
    CGFloat nextY = self.initialFrame.origin.y + translationY;
    if (self.scrollView
        && self.scrollView.panGestureRecognizer.state == UIGestureRecognizerStateChanged
        && preY > 0
        && preY > nextY) {
        return NO;
    }
    return YES;
}

// Prevent stretching a view having a constraint to SafeArea.bottom in an overflow
// from the full position because SafeArea is global in a screen.
- (void)preserveContentVCLayoutIfNeeded {
    
    if (!self.viewcontroller
        || self.viewcontroller.contentMode == JLContentModeFitToBounds) {
        return;
    }
    
    // Must include topY
    if (self.surfaceView.frame.origin.y <= self.layoutAdapter.topY) {
        if (!self.disabledBottomAutoLayout) {
            [self.disabledAutoLayoutItems removeAllObjects];
            
            for (NSLayoutConstraint *constraint in self.viewcontroller.view.constraints) {
                @autoreleasepool {
                    id oneContraint = self.viewcontroller.layoutGuide.bottomAnchor;
                    if (@available(iOS 10.0, *)) {
                        if (oneContraint == constraint.firstAnchor) {
                            [(UIView *)constraint.secondItem disableAutoLayout];
                            constraint.active = NO;
                            [self.disabledAutoLayoutItems addObject:constraint];
                        } else if (oneContraint == constraint.secondAnchor) {
                            [(UIView *)constraint.firstItem disableAutoLayout];
                            constraint.active = NO;
                            [self.disabledAutoLayoutItems addObject:constraint];
                        } else {
                            break;
                        }
                    } else {
                        // Fallback on earlier versions
#pragma warning -- todo
                    }
                }
            }
        }
        self.disabledBottomAutoLayout = YES;
    } else {
        if (self.disabledBottomAutoLayout) {
            for (NSLayoutConstraint *constraint in self.disabledAutoLayoutItems) {
                @autoreleasepool {
                    id oneContraint = self.viewcontroller.layoutGuide.bottomAnchor;
                    if (@available(iOS 10.0, *)) {
                        if (oneContraint == constraint.firstAnchor) {
                            [(UIView *)constraint.secondItem enableAutoLayout];
                            constraint.active = YES;
                        } else if (oneContraint == constraint.secondAnchor) {
                            [(UIView *)constraint.firstItem enableAutoLayout];
                            constraint.active = YES;
                        } else {
                            break;
                        }
                    } else {
                        // Fallback on earlier versions
#pragma warning -- todo
                    }
                }
            }
            [self.disabledAutoLayoutItems removeAllObjects];
        }
        self.disabledBottomAutoLayout = YES;
    }
}


#pragma mark - Layout update
- (void)updateLayoutWithToPosition:(JLFloatingPanelPosition)position {
    [self.layoutAdapter activateFixedLayout];
    [self.layoutAdapter activateLayoutWithPosition:position];
}

#pragma mark - Action
- (void)handlePanGesture:(UIPanGestureRecognizer *)panGesture {
    CGPoint velocity = [panGesture velocityInView:panGesture.view];
    
    if (panGesture == self.scrollView.panGestureRecognizer) {
        if (!self.scrollView) return;
        CGPoint location = [panGesture locationInView:self.surfaceView];
        
        CGFloat surfaceMinY = self.surfaceView.presentationFrame.origin.y;
        CGFloat adapterTopY = self.layoutAdapter.topY;
        BOOL belowTop = surfaceMinY > (adapterTopY + (1.0 / self.surfaceView.traitCollection.displayScale));
        CGFloat offset = self.scrollView.contentOffset.y - self.scrollView.contentOffsetZero.y;
        
        NSLog(@"scroll gesture(\(%@):\(%ld)) --belowTop = %d, interactionInProgress = %d,scroll offset = %f,location = %@, velocity = %@", @(self.state), (long)panGesture.state, belowTop, self.interactionInProgress, offset, NSStringFromCGPoint(location), NSStringFromCGPoint(velocity));
        
        if (belowTop) {
            // Scroll offset pinning
            if (self.state == self.layoutAdapter.topMostState) {
                if (self.interactionInProgress) {
                    NSLog(@"settle offset -- %f", self.initialScrollOffset.y);
                    [self.scrollView setContentOffset:self.initialScrollOffset animated:NO];
                } else {
                    if (CGRectContainsPoint([self grabberAreaFrame], location)) {
                        // Preserve the current content offset in moving from full.
                        [self.scrollView setContentOffset:self.initialScrollOffset animated:NO];
                    }
                }
            } else {
                [self.scrollView setContentOffset:self.initialScrollOffset animated:NO];
            }
            
            // Hide a scroll indicator at the non-top in dragging.
            if (self.interactionInProgress) {
                [self lockScrollView];
            } else {
                if (self.state == self.layoutAdapter.topMostState
                    && self.animator == nil
                    && offset > 0 && velocity.y < 0) {
                    [self unlockScrollView];
                }
            }
        } else {
            if (self.interactionInProgress) {
                // Show a scroll indicator at the top in dragging.
                if (offset >= 0 && velocity.y <= 0) {
                    [self unlockScrollView];
                } else {
                    if (self.state == self.layoutAdapter.topMostState) {
                        // Adjust a small gap of the scroll offset just after swiping down starts in the grabber area.
                        if (CGRectContainsPoint(self.grabberAreaFrame, location)
                            && CGRectContainsPoint(self.grabberAreaFrame, self.initialLocation)) {
                            [self.scrollView setContentOffset:self.initialScrollOffset animated:NO];
                        }
                    }
                }
            } else {
                if (self.state == self.layoutAdapter.topMostState) {
                    // Hide a scroll indicator just before starting an interaction by swiping a panel down.
                    if (velocity.y > 0 && ![self allowScrollPanGestureAtContentOffset:CGPointMake(0, offset)]) {
                        [self lockScrollView];
                    }
                    
                    // Show a scroll indicator when an animation is interrupted at the top and content is scrolled up
                    if (velocity.y < 0 && [self allowScrollPanGestureAtContentOffset:CGPointMake(0, offset)]) {
                        [self lockScrollView];
                    }
                    
                    // Adjust a small gap of the scroll offset just before swiping down starts in the grabber area,
                    if (CGRectContainsPoint(self.grabberAreaFrame, location) && CGRectContainsPoint(self.grabberAreaFrame, self.initialLocation)) {
                        [self.scrollView setContentOffset:self.initialScrollOffset animated:NO];
                    }
                }
            }
        }
        
    } else if (self.panGestureRecognizer == panGesture) {
        CGPoint translation = [panGesture translationInView:panGesture.view.superview];
        CGPoint location = [panGesture locationInView:panGesture.view];
        
        if (!self.interactionInProgress
            && !self.isDecelerating
            && ![self.viewcontroller.delegate floatingPanelShouldBeginDraggingWithFpc:self.viewcontroller]) {
            return;
        }
        
        if (self.animator) {
            if (self.surfaceView.presentationFrame.origin.y < self.layoutAdapter.topMaxY) return;
            if (self.animator.interruptible) {
                [self.animator stopAnimation:NO];
                // A user can stop a panel at the nearest Y of a target position so this fine-tunes
                // the a small gap between the presentation layer frame and model layer frame
                // to unlock scroll view properly at finishAnimation(at:)
                if (fabs(self.surfaceView.frame.origin.y - self.layoutAdapter.topY) <= 1.0) {
                    CGRect rect = self.surfaceView.frame;
                    rect.origin.y = self.layoutAdapter.topY;
                    self.surfaceView.frame = rect;
                }
                if (@available(iOS 10.0, *)) {
                    [self.animator finishAnimationAtPosition:UIViewAnimatingPositionCurrent];
                } else {
                    // Fallback on earlier versions
                }
            } else {
                self.animator = nil;
            }
        }
        
        if (self.panGestureRecognizer.state == UIGestureRecognizerStateBegan) {
            [self panningBeganWithLocation:location];
            return;
        }
        
        if ([self shouldScrollViewHandleTouchWithScrollView:self.scrollView point:location velocity:velocity]) {
            return;
        }
        
        switch (panGesture.state) {
            case UIGestureRecognizerStateChanged:
                if (!self.interactionInProgress) {
                    [self startInteractionWithTranslation:translation location:location];
                }
                [self panningChangeWithTranslation:translation];
                break;
            case UIGestureRecognizerStateEnded:
            case UIGestureRecognizerStateCancelled:
            case UIGestureRecognizerStateFailed:
                if (!self.interactionInProgress) {
                    [self startInteractionWithTranslation:translation location:location];
                    // Workaround: Prevent stopping the surface view b/w anchors if the pan gesture
                    // doesn't pass through .changed state after an interruptible animator is interrupted.
                    
                    // CGFloat.leastNormalMagnitude
                    CGFloat dy = translation.y - 0;
                    [self.layoutAdapter updateInteractiveTopConstraintWithDiff:dy
                                                               allowsTopBuffer:YES
                                                                      behavior:self.behavior];
                }
                [self panningEndWithTranslation:translation velocity:velocity];
                break;
            default:
                break;
        }
    }
    
    
}

- (void)handleBackdropWithTapGesture:(UITapGestureRecognizer *)tapGesture {
    __weak typeof(self) weakSelf = self;
    [self.viewcontroller dismissViewControllerAnimated:YES completion:^{
        if (weakSelf.viewcontroller) {
            [weakSelf.viewcontroller.delegate floatingPanelDidEndRemoveWithFpc:self.viewcontroller];
        }
    }];
}

#pragma mark - Getters
- (BOOL)isBottomState {
    NSInteger count = 0;
    for (NSNumber *num in self.layoutAdapter.supportedPositions) {
        @autoreleasepool {
            if (num.integerValue > (NSInteger)self.state) {
                count ++;
            }
        }
    }
    return count == 0;
}

- (CGRect)grabberAreaFrame {
    
    CGRect rect = CGRectMake(self.surfaceView.bounds.origin.x,
                             self.surfaceView.bounds.origin.y, self.surfaceView.bounds.size.width, self.surfaceView.topGrabberBarHeight * 2);
    return rect;
}

#pragma mark - UIGestureRecognizerDelegate
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    if (self.panGestureRecognizer != gestureRecognizer) return NO;
    
    if (self.viewcontroller) {
        if ([self.viewcontroller.delegate respondsToSelector:@selector(floatingPanelWithFpc:shouldRecognizeSimultaneouslyWithOtherGestureRecognizer:)]) {
            return [self.viewcontroller.delegate floatingPanelWithFpc:self.viewcontroller
            shouldRecognizeSimultaneouslyWithOtherGestureRecognizer:otherGestureRecognizer];
        } else {
            return NO;
        }
    }
    
    if ([otherGestureRecognizer isKindOfClass:[UIPanGestureRecognizer class]]
        || [otherGestureRecognizer isKindOfClass:[UISwipeGestureRecognizer class]]
        || [otherGestureRecognizer isKindOfClass:[UIRotationGestureRecognizer class]]
        || [otherGestureRecognizer isKindOfClass:[UIScreenEdgePanGestureRecognizer class]]
        || [otherGestureRecognizer isKindOfClass:[UIPinchGestureRecognizer class]]) {
        // all gestures of the tracking scroll view should be recognized in parallel
        // and handle them in self.handle(panGesture:)
        return [self.scrollView.gestureRecognizers containsObject:otherGestureRecognizer];
    } else {
        // Should recognize tap/long press gestures in parallel when the surface view is at an anchor position.
        CGRect surfaceFrame = CGRectIsNull(self.surfaceView.layer.presentationLayer.frame) ? self.surfaceView.frame : self.surfaceView.layer.presentationLayer.frame;
        CGFloat surfaceY = surfaceFrame.origin.y;
        CGFloat adapterY = [self.layoutAdapter positionYForPosition:self.state];
        return fabs(surfaceY - adapterY) < (1.0 / self.surfaceView.traitCollection.displayScale);
    }
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldBeRequiredToFailByGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    /* log.debug("shouldBeRequiredToFailBy", otherGestureRecognizer) */
    if (self.panGestureRecognizer != gestureRecognizer) return NO;
    
    return NO;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRequireFailureOfGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    if (self.panGestureRecognizer != gestureRecognizer) return NO;
    
    // Should begin the pan gesture without waiting for the tracking scroll view's gestures.
    // `scrollView.gestureRecognizers` can contains the following gestures
    // * UIScrollViewDelayedTouchesBeganGestureRecognizer
    // * UIScrollViewPanGestureRecognizer (scrollView.panGestureRecognizer)
    // * _UIDragAutoScrollGestureRecognizer
    // * _UISwipeActionPanGestureRecognizer
    // * UISwipeDismissalGestureRecognizer
    
    if (self.scrollView) {
        // On short contents scroll, `_UISwipeActionPanGestureRecognizer` blocks
        // the panel's pan gesture if not returns false
        if ([self.scrollView.gestureRecognizers containsObject:otherGestureRecognizer]) {
            if (self.scrollView.panGestureRecognizer == otherGestureRecognizer) {
                CGFloat offset = self.scrollView.contentOffset.y - [self.scrollView contentOffsetZero].y;
                return [self allowScrollPanGestureAtContentOffset:CGPointMake(0, offset)];
            } else {
                return NO;
            }
        }
    }
    
    if (self.viewcontroller) {
        if ([self.viewcontroller.delegate respondsToSelector:@selector(gestureRecognizer:shouldRecognizeSimultaneouslyWithGestureRecognizer:)]) {
            return [self.viewcontroller.delegate floatingPanelWithFpc:self.viewcontroller shouldRecognizeSimultaneouslyWithOtherGestureRecognizer:otherGestureRecognizer];
        }
        return NO;
    }
    
    if ([otherGestureRecognizer isKindOfClass:[UIPanGestureRecognizer class]]
    || [otherGestureRecognizer isKindOfClass:[UISwipeGestureRecognizer class]]
    || [otherGestureRecognizer isKindOfClass:[UIRotationGestureRecognizer class]]
    || [otherGestureRecognizer isKindOfClass:[UIScreenEdgePanGestureRecognizer class]]
        || [otherGestureRecognizer isKindOfClass:[UIPinchGestureRecognizer class]]) {
        // Do not begin the pan gesture until these gestures fail
        return YES;
    } else {
        // Should begin the pan gesture without waiting tap/long press gestures fail
        return NO;
    }
}

@end

