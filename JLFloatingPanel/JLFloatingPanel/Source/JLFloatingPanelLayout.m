//
//  JLFloatingPanelLayout.m
//  JLFloatingPanel
//
//  Created by Jacklin on 2019/12/28.
//  Copyright © 2019 Jacklin. All rights reserved.
//

#import "JLFloatingPanelLayout.h"
#import "JLFloatingPanelSurfaceView.h"
#import "JLFloatingPanelBackdropView.h"
#import "JLFloatingPanelController.h"
#import "UIVIewExtension.h"
#import "JLFloatingPanelBehavior.h"

@implementation JLLayoutSegment

+ (instancetype)segmentWithLower:(NSNumber *)lower upper:(NSNumber *)upper {
    JLLayoutSegment *segment = [[JLLayoutSegment alloc] init];
    segment.lower = lower;
    segment.upper = upper;
    return segment;
}

@end

#pragma mark - Bridge FullScreen
@interface JLFloatingPanelFullScreenLayout: NSObject <JLFloatingPanelFullScreenLayout>

@end

@implementation JLFloatingPanelFullScreenLayout

- (CGFloat)topInteractionBuffer {
    return 6.0;
}

- (CGFloat)bottomInteractionBuffer {
    return 6.0;
}

- (NSSet<NSNumber *> *)supportedPositions {
    return [NSSet setWithArray:@[@(JLFloatingPanelPositionFull),
                                 @(JLFloatingPanelPositionHalf),
                                 @(JLFloatingPanelPositionTip)]];
}

- (JLFloatingPanelLayoutReference)positionReference {
    return JLFloatingPanelLayoutReferenceFromSuperview;
}

@end

#pragma mark - Bridge IntrinsicLayout
@interface JLFloatingPanelIntrinsicLayout: NSObject <JLFloatingPanelIntrinsicLayout>

@end

@implementation JLFloatingPanelIntrinsicLayout

- (JLFloatingPanelPosition)initialPostion {
    return JLFloatingPanelPositionFull;
}

- (CGFloat)topInteractionBuffer {
    return 6.0;
}

- (CGFloat)bottomInteractionBuffer {
    return 6.0;
}

- (NSSet<NSNumber *> *)supportedPositions {
    return [NSSet setWithArray:@[@(JLFloatingPanelPositionFull)]];
}

- (CGFloat)insetForPosition:(JLFloatingPanelPosition)position {
    return CGFLOAT_MIN;
}
            
- (JLFloatingPanelLayoutReference)positionReference {
    return JLFloatingPanelLayoutReferenceFromSafeArea;
}

@end

#pragma mark - Bridge Default
@interface JLFloatingPanelLayout : NSObject <JLFloatingPanelLayout>

@end

@implementation JLFloatingPanelLayout

- (CGFloat)topInteractionBuffer {
    return 6.0;
}

- (CGFloat)bottomInteractionBuffer {
    return 6.0;
}

- (NSSet<NSNumber *> *)supportedPositions {
    return [NSSet setWithArray:@[@(JLFloatingPanelPositionFull),
                                 @(JLFloatingPanelPositionHalf),
                                 @(JLFloatingPanelPositionTip)]];
}

- (NSArray<NSLayoutConstraint *> *)prepareLayoutWithSurfaceView:(UIView *)surfaceView inView:(UIView *)view {
    if (@available(iOS 9.0, *)) {
        NSLayoutXAxisAnchor *left = view.leftAnchor;
        NSLayoutXAxisAnchor *right = view.rightAnchor;
        if (@available(iOS 11.0, *)) {
            left = view.safeAreaLayoutGuide.leftAnchor;
            right = view.safeAreaLayoutGuide.rightAnchor;
        }
        return @[[surfaceView.leftAnchor constraintEqualToAnchor:left constant:0.0], [surfaceView.rightAnchor constraintEqualToAnchor:right constant:0.0]];
    } else {
        NSLayoutConstraint *left = [NSLayoutConstraint constraintWithItem:surfaceView
                                                                attribute:NSLayoutAttributeLeft
                                                                relatedBy:NSLayoutRelationEqual
                                                                   toItem:view
                                                                attribute:NSLayoutAttributeLeft
                                                               multiplier:1
                                                                 constant:0];
        NSLayoutConstraint *right = [NSLayoutConstraint constraintWithItem:surfaceView
                                                                 attribute:NSLayoutAttributeRight
                                                                 relatedBy:NSLayoutRelationEqual
                                                                    toItem:view
                                                                 attribute:NSLayoutAttributeRight
                                                                multiplier:1
                                                                  constant:0];
        return @[left, right];
    }
}

- (CGFloat)backdropAlphaForPosition:(JLFloatingPanelPosition)position {
    return position == JLFloatingPanelPositionFull ? 0.3 : 0.f;
}

- (JLFloatingPanelLayoutReference)positionReference {
    return JLFloatingPanelLayoutReferenceFromSafeArea;
}

@end

#pragma mark  - Default
@interface JLFloatingPanelDefaultLayout()
@property (nonatomic, strong) JLFloatingPanelLayout *layout;
@end
@implementation JLFloatingPanelDefaultLayout

- (instancetype)init {
    if (self = [super init]) {
        self.layout = [[JLFloatingPanelLayout alloc] init];
    }
    return self;
}

- (JLFloatingPanelPosition)initialPostion {
    return JLFloatingPanelPositionHalf;
}

- (CGFloat)topInteractionBuffer {
    return self.layout.topInteractionBuffer;
}

- (CGFloat)bottomInteractionBuffer {
    return self.layout.bottomInteractionBuffer;
}

- (NSSet<NSNumber *> *)supportedPositions {
    return self.layout.supportedPositions;
}

- (NSArray<NSLayoutConstraint *> *)prepareLayoutWithSurfaceView:(UIView *)surfaceView inView:(UIView *)view {
    return [self.layout prepareLayoutWithSurfaceView:surfaceView inView:view];
}

- (CGFloat)backdropAlphaForPosition:(JLFloatingPanelPosition)position {
    return [self backdropAlphaForPosition:position];
}

- (CGFloat)insetForPosition:(JLFloatingPanelPosition)position {
    switch (position) {
        case JLFloatingPanelPositionFull:
            return 18.f;
            break;
        case JLFloatingPanelPositionHalf:
            return 262.f;
            break;
        case JLFloatingPanelPositionTip:
            return 69.f;
            break;
        default:
            return 0;
            break;
    }
}

- (JLFloatingPanelLayoutReference)positionReference {
    return self.layout.positionReference;
}

@end

#pragma mark - LandscapeLayout
@interface JLFloatingPanelDefaultLandscapeLayout()
@property (nonatomic, strong) JLFloatingPanelLayout *layout;
@end

@implementation JLFloatingPanelDefaultLandscapeLayout

- (instancetype)init {
    if (self = [super init]) {
        self.layout = [[JLFloatingPanelLayout alloc] init];
    }
    return self;
}

- (JLFloatingPanelPosition)initialPostion {
    return JLFloatingPanelPositionTip;
}

- (CGFloat)topInteractionBuffer {
    return self.layout.topInteractionBuffer;
}

- (CGFloat)bottomInteractionBuffer {
    return self.layout.bottomInteractionBuffer;
}

- (NSSet<NSNumber *> *)supportedPositions {
    return [NSSet setWithArray:@[@(JLFloatingPanelPositionFull),
                                 @(JLFloatingPanelPositionTip)]];
}

- (CGFloat)backdropAlphaForPosition:(JLFloatingPanelPosition)position {
    return [self backdropAlphaForPosition:position];
}

- (CGFloat)insetForPosition:(JLFloatingPanelPosition)position {
    switch (position) {
        case JLFloatingPanelPositionFull:
            return 16.f;
            break;
        case JLFloatingPanelPositionTip:
            return 69.f;
            break;
        default:
            return 0;
            break;
    }
}

- (JLFloatingPanelLayoutReference)positionReference {
    return self.layout.positionReference;
}

@end

@interface JLFloatingPanelLayoutAdapter()
@property (nonatomic, weak) JLFloatingPanelSurfaceView *surfaceView;
@property (nonatomic, weak) JLFloatingPanelBackdropView *backdropView;

@property (nonatomic, assign) UIEdgeInsets safeAreaInsets;

@property (nonatomic, assign) CGFloat heightBuffer;
@property (nonatomic, assign) CGFloat initialConst;

@property (nonatomic, strong) NSMutableArray <NSLayoutConstraint *> *fixedConstraints;
@property (nonatomic, strong) NSMutableArray <NSLayoutConstraint *> *fullConstraints;
@property (nonatomic, strong) NSMutableArray <NSLayoutConstraint *> *halfConstraints;
@property (nonatomic, strong) NSMutableArray <NSLayoutConstraint *> *tipConstraints;
@property (nonatomic, strong) NSMutableArray <NSLayoutConstraint *> *offConstraints;
@property (nonatomic, strong) NSMutableArray <NSLayoutConstraint *> *heightConstraints;

@property (nonatomic, strong) NSLayoutConstraint *interactiveTopConstraint;
@property (nonatomic, strong) NSLayoutConstraint *bottomConstraint;
@property (nonatomic, strong) NSLayoutConstraint *heightConstraint;

@property (nonatomic, assign) CGFloat intrinsicHeight;

@property (nonatomic, assign, readonly) CGFloat fullInset;
@property (nonatomic, assign, readonly) CGFloat halfInset;
@property (nonatomic, assign, readonly) CGFloat tipInset;
@property (nonatomic, assign, readonly) CGFloat hiddenInset;

@end

@implementation JLFloatingPanelLayoutAdapter

#pragma mark - Life Cycle
- (instancetype)initWithSurfaceView:(JLFloatingPanelSurfaceView *)surfaceView backdropView:(JLFloatingPanelBackdropView *)backdropView layout:(id<JLFloatingPanelLayout>)lauout {
    if (self = [super init]) {
        self.layout = lauout;
        self.surfaceView = surfaceView;
        self.backdropView = backdropView;
        [self initilizeValues];
    }
    return self;
}

#pragma mark - Public
- (void)prepareLayoutInViewController:(JLFloatingPanelController *)panelController {
    self.panelController = panelController;
    
    NSMutableArray *constraints = self.fixedConstraints.mutableCopy;
    [constraints addObjectsFromArray:self.fullConstraints];
    [constraints addObjectsFromArray:self.halfConstraints];
    [constraints addObjectsFromArray:self.tipConstraints];
    [constraints addObjectsFromArray:self.offConstraints];
    [NSLayoutConstraint deactivateConstraints:constraints];
    
    [NSLayoutConstraint deactivateConstraints:@[self.heightConstraint, self.bottomConstraint]];
    self.heightConstraint = nil;
    self.bottomConstraint = nil;
    
    self.surfaceView.translatesAutoresizingMaskIntoConstraints = NO;
    self.backdropView.translatesAutoresizingMaskIntoConstraints = NO;
    
    NSArray *surfaceContraints = [self.layout prepareLayoutWithSurfaceView:self.surfaceView
                                                                    inView:panelController.view];
    
    NSLayoutConstraint *top = [NSLayoutConstraint constraintWithItem:self.backdropView
                                                           attribute:NSLayoutAttributeTop
                                                           relatedBy:NSLayoutRelationEqual
                                                              toItem:panelController.view
                                                           attribute:NSLayoutAttributeTop
                                                          multiplier:1
                                                            constant:0];
    NSLayoutConstraint *left = [NSLayoutConstraint constraintWithItem:self.backdropView
                                                            attribute:NSLayoutAttributeLeft
                                                            relatedBy:NSLayoutRelationEqual
                                                               toItem:panelController.view
                                                            attribute:NSLayoutAttributeLeft
                                                           multiplier:1
                                                             constant:0];
    NSLayoutConstraint *right = [NSLayoutConstraint constraintWithItem:self.backdropView
                                                             attribute:NSLayoutAttributeRight
                                                             relatedBy:NSLayoutRelationEqual
                                                                toItem:panelController.view
                                                             attribute:NSLayoutAttributeRight
                                                            multiplier:1
                                                              constant:0];
    NSLayoutConstraint *bottom = [NSLayoutConstraint constraintWithItem:self.backdropView
                                                              attribute:NSLayoutAttributeBottom
                                                              relatedBy:NSLayoutRelationEqual
                                                                 toItem:panelController.view
                                                              attribute:NSLayoutAttributeBottom
                                                             multiplier:1
                                                               constant:0];
    NSMutableArray *backgroundContrints = @[top, left, right, bottom].mutableCopy;
    [backgroundContrints addObjectsFromArray:surfaceContraints];
    self.fixedConstraints = backgroundContrints;
    
    if (panelController.contentMode == JLContentModeFitToBounds) {
        self.bottomConstraint = [NSLayoutConstraint constraintWithItem:self.surfaceView
                                                             attribute:NSLayoutAttributeBottom
                                                             relatedBy:NSLayoutRelationEqual
                                                                toItem:panelController.view
                                                             attribute:NSLayoutAttributeBottom
                                                            multiplier:1 constant:0];
    }
    
    // ---------------------Top-------------------------------
    // Flexible surface constraints for full, half, tip and off
    NSLayoutConstraint *oneContraintFotFull = [NSLayoutConstraint constraintWithItem:self.surfaceView
                                                                           attribute:NSLayoutAttributeTop
                                                                           relatedBy:NSLayoutRelationEqual
                                                                              toItem:panelController.view
                                                                           attribute:NSLayoutAttributeTop
                                                                          multiplier:1
                                                                            constant:0];
    if (@available(iOS 9.0, *)) {
        NSLayoutYAxisAnchor *topAnchor = nil;
        if (self.layout.positionReference == JLFloatingPanelLayoutReferenceFromSuperview) {
            topAnchor = panelController.view.topAnchor;
        } else {
            topAnchor = panelController.layoutGuide.topAnchor;
        }
        oneContraintFotFull = [self.surfaceView.topAnchor constraintEqualToAnchor:topAnchor constant:0];
    }
    
    [self.fullConstraints removeAllObjects];
   
    
    if ([self.layout conformsToProtocol:@protocol(JLFloatingPanelIntrinsicLayout)]) {
        // Set up on updateHeight()
    } else {
        [self.fullConstraints addObject:oneContraintFotFull];
    }
    
    // ---------------------Bottom-------------------------------
    NSLayoutConstraint *oneContraintFotHalf = [NSLayoutConstraint constraintWithItem:self.surfaceView
                                                                            attribute:NSLayoutAttributeTop
                                                                            relatedBy:NSLayoutRelationEqual
                                                                               toItem:panelController.view
                                                                            attribute:NSLayoutAttributeBottom
                                                                           multiplier:1
                                                                             constant:-self.halfInset];
    NSLayoutConstraint *oneContraintFotTip = [NSLayoutConstraint constraintWithItem:self.surfaceView
                                                                          attribute:NSLayoutAttributeTop
                                                                          relatedBy:NSLayoutRelationEqual
                                                                             toItem:panelController.view
                                                                          attribute:NSLayoutAttributeBottom
                                                                         multiplier:1
                                                                           constant:-self.tipInset];
    NSLayoutConstraint *oneContraintFotHidden = [NSLayoutConstraint constraintWithItem:self.surfaceView
                                                                             attribute:NSLayoutAttributeTop
                                                                             relatedBy:NSLayoutRelationEqual
                                                                                toItem:panelController.view
                                                                             attribute:NSLayoutAttributeBottom
                                                                            multiplier:1
                                                                              constant:-self.hiddenInset];
    
    if (@available(iOS 9.0, *)) {
        NSLayoutYAxisAnchor *bottomAnchor = nil;
        if (self.layout.positionReference == JLFloatingPanelLayoutReferenceFromSuperview) {
            bottomAnchor = panelController.view.bottomAnchor;
        } else {
            bottomAnchor = panelController.layoutGuide.bottomAnchor;
        }
        oneContraintFotHalf = [self.surfaceView.topAnchor constraintEqualToAnchor:bottomAnchor
                                                                         constant:-self.halfInset];
        oneContraintFotTip = [self.surfaceView.topAnchor constraintEqualToAnchor:bottomAnchor
                                                                        constant:-self.tipInset];
        oneContraintFotHidden = [self.surfaceView.topAnchor constraintEqualToAnchor:bottomAnchor
                                                                           constant:-self.hiddenInset];
    }
    
    [self.halfConstraints removeAllObjects];
    [self.halfConstraints addObject:oneContraintFotFull];
    
    [self.tipConstraints removeAllObjects];
    [self.tipConstraints addObject:oneContraintFotTip];
    
    [self.offConstraints removeAllObjects];
    [self.offConstraints addObject:oneContraintFotHidden];
    
}

- (void)startInteractionWithState:(JLFloatingPanelPosition)position {
    [self startInteractionWithState:position offSet:CGPointZero];
}

- (void)startInteractionWithState:(JLFloatingPanelPosition)position offSet:(CGPoint)offset {
    if (self.interactiveTopConstraint) {
        return;
    }
    [self.fullConstraints addObjectsFromArray:self.halfConstraints];
    [self.fullConstraints addObjectsFromArray:self.tipConstraints];
    [self.fullConstraints addObjectsFromArray:self.offConstraints];
    
    NSLayoutConstraint *interactiveTopConstraint = nil;
    switch (self.layout.positionReference) {
        case JLFloatingPanelLayoutReferenceFromSafeArea:
            self.initialConst = self.surfaceView.frame.origin.y - self.safeAreaInsets.top + offset.y;
            if (@available(iOS 11.0, *)) {
                interactiveTopConstraint = [self.surfaceView.topAnchor constraintEqualToAnchor:self.panelController.layoutGuide.topAnchor
                                                                                      constant:self.initialConst];
            } else {
                interactiveTopConstraint = [NSLayoutConstraint constraintWithItem:self.surfaceView
                                                                        attribute:NSLayoutAttributeTop
                                                                        relatedBy:NSLayoutRelationEqual
                                                                           toItem:self.panelController.view
                                                                        attribute:NSLayoutAttributeTop
                                                                       multiplier:1
                                                                         constant:self.initialConst];
            }
            break;
            
        case JLFloatingPanelLayoutReferenceFromSuperview:
            self.initialConst = self.surfaceView.frame.origin.y - self.safeAreaInsets.top + offset.y;
            if (@available(iOS 11.0, *)) {
                interactiveTopConstraint = [self.surfaceView.topAnchor constraintEqualToAnchor:self.panelController.layoutGuide.topAnchor
                                                                                      constant:self.initialConst];
            } else {
                interactiveTopConstraint = [NSLayoutConstraint constraintWithItem:self.surfaceView
                                                                        attribute:NSLayoutAttributeTop
                                                                        relatedBy:NSLayoutRelationEqual
                                                                           toItem:self.panelController.view
                                                                        attribute:NSLayoutAttributeTop
                                                                       multiplier:1
                                                                         constant:self.initialConst];
            }
            break;
    }
    
    [NSLayoutConstraint activateConstraints:@[interactiveTopConstraint]];
    self.interactiveTopConstraint = interactiveTopConstraint;
}

- (void)endInteractionWithPosition:(JLFloatingPanelPosition)position {
    // Don't deactivate `interactiveTopConstraint` here because it leads to
    // unsatisfiable constraints

    if (!self.interactiveTopConstraint) {
        // Actiavate `interactiveTopConstraint` for `fitToBounds` mode.
        // It goes throught this path when the pan gesture state jumps
        // from .begin to .end.
        [self startInteractionWithState:position];
    }
}

// The method is separated from prepareLayout(to:) for the rotation support
// It must be called in FloatingPanelController.traitCollectionDidChange(_:)
- (void)updateHeight {
    if (!self.panelController) return;
    [NSLayoutConstraint deactivateConstraints:@[self.heightConstraint]];
    self.heightConstraint = nil;
    
    if ([self.layout conformsToProtocol:@protocol(JLFloatingPanelIntrinsicLayout)]) {
        [self updateIntrinsicHeight];
    }
    
    if (self.panelController.contentMode == JLContentModeFitToBounds) {
        [self resetFullConstraint];
        return;
    }
    if ([self.layout conformsToProtocol:@protocol(JLFloatingPanelIntrinsicLayout)]) {
        self.heightConstraint = [NSLayoutConstraint constraintWithItem:self.surfaceView
                                                             attribute:NSLayoutAttributeHeight
                                                             relatedBy:NSLayoutRelationEqual
                                                                toItem:nil
                                                             attribute:NSLayoutAttributeNotAnAttribute
                                                            multiplier:1
                                                              constant:self.intrinsicHeight + self.safeAreaInsets.bottom];
    } else {
        CGFloat constant = -[self positionYForPosition:self.topMostState];
        self.heightConstraint = [NSLayoutConstraint constraintWithItem:self.surfaceView
                                                             attribute:NSLayoutAttributeHeight
                                                             relatedBy:NSLayoutRelationEqual
                                                                toItem:self.panelController.view
                                                             attribute:NSLayoutAttributeHeight
                                                            multiplier:1
                                                              constant:constant];
    }
    [NSLayoutConstraint activateConstraints:@[self.heightConstraint]];
    self.surfaceView.bottomOverflow = self.panelController.view.bounds.size.height + self.layout.topInteractionBuffer;
    
    [self resetFullConstraint];
}

- (void)updateInteractiveTopConstraintWithDiff:(CGFloat)diff allowsTopBuffer:(BOOL)allowsTopBuffer behavior:(id <JLFloatingPanelBehavior>)behavior {
    
    CGFloat topMostConst = 0;
    if(self.layout.positionReference == JLFloatingPanelLayoutReferenceFromSafeArea) {
        topMostConst = self.topY - self.safeAreaInsets.top;
    } else {
        topMostConst = self.topY;
    }
    topMostConst = MAX(topMostConst, 0); // The top boundary is equal to the related topAnchor.
    
    CGFloat bottomMostConst = 0;
    CGFloat _bottomY = self.panelController.isRemovalInteractionEnabled ? [self positionYForPosition:JLFloatingPanelPositionHidden] : self.bottomY;
    if(self.layout.positionReference == JLFloatingPanelLayoutReferenceFromSafeArea) {
        bottomMostConst = _bottomY - self.safeAreaInsets.top;
    } else {
        bottomMostConst = _bottomY;
    }
    bottomMostConst = MIN(bottomMostConst, CGRectGetHeight(self.surfaceView.frame));
    
    CGFloat minConst = allowsTopBuffer ? topMostConst - self.layout.topInteractionBuffer : topMostConst;
    CGFloat maxConst = bottomMostConst + self.layout.bottomInteractionBuffer;
    
    CGFloat constant = self.initialConst + diff;
    
    // Rubberbanding top buffer
    if ([behavior allowsRubberBandingWithRectEdge:UIRectEdgeTop]
        && constant < topMostConst) {
        CGFloat buffer = topMostConst - constant;
        constant = topMostConst - [self rubberbandEffectWithBuffer:buffer base:self.panelController.view.bounds.size.height];
    }
    
    // Rubberbanding bottom buffer
    if ([behavior allowsRubberBandingWithRectEdge:UIRectEdgeBottom]
        && constant > bottomMostConst) {
        CGFloat buffer = constant - bottomMostConst;
        constant = bottomMostConst + [self rubberbandEffectWithBuffer:buffer base:self.panelController.view.bounds.size.height];
    }
    
    self.interactiveTopConstraint.constant = MAX(minConst, MIN(maxConst, constant));
    
    [self layoutSurfaceIfNeeded];
}

- (void)activateLayoutWithPosition:(JLFloatingPanelPosition)position {
    [self activateFixedLayout];
    [self activateLayoutWithPosition:position];
}

- (void)activateInteractiveLayoutWithPosition:(JLFloatingPanelPosition)position {
    JLFloatingPanelPosition aPosition = position;
    [self setBackdropAlphaWithPosition:position];
    
    if ([self isVaildWithPosition:position]) {
        aPosition = self.layout.initialPostion;
    }
    
    [self.fullConstraints addObjectsFromArray:self.halfConstraints];
    [self.fullConstraints addObjectsFromArray:self.tipConstraints];
    [self.fullConstraints addObjectsFromArray:self.offConstraints];
    [NSLayoutConstraint deactivateConstraints:self.fullConstraints];
    
    switch (aPosition) {
        case JLFloatingPanelPositionFull:
            [NSLayoutConstraint activateConstraints:self.fullConstraints];
            break;
        case JLFloatingPanelPositionHalf:
            [NSLayoutConstraint activateConstraints:self.halfConstraints];
            break;
        case JLFloatingPanelPositionTip:
            [NSLayoutConstraint activateConstraints:self.tipConstraints];
            break;
        case JLFloatingPanelPositionHidden:
            [NSLayoutConstraint activateConstraints:self.offConstraints];
            break;
    }
    
    [self layoutSurfaceIfNeeded];
    NSLog(@"activateLayout -- surface.presentation = %@ surface.frame = %@",
          NSStringFromCGRect(self.surfaceView.layer.presentationLayer.frame),
          NSStringFromCGRect(self.surfaceView.frame));
}

- (BOOL)isVaildWithPosition:(JLFloatingPanelPosition)position {
    NSMutableSet *set = [NSMutableSet setWithSet:self.supportedPositions];
    [set addObject:@(position)];
    BOOL isVaild = NO;
    for (NSNumber *one in set) {
        if ((JLFloatingPanelPosition)one.integerValue == position) {
            isVaild = YES;
            break;
        }
    }
    return isVaild;
}

- (JLLayoutSegment *)segmentWithPosY:(CGFloat)posY forward:(BOOL)forward {
    /// ----------------------->Y
    /// --> forward                <-- backward
    /// |-------|===o===|-------|  |-------|-------|===o===|
    /// |-------|-------x=======|  |-------|=======x-------|
    /// |-------|-------|===o===|  |-------|===o===|-------|
    /// pos: o/x, seguement: =
    
    // Ascending sort
    NSArray *sortDesc = @[[[NSSortDescriptor alloc] initWithKey:nil ascending:YES]];
    NSArray *sortedPositions = [self.supportedPositions sortedArrayUsingDescriptors:sortDesc];
    
    __block NSInteger upperIndex = NSIntegerMin;
    if (forward) {
        [sortedPositions enumerateObjectsUsingBlock:^(NSNumber *obj, NSUInteger idx, BOOL * _Nonnull stop) {
            JLFloatingPanelPosition pos = (JLFloatingPanelPosition)obj.integerValue;
            if (posY < [self positionYForPosition:pos]) {
                upperIndex = idx;
                *stop = YES;
            }
        }];
    } else {
        [sortedPositions enumerateObjectsUsingBlock:^(NSNumber *obj, NSUInteger idx, BOOL * _Nonnull stop) {
            JLFloatingPanelPosition pos = (JLFloatingPanelPosition)obj.integerValue;
            if (posY <= [self positionYForPosition:pos]) {
                upperIndex = idx;
                *stop = YES;
            }
        }];
    }
    
    if (upperIndex == 0) {
        return [JLLayoutSegment segmentWithLower:nil upper:sortedPositions.firstObject];
    } else if (upperIndex >= 1) {
        return [JLLayoutSegment segmentWithLower:sortedPositions[upperIndex - 1] upper:sortedPositions[upperIndex]];
    } else {
        return [JLLayoutSegment segmentWithLower:sortedPositions[sortedPositions.count - 1 - 1] upper:nil];
    }
}

- (CGFloat)positionYForPosition:(JLFloatingPanelPosition)position {
    switch (position) {
        case JLFloatingPanelPositionFull: {
            if ([self.layout conformsToProtocol:@protocol(JLFloatingPanelIntrinsicLayout)]) {
                return self.surfaceView.superview.bounds.size.height - self.surfaceView.bounds.size.height;
            }
            switch (self.layout.positionReference) {
                case JLFloatingPanelLayoutReferenceFromSafeArea:
                    return self.safeAreaInsets.top + self.fullInset;
                    break;
                case  JLFloatingPanelLayoutReferenceFromSuperview:
                    return self.fullInset;
                    break;
            }
        }
            break;
        case JLFloatingPanelPositionHalf: {
            switch (self.layout.positionReference) {
                case JLFloatingPanelLayoutReferenceFromSafeArea:
                    return self.surfaceView.superview.bounds.size.height - (self.safeAreaInsets.bottom + self.halfInset);
                    break;
                case  JLFloatingPanelLayoutReferenceFromSuperview:
                    return self.surfaceView.superview.bounds.size.height - self.halfInset;
                    break;
            }
        }
            break;
        case JLFloatingPanelPositionTip: {
            switch (self.layout.positionReference) {
                case JLFloatingPanelLayoutReferenceFromSafeArea:
                    return self.surfaceView.superview.bounds.size.height - (self.safeAreaInsets.bottom + self.tipInset);
                    break;
                case  JLFloatingPanelLayoutReferenceFromSuperview:
                    return self.surfaceView.superview.bounds.size.height - self.tipInset;
                    break;
            }
        }
            break;
            
        case JLFloatingPanelPositionHidden:
            return self.surfaceView.superview.bounds.size.height - self.hiddenInset;
            break;
    }
}

#pragma mark - Private
- (void)initilizeValues {
    self.initialConst = 0;
    self.intrinsicHeight = 0;
    self.fixedConstraints = [NSMutableArray new];
    self.halfConstraints = [NSMutableArray new];
    self.tipConstraints = [NSMutableArray new];
    self.offConstraints = [NSMutableArray new];
   
    
    
}

- (void)checkLayoutConsistance {
    // Verify layout configurations
    NSAssert(self.supportedPositions.count > 0, @"Can not be empty!");
    BOOL isContained = NO;
    JLFloatingPanelPosition initialPosition = self.layout.initialPostion;
    for (NSNumber *position in self.supportedPositions) {
        @autoreleasepool {
            if ((JLFloatingPanelPosition)position.integerValue == initialPosition) {
                isContained = YES;
                break;
            }
        }
    }
    
    NSString *desc = [NSString stringWithFormat:@"Does not include an initial position:%@ in supportedPositions: %@", @(initialPosition), self.supportedPositions];
    NSAssert(isContained, desc);
    
    if ([self.layout conformsToProtocol:@protocol(JLFloatingPanelIntrinsicLayout)]) {
        NSAssert([self.layout insetForPosition:JLFloatingPanelPositionFull] == CGFLOAT_MIN, @"Return `nil` for full position on FloatingPanelIntrinsicLayout");
    }
    

    if (self.halfInset > 0) {
        NSAssert(self.halfInset > self.tipInset, @"Invalid half and tip insets");
    }
    // The verification isn't working on orientation change(portrait -> landscape)
    // of a floating panel in tab bar. Because the `safeAreaInsets.bottom` is
    // updated in delay so that it can be 83.0(not 53.0) even after the surface
    // and the super view's frame is fit to landscape already.
    /*if fullInset > 0 {
        assert(middleY > topY, "Invalid insets { topY: \(topY), middleY: \(middleY) }")
        assert(bottomY > topY, "Invalid insets { topY: \(topY), bottomY: \(bottomY) }")
     }*/
}

- (void)updateIntrinsicHeight {
    CGSize fittingSize = UILayoutFittingCompressedSize;
    CGFloat intrinsicHeight = [self.surfaceView systemLayoutSizeFittingSize:fittingSize].height;
    CGFloat safeAreaBottom = 0.f;
    if (@available(iOS 11.0, *)) {
        safeAreaBottom = self.surfaceView.contentView.safeAreaInsets.bottom;
        if (safeAreaBottom > 0) {
            intrinsicHeight -= safeAreaBottom;
        }
    }
    self.intrinsicHeight = MAX(intrinsicHeight, 0.0);
    
    NSLog(@"Update intrinsic height = %f, surface(height) = %f, content(height) = %f, content safe area(bottom) = %f", intrinsicHeight, self.surfaceView.frame.size.height, self.surfaceView.contentView.frame.size.height, safeAreaBottom);
}

- (void)resetFullConstraint {
    if ([self.layout conformsToProtocol:@protocol(JLFloatingPanelIntrinsicLayout)]) {
        [NSLayoutConstraint deactivateConstraints:self.fullConstraints];
        NSLayoutConstraint *top = [NSLayoutConstraint constraintWithItem:self.surfaceView
                                                               attribute:NSLayoutAttributeTop
                                                               relatedBy:NSLayoutRelationEqual
                                                                  toItem:self.panelController.view
                                                               attribute:NSLayoutAttributeBottom
                                                              multiplier:1
                                                                constant:- self.fullInset];
        if (@available(iOS 11.0, *)) {
            top = [self.surfaceView.topAnchor constraintEqualToAnchor:self.panelController.layoutGuide.bottomAnchor
                                                             constant:- self.fullInset];
        }
        [self.fullConstraints removeAllObjects];
        [self.fullConstraints addObject:top];
    }
}

- (void)setBackdropAlphaWithPosition:(JLFloatingPanelPosition)position {
    if (position == JLFloatingPanelPositionHidden) {
        self.backdropView.alpha = 0.0;
    } else {
        self.backdropView.alpha = [self.layout backdropAlphaForPosition:position];
    }
}

- (void)layoutSurfaceIfNeeded {
    if (self.surfaceView.superview) {
        [self.surfaceView.superview layoutIfNeeded];
    }
}

- (void)activateFixedLayout {
    [NSLayoutConstraint deactivateConstraints:@[self.interactiveTopConstraint]];
    self.interactiveTopConstraint = nil;
    
    [NSLayoutConstraint activateConstraints:self.fixedConstraints];
    if (self.panelController.contentMode == JLContentModeFitToBounds) {
        [NSLayoutConstraint activateConstraints:@[self.bottomConstraint]];
    }
}

// According to @chpwn's tweet: https://twitter.com/chpwn/status/285540192096497664
// x = distance from the edge
// c = constant value, UIScrollView uses 0.55
// d = dimension, either width or height
- (CGFloat)rubberbandEffectWithBuffer:(CGFloat)buffer base:(CGFloat)base {
    return (1.0 - (1.0 / ((buffer * 0.55 / base) + 1.0))) * base;
}

#pragma mark - Setters
- (void)setLayout:(id <JLFloatingPanelLayout>)layout {
    _layout = layout;
    [self checkLayoutConsistance];
}

#pragma mark - Getters
- (CGFloat )fullInset {
    if ([self.layout conformsToProtocol:@protocol(JLFloatingPanelIntrinsicLayout)]) {
        return self.intrinsicHeight;
    }
    return [self.layout insetForPosition:JLFloatingPanelPositionFull];
}

- (CGFloat)halfInset {
    return [self.layout insetForPosition:JLFloatingPanelPositionHalf];
}

- (CGFloat)tipInset {
    return [self.layout insetForPosition:JLFloatingPanelPositionTip];
}

- (CGFloat)hiddenInset {
    return [self.layout insetForPosition:JLFloatingPanelPositionHidden];
}

- (NSSet<NSNumber *> *)supportedPositions {
    return self.layout.supportedPositions;
}

- (JLFloatingPanelPosition)topMostState {
    NSArray *sortDesc = @[[[NSSortDescriptor alloc] initWithKey:nil ascending:YES]];
    NSArray *sortArray = [self.supportedPositions sortedArrayUsingDescriptors:sortDesc];
    NSNumber *first = (NSNumber *)sortArray.firstObject;
    return (JLFloatingPanelPosition)first.integerValue;
}

- (JLFloatingPanelPosition)bottomMostState {
    NSArray *sortDesc = @[[[NSSortDescriptor alloc] initWithKey:nil ascending:YES]];
    NSArray *sortArray = [self.supportedPositions sortedArrayUsingDescriptors:sortDesc];
    NSNumber *last = (NSNumber *)sortArray.lastObject;
    return (JLFloatingPanelPosition)last.integerValue;
}

- (CGFloat)topY {
    return [self positionYForPosition:self.topMostState];
}

- (CGFloat)bottomY {
    return [self positionYForPosition:self.bottomMostState];
}

- (CGFloat)topMaxY {
    return self.topY - self.layout.topInteractionBuffer;
}

- (CGFloat)bottomMaxY {
    return self.bottomY + self.layout.bottomInteractionBuffer;
}

- (UIEdgeInsets)adjustedContentInsets {
    return UIEdgeInsetsMake(0, 0, self.safeAreaInsets.bottom, 0);
}

#pragma mark - Action

#pragma mark - Delegate


@end
