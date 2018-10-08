//
//  CYJAttentionAnalyseController.swift
//  ZiPingSwift
//
//  Created by kyang on 2017/10/27.
//  Copyright © 2017年 Chinayoujiao. All rights reserved.
//

import Foundation
import Charts
import HandyJSON
import SwiftTheme

class CYJInterestParam : CYJParameterEncoding{
    
    var token = LocaleSetting.token
    var year: Int = 2017
    var semester: Int = 1 //1,2
    var grade: Int = 0 //1,2,3,4
    var cId: Int = 0
    var stime: String?    //N    开始时间
    var endtime: String?   // N    截止时间
}

class CYJAttentionAnalyseController: KYBaseTableViewController {
    
    var parameterView: UIView!
    
    var termConditionView: CYJConditionView!
    var classConditionView: CYJConditionView!
    var scopeConditionView: CYJTimeConditionView!
    
    var semesterScope: (start: Date ,end: Date) = Date().getSemester()
    {
        didSet{
            let start = semesterScope.start.stringWithYMD()
            let ende = semesterScope.end.stringWithYMD()
            self.scopeConditionView.startButton.setTitle( start, for: .normal)
            self.scopeConditionView.endButton.setTitle( ende, for: .normal)
        }
    }
    
    var actionsView: CYJActionsView!
    
    var gradeCondition: CYJConditionButton!
    var classCondition: CYJConditionButton!
    
    var chartContainerView: UIView?
    
    var countedView: CYJCountedView?
    
    var interestParam: CYJInterestParam = CYJInterestParam()
    
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
    
    var classesForYear: [CYJClass] = []
    
    //MARK: 图表使用的数据
    var pieData: CYJPieData?
    
    var domainChartDatas: [PieChartData] = []
    var domainChartTitles: [String] = []
    
    var dimensionChartDatas: [PieChartData] = []
    var dimensionChartTitles: [String] = []
    
    var totalChartDatas: [PieChartData] = []
    var totalChartTitles: [String] = []
    /// true 没有评价指标
    var noDomainOrDimension: Bool {
        return domainChartDatas.count == 0 && dimensionChartDatas.count == 0 && totalChartDatas.count == 0
    }
    
    var pieChartDatas: [PieChartData]?
    
    var chartListIndex: Int = 0  // domain 0, dimension 1, total 2
    
    let countIdentifier = "CYJCountCell"
    
    let withIdentifier = "CYJPieChartCell"
    
    var scrollSegment: ScrollSegmentView!
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        tableView.register(CYJPieChartCell.self, forCellReuseIdentifier: withIdentifier)
        tableView.register(CYJAttentionCountedCell.self, forCellReuseIdentifier: countIdentifier)
        tableView.tableFooterView = UIView()
        tableView.contentInset = UIEdgeInsetsMake(0, 0, Theme.Measure.tabBarHeight, 0)
        // 滚动条
        var style = SegmentStyle()
        style.showLine = true        // 颜色渐变
        style.gradualChangeTitleColor = true         // 滚动条颜色
        style.titleMargin = 30        //标题间距
        style.scrollTitle = true// s滚动标题
        style.titleAlignment = false  //整体剧中
        
        let color = ThemeManager.color(for: "Nav.barTintColor")!
        let normalColor = ThemeManager.color(for: "Global.textColorLight")!
        
        style.scrollLineColor =  color
        style.normalTitleColor = normalColor
        style.selectedTitleColor = color
        //        style.scrollLineColor =  UIColor(red: 41/255.0, green: 167/255.0, blue: 158/255.0, alpha: 1)
        //        style.scrollLineColor =  UIColor(red: 41/255.0, green: 167/255.0, blue: 158/255.0, alpha: 1)
        
        //        style.normalTitleColor = UIColor(red: 86/255.0, green: 173/255.0, blue: 235/255.0, alpha: 1)
        style.titleFont = UIFont.systemFont(ofSize: 17)
        
        //        style.selectedTitleColor = UIColor(red: 86/255.0, green: 173/255.0, blue: 235/255.0, alpha: 1)
        
        scrollSegment = ScrollSegmentView(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: 44), segmentStyle: style, titles: [ "总体统计","按领域", "按维度"])
        scrollSegment.backgroundColor = UIColor.white
        scrollSegment.titleBtnOnClick = { [unowned self] in
            DLog( "chart list index"  + "\($0.1)" )
            self.chartListIndex = $0.1
            self.tableView.reloadData()
        }
        
        parameterView = UIView()
        
        
        //MARK: 设置 初始 年 学期
        let yearAndSemester = Date().getYearAndSemester()
        self.interestParam.year = yearAndSemester.year
        self.interestParam.semester = yearAndSemester.semester
        
        termConditionView = CYJConditionView(title: "记录时间", key: "time")
        let yearCondition = CYJConditionButton(title: "\(self.interestParam.year)", key: "time_year") { (sender) in
            //
            let currentIndex = self.yearArray.index(where: {$0.opId == self.interestParam.year})
            
            let optionController = CYJOptionsSelectedController(currentIndex: currentIndex!, options: self.yearArray) { [unowned sender, unowned self](op) in
                print("\(op.title)")
                sender.setTitle(op.title, for: .normal)
                
                self.interestParam.year = Int(op.title)!
                
                //TODO: 年选择完毕---更改 记录时间 ---更改班级
                self.semesterScope = Date().getSemesterDuration(year: self.interestParam.year, semester: self.interestParam.semester)
                
                //                self.classCondition.setTitle("班级", for: .normal)
                self.classCondition.title = "全部"
                
                self.interestParam.cId = 0
                self.getClassbyYear()
                self.interestParam.stime = self.semesterScope.start.stringWithYMD()
                self.interestParam.endtime = self.semesterScope.end.stringWithYMD()
            }
            self.navigationController?.pushViewController(optionController, animated: true)
        }
        let season = self.semesterArray.filter { $0.opId == self.interestParam.semester}
        
        let seasonCondition = CYJConditionButton(title: (season.first?.title)!, key: "time_season") { (sender) in
            
            let currentIndex = self.semesterArray.index(where: {$0.opId == self.interestParam.semester})
            
            let optionController = CYJOptionsSelectedController(currentIndex: currentIndex!, options: self.semesterArray) { [unowned sender](op) in
                print("\(op.title)")
                sender.setTitle(op.title, for: .normal)
                self.interestParam.semester = op.opId
                
                //TODO: 学期选择完毕 ---更改 记录时间 ---更改班级
                self.semesterScope = Date().getSemesterDuration(year: self.interestParam.year, semester: self.interestParam.semester)
                
                //                self.classCondition.setTitle("班级", for: .normal)
                self.classCondition.title = "全部"
                
                self.interestParam.cId = 0
                self.getClassbyYear()
                self.interestParam.stime = self.semesterScope.start.stringWithYMD()
                self.interestParam.endtime = self.semesterScope.end.stringWithYMD()
                
            }
            self.navigationController?.pushViewController(optionController, animated: true)
        }
        
        termConditionView.addCondition(yearCondition)
        termConditionView.addCondition(seasonCondition)
        termConditionView.frame.origin = CGPoint(x: 0, y: 0)
        //        scrollView.addSubview(termConditionView)
        parameterView.addSubview(termConditionView)
        
        //MARK: 设置初始年级为大班
        self.interestParam.grade = 1
        classConditionView = CYJConditionView(title: "筛选班级", key: "class")
        gradeCondition = CYJConditionButton(title: "大班", key: "class_grade") { (sender) in
            
            let currentIndex = self.gradeArray.index(where: {$0.opId == self.interestParam.grade})
            
            let optionController = CYJOptionsSelectedController(currentIndex: currentIndex!, options: self.gradeArray) { [unowned self, unowned sender](op) in
                print("\(op.title)")
                sender.setTitle(op.title, for: .normal)
                self.interestParam.grade = op.opId
                
                //TODO: 选择了年级之后，要清除 班级的选中
                //                self.classCondition.setTitle("班级", for: .normal)
                self.classCondition.title = "全部"
                
                self.interestParam.cId = 0
                
            }
            self.navigationController?.pushViewController(optionController, animated: true)
        }
        
        classCondition = CYJConditionButton(title: "全部", key: "class_class") { (sender) in
            print("班级")
            //班级需要从网络上进行获取
            
            if self.interestParam.grade == 0 {
                Third.toast.message("请先选择年级")
                return
            }
            
            var classInGrade = self.classesForYear.filter({ $0.grade == self.interestParam.grade})
            
            var options = [CYJOption]()
            options.append(CYJOption(title: "全部", opId: 0))
            
            for i in 0..<classInGrade.count {
                let ccc = classInGrade[i]
                let option = CYJOption(title: ccc.cName ?? "班级名称", opId: ccc.cId)
                options.append(option)
            }
            let currentIndex = options.index(where: {$0.opId == self.interestParam.cId})
            
            let optionController = CYJOptionsSelectedController(currentIndex: currentIndex!, options: options) { [unowned sender](op) in
                print("\(op.title)")
                sender.setTitle(op.title, for: .normal)
                self.interestParam.cId = op.opId
            }
            self.navigationController?.pushViewController(optionController, animated: true)
        }
        classConditionView.addCondition(gradeCondition)
        classConditionView.addCondition(classCondition)
        classConditionView.frame.origin = CGPoint(x: 0, y: termConditionView.frame.maxY)
        parameterView.addSubview(classConditionView)
        
        //        scrollView.addSubview(classConditionView)
        
        
        scopeConditionView = CYJTimeConditionView(title: "记录时间", start: {[unowned self]  (startBtn) in
            //
            let scope = Date().getSemesterDuration(year: self.interestParam.year, semester: self.interestParam.semester)
            
            let datePicker = KYDatePickerController(currentDate: Date(timeIntervalSinceNow: 0), minimumDate: scope.start, maximumDate: scope.end, completeHandler: { [unowned startBtn]  (selectedDate) in
                startBtn.setTitle(selectedDate.stringWithYMD(), for: .normal)
                
                self.interestParam.stime = selectedDate.stringWithYMD()
            })
            let halfContainer = KYHalfPresentationController(presentedViewController: datePicker, presenting: self)
            datePicker.transitioningDelegate = halfContainer;
            
            self.present(datePicker, animated: true, completion: nil)
            
            }, end: {[unowned self]  (endBtn) in
                
                let scope = Date().getSemesterDuration(year: self.interestParam.year, semester: self.interestParam.semester)
                
                let datePicker = KYDatePickerController(currentDate: Date(timeIntervalSinceNow: 0), minimumDate: scope.start, maximumDate: scope.end, completeHandler: { [unowned endBtn]  (selectedDate) in
                    endBtn.setTitle(selectedDate.stringWithYMD(), for: .normal)
                    
                    self.interestParam.endtime = selectedDate.stringWithYMD()
                    
                })
                let halfContainer = KYHalfPresentationController(presentedViewController: datePicker, presenting: self)
                datePicker.transitioningDelegate = halfContainer;
                
                self.present(datePicker, animated: true, completion: nil)
        })
        
        scopeConditionView.frame.origin = CGPoint(x: 0, y: classConditionView.frame.maxY)
        //        scrollView.addSubview(scopeConditionView)
        parameterView.addSubview(scopeConditionView)
        
        //MARK: 设置初始时间
        self.semesterScope = Date().getSemester()
        self.interestParam.stime = self.semesterScope.start.stringWithYMD()
        self.interestParam.endtime = self.semesterScope.end.stringWithYMD()
        
        actionsView = CYJActionsView(frame: CGRect(x: 0, y: scopeConditionView.frame.maxY, width: view.frame.width, height: 60))
        actionsView.innerPadding = 10
        actionsView.theme_backgroundColor = Theme.Color.ground
        let resetButton = CYJFilterButton(title: "重置") { [unowned self] (sender) in
            print("重置")
            let yearAndSemester = Date().getYearAndSemester()
            self.interestParam.year = yearAndSemester.year
            self.interestParam.semester = yearAndSemester.semester
            self.interestParam.grade = 1
            self.interestParam.cId = 0
            
            let season = self.semesterArray.filter { $0.opId == self.interestParam.semester}
            yearCondition.setTitle("\(yearAndSemester.year)", for: .normal)
            seasonCondition.setTitle( (season.first?.title)!, for: .normal)
            self.gradeCondition.setTitle("大班", for: .normal)
            //            self.classCondition.setTitle("全部", for: .normal)
            self.classCondition.title = "全部"
            self.semesterScope = Date().getSemester()
            self.getClassbyYear()
            self.clearChartView()
        }
        resetButton.filterButtonStyle = .nomal_light_Style
        
        let showButton = CYJFilterButton(title: "查看报告") {[unowned self] (sender) in
            print("查看报告")
            self.clearChartView()
            
            self.fetchInterestFromServer()
            //            self.addChartView()
        }
        showButton.filterButtonStyle = .nomal_color_Style
        
        actionsView.actions = [resetButton, showButton]
        //        scrollView.addSubview(actionsView)
        parameterView.addSubview(actionsView)
        
        parameterView.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: actionsView.frame.maxY + 10)
        tableView.tableHeaderView = parameterView
        //        scrollView.contentSize = CGSize(width: view.frame.width, height: actionsView.frame.maxY + 10)
        
        self.getClassbyYear()
        
        //        tableView.estimatedRowHeight = UITableViewAutomaticDimension
        //        tableView.rowHeight = 200
    }
    
    //MARK: 获取年级
    func getClassbyYear() {
        
        let parameter: [String: Any] = ["token": LocaleSetting.token, "year": self.interestParam.year, "semester": self.interestParam.semester]
        
        RequestManager.POST(urlString: APIManager.Baby.getClass, params: parameter ) { [unowned self] (data, error) in
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
    
    func fetchInterestFromServer() {
        
        guard self.interestParam.grade != 0 else {
            Third.toast.message("年级必选")
            return
        }
        let formater = DateFormatter()
        formater.dateFormat = "yyyy-MM-dd"
        formater.timeZone = TimeZone.current
        
        guard let sTime = self.interestParam.stime, let eTime = self.interestParam.endtime else {
            Third.toast.message("时间不能为空")
            return
        }
        
        guard let startTime = formater.date(from: sTime), let endTime = formater.date(from: eTime) else{
            Third.toast.message("时间格式不正确")
            return
        }
        guard startTime <= endTime else {
            Third.toast.message("开始时间不能早于结束时间")
            return
        }
        
        
        RequestManager.POST(urlString: APIManager.Tongji.attentionpj, params: self.interestParam.encodeToDictionary()) { [unowned self] (data, error) in
            //如果存在error
            guard error == nil else {
                Third.toast.message((error?.localizedDescription)!)
                return
            }
            if let bigData = data as? NSDictionary {
                //遍历，并赋值
                let target = JSONDeserializer<CYJPieData>.deserializeFrom(dict: bigData)
                self.pieData = target
                //                self.clearChartView()
                
                self.getPieChartDataByDomain()
                
                self.tableView.reloadData()
                //                self.addChartView()
            }
        }
    }
    
    func getPieChartDataByDomain() {
        //为饼状图提供数据
        
        let color0xs: [UInt32] = [0x306287, 0xfaae52, 0xeb5b53, 0xffd028, 0x5fab78, 0xFFFF00, 0x70DB93, 0x5C3317, 0x9F5F9F, 0xB5A642, 0xD9D919, 0xA67D3D, 0x9932CD, 0x855E42, 0x8F8FBD]
        
        let colors = color0xs.map({UIColor(hex6: $0)})
        
        var domainChartDatas: [PieChartData] = []
        if let domains = self.pieData?.domain {
            for i in 0..<domains.count {
                let domain = domains[i]
                
                if let dimensions = domain.dimension {
                    var entries = [PieChartDataEntry]()
                    for j in 0..<dimensions.count {
                        let dimension = dimensions[j]
                        if dimension.dNum! >  Float(0)  {
                            let numString = String(format: "%1.0f次", dimension.dNum ?? 0)
                            let label = (dimension.diName ?? "维度") + " " + numString
                            let entry = PieChartDataEntry(value: Double(dimension.dNum!), label: label)
                            entries.append(entry)
                        }
                    }
                    let chartDataSet = PieChartDataSet(values: entries, label: nil)
                    chartDataSet.colors = colors
                    let chartData = PieChartData(dataSet: chartDataSet)
                    chartData.setValueFormatter(DigitValueFormatter())
                    
                    domainChartTitles.append("针对领域\(domain.dName ?? "异常")的分析")
                    domainChartDatas.append(chartData)
                }
            }
        }
        self.domainChartDatas = domainChartDatas
        
        var dimensionChartDatas: [PieChartData] = []
        
        if let dimensions = self.pieData?.dimension {
            for i in 0..<dimensions.count {
                let dimension = dimensions[i]
                
                if let quotas = dimension.quota {
                    var entries = [PieChartDataEntry]()
                    for j in 0..<quotas.count {
                        let quota = quotas[j]
                        if quota.qNum! > Float(0) {
                            let numString = String(format: "%1.0f次",  quota.qNum ?? 0)
                            let label = (quota.qTitle ?? "领域") + " " + numString
                            
                            let entry = PieChartDataEntry(value: Double(quota.qNum!), label: label)
                            entries.append(entry)
                        }
                    }
                    let chartDataSet = PieChartDataSet(values: entries, label: nil)//)
                    chartDataSet.colors = colors
                    let chartData = PieChartData(dataSet: chartDataSet)
                    
                    //                    let formatter = NumberFormatter()
                    //                    formatter.usesGroupingSeparator = true
                    //                    formatter.numberStyle = .percent
                    //
                    chartData.setValueFormatter(DigitValueFormatter())
                    dimensionChartTitles.append("针对维度\(dimension.diName ?? "异常")的分析")
                    dimensionChartDatas.append(chartData)
                }
            }
        }
        self.dimensionChartDatas = dimensionChartDatas
        
        var totalChartDatass: [PieChartData] = []
        
        if let evaluates = self.pieData?.evaluate {
            for i in 0..<evaluates.count {
                let evaluate = evaluates[i]
                
                if let domains = evaluate.domain {
                    var entries = [PieChartDataEntry]()
                    for j in 0..<domains.count {
                        let domain = domains[j]
                        if domain.dNum! > Float(0) {
                            let numString = String(format: "%1.0f次",  domain.dNum ?? 0)
                            let label = (domain.dName ?? "领域") + " " + numString
                            
                            let entry = PieChartDataEntry(value: Double(domain.dNum!), label: label)
                            entries.append(entry)
                        }
                    }
                    let chartDataSet = PieChartDataSet(values: entries, label: nil)//)
                    chartDataSet.colors = colors
                    let chartData = PieChartData(dataSet: chartDataSet)
                    
                    //                    let formatter = NumberFormatter()
                    //                    formatter.usesGroupingSeparator = true
                    //                    formatter.numberStyle = .percent
                    //
                    chartData.setValueFormatter(DigitValueFormatter())
                    totalChartTitles.append("针对\(evaluate.eName ?? "异常")的总体分析")
                    totalChartDatass.append(chartData)
                }
            }
        }
        self.totalChartDatas = totalChartDatass
    }
    
    func clearChartView() {
        
        //清除数据
        self.pieData = nil
        self.domainChartDatas = []
        self.dimensionChartDatas = []
        
        self.tableView.reloadData()
        //        getPieChartDataByDomain()
        //        //清除表格
        //        if self.chartContainerView?.superview != nil {
        //            self.chartContainerView?.removeFromSuperview()
        //            self.chartContainerView = nil
        //        }
        //        //清除记录
        //        if self.countedView?.superview != nil {
        //            self.countedView?.removeFromSuperview()
        //            self.countedView = nil
        //        }
    }
    
    func addChartView() {
        
        countedView = CYJCountedView.countView(frame: CGRect(x: 0, y: actionsView.frame.maxY + 8, width: view.frame.width, height: 200))
        
        countedView?.pieData = self.pieData
        //        scrollView.addSubview(countedView!)
        
        //        scrollView.contentSize = CGSize(width: view.frame.width, height: countedView.frame.maxY)
        chartContainerView = UIView()
        chartContainerView?.theme_backgroundColor = Theme.Color.ground
        chartContainerView?.frame = CGRect(x: 0, y: (countedView?.frame.maxY)!, width: view.frame.width, height: view.frame.height - Theme.Measure.tabBarHeight - Theme.Measure.navigationBarHeight)
        //        scrollView.addSubview(chartContainerView!)
        
        // 这个是必要的设置
        automaticallyAdjustsScrollViewInsets = false
        
        
        //        let scrollPageView = ScrollPageView(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: Theme.Measure.screenHeight - 49 - 64), segmentStyle: style, titles: ["按领域", "按维度"], childVcs: setChildVcs(), parentViewController: self)
        //
        //        chartContainerView?.addSubview(scrollPageView)
        
        //        scrollView.contentSize = CGSize(width: view.frame.width, height: (chartContainerView?.frame.maxY)!)
    }
}

extension CYJAttentionAnalyseController {
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        
        if self.pieData != nil {
            return 2
        }
        return 0
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return 1
        case 1:
            if !noDomainOrDimension {
                switch chartListIndex {
                case 0: return self.totalChartDatas.count
                case 1: return self.domainChartDatas.count
                case 2: return self.dimensionChartDatas.count
                    
                default: return 0
                }
                
            }else {
                return 1
            }
        default:
            return 0
        }
        
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch indexPath.section {
        case 0:
            return 200
        case 1:
            if !noDomainOrDimension {
                
                var pieChartData: PieChartData
                switch chartListIndex {
                case 0: pieChartData =   self.totalChartDatas[indexPath.row]
                case 1: pieChartData =   self.domainChartDatas[indexPath.row]
                case 2: pieChartData =   self.dimensionChartDatas[indexPath.row]
                    
                default: pieChartData = PieChartData()
                }
                
                let height = CYJPieChartCell.legendSize(piedata: pieChartData)
                return 300 + height
            }else {
                return 0
            }
            
        default:
            return 0
        }
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 {
            return 40
        }
        return 44
    }
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if section == 0
        {
            let headerView = UIView()
            headerView.theme_backgroundColor = Theme.Color.viewLightColor
            let titleLabel = UILabel()
            titleLabel.text = "统计结果"
            titleLabel.theme_textColor = Theme.Color.textColorlight
            titleLabel.font = UIFont.systemFont(ofSize: 13)
            titleLabel.frame = CGRect(x:15 , y:0 , width:100,height:40)
            headerView.addSubview(titleLabel)
            return headerView
        }else if section == 1 {
            return self.scrollSegment
        }
        return nil
    }
    
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: countIdentifier) as? CYJAttentionCountedCell
            cell?.selectionStyle = .none
            cell?.pieData = self.pieData
            return cell!
        }else {
            let cell = tableView.dequeueReusableCell(withIdentifier: withIdentifier) as? CYJPieChartCell
            cell?.selectionStyle = .none
            
            cell?.noDomainOrDimension = self.noDomainOrDimension
            switch chartListIndex {
            case 0:
                if self.totalChartDatas.count > indexPath.row {
                    let pieData = self.totalChartDatas[indexPath.row]
                    cell?.pieChartData = pieData
                    cell?.title = self.totalChartTitles[indexPath.row]
                }
            case 1:
                if self.domainChartDatas.count > indexPath.row {
                    let pieData = self.domainChartDatas[indexPath.row]
                    cell?.pieChartData = pieData
                    cell?.title = self.domainChartTitles[indexPath.row]
                }
            case 2:
                if self.dimensionChartDatas.count > indexPath.row {
                    let pieData = self.dimensionChartDatas[indexPath.row]
                    cell?.pieChartData = pieData
                    cell?.title = self.dimensionChartTitles[indexPath.row]
                }
            default: break
            }
            
            return cell!
        }
    }
}

class CYJAttentionCountedCell: UITableViewCell {
    
    var countedView: CYJCountedView!
    
    var pieData: CYJPieData? {
        didSet{
            countedView.pieData = self.pieData
        }
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        countedView = CYJCountedView.countView(frame: CGRect(x: 0, y: 0, width: Theme.Measure.screenWidth, height: 190))
        countedView.theme_backgroundColor = Theme.Color.TabMain
        contentView.addSubview(countedView)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

