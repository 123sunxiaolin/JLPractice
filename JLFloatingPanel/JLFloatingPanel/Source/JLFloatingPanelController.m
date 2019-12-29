//
//  JLFloatingPanelController.m
//  JLFloatingPanel
//
//  Created by Jacklin on 2019/12/28.
//  Copyright © 2019 Jacklin. All rights reserved.
//

#import "JLFloatingPanelController.h"
#import "JLFloatingPanelCore.h"
#import "JLFloatingPanelTransitioning.h"
#import "JLFloatingPanelPassThroughView.h"
#import "JLFloatingPanelSurfaceView.h"
#import "JLFloatingPanelBackdropView.h"
#import "UIVIewExtension.h"

@interface JLFloatingPanelController ()

@property (nonatomic, strong) JLFloatingPanelCore *floatingPanel;

/// Capture the latest one
@property (nonatomic, assign) UIEdgeInsets preSafeAreaInsets;

@property (nonatomic, strong) JLFloatingPanelModalPresentTransition *modalTransition;

@end

@implementation JLFloatingPanelController

#pragma mark - Initialize
- (instancetype)init {
    if (self = [super init]) {
        [self setUp];
    }
    return self;
}

- (instancetype)initWithDelegate:(id<JLFloatingPanelControllerDelegate>)delegate {
    if (self = [super init]) {
        self.delegate = delegate;
        [self setUp];
    }
    return self;
}

#pragma mark - Life Cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)loadView {
    NSAssert(self.storyboard == nil, @"Storyboard isn't supported");
    
    JLFloatingPanelPassThroughView *view = [[JLFloatingPanelPassThroughView alloc] init];
    view.backgroundColor = [UIColor clearColor];
    
    self.backdropView.frame = view.bounds;
    [view addSubview:self.backdropView];
    
    self.surfaceView.frame = view.bounds;
    [view addSubview:self.surfaceView];
    
    self.view = view;
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    if (@available(iOS 11.0, *)) {
    } else {
        // Because {top,bottom}LayoutGuide is managed as a view
        if (!UIEdgeInsetsEqualToEdgeInsets(self.preSafeAreaInsets, self.layoutInsets)
            && !self.floatingPanel.isDecelerating) {
            [self updateSafeAreaInsets:self.layoutInsets];
        }
    }
}

- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator {
    [super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];
    
    if (self.view.translatesAutoresizingMaskIntoConstraints) {
        CGRect rect = self.view.frame;
        rect.size = size;
        self.view.frame = rect;
        [self.view layoutIfNeeded];
    }
}

- (void)willTransitionToTraitCollection:(UITraitCollection *)newCollection withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator {
    
}

#pragma mark - Private
- (void)setUp {
    
}

- (void)initializeValues {
    self.contentInsetAdjustmentBehavior = JLContentInsetAdjustmentBehaviorAlways;
    self.contentMode = JLContentModeStatic;
    self.modalTransition = [[JLFloatingPanelModalPresentTransition alloc] init];
    
}

- (void)didUpdateDelegate {
    self.floatingPanel.layoutAdapter.layout = [self fetchLayoutWithTraitCollection:self.traitCollection];
    self.floatingPanel.behavior = [self fetchBehaviorWithTraitCollection:self.traitCollection];
}

- (id <JLFloatingPanelLayout>)fetchLayoutWithTraitCollection:(UITraitCollection *)traitCollection {
    switch (traitCollection.verticalSizeClass) {
            //monitor whether is split
        case UIUserInterfaceSizeClassCompact:
            if ([self.delegate respondsToSelector:@selector(floatingPanelWithFpc:layoutForNewCollection:)]) {
                return [self.delegate floatingPanelWithFpc:self
                                    layoutForNewCollection:traitCollection];
            }
            return [JLFloatingPanelDefaultLandscapeLayout new];
            break;
            
        default:
            if ([self.delegate respondsToSelector:@selector(floatingPanelWithFpc:layoutForNewCollection:)]) {
                return [self.delegate floatingPanelWithFpc:self
                                    layoutForNewCollection:traitCollection];
            }
            return [JLFloatingPanelDefaultLayout new];
            break;
    }
}

- (id <JLFloatingPanelBehavior>)fetchBehaviorWithTraitCollection:(UITraitCollection *)traitCollection {
    
    if ([self.delegate respondsToSelector:@selector(floatingPanelWithFpc:behaviorForNewCollection:)]) {
        return [self.delegate floatingPanelWithFpc:self
        behaviorForNewCollection:traitCollection];
    }
    return [[JLFloatingPanelDefaultBehavior alloc] init];
    
}

- (void)updateSafeAreaInsets:(UIEdgeInsets)safeAreaInsets {
    if (UIEdgeInsetsEqualToEdgeInsets(self.preSafeAreaInsets, safeAreaInsets)) return;
    NSLog(@"Update safeAreaInsets:%@", NSStringFromUIEdgeInsets(safeAreaInsets));
    
    // Prevent an infinite loop on iOS 10: setUpLayout() -> viewDidLayoutSubviews() -> setUpLayout()
    self.preSafeAreaInsets = safeAreaInsets;
    
    [self activateLayout];
    switch (self.contentInsetAdjustmentBehavior) {
        case JLContentInsetAdjustmentBehaviorAlways:
            self.scrollView.contentInset = self.adjustedContentInsets;
            self.scrollView.scrollIndicatorInsets = self.adjustedContentInsets;
            break;
        default:
            break;
    }
}

- (void)activateLayout {
    [self.floatingPanel.layoutAdapter prepareLayoutInViewController:self];
    
    // preserve the current content offset
    CGPoint contentOffset = self.scrollView.contentOffset;
    [self.floatingPanel.layoutAdapter updateHeight];
    [self.floatingPanel.layoutAdapter activateLayoutWithPosition:self.floatingPanel.state];
    
    if (!self.scrollView) {
        contentOffset = CGPointZero;
    }
    self.scrollView.contentOffset = contentOffset;
}

#pragma mark - Getters
- (void)setDelegate:(id<JLFloatingPanelControllerDelegate>)delegate {
    _delegate = delegate;
    [self didUpdateDelegate];
}

#pragma mark - Action

#pragma mark - Delegate

@end
