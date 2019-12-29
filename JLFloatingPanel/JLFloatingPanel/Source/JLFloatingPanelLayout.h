//
//  JLFloatingPanelLayout.h
//  JLFloatingPanel
//
//  Created by Jacklin on 2019/12/28.
//  Copyright © 2019 Jacklin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JLFloatingPanelLayoutProtocol.h"

NS_ASSUME_NONNULL_BEGIN

@interface JLLayoutSegment : NSObject

@property (nonatomic, strong) NSNumber *lower;
@property (nonatomic, strong) NSNumber *upper;

+ (instancetype)segmentWithLower:(NSNumber * __nullable)lower upper:(NSNumber  * __nullable)upper;

@end

@interface JLFloatingPanelDefaultLayout : NSObject <JLFloatingPanelLayout>

@end

@interface JLFloatingPanelDefaultLandscapeLayout : NSObject<JLFloatingPanelFullScreenLayout>

@end

@class JLFloatingPanelController,
JLFloatingPanelSurfaceView,
JLFloatingPanelBackdropView;
@interface JLFloatingPanelLayoutAdapter : NSObject

@property (nonatomic, weak) id <JLFloatingPanelLayout> layout;

@property (nonatomic, weak) JLFloatingPanelController *panelController;

- (void)updateHeight;
- (void)activateLayoutWithPosition:(JLFloatingPanelPosition)position;
- (void)prepareLayoutInViewController:(JLFloatingPanelController *)panelController;

- (instancetype)initWithSurfaceView:(JLFloatingPanelSurfaceView *)surfaceView
                       backdropView:(JLFloatingPanelBackdropView *)backdropView
                             layout:(id <JLFloatingPanelLayout>)lauout;

@end

NS_ASSUME_NONNULL_END
