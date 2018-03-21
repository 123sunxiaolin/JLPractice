//
//  UIImage+Extension.swift
//  JLSwiftPractice
//
//  Created by jacklin on 2017/10/15.
//  Copyright © 2017 jacklin. All rights reserved.
//

import UIKit

extension UIImage {
    //颜色转图片
    class func getImageWithColor(color: UIColor) -> UIImage {
        let rect = CGRect(x: 0, y: 0, width: 1, height: 1)
        UIGraphicsBeginImageContext(rect.size)
        let context = UIGraphicsGetCurrentContext()
        context!.setFillColor(color.cgColor)
        context!.fill(rect)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image!
    }
}
