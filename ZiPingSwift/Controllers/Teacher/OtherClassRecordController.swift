//
//  OtherClassRecordController.swift
//  ZiPingSwift
//
//  Created by fanqie on 2018/8/14.
//  Copyright © 2018年 Chinayoujiao. All rights reserved.
//

import UIKit
import HandyJSON
class OtherClassRecordController: CYJRECListViewController {
    
    var searchBar: UISearchBar!
    
    lazy var listParam: RECListSearchParam = {
        return RECListSearchParam()
    }()
    var searchClassArray: [CYJClass]?
    
    
    //    var countView: CYJRecordCountView!
    
    override func viewDidLoad() {
        let   fakeSearchBarView = UIView(frame: CGRect(x:0 , y: Theme.Measure.navigationBarHeight, width:view.frame.width,height:46))
        fakeSearchBarView.theme_backgroundColor = Theme.Color.viewLightColor
        view.addSubview(fakeSearchBarView);
        
        let fakeSearchBar = UIButton(type: .custom)
        fakeSearchBar.theme_setTitleColor(Theme.Color.textColorHint, forState: .normal)
        fakeSearchBar.setTitle(" 筛选", for: .normal)
        fakeSearchBar.setImage(#imageLiteral(resourceName: "icon_gray_search"), for: .normal)
        fakeSearchBar.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        fakeSearchBar.frame = CGRect(x: 10, y:8, width: fakeSearchBarView.frame.width-20, height: 30)
        fakeSearchBar.addTarget(self, action: #selector(goSearchArea), for: .touchUpInside)
        fakeSearchBar.setBackgroundImage(#imageLiteral(resourceName: "icon_gray_shaixuankuang"), for: .normal)
        fakeSearchBarView.addSubview(fakeSearchBar)
        
        haveTabBar = true
        super.viewDidLoad()
        
        self.tableView.frame = CGRect(x: 0, y: Theme.Measure.navigationBarHeight + 50, width: view.frame.width, height: view.frame.height - Theme.Measure.navigationBarHeight - 50)
        self.tableView.contentInset = UIEdgeInsetsMake(0, 0, 0, 0)
        //        请求第一轮数据
        self.fetchDataSource()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        //        if self.page == 1 {
        //        }
    }
    
    override func fetchDataSource() {
        
        self.listParam.page = self.page
        self.listParam.isother = 1
        if self.page == 1 {
            
            //            if let _ = tableView.cellForRow(at: IndexPath(row: 0, section: 0 )) {
            //
            //                DispatchQueue.main.async {[unowned self] in
            //                    self.tableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .none, animated: false)
            //
            //                }
            //            }
            
            Third.toast.show { }
        }
        RequestManager.POST(urlString: APIManager.Record.list, params: listParam.encodeToDictionary()) { [weak self] (data, error) in
            
            if self?.page == 1 {
                Third.toast.hide {}
            }
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
                    
                    let recordFrame = CYJRecordCellFrame(record: target!, role: nil, isOtherClass : true)
                    tmpFrame.append(recordFrame)
                })
                if tmpFrame.count < 10 {
                    self?.tableView.mj_footer.endRefreshingWithNoMoreData()
                }
                self?.dataSource.append(contentsOf: tmpFrame)
                //                self?.countView?.count = 190
                
                self?.tableView.reloadData()
            }
        }
    }
    //
    //    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
    //        return 30
    //    }
    //    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
    //        let seprateView = UIView(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: 30))
    //        seprateView.theme_backgroundColor = Theme.Color.ground
    //
    //        //创建  countedView
    //        countView = CYJRecordCountView(frame: CGRect(x: 0, y: 0, width: Theme.Measure.screenWidth, height: 30))
    //        countView.clearButtonClickHandler = {[unowned self] _ in
    //            self.listParam.clear()
    //            self.page = 1
    //            self.fetchDataSource()
    //        }
    //
    //        seprateView.addSubview(countView)
    //
    //        return seprateView
    //    }
    //
    // 园长端增加删除 功能
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        if let cell = cell as? CYJRecordListCell {
            cell.deleteActionHandler = {
                if let index = self.tableView.indexPath(for: $0) {
                    let record = self.dataSource[index.row].record

                    let alert = UIAlertController(title: "提示", message: "是否要删除此条成长记录？", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "取消", style: .cancel, handler: nil))
                    alert.addAction(UIAlertAction(title: "确定", style: .default, handler: { (action) in

                        let parameter: [String: Any] = ["grId" : "\(record.grId)", "token" : LocaleSetting.token]

                        RequestManager.POST(urlString: APIManager.Record.delete, params: parameter) { [unowned self] (data, error) in
                            //如果存在error
                            guard error == nil else {
                                Third.toast.message((error?.localizedDescription)!)
                                return
                            }
                            self.dataSource.remove(at: index.row)
                            self.tableView.deleteRows(at: [index], with: .none)
                        }

                    }))

                    self.present(alert, animated: true, completion: nil)
                }
            }
        }
    }
}

extension OtherClassRecordController {
    
    func goSearchArea() {
        let filter = OtherClassSearchController()
        filter.listparam = self.listParam.copy() as! RECListSearchParam
        filter.classInGrade = self.searchClassArray
        filter.finishSelected = {[unowned self] in
            //选出来了
            self.listParam = $0.0.copy() as! RECListSearchParam
            DLog("self.listParam.encodeToDictionary()")
            
            DLog(self.listParam.encodeToDictionary())
            DLog("===================================")
            self.searchClassArray = $0.1
            self.page = 1
            self.tableView.mj_footer.resetNoMoreData()
            self.tableView.contentOffset = CGPoint.zero
            self.fetchDataSource()
        }
        
        let nav = KYNavigationController(rootViewController: filter)
        present(nav, animated: true, completion: nil)
    }
    
}
