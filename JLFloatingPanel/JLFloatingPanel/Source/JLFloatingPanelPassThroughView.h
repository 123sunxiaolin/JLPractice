//
//  JLFloatingPanelPassThroughView.h
//  JLFloatingPanel
//
//  Created by Jacklin on 2019/12/28.
//  Copyright © 2019 Jacklin. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface JLFloatingPanelPassThroughView : UIView

@property (nonatomic, weak) UIView *eventForwardingView;

@end

NS_ASSUME_NONNULL_END
