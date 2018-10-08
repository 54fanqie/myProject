//
//  TImeOptionSelectedController.swift
//  ZiPingSwift
//
//  Created by fanqie on 2018/8/15.
//  Copyright © 2018年 Chinayoujiao. All rights reserved.
//

import UIKit

class TImeOptionSelectedController: KYBaseTableViewController {
    var completeHandler: ((_ option: TestTimeModel , _ selectIndex: Int) -> Void)
    var currentIndex: Int = 0
    
    var dataSource:[TestTimeModel] = []
    
    /// 创建选择的页面
    ///
    /// - Parameters:
    ///   - currentIndex: 已选中位置
    ///   - options: 选项列表
    ///   - completeHandle: 完成事件
    init(currentIndex: Int, options: [TestTimeModel], completeHandler: @escaping ((_ option: TestTimeModel , _ selectIndex: Int) -> Void)) {
        self.currentIndex = currentIndex
        self.dataSource = options
        self.completeHandler = completeHandler
        
        super.init(nibName: nil, bundle: nil)
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.tableFooterView = UIView()
        self.title = "选择测评时间"
        
        
    }
}

extension TImeOptionSelectedController {
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: "CYJOptionsSelectedCell")
        
        if cell == nil {
            cell = UITableViewCell(style: .default , reuseIdentifier: "CYJOptionsSelectedCell")
        }
        //         cell?.textLabel?.theme_textColor = Theme.Color.main
        cell?.theme_tintColor = Theme.Color.main
        
        let option = dataSource[indexPath.row]
        
//        if indexPath.row == 1 {
//            cell?.accessoryType = .checkmark
//        }else
//        {
//            cell?.accessoryType = .none
//        }
        
        cell?.textLabel?.text = option.testTime
        
        
        if indexPath.row == currentIndex {
            cell?.accessoryType = .checkmark
        }else{
            cell?.accessoryType = .none
        }
        
        return cell!
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let option = dataSource[indexPath.row]
        completeHandler(option , indexPath.row)
        
        navigationController?.popViewController(animated: true)
    }
}
