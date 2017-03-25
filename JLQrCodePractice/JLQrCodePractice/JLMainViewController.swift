//
//  JLMainViewController.swift
//  JLQrCodePractice
//
//  Created by perfect on 2017/3/24.
//  Copyright © 2017年 JackLin. All rights reserved.
//

import UIKit

class JLMainViewController: UIViewController {

    lazy var scanButton:UIButton = {
        var button = UIButton.init(type: UIButtonType.custom)
        return button
        
    }
    
    
    //MARK:Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "扫一扫"
        self.view.backgroundColor = UIColor.white
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
