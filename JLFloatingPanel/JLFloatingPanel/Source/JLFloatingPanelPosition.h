//
//  FloatingPanelPosition.h
//  JLFloatingPanel
//
//  Created by Jacklin on 2019/12/28.
//  Copyright © 2019 Jacklin. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, JLFloatingPanelPosition) {
    JLFloatingPanelPositionFull = 0,
    JLFloatingPanelPositionHalf,
    JLFloatingPanelPositionTip,
    JLFloatingPanelPositionHidden
};

@interface JLFloatingPanelPositionPresenter : NSObject

+ (NSArray <NSNumber *> *)allPositions;
+ (JLFloatingPanelPosition)nextPositionWithPosition:(JLFloatingPanelPosition)position inPositions:(NSArray <NSNumber *> *)position;
+ (JLFloatingPanelPosition)previousPositionWithPosition:(JLFloatingPanelPosition)position inPositions:(NSArray <NSNumber *> *)position;

@end
