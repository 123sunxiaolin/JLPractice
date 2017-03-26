//
//  JLMainViewController.swift
//  JLQrCodePractice
//
//  Created by perfect on 2017/3/24.
//  Copyright © 2017年 JackLin. All rights reserved.
//

import UIKit

class JLMainViewController: UIViewController {

    private lazy var scanButton:UIButton! = {
        
        var button = UIButton(type: UIButtonType.Custom)
        button.frame = CGRect(x: 0, y: 0, width: 100, height: 50)
        button.setTitle("扫一扫", forState: UIControlState.Normal)
        button.setTitleColor(UIColor.orangeColor(), forState: UIControlState.Normal)
        button.backgroundColor = UIColor.lightGrayColor()
        button.addTarget(self, action: Selector("onClickScanButton:"), forControlEvents: UIControlEvents.TouchUpInside)
        button.layer.borderWidth = 2.0
        button.layer.cornerRadius = 3.0
        button.clipsToBounds = true

        return button
        
    }()
    
    
    //MARK:Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "扫一扫"
        self.view.backgroundColor = UIColor.whiteColor()
        self.view.addSubview(self.scanButton)
    }
    
    override func viewDidLayoutSubviews() {
        self.scanButton.center = self.view.center
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK:Action Method
    func onClickScanButton(sender:UIButton)->Void{
        let scanViewController = JLScanViewController()
        self.navigationController?.pushViewController(scanViewController, animated: true)
    }

}
