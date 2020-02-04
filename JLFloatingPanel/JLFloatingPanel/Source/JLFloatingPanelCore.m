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
    if (@available(iOS 10.0, *)) {
        if (self.floatingPanel.animator) {
            self.state = UIGestureRecognizerStateBegan;
        }
    } else {
        // Fallback on earlier versions
#pragma mark --TODO
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
    if (!self.scrollView) return;
    if (self.scrollView.isLocked) {
        NSLog(@"Already scroll locked.");
        return;
    }
     NSLog(@"lock scroll view");
    
    self.scrollBouncable = self.scrollView.bounces;
    self.scrollIndictorVisible = self.scrollView.showsVerticalScrollIndicator;
    
    self.scrollView.directionalLockEnabled = YES;
    self.scrollView.bounces = NO;
    self.scrollView.showsVerticalScrollIndicator = NO;
}

- (void)unlockScrollView {
    
    if (self.scrollView.isLocked) {
        NSLog(@"will unlock scroll view");
        self.scrollView.directionalLockEnabled = NO;
        self.scrollView.bounces = self.scrollBouncable;
        self.scrollView.showsVerticalScrollIndicator = self.scrollIndictorVisible;
    }
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
    if (!self.viewcontroller) return self.state;
    
    NSSet *supportedPositions = self.layoutAdapter.supportedPositions;
    if (supportedPositions.count <= 1) {
        return self.state;
    }
        
    NSArray *sourcePositions = [[NSArray alloc] initWithArray:supportedPositions.allObjects];
    NSArray *sortDesc = @[[[NSSortDescriptor alloc] initWithKey:nil ascending:YES]];
    NSArray *sortedPositions = [sourcePositions sortedArrayUsingDescriptors:sortDesc];
    
    // Projection
    CGFloat decelerationRate = [self.behavior momentumProjectionRateWithFpc:self.viewcontroller];
    CGFloat baseY = fabs([self.layoutAdapter positionYForPosition:self.layoutAdapter.bottomMostState] - [self.layoutAdapter positionYForPosition:self.layoutAdapter.topMostState]);
    CGFloat vecY = velocity.y / baseY;
    CGFloat pY = [self projectWithInitialVelocity:vecY decelerationRate:decelerationRate] * baseY + currentY;
    CGFloat forwardY = velocity.y == 0 ? (currentY - [self.layoutAdapter positionYForPosition:self.state] > 0) : velocity.y > 0;
    JLLayoutSegment *segment = [self.layoutAdapter segmentWithPosY:pY forward:forwardY];
    
    JLFloatingPanelPosition fromPos;
    JLFloatingPanelPosition toPos;
    
    JLFloatingPanelPosition lowerPos = (JLFloatingPanelPosition)[(segment.lower ? segment.lower : sortedPositions.firstObject) integerValue];
    JLFloatingPanelPosition upperPos = (JLFloatingPanelPosition)[(segment.upper ? segment.upper : sortedPositions.lastObject) integerValue];
    fromPos = forwardY ? lowerPos : upperPos;
    toPos = forwardY ? upperPos : lowerPos;
    
    if (![self.behavior shouldProjectMomentumWithFpc:self.viewcontroller proposedTargetPosition:toPos]) {
        JLLayoutSegment *oneSegment = [self.layoutAdapter segmentWithPosY:currentY forward:forwardY];
        JLFloatingPanelPosition lowerPos = (JLFloatingPanelPosition)[(oneSegment.lower ? oneSegment.lower : sortedPositions.firstObject) integerValue];
        JLFloatingPanelPosition upperPos = (JLFloatingPanelPosition)[(oneSegment.upper ? oneSegment.upper : sortedPositions.lastObject) integerValue];
        // Equate the segment out of {top,bottom} most state to the {top,bottom} most segment
        if (lowerPos == upperPos) {
            if (forwardY) {
                upperPos = [JLFloatingPanelPositionPresenter nextPositionWithPosition:lowerPos inPositions:sortedPositions];
            } else {
                lowerPos = [JLFloatingPanelPositionPresenter previousPositionWithPosition:upperPos inPositions:sortedPositions];
            }
        }
        fromPos = forwardY ? lowerPos : upperPos;
        toPos = forwardY ? upperPos : lowerPos;
        // Block a projection to a segment over the next from the current segment
        // (= Trim pY with the current segment)
        
        if (forwardY) {
            JLFloatingPanelPosition pos = [JLFloatingPanelPositionPresenter nextPositionWithPosition:toPos inPositions:sortedPositions];
            pY = MAX(MIN(pY, [self.layoutAdapter positionYForPosition:pos]), [self.layoutAdapter positionYForPosition:fromPos]);
        } else {
             JLFloatingPanelPosition pos = [JLFloatingPanelPositionPresenter previousPositionWithPosition:toPos inPositions:sortedPositions];
            pY = MAX(MIN(pY, [self.layoutAdapter positionYForPosition:fromPos]), [self.layoutAdapter positionYForPosition:pos]);
        }
    }
    
    // Redirection
    CGFloat redirectionalProgress = MAX(MIN([self.behavior redirectionalProgressWithFpc:self.viewcontroller fromPosition:fromPos toPosition:toPos], 1.0), 0);
    CGFloat progress = fabs(pY - [self.layoutAdapter positionYForPosition:fromPos]) / fabs([self.layoutAdapter positionYForPosition:fromPos] - [self.layoutAdapter positionYForPosition:toPos]);
    return progress > redirectionalProgress ? toPos : fromPos;
}

- (CGFloat)distanceToTargetPosition:(JLFloatingPanelPosition)targetPosition {
    CGFloat currentY = self.surfaceView.frame.origin.y;
    CGFloat targetY = [self.layoutAdapter positionYForPosition:targetPosition];
    return fabs(currentY - targetY);
}

// Distance travelled after decelerating to zero velocity at a constant rate.
// Refer to the slides p176 of [Designing Fluid Interfaces](https://developer.apple.com/videos/play/wwdc2018/803/)
- (CGFloat)projectWithInitialVelocity:(CGFloat)velocity decelerationRate:(CGFloat)rate {
    return (velocity / 1000.0) * rate / (1.0 - rate);
}

- (BOOL)shouldStartRemovalAnimationWithVelocityVector:(CGVector)velocityVector {
    CGFloat posY = [self.layoutAdapter positionYForPosition:self.state];
    CGFloat currentY = self.surfaceView.frame.origin.y;
    CGFloat hiddenY = [self.layoutAdapter positionYForPosition:JLFloatingPanelPositionHidden];
    CGFloat vth = self.behavior.removalVelocity;
    CGFloat pth = MAX(MIN(self.behavior.removalProgress, 1.0), 0.0);
    
    CGFloat num = currentY - posY;
    CGFloat den = hiddenY - posY;
    
    if (num >= 0
        && den != 0
        && (num / den >= pth || velocityVector.dy == vth)) {
        return YES;
    }
    return NO;
}

- (void)startRemovalAnimationWithVC:(JLFloatingPanelController *)vc velocityVector:(CGVector)velocityVector completion:(dispatch_block_t)completion {
    if (@available(iOS 10.0, *)) {
        UIViewPropertyAnimator *animator = [self.behavior removalInteractionAnimatorWithFpc:self.viewcontroller
                                                                                   velocity:velocityVector];
        [animator addAnimations:^{
            self.state = JLFloatingPanelPositionHidden;
            [self updateLayoutWithToPosition:JLFloatingPanelPositionHidden];
        }];
        
        [animator addCompletion:^(UIViewAnimatingPosition finalPosition) {
            self.animator = nil;
            if (completion) {
                completion();
            }
        }];
        self.animator = animator;
        [animator startAnimation];
        
    } else {
        // Fallback on earlier versions
#pragma mark - TODO
    }
}

- (void)finishRemovalAnimation {
    __weak typeof(self) weakSelf = self;
    [self.viewcontroller dismissViewControllerAnimated:NO completion:^{
        if (weakSelf.viewcontroller.delegate
            && [weakSelf.viewcontroller.delegate respondsToSelector:@selector(floatingPanelDidEndRemoveWithFpc:)]) {
            [weakSelf.viewcontroller.delegate floatingPanelDidEndRemoveWithFpc:weakSelf.viewcontroller];
        }
    }];
}

- (void)startAnimationToTargetPosition:(JLFloatingPanelPosition)targetPosition distance:(CGFloat)distance velocity:(CGPoint)velocity {
    NSLog(@"startAnimation to %@ -- distance = %f, velocity = %f", @(targetPosition), distance, velocity.y);
    if (!self.viewcontroller) return;
    
    self.isDecelerating = YES;
    
    if (self.viewcontroller.delegate
        && [self.viewcontroller.delegate respondsToSelector:@selector(floatingPanelWillBeginDeceleratingWithFpc:)]) {
        [self.viewcontroller.delegate floatingPanelWillBeginDeceleratingWithFpc:self.viewcontroller];
    }
    
    CGVector velocityVector = (distance != 0) ? CGVectorMake(0, fabs(velocity.y)/distance) : CGVectorMake(0, 0);
    if (@available(iOS 10.0, *)) {
        UIViewPropertyAnimator *animator = [self.behavior interactionAnimatorWithFpc:self.viewcontroller
                                                                      targetPosition:targetPosition
                                                                            velocity:velocityVector];
        __weak typeof(animator) weakAnimator = animator;
        [animator addAnimations:^{
            self.state = targetPosition;
            if (weakAnimator.isInterruptible) {
                if (self.viewcontroller.contentMode == JLContentModeFitToBounds) {
                    [UIView performWithLinearWithStartTime:0 relativeDuration:0.75 animations:^{
                        [self.layoutAdapter activateFixedLayout];
                        [self.surfaceView.superview layoutIfNeeded];
                    }];
                } else {
                    [self.layoutAdapter activateFixedLayout];
                }
            } else {
                [self.layoutAdapter activateFixedLayout];
            }
            [self.layoutAdapter activateLayoutWithPosition:targetPosition];
        }];
        
        [animator addCompletion:^(UIViewAnimatingPosition finalPosition) {
            // Prevent calling `finishAnimation(at:)` by the old animator whose `isInterruptive` is false
            // when a new animator has been started after the old one is interrupted.
            if (self.animator == weakAnimator) {
                [self endAnimationWithFinished:finalPosition == UIViewAnimatingPositionEnd];
            }
        }];
        self.animator = animator;
        [animator startAnimation];
        
    } else {
        // Fallback on earlier versions
#pragma mark - TODO ---
    }
}

- (void)endAnimationWithFinished:(BOOL)finished {
    self.isDecelerating = NO;
    if (@available(iOS 10.0, *)) {
        self.animator = nil;
    } else {
        // Fallback on earlier versions
    }
    
    if (self.viewcontroller.delegate
        && [self.viewcontroller.delegate respondsToSelector:@selector(floatingPanelDidEndDeceleratingWithFpc:)]) {
        [self.viewcontroller.delegate floatingPanelDidEndDeceleratingWithFpc:self.viewcontroller];
    }
    
    if (self.scrollView) {
        NSLog(@"finishAnimation -- scroll offset = %@", NSStringFromCGPoint(self.scrollView.contentOffset));
    }
    self.stopScrollDeceleration = NO;
    NSLog(@"finishAnimation -- state = %@ surface.minY = %f topY = %f", @(self.state), self.surfaceView.presentationFrame.origin.y, [self.layoutAdapter topY]);
    if (finished
        &&self.state == self.layoutAdapter.topMostState
        && fabs(self.surfaceView.presentationFrame.origin.y - self.layoutAdapter.topY) <= 1.0) {
        [self unlockScrollView];
    }
}


/// no-use，please use ·endAnimationWithFinished· to replace.
- (void)finishAnimationAtTargetPosition:(JLFloatingPanelPosition)targetPosition {
    NSLog(@"finishAnimation to %@", @(targetPosition));
    
    self.isDecelerating = NO;
    if (@available(iOS 10.0, *)) {
        self.animator = nil;
    } else {
        // Fallback on earlier versions
    }
    
    if (self.viewcontroller.delegate
        && [self.viewcontroller.delegate respondsToSelector:@selector(floatingPanelDidEndDeceleratingWithFpc:)]) {
        [self.viewcontroller.delegate floatingPanelDidEndDeceleratingWithFpc:self.viewcontroller];
    }
    
    if (self.scrollView) {
        NSLog(@"finishAnimation -- scroll offset = %@", NSStringFromCGPoint(self.scrollView.contentOffset));
    }
    self.stopScrollDeceleration = NO;
    NSLog(@"finishAnimation -- state = %@ surface.minY = %f topY = %f", @(self.state), self.surfaceView.presentationFrame.origin.y, [self.layoutAdapter topY]);
    if (self.state == self.layoutAdapter.topMostState
        && fabs(self.surfaceView.presentationFrame.origin.y - self.layoutAdapter.topY) <= 1.0) {
        [self unlockScrollView];
    }
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
            CGVector animationVector = CGVectorMake(fabs(velocityVector.dx), fabs(velocityVector.dy));
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
    /* Don't lock a scroll view to show a scroll indicator after hitting the top */
    NSLog(@"startInteraction  -- translation = %f, location = %f", translation.y, location.y);
    if (self.interactionInProgress) return;
    CGPoint offset = CGPointZero;
    
    self.initialFrame = self.surfaceView.frame;
    if (self.state == self.layoutAdapter.topMostState && self.scrollView) {
        if (CGRectContainsPoint(self.grabberAreaFrame, location)) {
            self.initialScrollOffset = self.scrollView.contentOffset;
        } else {
            self.initialScrollOffset = self.scrollView.contentOffsetZero;
            // Fit the surface bounds to a scroll offset content by startInteraction(at:offset:)
            CGFloat scrollOffsetY = self.scrollView.contentOffset.y - self.scrollView.contentOffsetZero.y;
            if (scrollOffsetY < 0) {
                offset = CGPointMake(-self.scrollView.contentOffset.x, -scrollOffsetY);
            }
        }
        NSLog(@"initial scroll offset --%@", NSStringFromCGPoint(self.initialScrollOffset));
    }
    self.initialTranslationY = translation.y;
    
    if (self.viewcontroller.delegate
        && [self.viewcontroller.delegate respondsToSelector:@selector(floatingPanelWillBeginDraggingWithFpc:)]) {
        [self.viewcontroller.delegate floatingPanelWillBeginDraggingWithFpc:self.viewcontroller];
    }
    [self.layoutAdapter startInteractionWithState:self.state offSet:offset];
    
    self.interactionInProgress = YES;
    [self lockScrollView];
}

- (void)endInteractionForTargetPosition:(JLFloatingPanelPosition)targetPosition {
    NSLog(@"endInteraction to %@", @(targetPosition));
    if (self.scrollView) {
        NSLog(@"endInteraction -- scroll offset = %@", NSStringFromCGPoint(self.scrollView.contentOffset));
    }
    self.interactionInProgress = NO;
    
    // Prevent to keep a scroll view indicator visible at the half/tip position
    if (targetPosition != self.layoutAdapter.topMostState) {
        [self lockScrollView];
    }
    [self.layoutAdapter endInteractionWithPosition:targetPosition];
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
        self.disabledBottomAutoLayout = NO;
    }
}

#pragma mark - Layout update
- (void)updateLayoutWithToPosition:(JLFloatingPanelPosition)position {
    [self.layoutAdapter activateFixedLayout];
    [self.layoutAdapter activateInteractiveLayoutWithPosition:position];
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
                if (@available(iOS 10.0, *)) {
                    if (self.state == self.layoutAdapter.topMostState
                        && self.animator == nil
                        && offset > 0 && velocity.y < 0) {
                        [self unlockScrollView];
                    }
                } else {
#pragma mark - TODO1
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
        
        if (@available(iOS 10.0, *)) {
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
        } else {
#pragma mark - TODO1
            
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
- (void)setScrollView:(UIScrollView *)scrollView {
    [_scrollView.panGestureRecognizer removeTarget:self action:nil];
    _scrollView = scrollView;
    [_scrollView.panGestureRecognizer addTarget:self action:@selector(handlePanGesture:)];
}

- (void)setState:(JLFloatingPanelPosition)state {
    _state = state;
    if (self.viewcontroller.delegate
        && [self.viewcontroller.delegate respondsToSelector:@selector(floatingPanelDidChangePositionWithFpc:)]) {
        [self.viewcontroller.delegate floatingPanelDidChangePositionWithFpc:self.viewcontroller];
    }
}

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

