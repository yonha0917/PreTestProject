//
//  PreRootViewController.swift
//  PreTestProject
//
//  Created by よんは きむ on 2017. 6. 4..
//  Copyright © 2017년 yonha kim. All rights reserved.
//

import UIKit

class PreRootViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    let detailInfoSegueIdentifier = "ShowDetailInfo"
    let requestListInfoURL = "https://itunes.apple.com/kr/rss/topfreeapplications/limit=50/genre=6015/json"
    var dataManager : DataManager!
    
    @IBOutlet weak var navigationItems: UINavigationItem!
    @IBOutlet var tableView: UITableView!
    var indicator: UIActivityIndicatorView!
    
    var naviTitle : String?
    var tableItems : [Any] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        initIndicator()
        self.dataManager = DataManager.init()
        loadData()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - IndicatorView init
    func initIndicator() {
        self.indicator = UIActivityIndicatorView()
        self.indicator.frame = CGRect(x: 0, y: 0, width: 50, height: 50)
        self.indicator.center = self.view.center
        self.indicator.hidesWhenStopped = true
        self.indicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.gray
        self.view.addSubview(self.indicator)
    }
    
    // MARK: - IndicatorView animating start
    func startIndicator() {
        self.indicator.startAnimating()
    }
    
    // MARK: - IndicatorView animating stop
    func stopIndicator() {
        self.indicator.stopAnimating()
    }
    
    // MARK: - 금융카테고리 50위 까지 리스트 호출
    func loadData() {
        startIndicator()
        self.dataManager.requestJsonDataFromURL(urlString:self.requestListInfoURL, successClosure: {
            (data) in
            guard let feed = data?["feed"] as? [String:Any],
                let title = feed["title"] as? [String:Any],
                let label = title["label"] as? String,
                let entry = feed["entry"] as? [Any]
                else {
                    return
                }
            self.naviTitle = label;
            self.tableItems = entry;
            DispatchQueue.main.async() { () -> Void in
                self.navigationItems.title = self.naviTitle
                self.tableView.reloadData()
                self.stopIndicator()
            }
        }, faileClosure:{
            (errorString) in
            let alert = UIAlertController(title:"에러발생!", message:errorString, preferredStyle: UIAlertControllerStyle.alert)
            let action = UIAlertAction(title: "확인", style: UIAlertActionStyle.cancel, handler: {
                (action: UIAlertAction!) in
               
            })
            alert.addAction(action)
            DispatchQueue.main.async() { () -> Void in
                self.present(alert, animated: true, completion: nil)
                self.stopIndicator()
            }
        })
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
        self.dataManager.requestDataFromURL(urlString: urlImage, successClosure: {
            (data) in
            guard let data = data
                else {
                    return
            }
            DispatchQueue.main.async() { () -> Void in
                cell.itemIconImage.image = UIImage(data: data)
            }

        }, faileClosure: {
            (errorString) in
            
            
        })

        cell.itemRanking.text = String(indexPath.row + 1)
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.tableItems.count
    }
    
    // MARK: - UITableViewDelegate
//    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//
//    }
//    
//    func tableView(_ tableView: UITableView, accessoryButtonTappedForRowWith indexPath: IndexPath) {
//
//    }
//    
//    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
//        
//    }
//    
//    func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
//        
//    }
    
    // MARK: - segue prepare method
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == self.detailInfoSegueIdentifier) {
            guard let item = self.tableItems[(self.tableView.indexPathForSelectedRow?.row)!] as? [String : Any],
                let id = item["id"] as? [String:Any],
                let attributes = id["attributes"] as? [String:Any],
                let appID = attributes["im:id"] as? String
                else {
                    return
            }
            let destination = segue.destination as? PreDetailViewController
            destination?.appID = appID;
        }
    }
}
