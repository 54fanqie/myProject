//
//  CYJRECListController_Parent.swift
//  ZiPingSwift
//
//  Created by kyang on 2017/9/22.
//  Copyright © 2017年 Chinayoujiao. All rights reserved.
//

import Foundation
import HandyJSON

class CYJRECListControllerParent: CYJRECListViewController {
    
    var uid: Int = 0
    var did: Int = 0
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
//        if self.page == 1 {
//            self.fetchDataSource()
//        }else
//        {
            self.tableView.reloadData()
//        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.fetchDataSource()
        
        if self.uid != 0 {
            self.tableView.contentInset = UIEdgeInsetsMake(0, 0, Theme.Measure.tabBarHeight + Theme.Measure.navigationBarHeight, 0)
        }
        self.tableView.frame = CGRect(x: 0, y: 0, width: Theme.Measure.screenWidth, height: Theme.Measure.screenHeight - Theme.Measure.tabBarHeight  )
    }
    
    
    override func fetchDataSource() {
        
        var paramter: [String: Any] = ["token": LocaleSetting.token, "page": "\(self.page)", "uId" : self.uid]
        
        var urlString = APIManager.Record.listParent
        //TODO: 从成长评价进来后加上这个参数
        if self.did != 0 {
            paramter["did"] = self.did
            urlString = APIManager.Record.listDomain
        }
        
        RequestManager.POST(urlString: urlString, params: paramter) { [weak self] (data, error) in
            
            self?.endRefreshing()

            //如果存在error
            guard error == nil else {
                self?.statusUpdated(success: false)
                Third.toast.message((error?.localizedDescription)!)
                return
            }
            
            self?.statusUpdated(success: true)
            
            if let records = data as? NSArray {
                if self?.page == 1 {
                    self?.dataSource.removeAll()
                }
                //遍历，并赋值
                var tmpFrame = [CYJRecordCellFrame]()
                records.forEach({
                    let target = JSONDeserializer<CYJRecord>.deserializeFrom(dict: $0 as? NSDictionary)
                    
                    let recordFrame = CYJRecordCellFrame(record: target!, role: .child)
                    tmpFrame.append(recordFrame)
                })
                if tmpFrame.count < 10 {
                    self?.tableView.mj_footer.endRefreshingWithNoMoreData()
                }
                self?.dataSource.append(contentsOf: tmpFrame)
                self?.tableView.reloadData()
            }
        }
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        if let recCell = cell as? CYJRecordListCell {
            recCell.goodActionHandler = { (cc, sender) in
                let recCC = cc as! CYJRecordListCell
                let record = recCC.listFrame.record

                let parameter: [String: Any] = ["grId" : record.grId, "token": LocaleSetting.token]
                
                RequestManager.POST(urlString: APIManager.Record.praise, params: parameter) { [unowned sender] (data, error) in
                    //如果存在error
                    guard error == nil else {
                        sender.isSelected = false
                        Third.toast.message((error?.localizedDescription)!)
                        return
                    }
                    sender.isSelected = true
                    record.isPraised = 1
                    Third.toast.message("点赞成功")
                }
            }
        }
        
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let recCellFrame = self.dataSource[indexPath.row]
        let detail = CYJRECControllerViewByParent(.grouped)
        detail.grId = recCellFrame.record.grId
        
        if self.uid == 0 {
            detail.userId = (LocaleSetting.userInfo()?.uId)!
        }else
        {
            detail.userId = self.uid
        }
        

        detail.listRecord = recCellFrame.record  //留着点赞后向 回传值
        self.navigationController?.pushViewController(detail, animated: true)
    }
}
