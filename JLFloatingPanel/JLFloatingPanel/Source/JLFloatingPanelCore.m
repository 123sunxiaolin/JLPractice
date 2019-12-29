//
//  JLFloatingPanelCore.m
//  JLFloatingPanel
//
//  Created by Jacklin on 2019/12/29.
//  Copyright © 2019 Jacklin. All rights reserved.
//

#import "JLFloatingPanelCore.h"
#import "JLFloatingPanelLayout.h"
#import "JLFloatingPanelSurfaceView.h"
#import "JLFloatingPanelBackdropView.h"
#import "JLFloatingPanelBehavior.h"

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
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapGesture:)];
        tap.enabled = NO;
        _backdropView.dismissalTapGestureRecognizer = tap;
        [_backdropView addGestureRecognizer:tap];
        
    }
    return self;
}

- (void)moveToPosition:(JLFloatingPanelPosition)position animated:(BOOL)animated completion:(dispatch_block_t)completion {
    [self moveFromPosition:self.state toPosition:position animated:animated completion:completion];
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

#pragma mark - Layout update
- (void)updateLayoutWithToPosition:(JLFloatingPanelPosition)position {
    [self.layoutAdapter activateFixedLayout];
    [self.layoutAdapter activateLayoutWithPosition:position];
}

#pragma mark - Action
- (void)handlePanGesture:(UIPanGestureRecognizer *)panGesture {
    
}

- (void)handleTapGesture:(UITapGestureRecognizer *)tapGesture {
    
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



#pragma mark - Delegate

@end

