//
//  RunloopSource.m
//  TestRunloop
//
//  Created by 时信互联 on 2018/10/11.
//  Copyright © 2018年 Jacklin. All rights reserved.
//

#import "RunloopSource.h"
#import "AppDelegate.h"

void RunLoopSourceScheduleRoutine(void *info, CFRunLoopRef rl, CFStringRef mode);
void RunLoopSourcePerformRoutine(void *info);
void RunLoopSourceCancelRoutine(void *info, CFRunLoopRef rl, CFStringRef mode);

@interface RunloopSource(){
    CFRunLoopSourceRef runloopSource;
    NSMutableArray *commands;
}

@end

@implementation RunloopSource

- (instancetype)init{
    if (self = [super init]) {
        
        CFRunLoopSourceContext runloopContext = {0, (__bridge void *)(self), NULL, NULL, NULL, NULL, NULL, &RunLoopSourceScheduleRoutine, &RunLoopSourceCancelRoutine, &RunLoopSourcePerformRoutine};
        runloopSource = CFRunLoopSourceCreate(NULL, 0, &runloopContext);
        commands = [[NSMutableArray alloc] init];
    }
    
    return self;
}

- (void)addToCurrentRunloop{
    CFRunLoopRef runloop = CFRunLoopGetCurrent();
    CFRunLoopAddSource(runloop, runloopSource, kCFRunLoopDefaultMode);
}

- (void)invalidate{
    CFRunLoopRef runloop = CFRunLoopGetCurrent();
    CFRunLoopRemoveSource(runloop, runloopSource, kCFRunLoopDefaultMode);
}

- (void)sourceFired{
    
}

- (void)fireAllCommandsOnRunloop:(CFRunLoopRef)runloop{
    CFRunLoopSourceSignal(runloopSource);
    CFRunLoopWakeUp(runloop);
}

#pragma mark - Runloop CallBack
void RunLoopSourceScheduleRoutine(void *info, CFRunLoopRef rl, CFStringRef mode){
    
    RunloopSource *source = (__bridge RunloopSource *)info;
    AppDelegate *delegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    RunLoopContext *context = [[RunLoopContext alloc] initWithRunloop:rl source:source];
    
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wundeclared-selector"
    
    [delegate performSelectorOnMainThread:@selector(registerSource:)
                               withObject:context
                            waitUntilDone:NO];
    
#pragma clang diagnostic pop
   
}

void RunLoopSourceCancelRoutine(void *info, CFRunLoopRef rl, CFStringRef mode){
    
    RunloopSource *source = (__bridge RunloopSource *)info;
    AppDelegate *delegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    RunLoopContext *context = [[RunLoopContext alloc] initWithRunloop:rl source:source];
    
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wundeclared-selector"
    
    [delegate performSelectorOnMainThread:@selector(removeSource:)
                               withObject:context
                            waitUntilDone:NO];
    
#pragma clang diagnostic pop
}


void RunLoopSourcePerformRoutine(void *info){
    
    RunloopSource *source = (__bridge RunloopSource *)info;
    [source sourceFired];
}


@end


@interface RunLoopContext(){
    RunloopSource *source;
    CFRunLoopRef runloop;
}

@end

@implementation RunLoopContext

- (instancetype)initWithRunloop:(CFRunLoopRef)runloop source:(RunloopSource *)source{
    if (self = [super init]) {
        source = source;
        runloop = runloop;
    }
    
    return self;
}

- (CFRunLoopRef)runloop{
    return runloop;
}

- (RunloopSource *)source{
    return source;
}

@end

