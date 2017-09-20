//
//  MainViewController.swift
//  JLSwiftPractice
//
//  Created by jacklin on 2017/9/17.
//  Copyright © 2017年 jacklin. All rights reserved.
//

import UIKit
import SnapKit
import Alamofire
import AlamofireObjectMapper
import SwiftyJSON
import ObjectMapper

let kBaseUrl = "https://is.snssdk.com/"
let IID: String = "5034850950"
let device_id: String = "6096495334"

class MainViewController: UIViewController {

    let dataSource = ["Alamofire", "snapKit", "基本框架搭建"]
    
    lazy fileprivate var mainTableView : UITableView = {
        let tableView = UITableView()
        tableView.backgroundColor = UIColor.clear
        tableView.delegate = self;
        tableView.dataSource = self;
        tableView.tableFooterView = UIView()
        return tableView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "主页"
        view.backgroundColor = UIColor.white
        
        view.addSubview(mainTableView)
        mainTableView.snp.makeConstraints { (make) in
            make.edges.equalTo(self.view)
        }
        
        //演示一些第三库的基本使用方法
        //整个框架的组织结构、初始化一些基类
        //封装一些网络框架

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

extension MainViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1;
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource.count;
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellIdentifer = "tableViewCell"
        var cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifer)
        if cell == nil {
            cell = UITableViewCell(style: .default, reuseIdentifier: "tableViewCell")
        }
        
        cell?.textLabel?.text = dataSource[indexPath.row]
        
        return cell!
    }
}

extension MainViewController: UITableViewDelegate{
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        if indexPath.row == 0 {
            //测试Alamofire使用方法
            
            let requestUrl = kBaseUrl + "article/category/get_subscribed/v1/?"
            let parameters = [device_id: device_id,
                              "aid": 13 ,
                              "iid": IID] as [String : Any]
            Alamofire.request(requestUrl, parameters: parameters).responseJSON { (reponse) in
                
                guard reponse.result.isSuccess else{
                    return
                }
                
                if let value = reponse.result.value{
                    
                    let json = JSON(value)
                    
                    let dataDic = json.dictionary
                    
                    let newsModel = Mapper<NewsDataModel>().map(JSON: value as! [String : Any])
                    
                    print("string = \(newsModel?.toJSONString())")
                    
                    /*let dataNewModel = Mapper<NewsDataModel>().map(dataDic)
                    
                    let dataModel = NewsDataModel()
                    _ = Mapper().map(JSON: dataDic!, toObject: dataModel)
                    
                    print("data = version : \(dataModel)")*/
                    
                    
                    
                }
                
                
                
                
            }
            
            
            
            
            
        }
        
    }
    
}
