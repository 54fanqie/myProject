//
//  CYJMessageController.swift
//  ZiPingSwift
//
//  Created by kyang on 2017/9/15.
//  Copyright © 2017年 Chinayoujiao. All rights reserved.
//

import Foundation
import HandyJSON

class CYJMessageSystemController: KYBaseTableViewController {
    
    var dataSource: [CYJMessage] = []
    var type: Int = 1
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "消息"
        
        self.shouldHeaderRefresh = true
        self.shouldFooterRefresh = true
        
        tableView.register(UINib(nibName: "CYJMessageTableViewCell", bundle: nil), forCellReuseIdentifier: "CYJMessageTableViewCell")

        self.fetchDataSource()
        
        LocaleSetting.share.unReadMessageCount.system = 0 // 因为只有园长端 会进入这个界面，所以，直接设置系统消息数目为0
        NotificationCenter.default.post(name: CYJNotificationName.unreadMessageCountChanged, object: nil)

    }
    
    override func fetchDataSource() {
        
        RequestManager.POST(urlString: APIManager.Message.list, params: ["token": LocaleSetting.token, "type" : "\(5)"]) { [weak self] (data, error) in
            
            self?.endRefreshing()
            
            //如果存在error
            guard error == nil else {
                //TODO: 区分服务器错误，和自身逻辑错误，分别设置 空数据文字和图片
                if error?.domain == CYJErrorDomainName {
                    // 逻辑错误
                    self?.statusUpdated(success: true)
                }else
                {
                    //服务器错误
                    self?.statusUpdated(success: false)
                }
                
                Third.toast.message((error?.localizedDescription)!)
                return
            }
            //解析数据
            self?.statusUpdated(success: true)
            
            if let messages = data as? NSArray {
                if self?.page == 1 {
                    self?.dataSource.removeAll()
                }
                //遍历，并赋值
                var tmpArr = [CYJMessage]()
                messages.forEach({
                    let target = JSONDeserializer<CYJMessage>.deserializeFrom(dict: $0 as? NSDictionary)
                    tmpArr.append(target!)
                })
                
                if tmpArr.count < 10 {
                    self?.tableView.mj_footer.endRefreshingWithNoMoreData()
                }
                
                self?.dataSource.append(contentsOf: tmpArr)
            }
            self?.tableView.reloadData()
        }
    }
}

extension CYJMessageSystemController {
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CYJMessageTableViewCell") as? CYJMessageTableViewCell
        cell?.message = dataSource[indexPath.row]
        cell?.selectionStyle = .none
        return cell!
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("点击了cell")
    }
}
