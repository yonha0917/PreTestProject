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

    func requestJsonDataFromURL(urlString:String, successClosure:@escaping ([String: Any]?) -> Void, faileClosure: @escaping (String?) -> Void) {
        let url = URL(string: urlString)!
        let request = URLRequest(url: url)
        let urlSession = URLSession.shared
        let task = urlSession.dataTask(with: request) {
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
    
    func requestDataFromURL(urlString: String, successClosure: @escaping (Data?) -> Void, faileClosure: @escaping (String?) -> Void) {
        let url = URL(string: urlString)!
        let request = URLRequest(url: url)
        let urlSession = URLSession.shared
        let task = urlSession.dataTask(with: request) {
            (data, response, error) in
            if (error == nil) {
                successClosure(data)
            } else {
                faileClosure(error?.localizedDescription)
            }
        }
        task.resume()
    }
}
