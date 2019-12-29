//
//  JLFloatingPanelSurfaceView.m
//  JLFloatingPanel
//
//  Created by Jacklin on 2019/12/28.
//  Copyright © 2019 Jacklin. All rights reserved.
//

#import "JLFloatingPanelSurfaceView.h"
#import "JLGrabberHandleView.h"

static CGFloat const kGrabberTopPadding = 6.f;

@implementation JLFloatingPanelSurfaceContentView
@end

@interface JLFloatingPanelSurfaceView()
@property (nonatomic, strong) UIColor *backgroundColor_;
@property (nonatomic, strong) CAShapeLayer *backgroundLayer;
@end

@implementation JLFloatingPanelSurfaceView

#pragma mark - Life Cycle
- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self renderUI];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    NSLog(@"SurfaceView frame = %@", NSStringFromCGRect(self.frame));
    
    [self updateLayers];
    [self updateContentViewMask];
    
    if (self.contentView) {
        self.contentView.layer.borderColor = self.borderColor.CGColor;
        self.contentView.layer.borderWidth = self.borderWidth;
        self.contentView.frame = self.bounds;
    }
}

#pragma mark - Public
- (void)addContentView:(UIView *)contentView {
    [self insertSubview:contentView belowSubview:self.grabberHandleView];
    self.contentView = contentView;
    
    contentView.translatesAutoresizingMaskIntoConstraints = NO;
    NSLayoutConstraint *top = [NSLayoutConstraint constraintWithItem:contentView
                                                           attribute:NSLayoutAttributeTop
                                                           relatedBy:NSLayoutRelationEqual
                                                              toItem:self
                                                           attribute:NSLayoutAttributeTop
                                                          multiplier:1
                                                            constant:0];
    NSLayoutConstraint *bottom = [NSLayoutConstraint constraintWithItem:contentView
                                                              attribute:NSLayoutAttributeBottom
                                                              relatedBy:NSLayoutRelationEqual
                                                                 toItem:self
                                                              attribute:NSLayoutAttributeBottom
                                                             multiplier:1
                                                               constant:0];
    NSLayoutConstraint *left = [NSLayoutConstraint constraintWithItem:contentView
                                                                 attribute:NSLayoutAttributeLeft
                                                                 relatedBy:NSLayoutRelationEqual
                                                                    toItem:self
                                                                 attribute:NSLayoutAttributeLeft
                                                                multiplier:1
                                                                  constant:0];
    NSLayoutConstraint *right = [NSLayoutConstraint constraintWithItem:contentView
                                                             attribute:NSLayoutAttributeRight
                                                             relatedBy:NSLayoutRelationEqual
                                                                toItem:self
                                                             attribute:NSLayoutAttributeRight
                                                            multiplier:1
                                                              constant:0];
    
    [NSLayoutConstraint activateConstraints:@[top, bottom, left, right]];
}

#pragma mark - Private
- (void)initializeValues {
    self.backgroundColor_ = [UIColor whiteColor];
    self.cornerRadius = 0.f;
    self.shadowHidden = NO;
    self.shadowColor = [UIColor blackColor];
    self.shadowOffset  = CGSizeMake(0, 1.f);
    self.shadowOpacity = 0.2f;
    self.shadowRadius = 3.f;
    self.borderWidth = 0.f;
    
}

- (void)renderUI {
    // 设置一些初始化值
    [self initializeValues];
    super.backgroundColor = [UIColor clearColor];
    self.clipsToBounds = NO;
    
    CAShapeLayer *bcgLayer = [[CAShapeLayer alloc] init];
    [self.layer insertSublayer:bcgLayer atIndex:0];
    self.backgroundLayer = bcgLayer;
    
    JLGrabberHandleView *grabberHangleView = [[JLGrabberHandleView alloc] init];
    [self addSubview:grabberHangleView];
    self.grabberHandleView = grabberHangleView;
    
    // Convert to AutoLayout
    grabberHangleView.translatesAutoresizingMaskIntoConstraints = NO;
    NSLayoutConstraint *topConstraint = [NSLayoutConstraint constraintWithItem:grabberHangleView
                                                                     attribute:NSLayoutAttributeTop
                                                                     relatedBy:NSLayoutRelationEqual
                                                                        toItem:self
                                                                     attribute:NSLayoutAttributeTop
                                                                    multiplier:1
                                                                      constant:kGrabberTopPadding];
    NSLayoutConstraint *widthConstraint = [NSLayoutConstraint constraintWithItem:grabberHangleView
                                                                     attribute:NSLayoutAttributeWidth
                                                                     relatedBy:NSLayoutRelationEqual
                                                                        toItem:nil
                                                                     attribute:NSLayoutAttributeNotAnAttribute
                                                                    multiplier:1
                                                                      constant:grabberHangleView.frame.size.width];
    NSLayoutConstraint *heightConstraint = [NSLayoutConstraint constraintWithItem:grabberHangleView
                                                                        attribute:NSLayoutAttributeHeight
                                                                        relatedBy:NSLayoutRelationEqual
                                                                           toItem:nil
                                                                        attribute:NSLayoutAttributeNotAnAttribute
                                                                       multiplier:1
                                                                         constant:grabberHangleView.frame.size.height];
    
    NSLayoutConstraint *centerXConstraint = [NSLayoutConstraint constraintWithItem:grabberHangleView
                                                                         attribute:NSLayoutAttributeCenterX
                                                                         relatedBy:NSLayoutRelationEqual
                                                                            toItem:self
                                                                         attribute:NSLayoutAttributeCenterX
                                                                        multiplier:1
                                                                          constant:0];
    
    [NSLayoutConstraint activateConstraints:@[topConstraint, widthConstraint, heightConstraint, centerXConstraint]];
}

- (void)updateLayers {
    NSLog(@"SurfaceView bounds = %@", NSStringFromCGRect(self.bounds));
    CGRect rect = self.bounds;
    rect.size.height += self.bottomOverflow;
    UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:rect
                                                      byRoundingCorners:UIRectCornerTopLeft | UIRectCornerTopRight
                                                            cornerRadii:CGSizeMake(self.cornerRadius, self.cornerRadius)];
    self.backgroundLayer.path = path.CGPath;
    self.backgroundLayer.fillColor = self.backgroundColor_.CGColor;
    if (!self.shadowHidden) {
        self.layer.shadowColor = self.shadowColor.CGColor;
        self.layer.shadowOffset = self.shadowOffset;
        self.layer.shadowOpacity = self.shadowOpacity;
        self.layer.shadowRadius = self.shadowRadius;
    }
}


- (void)updateContentViewMask {
    if (@available(iOS 11.0, *)) {
        // Don't use `contentView.clipToBounds` because it prevents content view from expanding the height of a subview of it
        // for the bottom overflow like Auto Layout settings of UIVisualEffectView in Main.storyborad of Example/Maps.
        // Because the bottom of contentView must be fit to the bottom of a screen to work the `safeLayoutGuide` of a content VC.
        CAShapeLayer *maskLayer = [[CAShapeLayer alloc] init];
        CGRect rect = self.bounds;
        rect.size.height += self.bottomOverflow;
        UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:rect
                                                   byRoundingCorners:UIRectCornerTopLeft | UIRectCornerTopRight
                                                         cornerRadii:CGSizeMake(self.cornerRadius, self.cornerRadius)];
        maskLayer.path = path.CGPath;
        self.contentView.layer.mask = maskLayer;
        
    } else {
        // Don't use `contentView.layer.mask` because of a UIVisualEffectView issue in iOS 10, https://forums.developer.apple.com/thread/50854
        // Instead, a user can mask the content view manually in an application.
    }
}

#pragma mark - Setters
- (void)setBackgroundColor_:(UIColor *)backgroundColor_ {
    _backgroundColor_ = backgroundColor_;
    [self setNeedsDisplay];
}

- (void)setBackgroundLayer:(CAShapeLayer *)backgroundLayer {
    _backgroundLayer = backgroundLayer;
    [self setNeedsDisplay];
}

#pragma mark - Getters
- (UIColor *)backgroundColor {
    return self.backgroundColor_;
}

- (void)setBackgroundColor:(UIColor *)backgroundColor {
    self.backgroundColor_ = backgroundColor;
}

- (CGFloat)topGrabberBarHeight {
    return kGrabberTopPadding * 2 + GrabberHandleViewHeight;
}


#pragma mark - Action

#pragma mark - Delegate


@end
