//
//  AppDelegate.swift
//  JLQrCodePractice
//
//  Created by JackLin on 2017/3/24.
//  Copyright © 2017年 JackLin. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


     func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        
        self.window = UIWindow(frame: UIScreen.mainScreen().bounds)
        self.window?.backgroundColor = UIColor.whiteColor()
        let mainViewController = JLMainViewController()
        let nav = UINavigationController(rootViewController: mainViewController)
        self.window?.rootViewController = nav
        self.window?.makeKeyAndVisible()
        
        return true
    }


}

