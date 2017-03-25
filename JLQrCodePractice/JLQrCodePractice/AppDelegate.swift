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


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        self.window = UIWindow(frame: UIScreen.main.bounds)
        self.window?.backgroundColor = UIColor.white
        let mainViewController = JLMainViewController()
        let nav = UINavigationController(rootViewController: mainViewController)
        self.window?.rootViewController = nav
        self.window?.makeKeyAndVisible()
        
        return true
    }


}

