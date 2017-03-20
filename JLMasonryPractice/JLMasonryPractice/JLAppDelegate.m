//
//  AppDelegate.m
//  JLMasonryPractice
//
//  Created by perfect on 2017/3/17.
//  Copyright © 2017年 JackLin. All rights reserved.
//

#import "JLAppDelegate.h"
#import "JLMainViewController.h"

@interface JLAppDelegate ()

@end

@implementation JLAppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    self.window.backgroundColor = [UIColor whiteColor];
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:[JLMainViewController new]];
    self.window.rootViewController = nav;
    [self.window makeKeyAndVisible];
    return YES;
}

@end
