//
//  MessageControllerMaster.swift
//  ZiPingSwift
//
//  Created by 番茄 on 8/18/18.
//  Copyright © 2018 Chinayoujiao. All rights reserved.
//

import UIKit

class MessageControllerMaster: KYBaseTableViewController {
    
    var examples = [KYTableExample]()
    let cellIdentifier = "CYJNotificationCell"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "消息通知"
        
        let arr = [KYTableExample(key: "apply", title: "收到的分析申请", selector: #selector(toApply), image: nil),
                   KYTableExample(key: "system", title: "系统消息", selector: #selector(toSystem), image: nil)
        ]
        
        examples = arr
        self.tableView.tableFooterView = UIView()
        tableView.register(UINib(nibName: cellIdentifier, bundle: nil), forCellReuseIdentifier: cellIdentifier)
        NotificationCenter.default.addObserver(self, selector: #selector(messageCountChanged), name: CYJNotificationName.unreadMessageCountChanged, object: nil)
        //进入当前页面时，保证红点的正确
        LocaleSetting.share.fetchUnreadMessageCount()
    }
    
    func messageCountChanged() {
        
        self.tableView.reloadData()
    }
    
    func toApply() {
        let messageController =  ApplyValuationViewController()
        messageController.title = "收到的分析申请"
        messageController.type = 10
        navigationController?.pushViewController(messageController, animated: true)
    }
    
    func toSystem() {
        let messageController =  CYJMessageSystemController()
        messageController.title = "系统消息"
        messageController.type = 5
        navigationController?.pushViewController(messageController, animated: true)
    }
    
}

extension MessageControllerMaster {
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return examples.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier) as! CYJNotificationCell
        
        let example = examples[indexPath.row]
        cell.titleLable.text = example.title
        
        let jsonData = LocaleSetting.share.unReadMessageCount
        
        switch example.key! {
        case "apply": cell.redIconLable.text = "\(jsonData.apply)"
        case "system": cell.redIconLable.text = "\(jsonData.system)"
            
        default:
            break
        }
        
        return cell
    }
    
    //    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
    //        return 8
    //    }
    //    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
    //        let space = UIView()
    //        space.theme_backgroundColor = Theme.Color.line
    //        return space
    //    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let example = examples[indexPath.row]
        
        perform(example.selector)
    }
}

