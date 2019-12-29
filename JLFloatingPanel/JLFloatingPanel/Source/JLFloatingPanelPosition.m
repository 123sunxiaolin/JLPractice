//
//  JLFloatingPanelPosition.m
//  JLFloatingPanel
//
//  Created by Jacklin on 2019/12/29.
//  Copyright © 2019 Jacklin. All rights reserved.
//

#import "JLFloatingPanelPosition.h"

@implementation JLFloatingPanelPositionPresenter

+ (NSArray <NSNumber *> *)allPositions {
    return @[@(JLFloatingPanelPositionFull),
             @(JLFloatingPanelPositionHalf),
             @(JLFloatingPanelPositionTip),
             @(JLFloatingPanelPositionHidden)];
}

+ (JLFloatingPanelPosition)nextPositionWithPosition:(JLFloatingPanelPosition)position inPositions:(NSArray <NSNumber *> *)positions {
    if (!positions.count) return position;
    NSInteger index = 0;
    for (NSInteger i = 0; i < positions.count; i ++) {
        if ((JLFloatingPanelPosition)positions[i].integerValue == position) {
            index = i;
            break;
        }
    }
    if (index + 1 >= positions.count) return position;
    return (JLFloatingPanelPosition)positions[index + 1].integerValue;
}

+ (JLFloatingPanelPosition)previousPositionWithPosition:(JLFloatingPanelPosition)position inPositions:(NSArray <NSNumber *> *)positions {
    if (!positions.count) return position;
    NSInteger index = 0;
    for (NSInteger i = 0; i < positions.count; i ++) {
        if ((JLFloatingPanelPosition)positions[i].integerValue == position) {
            index = i;
            break;
        }
    }
    if (index - 1 >= positions.count) return position;
    return (JLFloatingPanelPosition)positions[index - 1].integerValue;
}


@end
