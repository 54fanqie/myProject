//
//  CYJMessageControllerTeacher.swift
//  ZiPingSwift
//
//  Created by kyang on 2017/9/27.
//  Copyright © 2017年 Chinayoujiao. All rights reserved.
//

import Foundation
import HandyJSON

class CYJMessageControllerTeacher: KYBaseTableViewController {
    
    var examples = [KYTableExample]()
    let cellIdentifier = "CYJNotificationCell"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "消息通知"
        
        let arr = [KYTableExample(key: "good", title: "新收到的赞", selector: #selector(toGood), image: nil),
                   KYTableExample(key: "replay", title: "新收到的反馈", selector: #selector(toReplay), image: nil),
                   KYTableExample(key: "readover", title: "新获得园长的批阅", selector: #selector(toReadOver), image: nil),
                   KYTableExample(key: "system", title: "系统消息", selector: #selector(toSystem), image: nil)
        ]
        
        examples = arr
        self.tableView.tableFooterView = UIView()
        self.tableView.register(UINib(nibName: cellIdentifier, bundle: nil), forCellReuseIdentifier: cellIdentifier)
        NotificationCenter.default.addObserver(self, selector: #selector(messageCountChanged), name: CYJNotificationName.unreadMessageCountChanged, object: nil)
        //进入当前页面时，保证红点的正确
        LocaleSetting.share.fetchUnreadMessageCount()
    }
    
    func messageCountChanged() {
        
        self.tableView.reloadData()
    }
    
    func toGood() {
        let messageController =  CYJMessageRecordController()
        messageController.type = 1
        messageController.title = "赞"
        navigationController?.pushViewController(messageController, animated: true)
    }
    func toReplay() {
        let messageController =  CYJMessageRecordController()
        messageController.type = 2
        messageController.title = "收到反馈"
        navigationController?.pushViewController(messageController, animated: true)
    }
    func toReadOver() {
        let messageController =  CYJMessageRecordController()
        messageController.type = 3
        messageController.title = "园长批阅"
        navigationController?.pushViewController(messageController, animated: true)
    }
    func toSystem() {
        let messageController =  CYJMessageSystemController()
        
        navigationController?.pushViewController(messageController, animated: true)
    }
    
}

extension CYJMessageControllerTeacher {
    
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
        case "good": cell.redIconLable.text = "\(jsonData.thumb)"
        case "replay": cell.redIconLable.text = "\(jsonData.feedback)"
        case "readover": cell.redIconLable.text = "\(jsonData.mark)"
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

