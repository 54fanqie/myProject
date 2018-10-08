//
//  CYJMessageRecordController.swift
//  ZiPingSwift
//
//  Created by kyang on 2017/9/28.
//  Copyright © 2017年 Chinayoujiao. All rights reserved.
//

import UIKit
import HandyJSON

class CYJMessageRecordController: KYBaseTableViewController {

    let cellIdentifier = "CYJMessageRecordCell"
    
    var type: Int = 1
    var dataSource: [CYJMessage] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        self.shouldHeaderRefresh = true
        self.shouldFooterRefresh = true
        
        tableView.register(UINib(nibName: cellIdentifier, bundle: nil), forCellReuseIdentifier: cellIdentifier)
        self.tableView.tableFooterView = UIView()
        switch type {
        case 1:
            let unread = LocaleSetting.share.unReadMessageCount
            unread.thumb = 0
            LocaleSetting.share.unReadMessageCount = unread
        case 2:
            let unread = LocaleSetting.share.unReadMessageCount
            unread.feedback = 0
            LocaleSetting.share.unReadMessageCount = unread
        case 3:
            let unread = LocaleSetting.share.unReadMessageCount
            unread.mark = 0
            LocaleSetting.share.unReadMessageCount = unread
        case 5:
            let unread = LocaleSetting.share.unReadMessageCount
            unread.system = 0
            LocaleSetting.share.unReadMessageCount = unread
        default:
            break
        }
        
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
                    self?.dataSource.removeAll()
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
                
                self?.dataSource.append(contentsOf: tmpMessage)
            }
            self?.tableView.reloadData()
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

extension CYJMessageRecordController {
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier) as! CYJMessageRecordCell
        cell.message = dataSource[indexPath.row]
        cell.selectionStyle = .none
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let message = dataSource[indexPath.row]
        
        if message.dataType == 1  {
            //1成长记录；2档案袋
            if LocaleSetting.userInfo()?.role == .teacher || LocaleSetting.userInfo()?.role == .teacherL {
                
                let vc = CYJRECDetailViewController()
                vc.recordId = message.dataId!
                self.navigationController?.pushViewController(vc, animated: true)
                
            }else if LocaleSetting.userInfo()?.role == .child {
                
                let detail = CYJRECControllerViewByParent(.grouped)
                detail.grId = message.dataId!
                detail.userId = (LocaleSetting.userInfo()?.uId)!

                self.navigationController?.pushViewController(detail, animated: true)
            }
        }else if message.dataType == 2 {
            let archiveDetail = CYJArchiveDetailController()
            archiveDetail.arId = message.dataId!
            self.navigationController?.pushViewController(archiveDetail, animated: true)
        }else {
            DLog("这是啥")
        }
        
        
    }
}
