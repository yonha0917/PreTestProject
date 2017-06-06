//
//  PreDetailViewController.swift
//  PreTestProject
//
//  Created by sbi on 2017. 6. 5..
//  Copyright © 2017년 yonha kim. All rights reserved.
//

import UIKit

class PreDetailViewController : UIViewController,  UITableViewDelegate, UITableViewDataSource {
    public var appID : String!
    let requestDetailInfoURL = "https://itunes.apple.com/lookup?id=%@&country=kr"
    var dataManager : DataManager!
    
    @IBOutlet var tableView: UITableView!
    
    @IBOutlet var scrollViewContents: UIScrollView!
    
    var dataAppInfo : [String : Any]?
    var heightSelectedCell02 : CGFloat = 125
    var heightSelectedCell03 : CGFloat = 125
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.dataManager = DataManager.init()
        loadData()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func loadData() {
        let urlString = String(format: self.requestDetailInfoURL, self.appID)
        print(urlString)
        self.dataManager.requestJsonDataFromURL(urlString:urlString, successClosure: {
            (data) in
            
            guard let results = data?["results"] as? [Any],
                let result = results[0] as? [String : Any]
                else {
                    return
            }
            self.dataAppInfo = result
            DispatchQueue.main.async() { () -> Void in
                self.tableView.reloadData()
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
            }
        })
    }
    
    // MARK: - UITableViewDataSource
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if(indexPath.row == 0) {
            let cell = tableView.dequeueReusableCell(withIdentifier: "UITableViewItemCell01", for: indexPath) as! UITableViewItemCell01
            cell.selectionStyle = .none
            guard let artworkUrl100 = self.dataAppInfo?["artworkUrl100"] as? String,
                let trackCensoredName = self.dataAppInfo?["trackCensoredName"] as? String,
                let artistName = self.dataAppInfo?["artistName"] as? String
                else {
                    return cell
            }
            
            cell.appid = self.appID
            DispatchQueue.main.async() { () -> Void in
                let string01 : NSAttributedString = NSAttributedString(string: trackCensoredName, attributes: [NSFontAttributeName: UIFont.systemFont(ofSize: 14)])
                let space : NSAttributedString = NSAttributedString(string: "\n", attributes:nil)
                let string02 : NSAttributedString = NSAttributedString(string: artistName, attributes: [NSFontAttributeName: UIFont.systemFont(ofSize: 12)])
                let containString : NSMutableAttributedString = NSMutableAttributedString.init()
                containString.append(string01)
                containString.append(space)
                containString.append(string02)
                cell.labelAppTitle.attributedText = containString
            }
            
            self.dataManager.requestDataFromURL(urlString: artworkUrl100, successClosure: {
                (data) in
                guard let data = data
                    else {
                        return
                }
                DispatchQueue.main.async() { () -> Void in
                    cell.imageAppIcon.image = UIImage(data: data)
                }
                
            }, faileClosure: {
                (errorString) in
                cell.imageAppIcon.image = UIImage(named: "question100.png")
                
            })
            
            return cell
        } else if(indexPath.row == 1) {
            let cell = tableView.dequeueReusableCell(withIdentifier: "UITableViewItemCell02", for: indexPath) as! UITableViewItemCell02
            guard let screenshotUrls = self.dataAppInfo?["screenshotUrls"] as? [String]
                else {
                    return cell
            }
            
            cell.scrollViewAppScreenShots.contentSize = CGSize(width: 200 * screenshotUrls.count, height: 350)
            
            for i in 0  ..< screenshotUrls.count {
                self.dataManager.requestDataFromURL(urlString: screenshotUrls[i], successClosure: {
                    (data) in
                    guard let data = data
                        else {
                            return
                    }
                    DispatchQueue.main.async() { () -> Void in
                        let space : Int = i * 4
                        let imageView  : UIImageView = UIImageView.init(frame: CGRect(x: 196 * i + space, y: 0, width: 196, height: 350))
                        imageView.image = UIImage.init(data: data)
                        
                        cell.scrollViewAppScreenShots.addSubview(imageView)
                    }
                    
                }, faileClosure: {
                    (errorString) in
                    
                    
                })
            }

            return cell
        } else if(indexPath.row == 2) {
            let cell = tableView.dequeueReusableCell(withIdentifier: "UITableViewItemCell03", for: indexPath) as! UITableViewItemCell03

            guard let description = self.dataAppInfo?["description"] as? String
                else {
                    return cell
            }
            cell.selectionStyle = .none
            
            DispatchQueue.main.async() { () -> Void in
                let string01 : NSAttributedString = NSAttributedString(string:"설명", attributes: [NSFontAttributeName: UIFont.boldSystemFont(ofSize: 14)])
                let space : NSAttributedString = NSAttributedString(string: "\n", attributes:nil)
                let string02 : NSAttributedString = NSAttributedString(string: description, attributes: [NSFontAttributeName: UIFont.systemFont(ofSize: 12)])
                let containString : NSMutableAttributedString = NSMutableAttributedString.init()
                containString.append(string01)
                containString.append(space)
                containString.append(space)
                containString.append(string02)
                
                cell.labelInfo.sizeToFit()
                cell.labelInfo.attributedText = containString
                
            }

            return cell
        } else if(indexPath.row == 3) {
            let cell = tableView.dequeueReusableCell(withIdentifier: "UITableViewItemCell03", for: indexPath) as! UITableViewItemCell03
            
            guard let releaseNotes = self.dataAppInfo?["releaseNotes"] as? String,
                let currentVersionReleaseDate = self.dataAppInfo?["currentVersionReleaseDate"] as? String
                else {
                    return cell
            }
            
            cell.selectionStyle = .none

            DispatchQueue.main.async() { () -> Void in
                let string01 : NSAttributedString = NSAttributedString(string:"새로운 기능", attributes: [NSFontAttributeName: UIFont.boldSystemFont(ofSize: 14)])
                let space : NSAttributedString = NSAttributedString(string: "\n", attributes:nil)
                let string02 : NSAttributedString = NSAttributedString(string: releaseNotes, attributes: [NSFontAttributeName: UIFont.systemFont(ofSize: 12)])
                let containString : NSMutableAttributedString = NSMutableAttributedString.init()
                containString.append(string01)
                containString.append(space)
                containString.append(space)
                containString.append(string02)
                
                cell.labelInfo.sizeToFit()
                cell.labelInfo.attributedText = containString
            }
            return cell
        } else {
            let cell = UITableViewCell(style: .subtitle, reuseIdentifier: "cell")
            
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 9
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        print("heightForRowAt: \(indexPath.row)")
        if(indexPath.row == 0) {
            return 125
        } else if (indexPath.row == 1) {
            return 350
        } else if (indexPath.row == 2) {
            return self.heightSelectedCell02
        } else if (indexPath.row == 3) {
            return self.heightSelectedCell03
        }else {
            return 125
        }
    }
    
    // MARK: - UITableViewDelegate
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if (indexPath.row == 2) {
            let cell = tableView.cellForRow(at: indexPath) as! UITableViewItemCell03
            if(cell.labelInfo.frame.height > self.heightSelectedCell02) {
                if(!cell.isTapCell) {
                    self.heightSelectedCell02 = cell.labelInfo.frame.height + 50
                    self.tableView.reloadRows(at: [indexPath], with: .none)
                    cell.isTapCell = true
                }
            } 
        } else if (indexPath.row == 3) {
            let cell = tableView.cellForRow(at: indexPath) as! UITableViewItemCell03
            if(cell.labelInfo.frame.height > self.heightSelectedCell03) {
                if(!cell.isTapCell) {
                    self.heightSelectedCell03 = cell.labelInfo.frame.height + 50
                    self.tableView.reloadRows(at: [indexPath], with: .none)
                    cell.isTapCell = true
                }
            }
        }
    }
    
    func tableView(_ tableView: UITableView, accessoryButtonTappedForRowWith indexPath: IndexPath) {
//        print("タップされたセルのindex番号: \(indexPath.row)")
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
//        print("willDisplay : \(indexPath.row)")
    }
    
    func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
//        print("didEndDisplaying : \(indexPath.row)")
    }

    
}

class UITableViewItemCell01: UITableViewCell {
    @IBOutlet weak var imageAppIcon: UIImageView!
    @IBOutlet var labelAppTitle: UILabel!
    @IBOutlet weak var buttonAppStore: UIButton!
    var appid : String?
    
    @IBAction func actionMoveAppStore(_ sender: Any) {
        let url :URL = URL(string : "itms-apps://itunes.apple.com/app/id" + self.appid!)!
        UIApplication.shared.openURL(url)
    }
}

class UITableViewItemCell02: UITableViewCell {
    @IBOutlet var scrollViewAppScreenShots: UIScrollView!
}

class UITableViewItemCell03: UITableViewCell {
    @IBOutlet var labelInfo: UILabel!
    var isTapCell : Bool = false
}
