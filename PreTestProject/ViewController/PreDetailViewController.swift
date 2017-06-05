//
//  PreDetailViewController.swift
//  PreTestProject
//
//  Created by sbi on 2017. 6. 5..
//  Copyright © 2017년 yonha kim. All rights reserved.
//

import UIKit

class PreDetailViewController : UIViewController {
    public var appID : String!
    let requestDetailInfoURL = "https://itunes.apple.com/lookup?id=%@&country=kr"
    var dataManager : DataManager!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.dataManager = DataManager.init()
        loadData()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func loadData() {
        var urlString = String(format: self.requestDetailInfoURL, self.appID)
        self.dataManager.requestJsonDataFromURL(urlString:urlString, successClosure: {
            (data) in
            
            print(data)
            
//            guard let feed = data?["feed"] as? [String:Any],
//                let title = feed["title"] as? [String:Any],
//                let label = title["label"] as? String,
//                let entry = feed["entry"] as? [Any]
//                else {
//                    return
//            }
//            
//            DispatchQueue.main.async() { () -> Void in
//                
//            }
            
        }, faileClosure:{
            (errorString) in
            let alert = UIAlertController(title:"에러발생!", message:errorString, preferredStyle: UIAlertControllerStyle.alert)
            let action = UIAlertAction(title: "확인", style: UIAlertActionStyle.cancel, handler: {
                (action: UIAlertAction!) in
                
            })
            alert.addAction(action)
            DispatchQueue.main.async() { () -> Void in
                self.present(alert, animated: true, completion: nil)
            }
        })
    }
}
