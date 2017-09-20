//
//  UserModel.swift
//  JLSwiftPractice
//
//  Created by jacklin on 2017/9/17.
//  Copyright © 2017年 jacklin. All rights reserved.
//

import UIKit
import ObjectMapper

class UserModel: Mappable {

    var category: String?
    
    var tip_new: Int?
    
    var default_add: Int?
    
    var concern_id: String?
    
    var web_url: String?
    
    var icon_url: String?
    
    var flags: Int?
    
    var type: Int?
    
    var name: String?
    
    required init?(map: Map) {
        
    }
    
    func mapping(map: Map) {
        
        category       <-   map["category"]
        tip_new        <-   map["tip_new"]
        default_add    <-   map["default_add"]
        web_url        <-   map["web_url"]
        concern_id     <-   map["concern_id"]
        icon_url       <-   map["icon_url"]
        flags          <-   map["flags"]
        type           <-   map["type"]
        name           <-   map["name"]
        
    }
    
}
