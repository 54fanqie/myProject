//
//  CYJRECBuildAddChildController.swift
//  ZiPingSwift
//
//  Created by kyang on 2017/9/26.
//  Copyright © 2017年 Chinayoujiao. All rights reserved.
//

import Foundation
import HandyJSON


class CYJRECBuildAddChildController: KYBaseTableViewController {
    
    var uploadButton: UIButton!
    /// 保存后的回调
    var hasSelected: CYJCompleteHandler?
    
    var dataSource: [CYJChild] = []
    var selectedChildren: [CYJChild] = []
    
    let maxCount = 5
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //input code heree
        title = "选择幼儿"
        
        self.shouldHeaderRefresh = false
        self.shouldFooterRefresh = true
        
        makeTableViewStyle()
        
        makeUploadButton()
        
        fetchDataSource()
        
    }
    /// 请求列表数据
    override func fetchDataSource() {
        
        RequestManager.POST(urlString: APIManager.Baby.list, params: ["token": LocaleSetting.token, "type": "1", "page": "\(self.page)"]) { [unowned self] (data, error) in
            
            self.tableView.mj_footer.endRefreshing()
            //如果存在error
            
            guard error == nil else {
                self.statusUpdated(success: false)
                Third.toast.message((error?.localizedDescription)!)
                return
            }
            self.statusUpdated(success: true)
            
            if let children = data as? NSArray {
                if self.page == 1 {
                    self.dataSource.removeAll()
                }
                //遍历，并赋值
                var tmpChildren = [CYJChild]()
                children.forEach({
                    let target = JSONDeserializer<CYJChild>.deserializeFrom(dict: $0 as? NSDictionary)
                    
                    tmpChildren.append(target!)
                })
                
                if tmpChildren.count < 10 {
                    self.tableView.mj_footer.endRefreshingWithNoMoreData()
                }
                self.dataSource.append(contentsOf: tmpChildren)
                
                self.tableView.reloadData()
            }
        }
    }
}

//MARK: make UI
extension CYJRECBuildAddChildController {
    
    /// 格式化表格
    func makeTableViewStyle() {
        
        tableView.register(UINib(nibName: "CYJRECBuildChildAddCell", bundle: nil), forCellReuseIdentifier: "CYJClassSelectedCell")
        tableView.contentInset = UIEdgeInsetsMake(0, 0, 64, 0)
        tableView.separatorStyle = UITableViewCellSeparatorStyle.singleLine
        tableView.tableFooterView = UIView()
//        tableView.allowsMultipleSelection = true
        
        tableView.reloadData()
    }
    
    /// 创建提交按钮
    func makeUploadButton() {
        
        uploadButton = UIButton(frame: CGRect(x: 0, y: 0, width: 65, height: 35))
        uploadButton.backgroundColor = UIColor.clear
        uploadButton.setTitle("确定", for: UIControlState.normal)
        uploadButton.theme_setTitleColor("Nav.barTextColor", forState: .normal)
        
        uploadButton.addTarget(self, action: #selector(uploadSelected), for: UIControlEvents.touchUpInside)
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: uploadButton)
        
        view.addSubview(uploadButton)
    }
}
//MARK: click method
extension CYJRECBuildAddChildController {
    //MARK: 保存更改
    func uploadSelected() {
        DLog("upload selected")
        
        if (self.hasSelected) != nil {
            self.hasSelected!(self.selectedChildren)
        }
        self.navigationController?.popViewController(animated: true)
    }
    
}
//MARK: tableView Delegate
extension CYJRECBuildAddChildController {
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 55
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "CYJClassSelectedCell") as! CYJRECBuildChildAddCell
        cell.selectionStyle = UITableViewCellSelectionStyle.none
        cell.separatorInset = UIEdgeInsetsMake(0, 0, 0, 0)
        let child = dataSource[indexPath.row]
        cell.child = child
        
        //设置选中效果
        cell.isAdd =  selectedChildren.contains(where: { (selected) -> Bool in
            selected.uId == child.uId
        })
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        
        return indexPath
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //选中
        let cell = tableView.cellForRow(at: indexPath) as? CYJRECBuildChildAddCell
        let child = dataSource[indexPath.row]
        
        if let index = selectedChildren.index(where: { $0.uId == child.uId}) {
            //删除，不受个数限制
            selectedChildren.remove(at: index)
            cell?.isAdd = false
        }else
        {
            // 添加，收到最大个数限制
            guard selectedChildren.count < maxCount else{
                Third.toast.message("幼儿最多可选择\(maxCount)个")
                return
            }
            selectedChildren.append(child)
            cell?.isAdd = true
        }
        
//        uploadButton.isEnabled = selectedChildren.count > 0
    }
//    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
//        //检查选中个数
////        guard let _ = tableView.indexPathsForSelectedRows else
////        {
////
////            return
////        }
//    }
    override func title(forEmptyDataSet scrollView: UIScrollView) -> NSAttributedString? {
        switch status {
        case .emptyDate:
            let text = "班级中没有幼儿"
            let font = UIFont.systemFont(ofSize: 15)
            let textColor = UIColor(hex: "666666", alpha: 1.0)
            var attributes = [String:Any]()
            
            if text.isEmpty {
                return nil
            }
            attributes[NSFontAttributeName] = font
            attributes[NSForegroundColorAttributeName] = textColor
            
            return NSAttributedString(string: text, attributes: attributes)
        default:
            let attrText = super.title(forEmptyDataSet: scrollView)
            return attrText
        }
    }
}

