//
//  CYJDomainMutiSelector.swift
//  ZiPingSwift
//
//  Created by kyang on 2017/10/12.
//  Copyright © 2017年 Chinayoujiao. All rights reserved.
//

import Foundation
import HandyJSON

class CYJDomainMutiSelector: KYBaseTableViewController {
    
    var dataSource: [CYJFormData.Domain] = []
    
    var selectedDomain: [CYJFormData.Domain] = []
    
    var completeAction: ((_ domain: [CYJFormData.Domain]) -> Void)?
    
    var maxCount: Int = 4
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //input code here
        
        let buttonActionView = CYJActionsView(frame: CGRect(x: 0, y: 130, width: view.frame.width, height: 100))

        let resetButton = CYJFilterButton(title: "重置") {[unowned self] (sender) in
            self.selectedDomain = []
            self.tableView.reloadData()
        }
        resetButton.filterButtonStyle = .circle_light_Style
        
        let sureButton = CYJFilterButton(title: "确定") { [unowned self] (sender) in
            
            guard self.selectedDomain.count > 0 else {
                Third.toast.message("您至少需要选择一个领域")
                return
            }
            
            self.completeAction?(self.selectedDomain)
        }
        sureButton.filterButtonStyle = .circle_color_Style
        
        buttonActionView.actions = [resetButton, sureButton]
        
        tableView.tableFooterView = buttonActionView
    
        
//        fetchDataSource()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //input code here
    }
}

//MARK: make UI
extension CYJDomainMutiSelector {
    
//    override func fetchDataSource() {
//        RequestManager.POST(urlString: APIManager.Record.tree, params: ["level": "1", "token": LocaleSetting.token]) { [unowned self] (data, error) in
//            //如果存在error
//            guard error == nil else {
//                Third.toast.message((error?.localizedDescription)!)
//                return
//            }
//            if let domains = data as? NSArray {
//                //遍历，并赋值
//                domains.forEach({ [unowned self] in
//                    let target = JSONDeserializer<CYJDomain>.deserializeFrom(dict: $0 as? NSDictionary)
//
//                    self.dataSource.append(target!)
//                })
//
//                self.tableView.reloadData()
//            }
//        }
//    }
}

extension CYJDomainMutiSelector {
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource.count
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: "UITableViewCell")
        
        if cell == nil {
            cell = UITableViewCell(style: UITableViewCellStyle.value1, reuseIdentifier: "UITableViewCell")
        }
        cell?.selectionStyle = .none
        let demain = dataSource[indexPath.row]
        cell?.textLabel?.text = demain.dName
        
        if selectedDomain.contains(where: { $0.dId == demain.dId}) {
            cell?.accessoryType = .checkmark
        }else
        {
            cell?.accessoryType = .none
        }
        
        return cell!
    }
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let demain = dataSource[indexPath.row]
        
        let cell = tableView.cellForRow(at: indexPath)
        
        if let index = selectedDomain.index(where: {$0.dId == demain.dId}) {
            selectedDomain.remove(at: index)
            cell?.accessoryType = .none
        }else
        {
            guard selectedDomain.count < 4 else{
                Third.toast.message("您最多可以选择 \(maxCount) 个领域")
                return
            }
            selectedDomain.append(demain)
            cell?.accessoryType = .checkmark
        }
    }
}
