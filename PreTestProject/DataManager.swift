//
//  DataManager.swift
//  PreTestProject
//
//  Created by よんは きむ on 2017. 6. 4..
//  Copyright © 2017년 yonha kim. All rights reserved.
//

import Foundation

class DataManager : NSObject {
    
    override init() {
        super.init()
    }

    func requestJsonDataFromURL(urlString:NSString, successClosure:@escaping ([String: Any]?) -> Void, faileClosure: @escaping (String?) -> Void) {
        let url = NSURL(string: urlString as String)!
        let request = NSMutableURLRequest(url: url as URL)
        let urlSession = URLSession.shared
        let task = urlSession.dataTask(with: request as URLRequest) {
            (data, response, error) in
            if (error == nil) {
                var jsonData : [String: Any]?
                do {
                    let json = try JSONSerialization.jsonObject(with: data!) as! [String: Any]
                    jsonData = json;
                }
                catch {
                    faileClosure("JSon parsing error!")
                }
               
                successClosure(jsonData)
            } else {
                faileClosure(error?.localizedDescription)
            }
        }

        task.resume()
    }
}
