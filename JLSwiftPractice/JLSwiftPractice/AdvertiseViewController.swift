//
//  AdvertiseViewController.swift
//  JLSwiftPractice
//
//  Created by jacklin on 2017/10/15.
//  Copyright © 2017年 jacklin. All rights reserved.
//

import UIKit
import SnapKit

class AdvertiseViewController: UIViewController {

    lazy var timeButton : UIButton = {
        let button = UIButton(type: UIButtonType.custom)
        button.backgroundColor = UIColor.gray
        button.titleLabel?.font = UIFont.systemFont(ofSize: 12)
        button.setTitle("2s 跳过", for: .normal)
        button.addTarget(self, action: #selector(timeButtonClicked), for: .touchUpInside)
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        view.addSubview(timeButton)
        timeButton.snp.makeConstraints { (make) in
            make.right.equalTo(view.snp.right).offset(-20)
            make.top.equalTo(view).offset(20)
            make.size.equalTo(CGSize(width: 60, height: 30))
        }
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @objc private func timeButtonClicked(_ sender: UIButton){
        
    }
}
