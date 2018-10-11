//
//  RunloopSource.h
//  TestRunloop
//
//  Created by 时信互联 on 2018/10/11.
//  Copyright © 2018年 Jacklin. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RunloopSource : NSObject

- (instancetype)init;
- (void)addToCurrentRunloop;
- (void)invalidate;

// Handler method
- (void)sourceFired;
- (void)fireAllCommandsOnRunloop:(CFRunLoopRef)runloop;

@end


@interface RunLoopContext:NSObject

@property (nonatomic, strong, readonly) RunloopSource *source;
@property (readonly) CFRunLoopRef runloop;

- (instancetype)initWithRunloop:(CFRunLoopRef)runloop source:(RunloopSource *)source;

@end


