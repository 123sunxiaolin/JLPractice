//
//  AppDelegate.m
//  JLMailCore2Practice
//
//  Created by perfect on 2017/6/19.
//  Copyright © 2017年 JackLin. All rights reserved.
//

#import "AppDelegate.h"
#import "MainViewController.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    MainViewController *mainVC = [[MainViewController alloc] init];
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:mainVC];
    self.window.rootViewController = nav;
    [self.window makeKeyAndVisible];
    
    return YES;
}


- (void)applicationWillResignActive:(UIApplication *)application {
    
    //进入后台盖上view，实现模糊效果
    
    UIView* view = [[UIView alloc] initWithFrame:[UIScreen mainScreen].bounds];
    
    UIImageView *imageV = [[UIImageView alloc] initWithFrame:[UIScreen mainScreen].bounds];
    //获取当前视图控制器
    UIViewController *vc = [self getCurrentVC];
    //截取当前视图为图片
    imageV.image = [self snapshot:vc.view];
    
    //添加毛玻璃效果
    UIBlurEffect *blur = [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];
    UIVisualEffectView *effectview = [[UIVisualEffectView alloc] initWithEffect:blur];
    effectview.frame = [UIScreen mainScreen].bounds;
    [imageV addSubview:effectview];
    view.tag = 1111;
    [view addSubview:imageV];
    [self.window addSubview:view];
    
}

//获取当前屏幕显示的viewcontroller

- (UIViewController *)getCurrentVC
{
    UIViewController *result = nil;
    
    
    if (self.window.windowLevel != UIWindowLevelNormal)
    {
        NSArray *windows = [[UIApplication sharedApplication] windows];
        for(UIWindow * tmpWin in windows)
        {
            if (tmpWin.windowLevel == UIWindowLevelNormal)
            {
                self.window = tmpWin;
                break;
            }
        }
    }
    
    UIView *frontView = [[self.window subviews] lastObject];
    id nextResponder = [frontView nextResponder];
    
    if ([nextResponder isKindOfClass:[UIViewController class]]){
        result = nextResponder;
    }
    //    else{
    //        result = self.window.rootViewController;
    //    }
    return result;
}

//截取当前视图为图片
- (UIImage *)snapshot:(UIView *)view

{
    
    UIGraphicsBeginImageContextWithOptions(view.bounds.size, YES, 0);
    
    [view drawViewHierarchyInRect:view.bounds afterScreenUpdates:YES];
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    return image;
    
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}


- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}


@end
