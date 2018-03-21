//
//  MainNavigationController.swift
//  JLSwiftPractice
//
//  Created by jacklin on 2017/10/15.
//  Copyright © 2017年 jacklin. All rights reserved.
//

import UIKit

class MainNavigationController: UINavigationController {

    override func viewDidLoad() {
        super.viewDidLoad()

        let navBar = UINavigationBar.appearance()
        navBar.barTintColor = UIColor.white
        navBar.tintColor = UIColor(r:0, g: 0, b: 0, alpha: 0.7)
        navBar.titleTextAttributes = [NSFontAttributeName: UIFont.systemFont(ofSize: 17)];
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    override func pushViewController(_ viewController: UIViewController, animated: Bool) {
       
        if viewControllers.count > 0{
            viewController.hidesBottomBarWhenPushed = true
            let barItemImage = UIImage(named: "lefterbackicon_titlebar_24x24_")
            viewController.navigationItem.leftBarButtonItem = UIBarButtonItem(image: barItemImage, style: UIBarButtonItemStyle, target: self, action: #selector(navigationBack))
        }
        super.pushViewController(viewController, animated: true)
    }
    
    @objc private func navigationBack(){
        popViewController(animated: true)
    }
    
}

extension MainNavigationController: UIGestureRecognizerDelegate{
    
    fileprivate func initGlobalPan(){
        
        let target = interactivePopGestureRecognizer?.delegate;
        let globalPan = UIPanGestureRecognizer(target: target, action: Selector(("handleNavigationTransition:")));
        globalPan.delegate = self;
        self.view.addGestureRecognizer(globalPan)
        //2.禁止系统的手势
        navigationController?.interactivePopGestureRecognizer?.isEnabled = false
        
    }
    
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        return self.childViewControllers.count != 1
    }
    
}




