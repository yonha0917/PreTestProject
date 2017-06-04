//
//  PreRootViewController.swift
//  PreTestProject
//
//  Created by よんは きむ on 2017. 6. 4..
//  Copyright © 2017년 yonha kim. All rights reserved.
//

import UIKit

class PreRootViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var dataManager : DataManager!
    
    @IBOutlet weak var navigationItems: UINavigationItem!
    @IBOutlet var tableView: UITableView!
    
    var naviTitle : String?
    var tableItems : [Any] = []
    
    override func viewDidLayoutSubviews(){
        super.viewDidLayoutSubviews()
        self.navigationItems.title = naviTitle
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        loadData()
        
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func loadData() {
        dataManager = DataManager.init()
        dataManager.requestJsonDataFromURL(urlString:"https://itunes.apple.com/kr/rss/topfreeapplications/limit=50/genre=6015/json",
                                           successClosure: {
                                            (data) in
                                            guard let feed = data?["feed"] as? [String:Any],
                                                let title = feed["title"] as? [String:Any],
                                                let label = title["label"] as? String,
                                                let entry = feed["entry"] as? [Any]
                                            else {
                                                return
                                            }
                                            print(label)
                                            self.naviTitle = label;
                                            self.tableItems = entry;
                                            
                                            DispatchQueue.main.async() { () -> Void in
                                                self.tableView.reloadData()
                                            }
                                            
        },
                                           faileClosure:{
                                            (error) in
                                            print(error.debugDescription)
                                            
        })
    }
    
    func getDataFromUrl(url: URL, completion: @escaping (_ data: Data?, _  response: URLResponse?, _ error: Error?) -> Void) {
        URLSession.shared.dataTask(with: url) {
            (data, response, error) in
            completion(data, response, error)
            }.resume()
    }
    
    // MARK: - UITableViewDataSource
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "UITableViewItemCell", for: indexPath) as! UITableViewItemCell
    
        cell.accessoryType = .disclosureIndicator
        
        guard let item = self.tableItems[indexPath.row] as? [String : Any],
            let name = item["im:name"] as? [String:Any],
            let label = name["label"] as? String,
            let imageItems = item["im:image"] as? [Any],
            let imageItem = imageItems[0] as? [String : Any],
            let urlImage = imageItem["label"] as? String
            else {
                return cell
        }

        
        cell.itemTitle.text = label
        let url = URL(string: urlImage);
        getDataFromUrl(url: url!) { (data, response, error)  in
            guard let data = data, error == nil else { return }
            DispatchQueue.main.async() { () -> Void in
                cell.itemIconImage.image = UIImage(data: data)
            }
        }
        cell.itemRanking.text = String(indexPath.row + 1)
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.tableItems.count
    }
    
    // MARK: - UITableViewDelegate
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("タップされたセルのindex番号: \(indexPath.row)")
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    func tableView(_ tableView: UITableView, accessoryButtonTappedForRowWith indexPath: IndexPath) {
        print("タップされたアクセサリがあるセルのindex番号: \(indexPath.row)")
    }
}
