//
//  CYJAnalyseViewController.swift
//  ZiPingSwift
//
//  Created by kyang on 2017/9/22.
//  Copyright © 2017年 Chinayoujiao. All rights reserved.
//

import Foundation
import Charts
import HandyJSON
import SwiftTheme

class CYJAnalyseParam: CYJParameterEncoding {
    
    var token = LocaleSetting.token
    
    var year: Int = 2017
    var semester: Int = 1 //学期（1秋季，2春季）
    var grade: Int = 1 //所属年级(1 '大班', 2 '中班', 3 '小班', 4 '托班 ',)
    var cId: Int = 0   // Y    班级id 全部的时候 为0
    var dId: String?  //Y    领域id，数组形式
    var diId: String?   // Y    维度id，数组形式
    
}


class CYJAnalyseViewController: KYBaseTableViewController {
    
    var tabelHeaderView: UIView!
    
    /// 三个条件
    var termConditionView: CYJConditionView!
    var classConditionView: CYJConditionView!
    var scopeConditionView: CYJConditionView!
    
    
    var gradeCondition: CYJConditionButton!
    var classCondition: CYJConditionButton!
    var scopeCondition: CYJConditionButton!
    
    // 按钮的承载
    var actionsView: CYJActionsView!
    /// 表格 的列表
    var chartViews: [UIView] = []
    /// 参数 对象
    var analyseParam: CYJAnalyseParam = CYJAnalyseParam()
    
    /// 年分的数组
    lazy var yearArray: [CYJOption] = {
        
        var years = [CYJOption]()
        
        let data = Date(timeIntervalSinceNow: 0)
        let calendar = Calendar.current
        let comp = calendar.dateComponents([.year], from: data)
        let year = comp.year
        
        let index = year! - 2017
        for i in 0..<(index + 1) {
            let option = CYJOption(title: "\(year! - i)", opId: year! - i)
            years.append(option)
        }
        return years
    }()
    /// 学期的数组
    lazy var semesterArray: [CYJOption] = {
        return [CYJOption(title: "春季", opId: 2), CYJOption(title: "秋季", opId: 1)]
    }()
    
    /// 你那集的数组
    lazy var gradeArray:  [CYJOption] = {
        return [CYJOption(title: "大班", opId: 1),
                CYJOption(title: "中班", opId: 2),
                CYJOption(title: "小班", opId: 3),
                CYJOption(title: "托班", opId: 4)]
    }()
    /// 年度 所有 班级列表
    var classesForYear: [CYJClass] = []
    
    /// 班级下面的范围
    var domainsForClass: [CYJDomain] = []
    var selectedDids: [String] {
        guard let dids = self.analyseParam.dId else{
            return []
        }
        return dids.components(separatedBy: ",")
    }
    
    var selectedDiids: [String]{
        
        guard let dids = self.analyseParam.diId else{
            return []
        }
        return dids.components(separatedBy: ",")
    }
    /// 表格数据 的数据源
    var barChartDatas: [BarChartData] = []
    
    /// titles
    var barChartTitle: [String] = []

    /// 页面的数据源
    var dataSource: CYJBarData?
    
    override func viewDidLoad() {
        
        enabledEmptyDataSet = false
        
        super.viewDidLoad()
        
        tabelHeaderView = UIView(frame: CGRect(x: 0, y: Theme.Measure.navigationBarHeight, width: view.frame.width, height: 240))
        tabelHeaderView.theme_backgroundColor = Theme.Color.line
        tableView.tableHeaderView = tabelHeaderView
        tableView.tableFooterView = UIView()
        
        //MARK: 设置 初始 年 学期
        let yearAndSemester = Date().getYearAndSemester()
        self.analyseParam.year = yearAndSemester.year
        self.analyseParam.semester = yearAndSemester.semester
        
        termConditionView = CYJConditionView(title: "记录时间", key: "time")
        let yearCondition = CYJConditionButton(title: "\(self.analyseParam.year)", key: "time_year") { (sender) in

            let index = self.yearArray.index(where: { $0.opId == self.analyseParam.year}) ?? 0
            
            let optionController = CYJOptionsSelectedController(currentIndex: index, options:             self.yearArray) { [unowned sender](op) in
                print("\(op.title)")
                sender.setTitle(op.title, for: .normal)
                
                self.analyseParam.year = Int(op.title)!
                
                //TODO: 选年--刷新--班级--范围
//                self.classCondition.setTitle("全部", for: .normal)
                self.classCondition.title = "全部"
                self.scopeCondition.title = "筛选"
                self.getClassbyYear()
                self.fetchDomainsFromServer()

                self.analyseParam.cId = 0
                self.analyseParam.dId = nil
                self.analyseParam.diId = nil
            }
            self.navigationController?.pushViewController(optionController, animated: true)
        }
        let season = self.semesterArray.index { $0.opId == self.analyseParam.semester}
        
        let seasonCondition = CYJConditionButton(title: self.semesterArray[season!].title , key: "time_season") { (sender) in
            
            let index = self.semesterArray.index { $0.opId == self.analyseParam.semester} ?? 0
            
            let optionController = CYJOptionsSelectedController(currentIndex: index, options: self.semesterArray) { [unowned sender](op) in
                print("\(op.title)")
                sender.setTitle(op.title, for: .normal)
                
                self.analyseParam.semester = op.opId
                //TODO: 选年--刷新--班级--范围
//                self.classCondition.setTitle("全部", for: .normal)
                self.classCondition.title = "全部"

//                self.scopeCondition.setTitle("范围", for: .normal)
                self.scopeCondition.title = "筛选"
                self.getClassbyYear()
                self.fetchDomainsFromServer()

                self.analyseParam.cId = 0
                self.analyseParam.dId = nil
                self.analyseParam.diId = nil
            }
            self.navigationController?.pushViewController(optionController, animated: true)
        }

        termConditionView.addCondition(yearCondition)
        termConditionView.addCondition(seasonCondition)
        termConditionView.frame.origin = CGPoint(x: 0, y: 0)
        tabelHeaderView.addSubview(termConditionView)
        
        //MARK: 设置初始年级为 大班 -- 获取领域
        self.analyseParam.grade = 1
        self.fetchDomainsFromServer()

        classConditionView = CYJConditionView(title: "筛选班级", key: "class")
        gradeCondition = CYJConditionButton(title: "大班", key: "class_grade") {[unowned self] (sender) in
            print("筛选年级")
            
            let gradeIndex = self.gradeArray.index(where: { $0.opId == self.analyseParam.grade}) ?? 0
            
            let optionController = CYJOptionsSelectedController(currentIndex: gradeIndex, options: self.gradeArray) { [unowned sender](op) in
                print("\(op.title)")
                sender.setTitle(op.title, for: .normal)
                
                self.analyseParam.grade = op.opId
                
                self.fetchDomainsFromServer()
                
                //刷新下面参数
                //TODO: 选年--刷新--班级--范围
//                self.classCondition.setTitle("全部", for: .normal)
                self.classCondition.title = "全部"

//                self.scopeCondition.setTitle("范围", for: .normal)
                self.scopeCondition.title = "筛选"

                
                self.fetchDomainsFromServer()

                self.analyseParam.cId = 0
                self.analyseParam.dId = nil
                self.analyseParam.diId = nil
            }
            self.navigationController?.pushViewController(optionController, animated: true)
        }

        classCondition = CYJConditionButton(title: "班级", key: "class_class") {[unowned self] (sender) in
            print("班级")
            //班级需要从网络上进行获取
            if self.analyseParam.grade == 0 {
                Third.toast.message("请先选择年级")
                return
            }
            
            var classInGrade = self.classesForYear.filter({
                $0.grade == self.analyseParam.grade
            })
            
            var options = [CYJOption]()
            options.append(CYJOption(title: "全部", opId: 0))

            for i in 0..<classInGrade.count {
                let ccc = classInGrade[i]
                let option = CYJOption(title: ccc.cName!, opId: ccc.cId)
                options.append(option)
            }
            
            let classIndex = options.index(where: { $0.opId == self.analyseParam.cId}) ?? 0

            
            let optionController = CYJOptionsSelectedController(currentIndex: classIndex, options: options) { [unowned sender](op) in
                print("\(op.title)")
                sender.setTitle(op.title, for: .normal)
                sender.title = op.title
                
                self.analyseParam.cId = op.opId
            }
            self.navigationController?.pushViewController(optionController, animated: true)
        }
        classConditionView.addCondition(gradeCondition)
        classConditionView.addCondition(classCondition)
        classConditionView.frame.origin = CGPoint(x: 0, y: termConditionView.frame.maxY)
        tabelHeaderView.addSubview(classConditionView)
        
        scopeConditionView = CYJConditionView(title: "分析范围", key: "scope")
        scopeCondition = CYJConditionButton(title: "范围", key: "scope_scope") { [unowned self] (sender) in
            //TODO: print("分析范围")
            
            if self.domainsForClass.count == 0 {
                Third.toast.message("该年级园长暂未设置评价指标，暂不能查看成长分析报告。")
                return
            }
            
            let scope = CYJAnalyseScropeController()
            scope.domains = self.domainsForClass
            scope.selectedDids = self.selectedDids
            scope.selectedDiids = self.selectedDiids

            scope.completeClosure = { [unowned sender] in
                print($0)
                //改变已选个数
                let count = $0.0.count + $0.1.count
                
                if count > 0 {
                    
//                    sender.setTitle("已选\(count)", for: .normal)
//                    self.scopeCondition.title = "筛选"
                    sender.title = "已选分析范围\(count)个"
                    self.analyseParam.dId = $0.0.joined(separator: ",")
                    self.analyseParam.diId = $0.1.joined(separator: ",")
                    
                }else{
                    sender.setTitle("筛选", for: .normal)
                }
            }
            
            self.navigationController?.pushViewController(scope, animated: true)
        }
        scopeConditionView.addCondition(scopeCondition)
        scopeConditionView.frame.origin = CGPoint(x: 0, y: classConditionView.frame.maxY)
        tabelHeaderView.addSubview(scopeConditionView)
        
        actionsView = CYJActionsView(frame: CGRect(x: 0, y: scopeConditionView.frame.maxY, width: view.frame.width, height: 60))
        actionsView.innerPadding = 10
        actionsView.theme_backgroundColor = Theme.Color.ground
        
        let resetButton = CYJFilterButton(title: "重置") { [unowned self] (sender) in
            print("重置")
            //TODO: 重置筛选的状态
            //MARK: 设置 初始 年 学期
            let yearAndSemester = Date().getYearAndSemester()
            self.analyseParam.year = yearAndSemester.year
            self.analyseParam.semester = yearAndSemester.semester
            self.analyseParam.grade = 1
            self.analyseParam.cId = 0
            self.analyseParam.dId = nil
            self.analyseParam.diId = nil

            let season = self.semesterArray.index { $0.opId == self.analyseParam.semester}
            yearCondition.setTitle("\(self.analyseParam.year)", for: .normal)
            seasonCondition.setTitle("\(self.semesterArray[season!].title)", for: .normal)
            
            self.gradeCondition.setTitle("大班", for: .normal)
//            self.classCondition.setTitle("班级", for: .normal)
            self.classCondition.title = "全部"

            self.scopeCondition.title = "筛选"
            // 获取一下班级信息
            self.getClassbyYear()
            self.clearAllCharts()

        }
        resetButton.filterButtonStyle = .nomal_light_Style
        
        let showButton = CYJFilterButton(title: "查看报告") {[weak self] (sender) in
            print("查看报告")
            //MARK: 请求bar数据
            if self?.analyseParam.dId == nil || self?.analyseParam.diId == nil {
                Third.toast.message("请选择分析范围")
                return
            }
            
            self?.fetchBarDataFromServer()
        }
        showButton.filterButtonStyle = .nomal_color_Style
        
        
        let applyButton = CYJFilterButton(title: "申请专业分析") { [unowned self] (sender) in
            print("申请专业分析")
            let applyController = CYJProfessionalAnalyseController()
            
            self.navigationController?.pushViewController(applyController, animated: true)
        }
        applyButton.filterButtonStyle = .nomal_color_Style
        
        
        actionsView.actions = [resetButton, showButton, applyButton]
        tabelHeaderView.addSubview(actionsView)

        tableView.register(CYJCustomBarChartCell.self, forCellReuseIdentifier: "CYJCustomBarChartCell")
        tableView.contentInset = UIEdgeInsetsMake(0, 0, 49, 0)
        // 获取一下班级信息
        self.getClassbyYear()
    }
    
    func reseGradeClassScope(_ by : Int) {
        if by > 99 {
            self.gradeCondition.setTitle("年级", for: .normal)
            self.analyseParam.grade = 0
        }
        
//        self.classCondition.setTitle("班级", for: .normal)
        self.classCondition.title = "全部"

//        self.scopeCondition.setTitle("范围", for: .normal)
        self.scopeCondition.title = "筛选"

        
        self.analyseParam.cId = 0
        self.analyseParam.dId = nil
        self.analyseParam.diId = nil
    }
    
    //请求班级信息
    func getClassbyYear() {
        
        let parameter: [String: Any] =  ["token": LocaleSetting.token, "year": self.analyseParam.year , "semester": "\(self.analyseParam.semester)"]
        
        RequestManager.POST(urlString: APIManager.Baby.getClass, params: parameter) { [unowned self] (data, error) in
            //如果存在error
            guard error == nil else {
                Third.toast.message((error?.localizedDescription)!)
                return
            }
            if let classes = data as? NSArray {
                //晴空所有先
                self.classesForYear.removeAll()
                
                //遍历，并赋值
                classes.forEach({ [unowned self] in
                    let target = JSONDeserializer<CYJClass>.deserializeFrom(dict: $0 as? NSDictionary)
                    self.classesForYear.append(target!)
                })
            }
        }
    }
    
    //MARK: 数据请求
    /// 请求领域信息
    func fetchDomainsFromServer() {
        //每次请求，重置领域信息
        self.domainsForClass.removeAll()
        
        let domainParam: [String: Any] = [
            "level": "2",
            "year" : self.analyseParam.year,
            "semester" : "\(self.analyseParam.semester)",
            "grade" : "\(self.analyseParam.grade)",
            "token" : LocaleSetting.token ]
        
        RequestManager.POST(urlString: APIManager.Record.tree, params: domainParam ) { [unowned self] (data, error) in
            //如果存在error
            guard error == nil else {
                Third.toast.message((error?.localizedDescription)!)
                return
            }
            var tempArr = [CYJDomain]()
            if let fields = data as? NSArray {
                //遍历，并赋值
                fields.forEach({
                    let target = JSONDeserializer<CYJDomain>.deserializeFrom(dict: $0 as? NSDictionary)
                    tempArr.append(target!)
                })
            }
            self.domainsForClass = tempArr
            self.tableView.reloadData()
        }
    }
    /// 请求所有数据
    func fetchBarDataFromServer() {
        
        RequestManager.POST(urlString: APIManager.Tongji.grownfx, params: self.analyseParam.encodeToDictionary() ) { [unowned self] (data, error) in
            //如果存在error
            guard error == nil else {
                Third.toast.message((error?.localizedDescription)!)
                return
            }
            if let bigData = data as? NSDictionary {
                //遍历，并赋
                let target = JSONDeserializer<CYJBarData>.deserializeFrom(dict: bigData)
                self.dataSource = target
                
                // 根据数据，分步创建表格
                
                self.makeChartViewStepByStep()
            }
        }
    }
    
    
    //TODO: 表格创建
    func clearAllCharts() {
        barChartDatas.removeAll()
        tableView.reloadData()
    }
    
    /// 顺便分析好数据
    ///
    func makeChartViewStepByStep() {
        
        clearAllCharts()
 
        dataSource?.domain?.forEach({ (domain) in
            // 纬度
            var dataSets = [BarChartDataSet]()
//            let mainColor = ThemeManager.color(for: "Nav.barTintColor")!
            let mainColor = UIColor(red: 144/255.0, green: 220/255.0, blue: 255/255.0, alpha: 1.0)
            var colors = [mainColor]
            
            if let dimensions = domain.dimension {
                for i in 0..<(dimensions.count) {
                    
                    let dimension = dimensions[i]
             
                    print(Double(dimension.dNum!).roundTo(places: 1))
                    
                    let entry = BarChartDataEntry(x: Double(i) , y: Double(dimension.dNum!))
                    let entries = [entry]
                    
                    let barChartDataSet = BarChartDataSet(values: entries , label: dimension.diName)
                    barChartDataSet.colors = [colors[i % colors.count],UIColor.black]
                    dataSets.append(barChartDataSet)
                }
                let barChartData = BarChartData(dataSets: dataSets)
                barChartData.barWidth = 0.5
                barChartDatas.append(barChartData)
                barChartTitle.append("按\(domain.dName ?? "--")进行整体分析")
            }
        })
        dataSource?.dimension?.forEach({ (demision) in
             // 纬度
            var dataSets = [BarChartDataSet]()
            let mainColor = ThemeManager.color(for: "Nav.barTintColor")!
            var colors = [mainColor]
            
            if let quotas = demision.quota {
                for i in 0..<(quotas.count) {
                    
                    let quota = quotas[i]
                    
                    let doubleStr = String(format: "%.1f", quota.qNum!)
                    
                    print(doubleStr)
                    
                    
                    print(pow(10.0, Double(1.42121212)))
                    
                    let entry = BarChartDataEntry(x: Double(i) , y: Double(doubleStr)! )
                    let entries = [entry]
                    
                    let barChartDataSet = BarChartDataSet(values: entries , label: quota.qTitle)
                    barChartDataSet.colors = [colors[i % colors.count],UIColor.black]
                    dataSets.append(barChartDataSet)
                }
                let barChartData = BarChartData(dataSets: dataSets)
                barChartData.barWidth = 0.5
                barChartDatas.append(barChartData)
                barChartTitle.append("按\(demision.diName ?? "--")进行整体分析")
            }
        })
        tableView.reloadData()
    }
    
    //TODO: 将无数据的背景设置为空
    override func backgroundColor(forEmptyDataSet scrollView: UIScrollView) -> UIColor? {
        return UIColor.clear
    }
}

extension CYJAnalyseViewController: UIPopoverPresentationControllerDelegate {
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return UIModalPresentationStyle.none
    }
}
//220 + CGFloat(barChartData.dataSets.count) * 21)/
extension CYJAnalyseViewController {
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return barChartDatas.count
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let barChatData = barChartDatas[indexPath.row]
        return 220 + 10 + CGFloat(21 * barChatData.dataSets.count) // 4 时领域个数
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CYJCustomBarChartCell") as? CYJCustomBarChartCell
        cell?.barChartData = barChartDatas[indexPath.row]
        cell?.title = barChartTitle[indexPath.row]
        cell?.selectionStyle = .none
        return cell!
        
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView()
        headerView.theme_backgroundColor = Theme.Color.viewLightColor
        let titleLabel = UILabel()
        titleLabel.text = "分析结果"
        titleLabel.theme_textColor = Theme.Color.textColorlight
        titleLabel.font = UIFont.systemFont(ofSize: 13)
        titleLabel.frame = CGRect(x:15 , y:0 , width:100,height:35)
        headerView.addSubview(titleLabel)
        return headerView
    }
    
    //返回分区头部高度
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 35
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
//        let cell = tableView.cellForRow(at: indexPath) as? CYJCustomBarChartCell
//        cell?.animateOut()
    }
    
}

extension Double {
    
    /// Rounds the double to decimal places value
    
    func roundTo(places:Int) -> Double {
        
        let divisor = pow(10.0, Double(places))
        
        return (self * divisor).rounded() / divisor
        
    }
    
}
