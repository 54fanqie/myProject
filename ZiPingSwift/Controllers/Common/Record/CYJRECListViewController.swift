//
//  CYJRECListViewController.swift
//  ZiPingSwift
//
//  Created by kyang on 2017/8/30.
//  Copyright © 2017年 Chinayoujiao. All rights reserved.
//

import UIKit

class CYJRECListViewController: KYBaseTableViewController {

    var dataSource: [CYJRecordCellFrame] = []
    
    var readyToReload: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.shouldHeaderRefresh = true
        self.shouldFooterRefresh = true
        

        tableView.separatorStyle = .singleLine
        
        tableView.register(CYJRecordListCell.self, forCellReuseIdentifier: CYJRecordListCell.CellMode.none.rawValue)
        tableView.register(CYJRecordListCell.self, forCellReuseIdentifier: CYJRecordListCell.CellMode.one.rawValue)
        tableView.register(CYJRecordListCell.self, forCellReuseIdentifier: CYJRecordListCell.CellMode.two.rawValue)
        tableView.register(CYJRecordListCell.self, forCellReuseIdentifier: CYJRecordListCell.CellMode.three.rawValue)
        tableView.register(CYJRecordListCell.self, forCellReuseIdentifier: CYJRecordListCell.CellMode.four.rawValue)
        tableView.register(CYJRecordListCell.self, forCellReuseIdentifier: CYJRecordListCell.CellMode.video.rawValue)

        NotificationCenter.default.addObserver(self, selector: #selector(listenRecordChanged(notifi:)), name: CYJNotificationName.recordChanged, object: nil)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if  readyToReload {
            tableView.reloadData()
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func listenRecordChanged(notifi: Notification) {
        if let _ = notifi.object as? String {
            //暂存-->暂存
            DLog("//暂存-->暂存  没有变化")
        }else {
            //暂存--发布新建--发布
            DLog("// 暂存-->发布,//新建--发布 刷新")
            if self.tableView.contentOffset.y == 0 {
                //刷新页面
                DLog("//刷新--------------------")
                DispatchQueue.main.async { [weak self] in
                    self?.page = 1
                    self?.tableView.mj_footer.resetNoMoreData()
                    self?.fetchDataSource()
                }
            }
        }
    }
}

extension CYJRECListViewController {
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if dataSource.count > 0 {
            let cellFrame = dataSource[indexPath.row]
            
            let photoCount = cellFrame.record.photo?.count
            var mode: CYJRecordListCell.CellMode
            switch photoCount! {
                
            case 0: mode = CYJRecordListCell.CellMode.none
            case 1: mode = CYJRecordListCell.CellMode.one
            case 2: mode = CYJRecordListCell.CellMode.two
            case 3: mode = CYJRecordListCell.CellMode.three
            case 4: mode = CYJRecordListCell.CellMode.four
            default:
                mode = CYJRecordListCell.CellMode.none
            }
            let cell = tableView.dequeueReusableCell(withIdentifier: mode.rawValue ) as? CYJRecordListCell
            cell?.listFrame = cellFrame
            cell?.selectionStyle = .none
            return cell!
        }else
        {
            return UITableViewCell()
        }
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if dataSource.count > 0
        {
            let cellFrame = dataSource[indexPath.row]
                print(cellFrame.cellHeight)
            return cellFrame.cellHeight
        }
        return 0

    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if dataSource.count > 0
        {
            let cellFrame = dataSource[indexPath.row]
            
            let vc = CYJRECDetailViewController()
            vc.recordId = cellFrame.record.grId
            vc.isOtherClass = cellFrame.isOtherClass
            vc.indexPath = indexPath
            vc.isPraisedHandler = { [unowned self] in
                if let indexP = $0 as? IndexPath{
                    let record = self.dataSource[indexPath.row].record
                    record.isPraised = 1
                    record.praiseNum += 1
                    self.tableView.reloadRows(at: [indexP], with: .none)
                }
            }
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
}


