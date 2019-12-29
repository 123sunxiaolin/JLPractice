//
//  JLFloatingPanelCore.h
//  JLFloatingPanel
//
//  Created by Jacklin on 2019/12/29.
//  Copyright © 2019 Jacklin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JLFloatingPanelPosition.h"

NS_ASSUME_NONNULL_BEGIN

@class JLFloatingPanelLayoutAdapter;
@protocol JLFloatingPanelBehavior;
@interface JLFloatingPanelCore : NSObject

@property (nonatomic, strong) JLFloatingPanelLayoutAdapter *layoutAdapter;
@property (nonatomic, strong) id <JLFloatingPanelBehavior> behavior;

@property (nonatomic, assign) JLFloatingPanelPosition state;

@property (nonatomic, assign) BOOL isDecelerating;

@end

NS_ASSUME_NONNULL_END
