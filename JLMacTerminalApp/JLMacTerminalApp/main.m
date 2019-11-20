//
//  main.m
//  JLMacTerminalApp
//
//  Created by Jacklin on 2019/11/20.
//  Copyright © 2019 Jacklin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <objc/runtime.h>
#import <malloc/malloc.h>

struct NSObject_IMPL {
    Class isa;
};

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        NSObject *obj = [[NSObject alloc] init];
        
        NSLog(@"class_getInstanceSize = %zd", class_getInstanceSize([NSObject class]));
        NSLog(@"malloc_size = %zd", malloc_size((__bridge const void *)(obj)));
        NSLog(@"sizeOf = %zd", sizeof(obj));
        
    }
    return 0;
}
