//
//  ViewController.m
//  SamplesObjC
//
//  Created by Shin Yamamoto on 2018/12/07.
//  Copyright © 2018 Shin Yamamoto. All rights reserved.
//

#import "ViewController.h"
@import FloatingPanelObjC;

@interface FloatingPanelMyLayout: NSObject<FloatingPanelLayout>
@end

@implementation FloatingPanelMyLayout

- (FloatingPanelPosition)initialPosition {
    return FloatingPanelPositionTip;
}

- (CGFloat)bottomInteractionBuffer {
    return 6.0;
}

- (CGFloat)topInteractionBuffer {
    return 6.0;
}
- (NSSet<FloatingPanelPosition> *)supportedPositions {
    return [[NSSet alloc] initWithArray:@[FloatingPanelPositionFull, FloatingPanelPositionHalf, FloatingPanelPositionTip]];
}

- (CGFloat)backdropAlphaForPosition:(FloatingPanelPosition _Nonnull)position {
    return 0.3;
}

- (NSNumber * _Nullable)insetForPosition:(FloatingPanelPosition _Nonnull)position {
    if ([position isEqualToString:FloatingPanelPositionFull]) {
        return @18.0;
    }

    if ([position isEqualToString:FloatingPanelPositionTip]) {
        return @64.0;
    }

    return nil;
}

- (NSArray<NSLayoutConstraint *> * _Nonnull)prepareLayoutWithSurfaceView:(UIView * _Nonnull)surfaceView inView:(UIView * _Nonnull)view {
    return @[
            [surfaceView.leftAnchor constraintEqualToAnchor:view.leftAnchor constant:0.0],
            [surfaceView.rightAnchor constraintEqualToAnchor:view.rightAnchor constant:0.0]
            ];
}

@end

@interface ViewController ()<FloatingPanelControllerDelegate>
@property FloatingPanelController *fpc;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];

//    self.fpAdapter = [[FloatingPanelAdapter alloc] init];
//    [self.fpAdapter addPanelWithVc:self];

    self.fpc = [[FloatingPanelController alloc] init];
//    [self.fpc setContentViewController:nil];
//    [self.fpc trackScrollView:nil];
    [self.fpc setDelegate:self];
//    [self.fpc show:true completion:nil];
//    [self.fpc hide:true completion:nil];
    [self.fpc addPanelToParent:self belowView:nil animated:true];
//    [self.fpc removePanelFromParent:true completion:nil];
//    [self.fpc moveTo:FloatingPanelPositionTip animated:true completion:nil];
}

- (id<FloatingPanelBehavior> _Nullable)floatingPanel:(FloatingPanelController * _Nonnull)vc behaviorFor:(UITraitCollection * _Nonnull)newCollection {
    return nil;
}

- (id<FloatingPanelLayout> _Nullable)floatingPanel:(FloatingPanelController * _Nonnull)vc layoutFor:(UITraitCollection * _Nonnull)newCollection {
    return [[FloatingPanelMyLayout alloc] init];
}

- (BOOL)floatingPanel:(FloatingPanelController * _Nonnull)vc shouldRecognizeSimultaneouslyWith:(UIGestureRecognizer * _Nonnull)gestureRecognizer {
    return false;
}

- (void)floatingPanelDidChangePosition:(FloatingPanelController * _Nonnull)vc { }
- (void)floatingPanelDidEndDecelerating:(FloatingPanelController * _Nonnull)vc { }
- (void)floatingPanelDidEndDragging:(FloatingPanelController * _Nonnull)vc withVelocity:(CGPoint)velocity targetPosition:(FloatingPanelPosition _Nonnull)targetPosition { }
- (void)floatingPanelDidEndDraggingToRemove:(FloatingPanelController * _Nonnull)vc withVelocity:(CGPoint)velocity { }
- (void)floatingPanelDidEndRemove:(FloatingPanelController * _Nonnull)vc { }
- (void)floatingPanelDidMove:(FloatingPanelController * _Nonnull)vc { }
- (void)floatingPanelWillBeginDecelerating:(FloatingPanelController * _Nonnull)vc { }
- (void)floatingPanelWillBeginDragging:(FloatingPanelController * _Nonnull)vc { }

@end
