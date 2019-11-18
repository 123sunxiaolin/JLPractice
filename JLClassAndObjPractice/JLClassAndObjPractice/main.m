//
//  main.m
//  JLClassAndObjPractice
//
//  Created by Jacklin on 2019/11/18.
//  Copyright © 2019 Jacklin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"

int main(int argc, char * argv[]) {
    NSString * appDelegateClassName;
    @autoreleasepool {
        // Setup code that might create autoreleased objects goes here.
        appDelegateClassName = NSStringFromClass([AppDelegate class]);
        
        // 创建一个NSObject对象
        NSObject *obj = [[NSObject alloc] init];
        
    }
    return UIApplicationMain(argc, argv, nil, appDelegateClassName);
}
