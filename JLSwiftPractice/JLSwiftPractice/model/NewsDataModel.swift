//
//  NewsDataModel.swift
//  JLSwiftPractice
//
//  Created by jacklin on 2017/9/17.
//  Copyright © 2017年 jacklin. All rights reserved.
//

import UIKit
import ObjectMapper

class NewsDataModel: Mappable {
    
    var data: [UserModel]?
    
    var version : String?
    
    init() {
        
    }
    
    required init?(map: Map) {
        
    }
    
    func mapping(map: Map) {
        
        version <- map["version"]
        data    <- map["data"]
    }
}
