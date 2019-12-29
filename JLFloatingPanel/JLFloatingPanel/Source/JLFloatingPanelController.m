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
#import <Objc/runtime.h>

@interface JLFloatingPanelController () {
    UIViewController *_contentViewController_;
}

@property (nonatomic, strong) JLFloatingPanelCore *floatingPanel;

/// Capture the latest one
@property (nonatomic, assign) UIEdgeInsets preSafeAreaInsets;

@property (nonatomic, strong) JLFloatingPanelModalTransition *modalTransition;

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

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    // Remove KVO
    [self removeObserver:self.view forKeyPath:@"safeAreaInsets"];
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
    [super willTransitionToTraitCollection:newCollection
                 withTransitionCoordinator:coordinator];
    [self prepareForNewCollection:newCollection];
}

- (void)showViewController:(UIViewController *)vc sender:(id)sender {
    UIViewController *target = [self.parentViewController targetViewControllerForAction:@selector(showViewController:sender:) sender:sender];
    if (target) {
        [target showViewController:vc sender:sender];
    }
}

- (void)showDetailViewController:(UIViewController *)vc sender:(id)sender {
    UIViewController *target = [self.parentViewController targetViewControllerForAction:@selector(showDetailViewController:sender:) sender:sender];
    if (target) {
        [target showDetailViewController:vc sender:sender];
    }
}

#pragma mark - Public
- (void)setContentVC:(UIViewController *)contentViewController {
    if (_contentViewController_) {
        [_contentViewController_ willMoveToParentViewController:nil];
        [_contentViewController_.view removeFromSuperview];
        [_contentViewController_ removeFromParentViewController];
    }
    
    if (contentViewController) {
        [self addChildViewController:contentViewController];
        [self.floatingPanel.surfaceView addContentView:contentViewController.view];
        [contentViewController didMoveToParentViewController:self];
    }
    _contentViewController_ = contentViewController;
}

- (void)showWithAnimated:(BOOL)animated completion:(dispatch_block_t)completion {
    // Must apply the current layout here
    [self reloadLayoutForTraitCollection:self.traitCollection];
    [self activateLayout];
    
    if (@available(iOS 11.0, *)) {
        // Must track the safeAreaInsets of `self.view` to update the layout.
        // There are 2 reasons.
        // 1. This or the parent VC doesn't call viewSafeAreaInsetsDidChange() on the bottom
        // inset's update expectedly.
        // 2. The safe area top inset can be variable on the large title navigation bar(iOS11+).
        // That's why it needs the observation to keep `adjustedContentInsets` correct.
        [self addObserver:self.view
               forKeyPath:@"safeAreaInsets"
                  options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionOld
                  context:nil];
    } else {
        // KVOs for topLayoutGuide & bottomLayoutGuide are not effective.
        // Instead, update(safeAreaInsets:) is called at `viewDidLayoutSubviews()`
    }
    
    [self moveToPosition:self.floatingPanel.layoutAdapter.layout.initialPostion
                animated:animated
              completion:completion];
}

- (void)hideWithAnimated:(BOOL)animated completion:(dispatch_block_t __nullable)completion {
    [self moveToPosition:JLFloatingPanelPositionHidden animated:animated completion:completion];
}

- (void)addPanelToParentViewController:(UIViewController *)parent belowView:(UIView *)belowView animated:(BOOL)animated {
    if (self.parentViewController) {
        NSLog(@"Already added to a parent(%@)", self.parentViewController);
        return;
    }
    
    NSAssert(![parent isKindOfClass:[UINavigationController class]], @"UINavigationController displays only one child view controller at a time.");
    NSAssert(![parent isKindOfClass:[UITabBarController class]], @"UITabBarController displays child view controllers with a radio-style selection interface");
    NSAssert(![parent isKindOfClass:[UISplitViewController class]], @"UISplitViewController manages two child view controllers in a master-detail interface");
    NSAssert(![parent isKindOfClass:[UITableViewController class]], @"UITableViewController should not be the parent because the view is a table view so that a floating panel doens't work well");
    NSAssert(![parent isKindOfClass:[UICollectionViewController class]], @"UICollectionViewController should not be the parent because the view is a collection view so that a floating panel doens't work well");
    
    if (belowView) {
        [parent.view insertSubview:self.view belowSubview:belowView];
    } else {
        [parent.view addSubview:self.view];
    }
    
    [parent addChildViewController:self];
    
    // Needed for a correct safe area configuration
    self.view.frame = parent.view.bounds;
    self.view.translatesAutoresizingMaskIntoConstraints = NO;
    
    NSLayoutConstraint *top = [NSLayoutConstraint constraintWithItem:self.view
                                                           attribute:NSLayoutAttributeTop
                                                           relatedBy:NSLayoutRelationEqual
                                                              toItem:parent.view
                                                           attribute:NSLayoutAttributeTop
                                                          multiplier:1
                                                            constant:0];
    NSLayoutConstraint *bottom = [NSLayoutConstraint constraintWithItem:self.view
                                                              attribute:NSLayoutAttributeBottom
                                                              relatedBy:NSLayoutRelationEqual
                                                                 toItem:parent.view
                                                              attribute:NSLayoutAttributeBottom
                                                             multiplier:1
                                                               constant:0];
    NSLayoutConstraint *left = [NSLayoutConstraint constraintWithItem:self.view
                                                                 attribute:NSLayoutAttributeLeft
                                                                 relatedBy:NSLayoutRelationEqual
                                                                    toItem:parent.view
                                                                 attribute:NSLayoutAttributeLeft
                                                                multiplier:1
                                                                  constant:0];
    NSLayoutConstraint *right = [NSLayoutConstraint constraintWithItem:self.view
                                                             attribute:NSLayoutAttributeRight
                                                             relatedBy:NSLayoutRelationEqual
                                                                toItem:parent.view
                                                             attribute:NSLayoutAttributeRight
                                                            multiplier:1
                                                              constant:0];
    [NSLayoutConstraint activateConstraints:@[top, bottom, left, right]];
    
    __weak typeof(self) weakSelf = self;
    [self showWithAnimated:animated completion:^{
        [weakSelf didMoveToParentViewController:parent];
    }];
}

- (void)removePanelFromParentWithAnimated:(BOOL)animated completion:(dispatch_block_t)completion {
    if (!self.parentViewController) {
        if (completion) {
            completion();
        }
        return;
    }
    
    __weak typeof(self) weakSelf = self;
    [self hideWithAnimated:animated completion:^{
        [weakSelf willMoveToParentViewController:nil];
        [weakSelf.view removeFromSuperview];
        [weakSelf removeFromParentViewController];
        
        if (completion) {
            completion();
        }
    }];
}

- (void)moveToPosition:(JLFloatingPanelPosition)position animated:(BOOL)animated completion:(dispatch_block_t)completion {
    NSAssert(self.floatingPanel.layoutAdapter.panelController != nil, @"Use show(animated:completion)");
    [self.floatingPanel moveToPosition:position animated:animated completion:completion];
}

- (void)trackWithScrollView:(UIScrollView *)scrollView {
    if (!scrollView) {
        self.floatingPanel.scrollView = nil;
        return;
    }
    
    self.floatingPanel.scrollView = scrollView;
    
    switch (self.contentInsetAdjustmentBehavior) {
        case JLContentInsetAdjustmentBehaviorAlways: {
            if (@available(iOS 11.0, *)) {
                scrollView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
            } else {
                for (UIViewController *child in self.childViewControllers) {
                    child.automaticallyAdjustsScrollViewInsets = NO;
                }
            }
        }
            break;
            
        default:
            break;
    }
}

- (void)updateLayout {
    [self reloadLayoutForTraitCollection:self.traitCollection];
    [self activateLayout];
}

- (CGFloat)originYOfSurfaceForPosition:(JLFloatingPanelPosition)position {
    return [self.floatingPanel.layoutAdapter positionYForPosition:position];
}

#pragma mark - KVO
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    if ([keyPath isEqualToString:@"safeAreaInsets"]) {
        UIEdgeInsets oldEdgeInset = [[change objectForKey:NSKeyValueChangeOldKey] UIEdgeInsetsValue];
        UIEdgeInsets newEdgeInset = [[change objectForKey:NSKeyValueChangeNewKey] UIEdgeInsetsValue];
        if (!UIEdgeInsetsEqualToEdgeInsets(newEdgeInset, oldEdgeInset)) {
            [self updateSafeAreaInsets:self.layoutInsets];
        }
    }
}

#pragma mark - Private
- (void)setUp {
    [self dismissSwizzling];
    
    self.modalPresentationStyle = UIModalPresentationCustom;
    self.transitioningDelegate = self.modalTransition;
    self.floatingPanel = [[JLFloatingPanelCore alloc] initWithFpc:self
                                                           layout:[self fetchLayoutWithTraitCollection:self.traitCollection]
                                                         behavior:[self fetchBehaviorWithTraitCollection:self.traitCollection]];
}

- (void)initializeValues {
    self.contentInsetAdjustmentBehavior = JLContentInsetAdjustmentBehaviorAlways;
    self.contentMode = JLContentModeStatic;
    self.modalTransition = [[JLFloatingPanelModalTransition alloc] init];
    
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

- (void)prepareForNewCollection:(UITraitCollection *)collection {
    if (![collection shouldUpdateLayoutWithPreviousCollection:self.traitCollection]) return;
    // Change a layout & behavior for a new trait collection
    [self reloadLayoutForTraitCollection:collection];
    [self activateLayout];
    self.floatingPanel.behavior = [self fetchBehaviorWithTraitCollection:collection];
}

- (void)reloadLayoutForTraitCollection:(UITraitCollection *)traitCollection {
    self.floatingPanel.layoutAdapter.layout = [self fetchLayoutWithTraitCollection:traitCollection];
    
    if (self.parentViewController) {
        if ([self.layout isKindOfClass:[UIViewController class]]
            && (UIViewController *)self.layout == self.parentViewController) {
            NSLog(@"A memory leak will occur by a retain cycle because %@ owns the parent view controller(%@) as the layout object. Don't let the parent adopt FloatingPanelLayout.", self, self.parentViewController);
        }
        
        if ([self.behavior isKindOfClass:[UIViewController class]]
            && (UIViewController *)self.behavior == self.parentViewController) {
            NSLog(@"A memory leak will occur by a retain cycle because %@ owns the parent view controller(%@) as the behavior object. Don't let the parent adopt FloatingPanelBehavior.", self, self.parentViewController);
        }
    }
}

#pragma mark - Setters
- (void)setDelegate:(id<JLFloatingPanelControllerDelegate>)delegate {
    _delegate = delegate;
    [self didUpdateDelegate];
}

- (void)setContentMode:(JLContentMode)contentMode {
    _contentMode = contentMode;
    [self activateLayout];
}

- (void)setIsRemovalInteractionEnabled:(BOOL)isRemovalInteractionEnabled {
    self.floatingPanel.isRemovalInteractionEnabled = isRemovalInteractionEnabled;
}

- (void)setContentViewController:(UIViewController *)contentViewController {
    [self setContentViewController:contentViewController];
}

#pragma mark - Getters

- (JLFloatingPanelSurfaceView *)surfaceView {
    return self.floatingPanel.surfaceView;
}

- (JLFloatingPanelBackdropView *)backdropView {
    return self.floatingPanel.backdropView;
}

- (UIScrollView *)scrollView {
    return self.floatingPanel.scrollView;
}

- (UIPanGestureRecognizer *)panGestureRecognizer {
    return self.floatingPanel.panGestureRecognizer;
}

- (JLFloatingPanelPosition)position {
    return self.floatingPanel.state;
}

- (id<JLFloatingPanelLayout>)layout {
    return self.floatingPanel.layoutAdapter.layout;
}

- (id<JLFloatingPanelBehavior>)behavior {
    return self.floatingPanel.behavior;
}

- (UIEdgeInsets)adjustedContentInsets {
    return self.floatingPanel.layoutAdapter.adjustedContentInsets;
}

- (BOOL)isRemovalInteractionEnabled {
    return  self.floatingPanel.isRemovalInteractionEnabled;
}

- (UIViewController *)contentViewController {
    return _contentViewController_;
}



#pragma mark - Action

#pragma mark - Delegate

@end


@implementation UIViewController (Swizzing)

- (void)dismissSwizzling {
    Class clazz = object_getClass(self);
    IMP imp = class_getMethodImplementation(clazz, @selector(dismissViewControllerAnimated:completion:));
    Method originaLMethod = class_getInstanceMethod(clazz, @selector(fp_original_dismissWithAnimated:completion:));
    if (imp && originaLMethod) {
        method_setImplementation(originaLMethod, imp);
    }
    
    Method originalMethod = class_getInstanceMethod(clazz, @selector(dismissViewControllerAnimated:completion:));
    Method swizzleMethod = class_getInstanceMethod(clazz, @selector(fp_dismissWithAnimated:completion:));
    
    if (originalMethod && swizzleMethod) {
        method_exchangeImplementations(originalMethod, swizzleMethod);
    }
}

#pragma mark - Private
- (void)fp_original_dismissWithAnimated:(BOOL)animated completion:(dispatch_block_t)completion {
    // Implementation will be replaced by IMP of self.dismiss(animated:completion:)
}

- (void)fp_dismissWithAnimated:(BOOL)animated completion:(dispatch_block_t)completion {
    // Call dismiss(animated:completion:) to a content view controller
    if ([self.parentViewController isKindOfClass:[JLFloatingPanelController class]]) {
        if (self.parentViewController.presentingViewController) {
            [self fp_original_dismissWithAnimated:animated completion:completion];
        } else {
            [(JLFloatingPanelController *)self.parentViewController removePanelFromParentWithAnimated:animated completion:completion];
        }
        return;
    }
    
    // Call dismiss(animated:completion:) to FloatingPanelController directly
    if ([self isKindOfClass:[JLFloatingPanelController class]]) {
        if (self.presentingViewController) {
            [self fp_original_dismissWithAnimated:animated completion:completion];
        } else {
            [(JLFloatingPanelController *)self removePanelFromParentWithAnimated:animated completion:completion];
        }
        return;
    }
    
    // For other view controllers
    [self fp_original_dismissWithAnimated:animated completion:completion];
}

@end
