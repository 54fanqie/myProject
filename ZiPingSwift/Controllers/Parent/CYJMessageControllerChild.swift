//
//  CYJMessageControllerChild.swift
//  ZiPingSwift
//
//  Created by kyang on 2017/9/28.
//  Copyright © 2017年 Chinayoujiao. All rights reserved.
//

import UIKit
import HandyJSON

class CYJMessageControllerChild: KYBaseTableViewController {
    
    var examples = [KYTableExample]()
    let cellIdentifier = "CYJNotificationCell"
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "消息通知"
        
        let arr = [
                   KYTableExample(key: "feedback", title: "新收到的反馈", selector: #selector(toReplay), image: nil),
                   KYTableExample(key: "system", title: "系统消息", selector: #selector(toSystem), image: nil)
        ]
        
        examples = arr
        tableView.register(UINib(nibName: cellIdentifier, bundle: nil), forCellReuseIdentifier: cellIdentifier)
        self.fetchDataSource()
        
        NotificationCenter.default.addObserver(self, selector: #selector(messageCountChanged), name: CYJNotificationName.unreadMessageCountChanged, object: nil)

        //进入当前页面时，保证红点的正确
        LocaleSetting.share.fetchUnreadMessageCount()
    }
    
    func messageCountChanged() {
        self.tableView.reloadData()
    }
    
    func toReplay() {
        let messageController =  CYJMessageRecordController()
        messageController.title = "收到的反馈"
        messageController.type = 2
        navigationController?.pushViewController(messageController, animated: true)
    }

    func toSystem() {
        let messageController =  CYJMessageRecordController()
        messageController.title = "系统消息"
        messageController.type = 5
        navigationController?.pushViewController(messageController, animated: true)
    }
    
}

extension CYJMessageControllerChild {
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return examples.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        var cell = tableView.dequeueReusableCell(withIdentifier: "MessageInfoCell")
//
//        if cell == nil {
//            cell = UITableViewCell(style: .value1, reuseIdentifier: "MessageInfoCell")
//            cell?.accessoryType = .disclosureIndicator
//            cell?.selectionStyle = .none
//            cell?.detailTextLabel?.theme_textColor = Theme.Color.badge
//        }
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier) as! CYJNotificationCell
        
        let example = examples[indexPath.row]
        cell.titleLable.text = example.title
        
        let jsonData = LocaleSetting.share.unReadMessageCount
            
            switch example.key! {
            case "feedback":
                cell.redIconLable.text = "\(jsonData.feedback)"
            case "system":
                cell.redIconLable.text = "\(jsonData.system)"
            case "thumb":
                cell.redIconLable.text = "\(jsonData.thumb)"
            case "mark":
                cell.redIconLable.text = "\(jsonData.mark)"
            default:
                break
            }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 8
    }
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let space = UIView()
        space.theme_backgroundColor = Theme.Color.line
        return space
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let example = examples[indexPath.row]
        
        perform(example.selector)
    }
}

