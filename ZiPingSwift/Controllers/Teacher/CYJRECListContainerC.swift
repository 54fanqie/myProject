//
//  CYJRECListContainerC.swift
//  ZiPingSwift
//
//  Created by kyang on 2017/9/11.
//  Copyright © 2017年 Chinayoujiao. All rights reserved.
//

import UIKit

import HandyJSON

class CYJRECListViewControllerTeacher: CYJRECListViewController, CYJDropDownViewDelegate {
    
    var dropDownView: CYJRECDropDownView!
    var items = [CYJDropDownItem]()
    
    var listParam: RECListSearchParam = RECListSearchParam()
    
    var domains: [CYJDomain]?
    var teachers: [CYJChild]? //老师的数据和学生一样。因此不再单开
    var children: [CYJChild]?
    
    var timeSelectedIndex: Int = 0
    var startTime: String?
    var endTime: String?
    
    var countedView: CYJRecordCountView?
    
    override func viewDidLoad() {

        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        items.append(CYJDropDownItem(text: "按日期", key: "time"))
        items.append(CYJDropDownItem(text: "按领域", key: "domain"))
        items.append(CYJDropDownItem(text: "按教师", key: "teacher"))
        items.append(CYJDropDownItem(text: "按幼儿", key: "child"))
        

        let seprateView = UIView(frame: CGRect(x: 0, y: Theme.Measure.navigationBarHeight, width: view.frame.width, height: 44 + 30))
        seprateView.theme_backgroundColor = Theme.Color.line
        
        let dropDownView = CYJRECDropDownView(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: 44))
        dropDownView.contianerView = self.view
        dropDownView.delegate = self
         
        seprateView.addSubview(dropDownView)
        dropDownView.reloadDropDownView()
        self.dropDownView = dropDownView
        //创建  countedView
        countedView = CYJRecordCountView(frame: CGRect(x: 0, y: 44, width: Theme.Measure.screenWidth, height: 30))
        countedView?.theme_backgroundColor = Theme.Color.viewLightColor
        seprateView.addSubview(countedView!)
        
        countedView?.clearButtonClickHandler = { [unowned self] _ in
            self.listParam.clear()
            self.page = 1
            //MARK: 清除全部选项
            DispatchQueue.main.async {
                let indexPath = IndexPath(row: 0, section: 0)
                if let _ = self.tableView.cellForRow(at: indexPath) {
                    self.tableView.scrollToRow(at: indexPath, at: .top, animated: false)
                }
                //清除日期的选中
                self.timeSelectedIndex = 0
                //清除countedView的所有选中
                self.countedView?.removeKey(key: .time)
                self.countedView?.removeKey(key: .domain)
                self.countedView?.removeKey(key: .teacher)
                self.countedView?.removeKey(key: .child)
                //清除dropDownView的所有选中
                self.dropDownView.reloadDropDownView()
                self.fetchDataSource()
            }
        }
        
        view.addSubview(seprateView)
        
        //区分系统版本
        if #available(iOS 11, *) {
            tableView.frame = CGRect(x: 0, y: 44+30+Theme.Measure.navigationBarHeight, width: Theme.Measure.screenWidth, height: Theme.Measure.screenHeight - (Theme.Measure.navigationBarHeight+44+30) - Theme.Measure.tabBarHeight)

        } else {
            tableView.frame = CGRect(x: 0, y: 44+30, width: Theme.Measure.screenWidth, height: Theme.Measure.screenHeight - (Theme.Measure.navigationBarHeight+49+30))

        }

        self.fetchDomainForClass()
        self.fetchDataSource()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
    }
    
    
    /// 请求数据
    override func fetchDataSource() {
        
        self.listParam.page = self.page
//        self.listParam.isother = 0
        RequestManager.POST(urlString: APIManager.Record.list, params: listParam.encodeToDictionary()) { [weak self] (data, error) in
            //如果存在error
            self?.endRefreshing()
            
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
               var recordTmp = [CYJRecordCellFrame]()
                records.forEach({
                    let target = JSONDeserializer<CYJRecord>.deserializeFrom(dict: $0 as? NSDictionary)
                    let recordFrame = CYJRecordCellFrame(record: target!, role: nil)
                    recordTmp.append(recordFrame)
                })
                if recordTmp.count < 10 {
                    self?.tableView.mj_footer.endRefreshingWithNoMoreData()
                }

                DispatchQueue.main.async {
                    self?.dataSource.append(contentsOf: recordTmp)
                    self?.countedView?.count = (self?.dataSource.first?.record.total) ?? 0
    
                    self?.tableView.reloadData()
                }
            }else {
                self?.countedView?.count = (self?.dataSource.first?.record.total) ?? 0
            }

        }
    }
    
    
    
    func numberOfItemIn(dropdownView: CYJRECDropDownView) -> Int {
        return 4
    }
    func dropDownView(dropdownView: CYJRECDropDownView, itemFor index: Int) -> CYJDropDownItem {
        print("itemFor \(index)")
        return items[index]
    }
    func dropDownView(dropdownView: CYJRECDropDownView, selectedViewFor index: Int) -> UIView {
        let item = items[index]
        
        switch item.key {
        case "time":
            let selectV = CYJDropDownTimeView(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: 180), currentIndex: self.timeSelectedIndex)
            //设置日期选择的时间段
            
            let scope = Date().getSemester()
            
            selectV.miniumDate = scope.start
            selectV.maxiumDate = scope.end
            
            //检查是否存在开始时间和结束时间
            selectV.currentScope = (self.listParam.startTime,self.listParam.endTime )

            selectV.sureButtonHandler = {[unowned self, scope] (min, max, index) in
                
                dropdownView.dismissSelected(animated: false)
                self.listParam.startTime = min.stringWithYMD()
                self.listParam.endTime = max.stringWithYMD()
                
                self.timeSelectedIndex = index
                
                //根据选择的是不是全部，更新
                if self.timeSelectedIndex == 0 , min == scope.start, max == scope.end { //如果有，那么删除
                    self.countedView?.removeKey(key: .time)
                }else {
                    self.countedView?.addKey(key: .time)
                }
                
                self.page = 1
                self.tableView.mj_footer.resetNoMoreData()
                
                self.fetchDataSource()
            }
            return selectV
        case "domain":
            let selectV = CYJDropDownTableView(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: view.frame.height - 300))
            selectV.allowsMultipleSelection = false
            //TODO: 获取本学期对应的领域
            var options = self.domains?.map({ (domain) -> CYJOption in
                CYJOption(title: domain.dName!, opId: domain.dId!)
            })
            if options == nil {
                options = []
            }
            options?.insert(CYJOption(title: "全部", opId: 0), at: 0)
            let index = options?.index(where: { $0.opId == self.listParam.did})
            selectV.currentIndex = index ?? 0
            
            selectV.options = options!
            selectV.cancelActionHandler = {
                dropdownView.dismissSelected(animated: false)
            }
            selectV.sureActionHandler = {[unowned self] (ops) in
                dropdownView.dismissSelected(animated: true)



                self.page = 1
                self.tableView.mj_footer.resetNoMoreData()

                if ops.contains(where: { $0.opId == 0}) {
                    self.listParam.did = nil
                    self.countedView?.removeKey(key: .domain)

                }else {
                    self.listParam.did = ops.first?.opId
                    self.countedView?.addKey(key: .domain)

                }

//                dropdownView.setTitleForItem(title: "\(ops.first?.title ?? "按领域")", at: 1)

                self.fetchDataSource()
            }
            return selectV
        case "teacher":
            let selectV = CYJDropDownTableView(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: view.frame.height - 300))
            selectV.allowsMultipleSelection = true
            
            selectV.cancelActionHandler = {
                dropdownView.dismissSelected(animated: false)
            }
            selectV.sureActionHandler = {[unowned self] (ops) in
                dropdownView.dismissSelected(animated: true)
                self.page = 1
                self.tableView.mj_footer.resetNoMoreData()

                var teacherids = [Int]()
                ops.forEach({ (op) in
                    teacherids.append(op.opId)
                })
                if ops.contains(where: { $0.opId == 0}) {
                    self.listParam.teacherid = nil
                    self.countedView?.removeKey(key: .teacher)
                }else {
                    self.listParam.teacherid = teacherids
                    self.countedView?.addKey(key: .teacher)
                }
                self.fetchDataSource()
            }
            self.fetchTeachersForClass(selectV)

            return selectV
        case "child":
            
            let selectV = CYJDropDownTableView(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: view.frame.height - 150))
            selectV.allowsMultipleSelection = true

            
            selectV.cancelActionHandler = {
                dropdownView.dismissSelected(animated: false)
            }
            selectV.sureActionHandler = {[unowned self] (ops) in
                dropdownView.dismissSelected(animated: true)
                
                self.page = 1
                self.tableView.mj_footer.resetNoMoreData()

                var childNames = [String]()
                ops.forEach({ (op) in
                    childNames.append(op.title)
                })
                if ops.contains(where: { $0.opId == 0}) {
                    self.listParam.babyName = nil
                    self.countedView?.removeKey(key: .child)
                }else {
                    self.listParam.babyName = childNames
                    self.countedView?.addKey(key: .child)
                }
                self.fetchDataSource()
            }
            //MARK: 每次都请求数据
            self.fetchChildrenForClass(selectV)

            return selectV
            
        default:
            return UIView()
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0.001
    }
    
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
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

// MARK: - 数据请求
extension CYJRECListViewControllerTeacher {
    
    func fetchDomainForClass() {
        let domainParam: [String :String] = ["level": "1", "token": LocaleSetting.token]
        
        RequestManager.POST(urlString: APIManager.Record.tree, params: domainParam) { [unowned self] (data, error) in
            
            //如果存在error
            guard error == nil else {
                Third.toast.message((error?.localizedDescription)!)
                return
            }
            if let domains = data as? NSArray {
                //遍历，并赋值
                var domainTmp = [CYJDomain]()
                domains.forEach({
                    let target = JSONDeserializer<CYJDomain>.deserializeFrom(dict: $0 as? NSDictionary)
                    domainTmp.append(target!)
                })
                self.domains = domainTmp
            }
        }
    }
    func fetchTeachersForClass(_ dropDownView: CYJDropDownTableView) {
        
        let teacherParam: [String :String] = ["token": LocaleSetting.token]
        
        RequestManager.POST(urlString: APIManager.Mine.teacher, params: teacherParam) { [unowned self] (data, error) in
            //如果存在error
            guard error == nil else {
                Third.toast.message((error?.localizedDescription)!)
                return
            }
            if let teachers = data as? NSArray {
                //遍历，并赋值
                var teacherTmp = [CYJChild]()
                teachers.forEach({
                    let target = JSONDeserializer<CYJChild>.deserializeFrom(dict: $0 as? NSDictionary)
                    teacherTmp.append(target!)
                })
                self.teachers = teacherTmp
                
                var options = self.teachers?.map({ (user) -> CYJOption in
                    CYJOption(title: user.realName!, opId: user.uId)
                })
                options?.insert(CYJOption(title: "全部", opId: 0), at: 0)
                
                let index = options?.index(where: { $0.opId == self.listParam.teacherid?.first})
                
                dropDownView.currentIndex = index ?? 0
                dropDownView.options = options!  //这里不可能为空
            }
        }
    }
    
    func fetchChildrenForClass(_ dropDownView: CYJDropDownTableView) {
        
        let childParam: [String :String] = ["token": LocaleSetting.token,"type":"1", "page": "1", "limit": "100"]
        
        RequestManager.POST(urlString: APIManager.Baby.list, params: childParam) { [weak self] (data, error) in
            //如果存在error
//            self?.endRefreshing()
            
            guard error == nil else {
                Third.toast.message((error?.localizedDescription)!)
                return
            }
            if let children = data as? NSArray {
                if self?.page == 1 {
                    self?.dataSource.removeAll()
                }
                //遍历，并赋值
                var childrenTmp = [CYJChild]()
                children.forEach({
                    let target = JSONDeserializer<CYJChild>.deserializeFrom(dict: $0 as? NSDictionary)
                    childrenTmp.append(target!)
                })
                self?.children = childrenTmp
                
                var options = self?.children?.map({ (user) -> CYJOption in
                    CYJOption(title: user.realName!, opId: user.uId)
                })
                
                //TODO: 如果为空，那么为空吧就
                if options == nil {
                    options = []
                }
                
                // 请求下来之后，配置数据
                options?.insert(CYJOption(title: "全部", opId: 0), at: 0)
                
                let index = options?.index(where: { $0.title == self?.listParam.babyName?.first})
                dropDownView.currentIndex = index ?? 0
                dropDownView.options = options!
            }
        }
    }
    
}
