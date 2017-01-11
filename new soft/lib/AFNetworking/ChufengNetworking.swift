//
//  ChufengNetworking.swift
//  bAFNetworking
//
//  Created by qianfeng on 16/10/21.
//  Copyright © 2016年 qianfeng. All rights reserved.
//

import UIKit

class ChufengNetworking: NSObject {
    static func GET(succer suc:@escaping (_ data:Data)->Void,failed fail:@escaping (_ reason:String)->Void,urlSting:String){
    let manager=AFHTTPSessionManager()
        manager.responseSerializer=AFHTTPResponseSerializer()
        manager.get(urlSting, parameters: nil, progress: nil, success: { (task, data) in
        let manager=AFHTTPSessionManager()
        manager.responseSerializer=AFHTTPResponseSerializer()
        manager.get(urlSting, parameters: nil, progress: nil, success: { (task, data) in
            //通过suc闭包反传参数
            suc(data as! Data)
        }) { (_,_) in
            
        }
        })
    }
    
    static func POST(succer suc:@escaping (_ data:Data)->Void,failed fail:@escaping (_ reason:String)->Void,urlString:String,parameters:NSDictionary){
        let manager=AFHTTPSessionManager()
        manager.responseSerializer=AFHTTPResponseSerializer()
        manager.post(urlString, parameters: parameters, success: { (task, data) in
            suc(data as! Data)
            }) { (task, error) in
                
        }
    }
}
