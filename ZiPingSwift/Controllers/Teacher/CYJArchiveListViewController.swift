//
//  CYJArchiveListViewController.swift
//  ZiPingSwift
//
//  Created by kyang on 2017/9/28.
//  Copyright © 2017年 Chinayoujiao. All rights reserved.
//

import UIKit
import HandyJSON

class CYJArchiveListViewController: KYBaseTableViewController {

    var dataSource: [CYJArchive] = []
    
    var uid: Int?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        title = "档案袋"
        self.shouldFooterRefresh = true
        self.shouldHeaderRefresh = true
        self.tableView.tableFooterView = UIView();
        self.fetchDataSource()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func fetchDataSource() {
        
        var paramater: [String: Any] = ["token" : LocaleSetting.token,
                         "page" : "\(self.page)"]
    
        if self.uid == nil {
            self.uid = LocaleSetting.userInfo()?.uId
        }
        
        if let uId = self.uid {
            paramater["uId"] = uId
        }
        
        RequestManager.POST(urlString: APIManager.Archive.list, params: paramater) { [weak self] (data, error) in
            
            self?.endRefreshing()

            //如果存在error
            guard error == nil else {
                self?.statusUpdated(success: false)
                Third.toast.message((error?.localizedDescription)!)
                return
            }
            self?.statusUpdated(success: true)
            
            if let archives = data as? NSArray {
                if self?.page == 1 {
                    self?.dataSource.removeAll()
                }
                //遍历，并赋值
                var tmpArr = [CYJArchive]()
                archives.forEach({
                    let target = JSONDeserializer<CYJArchive>.deserializeFrom(dict: $0 as? NSDictionary)
                    
                    tmpArr.append(target!)
                })
                if tmpArr.count < 10 {
                    self?.tableView.mj_footer.endRefreshingWithNoMoreData()
                }
                self?.dataSource.append(contentsOf: tmpArr)

                self?.tableView.reloadData()
            }
        }
    }
}

extension CYJArchiveListViewController {
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 65
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: "CYJArchiveListCell")
        
        if cell == nil {
            cell = UITableViewCell(style: .subtitle, reuseIdentifier: "CYJArchiveListCell")
            cell?.textLabel?.theme_textColor = Theme.Color.textColorDark
            cell?.textLabel?.font = UIFont.systemFont(ofSize: 15)
            cell?.detailTextLabel?.theme_textColor = Theme.Color.textColorlight
            cell?.detailTextLabel?.font = UIFont.systemFont(ofSize: 13)
        }
        
        let archive = self.dataSource[indexPath.row]
        cell?.textLabel?.text = archive.archivesName
        cell?.detailTextLabel?.text = "记录时间：\(archive.startTime ?? "0000-00-00") - \(archive.endTime ?? "0000-00-00")"
        
        return cell!
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)
        
        let archiveDetail = CYJArchiveDetailController()
        let archive = self.dataSource[indexPath.row]

        archiveDetail.arId = archive.arId
        self.navigationController?.pushViewController(archiveDetail, animated: true)
    }
    
}
