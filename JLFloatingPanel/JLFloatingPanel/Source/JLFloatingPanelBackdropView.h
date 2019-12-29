//
//  JLFloatingPanelBackdropView.h
//  JLFloatingPanel
//
//  Created by Jacklin on 2019/12/28.
//  Copyright © 2019 Jacklin. All rights reserved.
//
@import UIKit;

NS_ASSUME_NONNULL_BEGIN

/*
 A view that presents a backdrop interface behind a floating panel.
 */
@interface JLFloatingPanelBackdropView : UIView

@property (nonatomic, strong) UITapGestureRecognizer *dismissalTapGestureRecognizer;

@end

NS_ASSUME_NONNULL_END
