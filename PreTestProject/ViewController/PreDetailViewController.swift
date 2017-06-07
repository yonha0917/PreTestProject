//
//  PreDetailViewController.swift
//  PreTestProject
//
//  Created by よんは きむ on 2017. 6. 5..
//  Copyright © 2017년 yonha kim. All rights reserved.
//

import UIKit

class PreDetailViewController : UIViewController,  UITableViewDelegate, UITableViewDataSource {
    public var appID : String!
    
    let TABLE_CELL_00_APP_TITLE : Int = 0
    let TABLE_CELL_01_APP_SCREENSHOTS : Int = 1
    let TABLE_CELL_02_APP_DESCRIPTION : Int = 2
    let TABLE_CELL_03_APP_RELEASENOTES : Int = 3
    let TABLE_CELL_04_APP_INFO : Int = 4
    let TABLE_CELL_05_APP_DEVELOPER_WEBSITE: Int = 5
    let TABLE_CELL_06_APP_COPYRIGHT: Int = 6
    
    let FONT_SIZE : CGFloat = 13.0
    
    let requestDetailInfoURL = "https://itunes.apple.com/lookup?id=%@&country=kr"
    var dataManager : DataManager!
    
    var indicator: UIActivityIndicatorView!
    
    @IBOutlet var tableView: UITableView!
    
    var dataAppInfo : [String : Any]?
    var heightSelectedCell02 : CGFloat = 125
    var heightSelectedCell03 : CGFloat = 125
    
    var heightOpenSelectedCell02 : CGFloat = 0
    var heightOpenSelectedCell03 : CGFloat = 0
    
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

    // MARK: - 어플리케이션 상세 정보 호출
    
    func loadData() {
        startIndicator()
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
                self.stopIndicator()
                self.present(alert, animated: true, completion: nil)
            }
        })
    }
    
    // MARK: - UITableViewDataSource
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if(indexPath.row == TABLE_CELL_00_APP_TITLE) {
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
                let string01 : NSAttributedString = NSAttributedString(string: trackCensoredName + "\n", attributes: [NSFontAttributeName: UIFont.systemFont(ofSize: 14)])
                let string02 : NSAttributedString = NSAttributedString(string: artistName, attributes: [NSFontAttributeName: UIFont.systemFont(ofSize: 12)])
                let containString : NSMutableAttributedString = NSMutableAttributedString.init()
                containString.append(string01)
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
        } else if(indexPath.row == TABLE_CELL_01_APP_SCREENSHOTS) {
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
        } else if(indexPath.row == TABLE_CELL_02_APP_DESCRIPTION) {
            let cell = tableView.dequeueReusableCell(withIdentifier: "UITableViewItemCell03", for: indexPath) as! UITableViewItemCell03

            guard let description = self.dataAppInfo?["description"] as? String
                else {
                    return cell
            }
            cell.selectionStyle = .none
            
            DispatchQueue.main.async() { () -> Void in
                cell.labelTitle.text = "설명"
                cell.labelDescription.text = description
                cell.labelDescription.sizeToFit()
                
                let size : CGSize = (description as NSString).size(attributes: [NSFontAttributeName: UIFont.systemFont(ofSize: self.FONT_SIZE)])
                cell.labelDescription.frame(forAlignmentRect: CGRect(x: cell.labelDescription.frame.origin.x, y: cell.labelDescription.frame.origin.y, width: cell.labelDescription.frame.width, height: size.height))
                
                self.heightOpenSelectedCell02 = cell.labelTitle.frame.height + size.height
            }

            return cell
        } else if(indexPath.row == TABLE_CELL_03_APP_RELEASENOTES) {
            let cell = tableView.dequeueReusableCell(withIdentifier: "UITableViewItemCell03", for: indexPath) as! UITableViewItemCell03
            
            guard let releaseNotes = self.dataAppInfo?["releaseNotes"] as? String,
                let currentVersionReleaseDate = self.dataAppInfo?["currentVersionReleaseDate"] as? String
                else {
                    return cell
            }
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss'Z"
            let date : Date = formatter.date(from: currentVersionReleaseDate)!
            formatter.dateFormat = "yyyy/MM/dd"
            let dateString : String = formatter.string(from: date)
            
            cell.selectionStyle = .none

            DispatchQueue.main.async() { () -> Void in
                cell.labelTitle.text = "새로운 기능"
                let description : String = dateString + "\n\n" + releaseNotes
                cell.labelDescription.text = description
                cell.labelDescription.sizeToFit()
                
                let size : CGSize = (description as NSString).size(attributes: [NSFontAttributeName: UIFont.systemFont(ofSize: self.FONT_SIZE)])
                cell.labelDescription.frame(forAlignmentRect: CGRect(x: cell.labelDescription.frame.origin.x, y: cell.labelDescription.frame.origin.y, width: cell.labelDescription.frame.width, height: size.height))
                self.heightOpenSelectedCell03 = cell.labelTitle.frame.height + size.height
            }
            return cell
        } else if (indexPath.row == TABLE_CELL_04_APP_INFO){
            let cell = tableView.dequeueReusableCell(withIdentifier: "UITableViewItemCell04", for: indexPath) as! UITableViewItemCell04
            guard let artistName = self.dataAppInfo?["artistName"] as? String,
                let genres = self.dataAppInfo?["genres"] as? [String],
                let currentVersionReleaseDate = self.dataAppInfo?["currentVersionReleaseDate"] as? String,
                let version = self.dataAppInfo?["version"] as? String,
                let trackContentRating = self.dataAppInfo?["trackContentRating"] as? String,
                let minimumOsVersion = self.dataAppInfo?["minimumOsVersion"] as? String,
                let languageCodesISO2A = self.dataAppInfo?["languageCodesISO2A"] as? [String]
                else {
                    return cell
            }
             cell.selectionStyle = .none
            
            DispatchQueue.main.async() { () -> Void in
                let string01 : NSAttributedString = NSAttributedString(string: "개발자  " + artistName + "\n\n", attributes: [NSFontAttributeName: UIFont.systemFont(ofSize: 12)])
                let string02 : NSAttributedString = NSAttributedString(string: "카테고리  " + genres[0] + "\n\n", attributes: [NSFontAttributeName: UIFont.systemFont(ofSize: 12)])
                
                let formatter = DateFormatter()
                formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss'Z"
                let date : Date = formatter.date(from: currentVersionReleaseDate)!
                formatter.dateFormat = "yyyy/MM/dd"
                let dateString : String = formatter.string(from: date)
                
                let string03 : NSAttributedString = NSAttributedString(string: "업데이트  " + dateString + "\n\n", attributes: [NSFontAttributeName: UIFont.systemFont(ofSize: 12)])
                let string04 : NSAttributedString = NSAttributedString(string: "버전  " + version + "\n\n", attributes: [NSFontAttributeName: UIFont.systemFont(ofSize: 12)])
                let string05 : NSAttributedString = NSAttributedString(string: "등급  " + trackContentRating + "\n\n", attributes: [NSFontAttributeName: UIFont.systemFont(ofSize: 12)])
                let string06 : NSAttributedString = NSAttributedString(string: "호환성  iOS " + minimumOsVersion + " 버전 이상이 필요\n\n", attributes: [NSFontAttributeName: UIFont.systemFont(ofSize: 12)])
                
                var language : String = ""
                for languageCode in languageCodesISO2A {
                    if (languageCode == "EN") {
                        language +=  "영어"
                    } else if (languageCode == "KO") {
                        language +=  "한글"
                    }
                    language += " "
                }
                
                let string07 : NSAttributedString = NSAttributedString(string: "언어  " + language, attributes: [NSFontAttributeName: UIFont.systemFont(ofSize: 12)])
                
                let containString : NSMutableAttributedString = NSMutableAttributedString.init()
                containString.append(string01)
                containString.append(string02)
                containString.append(string03)
                containString.append(string04)
                containString.append(string05)
                containString.append(string06)
                containString.append(string07)
                
                cell.labelDescription.attributedText = containString
                cell.labelDescription.sizeToFit()
            }
            return cell
        } else if(indexPath.row == TABLE_CELL_05_APP_DEVELOPER_WEBSITE) {
            let cell = UITableViewCell(style: .subtitle, reuseIdentifier: "cell")
            cell.accessoryType = .disclosureIndicator
            cell.textLabel?.text = "개발자 웹사이트"
            return cell
        } else if(indexPath.row == TABLE_CELL_06_APP_COPYRIGHT) {
            let cell = UITableViewCell(style: .subtitle, reuseIdentifier: "cell")
            guard let sellerName = self.dataAppInfo?["sellerName"] as? String
                else {
                    return cell
            }
            cell.selectionStyle = .none
            let string01 : NSAttributedString = NSAttributedString(string: sellerName, attributes: [NSFontAttributeName: UIFont.systemFont(ofSize: 12)])
            cell.textLabel?.attributedText = string01
            return cell
        } else {
            let cell = UITableViewCell(style: .subtitle, reuseIdentifier: "cell")
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 7
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if(indexPath.row == TABLE_CELL_00_APP_TITLE) {
            return 125
        } else if (indexPath.row == TABLE_CELL_01_APP_SCREENSHOTS) {
            return 370
        } else if (indexPath.row == TABLE_CELL_02_APP_DESCRIPTION) {
            return self.heightSelectedCell02
        } else if (indexPath.row == TABLE_CELL_03_APP_RELEASENOTES) {
            return self.heightSelectedCell03
        } else if (indexPath.row == TABLE_CELL_04_APP_INFO) {
            return 260
        } else {
            return 50
        }
    }
    
    // MARK: - UITableViewDelegate
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if (indexPath.row == TABLE_CELL_02_APP_DESCRIPTION) {
            if(self.heightOpenSelectedCell02 > self.heightSelectedCell02) {
                self.heightSelectedCell02 = self.heightOpenSelectedCell02 + 50
                DispatchQueue.main.async() { () -> Void in
                    self.tableView.reloadRows(at: [indexPath], with: .fade)
                }
            }
        } else if (indexPath.row == TABLE_CELL_03_APP_RELEASENOTES) {
            if(self.heightOpenSelectedCell03 > self.heightSelectedCell03) {
                self.heightSelectedCell03 = self.heightOpenSelectedCell03 + 50
                DispatchQueue.main.async() { () -> Void in
                    self.tableView.reloadRows(at: [indexPath], with: .fade)
                }
            }
        } else if (indexPath.row == TABLE_CELL_05_APP_DEVELOPER_WEBSITE) {
            guard let sellerUrl = self.dataAppInfo?["sellerUrl"] as? String
                else {
                    return
            }
            let url :URL = URL(string : sellerUrl)!
            UIApplication.shared.openURL(url)
        }
    }
}

// MARK: - Custom UITableViewCell
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
    @IBOutlet var labelTitle: UILabel!
    @IBOutlet weak var labelDescription: UILabel!
    var canOpenCell : Bool = false
    
}

class UITableViewItemCell04: UITableViewCell {
    @IBOutlet weak var labelDescription: UILabel!
    
}
