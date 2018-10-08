//
//  CYJDropDownTableView.swift
//  ZiPingSwift
//
//  Created by kyang on 2017/9/26.
//  Copyright © 2017年 Chinayoujiao. All rights reserved.
//

import Foundation

class CYJDropDownTableView: UIView {
    
    var tableView: UITableView!
    var allowsMultipleSelection: Bool = false
    
    lazy var buttonActionView: CYJActionsView = {
        let action = CYJActionsView(frame: CGRect(x: 0, y: self.frame.height - 150, width: self.frame.width, height: 60))
        return action
    }()
    
    var currentIndex: Int = 0
    
    var cancelActionHandler: (()->Void)?
    var sureActionHandler: ((_ options: [CYJOption])->Void)?

    var options:[CYJOption] = [] {
        didSet{
            tableView.reloadData()
        }
    }
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        tableView = UITableView(frame: CGRect(x: 0, y: 0, width: frame.width, height: frame.height - 150), style: .plain)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.allowsSelection = true
        
        tableView.allowsMultipleSelection = allowsMultipleSelection
        tableView.tableFooterView = UIView()
        tableView.register(CYJDropDownTableViewCell.self, forCellReuseIdentifier: "CYJDropDownTableViewCell")
        addSubview(tableView)
        
        let resetButton = CYJFilterButton(title: "取消") {[unowned self] (sender) in
            if let cancel = self.cancelActionHandler {
                cancel()
            }
        }
        resetButton.filterButtonStyle = .circle_light_Style
        
        let sureButton = CYJFilterButton(title: "确定") { [unowned self] (sender) in
            
            if let sure = self.sureActionHandler {
                
                if self.allowsMultipleSelection {
                    let indexPaths = self.tableView.indexPathsForSelectedRows
                    if indexPaths != nil {
                        let selects = indexPaths?.map({ (index) -> CYJOption in
                            return self.options[index.row]
                        })
                        sure(selects!)
                    }else
                    {
                        sure([])
                    }
                }else
                {
                    if let index = self.tableView.indexPathForSelectedRow {
                        let op = self.options[index.row]
                        sure([op])
                    }
                }
            }
        }
        
        sureButton.filterButtonStyle = .circle_color_Style
        
        buttonActionView.actions = [resetButton, sureButton]
        buttonActionView.theme_backgroundColor = Theme.Color.ground
        addSubview(buttonActionView)
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

extension CYJDropDownTableView: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return options.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CYJDropDownTableViewCell")
        cell?.selectionStyle = .none
        cell?.textLabel?.theme_textColor = Theme.Color.textColor
        let option = options[indexPath.row]
        cell?.textLabel?.text = option.title
        
        if currentIndex == indexPath.row {
            //设置默认选中
            tableView.selectRow(at: indexPath, animated: true, scrollPosition: .none)
        }
        
        return cell!
    }
}

class CYJDropDownTableViewCell: UITableViewCell {
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: true)
        self.accessoryType = isSelected ? .checkmark : .none
        self.theme_tintColor = Theme.Color.main
    }
}
