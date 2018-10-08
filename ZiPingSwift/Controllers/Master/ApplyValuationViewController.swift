//
//  ApplyValuationViewController.swift
//  ZiPingSwift
//
//  Created by 番茄 on 8/18/18.
//  Copyright © 2018 Chinayoujiao. All rights reserved.
//

import UIKit
import HandyJSON

class ApplyValuationViewController: KYBaseTableViewController {
   
    var examples = [CYJMessage]()
    let cellIdentifier = "CYJMessageTableViewCell"
    var type: Int = 1
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "收到的分析申请"
        self.shouldHeaderRefresh = true
        self.shouldFooterRefresh = true
        self.tableView.tableFooterView = UIView(frame: CGRect.zero)
        tableView.register(UINib(nibName: cellIdentifier, bundle: nil), forCellReuseIdentifier: cellIdentifier)
        
        //消除红点
        LocaleSetting.share.unReadMessageCount.apply = 0 // 因为只有园长端 会进入这个界面，所以，直接设置系统消息数目为0
        NotificationCenter.default.post(name: CYJNotificationName.unreadMessageCountChanged, object: nil)
         self.fetchDataSource()
    }
    
    override func fetchDataSource() {
        
        RequestManager.POST(urlString: APIManager.Message.list, params: ["token": LocaleSetting.token, "type" : "\(self.type)", "page": "\(self.page)"]) { [weak self] (data, error) in
            
            self?.endRefreshing()
            
            //如果存在error
            guard error == nil else {
                //TODO: 区分服务器错误，和自身逻辑错误，分别设置 空数据文字和图片
                //服务器错误
                self?.statusUpdated(success: false)
                
                Third.toast.message((error?.localizedDescription)!)
                return
            }
            //解析数据
            self?.statusUpdated(success: true)
            
            if let messages = data as? NSArray {
                if self?.page == 1 {
                    self?.examples.removeAll()
                }
                //遍历，并赋值
                var tmpMessage = [CYJMessage]()
                messages.forEach({
                    let target = JSONDeserializer<CYJMessage>.deserializeFrom(dict: $0 as? NSDictionary)
                    tmpMessage.append(target!)
                })
                if tmpMessage.count < 10 {
                    self?.tableView.mj_footer.endRefreshingWithNoMoreData()
                }
                
                self?.examples.append(contentsOf: tmpMessage)
            }
            self?.tableView.reloadData()
        }
    }
    
}

extension ApplyValuationViewController {
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return examples.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier) as! CYJMessageTableViewCell
        
        cell.message = examples[indexPath.row]
        cell.selectionStyle = .none
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        let example = examples[indexPath.row]
//
//        perform(example.selector)
    }
}

