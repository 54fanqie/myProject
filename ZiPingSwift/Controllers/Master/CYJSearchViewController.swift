//
//  CYJSearchViewController.swift
//  ZiPingSwift
//
//  Created by kyang on 2017/9/22.
//  Copyright © 2017年 Chinayoujiao. All rights reserved.
//

import Foundation
import HandyJSON
import SnapKit

class CYJSearchViewController: KYBaseCollectionViewController {
    
    var fakeBar: UIView!
    
    var searchBar: UISearchBar!
    
    var listparam: RECListSearchParam!
    
    var actionsView: CYJActionsView!
    
    var classesForYear: [CYJClass] = []
    
    var classInGrade: [CYJClass]?
    
    var finishSelected: ((_ param:RECListSearchParam, _ classInGrade: [CYJClass]?)->Void)!
    
    /// 当前的年和学期
    var today = Date().getYearAndSemester()
    
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
    var checkStatusOptions: [CYJOption] = [CYJOption(title: "未批阅", opId: 1),CYJOption(title: "已批阅", opId: 2)]
    
    var goodOptions: [CYJOption] = [CYJOption(title: "是", opId: 1),CYJOption(title: "否", opId: 2)]

    
    var gradeIndex: Int? {
        guard let grade = self.listparam.grade?.first  else {
            return nil
        }
        let index = self.gradeArray.index { $0.opId == grade}
        
        return index
    }
    var classArray: [CYJOption] {
        
        let classes = classesForYear.filter({ $0.grade == self.listparam.grade?.first})
        self.classInGrade = classes
        let options = classes.map({ (clas) -> CYJOption in
            return CYJOption(title: clas.cName ?? "班级名称", opId: clas.cId)
        })
        return options
    }
    
    
    var classIndex: Int? {
        guard let cid = self.listparam.cId?.first  else {
            return nil
        }
        let index = self.gradeArray.index { $0.opId == cid}
        
        return index
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.automaticallyAdjustsScrollViewInsets = false

        fakeBar = UIView(frame: CGRect(x: 0, y: 0, width: Theme.Measure.screenWidth, height: 35))
        fakeBar.backgroundColor = UIColor.clear
        
        view.addSubview(fakeBar)
        
        searchBar = UISearchBar(frame: CGRect(x: 0, y: 0, width: Theme.Measure.screenWidth - 70, height: 35))
        searchBar.delegate = self
        searchBar.searchBarStyle = .prominent
        searchBar.theme_barTintColor = Theme.Color.main
        searchBar.placeholder = "输入学生，筛选"
//        fakeBar.addSubview(searchBar)
        
        let cancelButton = UIButton(frame: CGRect(x: Theme.Measure.screenWidth - 70, y: 0, width: 60, height: 35))
        cancelButton.setTitle("取消", for: .normal)
        cancelButton.theme_setTitleColor(Theme.Color.ground, forState: .normal)
        cancelButton.addTarget(self, action: #selector(searchBarCanceled), for: .touchUpInside)
        fakeBar.addSubview(cancelButton)
        
        navigationItem.titleView = fakeBar
        
        makeFilterView()
        
        makeActionView()
        
        getClassbyYear()
    }
    
    var filterParams: [CYJFilterModel] = []
    
     func makeFilterView() {

        //MARK: 初始化
        if self.listparam.year == nil {
            self.listparam.year = today.year
            self.listparam.semester = today.semester
        }

        let timeScope = Date().getSemesterDuration(year: self.listparam.year!, semester: self.listparam.semester!)
        
        if self.listparam.startTime == nil || self.listparam.endTime == nil{
            self.listparam.startTime = timeScope.start.stringWithYMD()
            self.listparam.endTime = timeScope.end.stringWithYMD()
        }
        
        let yearOption = self.yearArray.first { $0.opId == self.listparam.year}
        let semesterOption = self.semesterArray.first { $0.opId == self.listparam.semester}
        

        
        //MARK: 创建ViewModel
        filterParams.removeAll()
        
        filterParams.append(CYJFilterModel(filter: ("记录学期", "year-term"), mode: .dropDown, currentIndex: nil, options: [yearOption!, semesterOption!]))
        
        //年级已经选择
        let gradeIndex = self.gradeArray.index(where: {$0.opId == self.listparam.grade?.first})
        filterParams.append(CYJFilterModel(filter: ("按年级", "grade"), mode: .normal, currentIndex: gradeIndex, options: self.gradeArray))

        if gradeIndex != nil {
            //班级已经选择
            if classInGrade != nil {
                let options = self.classInGrade!.map({ (clas) -> CYJOption in
                    return CYJOption(title: clas.cName ?? "班级名称", opId: clas.cId)
                })
                let classIndex = options.index(where: {$0.opId == self.listparam.cId?.first})
                filterParams.append(CYJFilterModel(filter: ("按班级", "class"), mode: .normal, currentIndex: classIndex ,options: options))
            }
        }
        
        if let startTime = self.listparam.startTime, let endTime = self.listparam.endTime {
            if let startDate = Date.date(from: startTime), let endDate = Date.date(from: endTime) {
                filterParams.append(CYJFilterModel(filter: ("记录时间", "time"), minTime: startDate, maxTime: endDate))
            }
        }else { // 没有额外设置时间的话～
            
            filterParams.append(CYJFilterModel(filter: ("记录时间", "time"), minTime: timeScope.start, maxTime: timeScope.end))
        }
        
        //添加记录时间
        
        //批阅状态
        let checkIndex = self.checkStatusOptions.index { $0.opId == self.listparam.isMark }
        
        filterParams.append(CYJFilterModel(filter: ("批阅状态", "checkStatus"), mode: .normal, currentIndex: checkIndex, options: checkStatusOptions))
        
        //标记了已批阅
        if self.listparam.isMark == 2 {
            let goodIndex = self.goodOptions.index(where: { $0.opId == self.listparam.isGood })
            filterParams.append(CYJFilterModel(filter: ("是否优秀", "excellent"), mode: .normal, currentIndex: goodIndex, options: self.goodOptions))
        }
        
        
        collectionView.frame = CGRect(x: 0, y: 64, width: Theme.Measure.screenWidth, height: Theme.Measure.screenHeight - 64 - 60)
        collectionView.alwaysBounceVertical = true
        
        collectionView.register(CYJFilterTimeCell.self, forCellWithReuseIdentifier: "CYJFilterTimeCell.self")
        collectionView.register(CYJFilterCell.self, forCellWithReuseIdentifier: "CYJFilterCell.self")
        collectionView.register(CYJFilterTitleView.self, forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: "CYJFilterTitleView.self")
        collectionView.register(UICollectionReusableView.self, forSupplementaryViewOfKind: UICollectionElementKindSectionFooter, withReuseIdentifier: "UICollectionReusableView.self")
        
        collectionView.reloadData()
    }
    

    func makeActionView() {
        
        actionsView = CYJActionsView(frame: CGRect(x: 0, y: self.collectionView.frame.maxY, width: self.collectionView.frame.width, height: 60))
        actionsView.theme_backgroundColor = Theme.Color.ground
        
        let resetButton = CYJFilterButton(title: "重置") { [unowned self] (sender) in
            print("重置")
            //TODO: 重置筛选的状态
            self.listparam.year = self.today.year
            self.listparam.semester = self.today.semester
            self.listparam.grade = nil
            self.listparam.cId = nil
            self.listparam.isMark = nil
            self.listparam.isGood = nil
            self.classInGrade = []

            //根据年和学期，重置当前的时间
            let timeScope = Date().getSemesterDuration(year: self.listparam.year!, semester: self.listparam.semester!)
            self.listparam.startTime = timeScope.start.stringWithYMD()
            self.listparam.endTime = timeScope.end.stringWithYMD()
            
            let yearOption = self.yearArray.first { $0.opId == self.listparam.year}
            let semesterOption = self.semesterArray.first { $0.opId == self.listparam.semester}

            self.filterParams = [
                CYJFilterModel(filter: ("记录学期", "year-term"), mode: .dropDown,currentIndex: nil, options: [yearOption!, semesterOption!]),
                CYJFilterModel(filter: ("按年级", "grade"), mode: .normal, currentIndex: nil, options: self.gradeArray),
                CYJFilterModel(filter: ("记录时间", "time"), minTime: timeScope.start, maxTime: timeScope.end),
                CYJFilterModel(filter: ("批阅状态", "checkStatus"), mode: .normal, currentIndex: nil, options: self.checkStatusOptions)
            ]
            self.collectionView.reloadData()
        }
        resetButton.filterButtonStyle = .circle_light_Style
        
        let showButton = CYJFilterButton(title: "确定") {[unowned self] (sender) in
            print("完成选择")
            //MARK: 请求bar数据
            self.finishSelected(self.listparam, self.classInGrade)
            self.dismiss(animated: true, completion: nil)
        }
        showButton.filterButtonStyle = .circle_color_Style
        
        actionsView.actions = [resetButton, showButton]
        self.view.addSubview(actionsView)
    }
    
    //请求班级信息
    func getClassbyYear() {
        
        let parameter: [String: Any] =  ["token": LocaleSetting.token, "year": self.listparam.year ?? 2017, "semester": "\(self.listparam.semester ?? 2)"]
        
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
    
    
    func searchBarCanceled() {
        self.dismiss(animated: true, completion: nil)
    }
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        searchBar.endEditing(true)
    }
    
    /// 根据不同选项，重置下面的相关的项
    ///
    /// - Parameter levels: ["excellent"]]
    func resetParamFrom(level: String) {
        
        if level == "year" || level == "term" {
            
            if let gradeOne = filterParams.index(where: { $0.filterId == "grade"}){
                filterParams[gradeOne] = CYJFilterModel(filter: ("按年级", "grade"), mode: .normal, currentIndex: nil ,options: self.gradeArray)
                self.listparam.grade = nil
                self.classInGrade = []

            }
            if let classOne = filterParams.index(where: { $0.filterId == "class"}) {
                filterParams.remove(at: classOne)
                self.listparam.cId = nil
                
            }
            if let timeOne = filterParams.index(where: { $0.filterId == "time"}){
                
                let timeScope = Date().getSemesterDuration(year: self.listparam.year!, semester: self.listparam.semester!)

                filterParams[timeOne] = CYJFilterModel(filter: ("记录时间", "time"), minTime: timeScope.start, maxTime: timeScope.end)
                //修改时间
                self.listparam.startTime = timeScope.start.stringWithYMD()
                self.listparam.endTime = timeScope.end.stringWithYMD()
            }
        }
        else if level == "grade"{
            if let gradeOne = filterParams.index(where: { $0.filterId == "grade"}){
                if filterParams[gradeOne].currentIndex == nil { //反旋了
                    if let classOne = filterParams.index(where: { $0.filterId == "class"}) {
                        //FIXME: 根据年级设置班级数据
                        filterParams.remove(at: classOne)
                    }
                }else{
                    if self.classArray.count > 0 {
                        
                        if let classOne = filterParams.index(where: { $0.filterId == "class"}) {
                            //FIXME: 根据年级设置班级数据
                            filterParams[classOne] = CYJFilterModel(filter: ("按班级", "class"), mode: .normal, currentIndex: nil ,options: self.classArray)
                            
                        }else
                        {
                            filterParams.insert(CYJFilterModel(filter: ("按班级", "class"), mode: .normal, currentIndex: nil, options: self.classArray), at: gradeOne + 1)
                        }
                        
                    }else
                    {
                        if let classOne = filterParams.index(where: { $0.filterId == "class"}) {
                            filterParams.remove(at: classOne)
                        }
                    }
                }
                self.listparam.cId = nil
            }
        }else if level == "checkStatus"{
            if let checkOne = filterParams.index(where: { $0.filterId == "checkStatus"}){
                let check = filterParams[checkOne]
                //0的时候是已批阅
                if check.currentIndex == 1 {
                    if filterParams.last?.filterId != "excellent" {
                        filterParams.append(CYJFilterModel(filter: ("是否优秀", "excellent"), mode: .normal, currentIndex: nil, options: self.goodOptions))
                    }
                    
                }else
                {
                    if let excellentOne = filterParams.index(where: { $0.filterId == "excellent"}) {
                        filterParams.remove(at: excellentOne)
                    }
                    self.listparam.isGood = nil
                }
            }
        }
    }
    
    
}

extension CYJSearchViewController: UISearchBarDelegate
{
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        self.dismiss(animated: true, completion: nil)

    }
}


extension CYJSearchViewController {
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return filterParams.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let param = filterParams[section]
        
        if param.filterId == "time" {
            return 1
        }else
        {
            return param.options.count
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let param = filterParams[indexPath.section]
        
        if param.filterId == "time" {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CYJFilterTimeCell.self", for: indexPath) as! CYJFilterTimeCell
            
            cell.cellData = param
            //MARK: 初始需要设置初始气质时间
            cell.lowerFilterTimeHandler = { [unowned self](_) in
                
                let timeScope = Date().getSemesterDuration(year: self.listparam.year!, semester: self.listparam.semester!)

                let datePicker = KYDatePickerController(currentDate: Date(timeIntervalSinceNow: 0), minimumDate: timeScope.start, maximumDate: timeScope.end, completeHandler: { [unowned cell]  (selectedDate) in
                    
                    cell.lowerDate = selectedDate
                    
                    self.listparam.startTime = selectedDate.stringWithYMD()
                    
                })
                let halfContainer = KYHalfPresentationController(presentedViewController: datePicker, presenting: self)
                datePicker.transitioningDelegate = halfContainer;

                self.present(datePicker, animated: true, completion: nil)
            }
            
            cell.higherFilterTimeHandler = {
                print($0.0)
                print($0.1)
                let timeScope = Date().getSemesterDuration(year: self.listparam.year!, semester: self.listparam.semester!)

                let datePicker = KYDatePickerController(currentDate: Date(timeIntervalSinceNow: 0), minimumDate: timeScope.start, maximumDate: timeScope.end, completeHandler: { [unowned cell] (selectedDate) in
                    
                    cell.upperDate = selectedDate
                    self.listparam.endTime = selectedDate.stringWithYMD()

                })
                let halfContainer = KYHalfPresentationController(presentedViewController: datePicker, presenting: self)
                datePicker.transitioningDelegate = halfContainer;
                
                self.present(datePicker, animated: true, completion: nil)
            }
            
            
            return cell
        }else
        {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CYJFilterCell.self", for: indexPath) as! CYJFilterCell
            cell.cellData = param.options[indexPath.row]
            cell.mode = param.mode
            
            if param.filterId != "time"{
                cell.isFilterd = param.currentIndex == indexPath.row
            }
            
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 10
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 10
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        let param = filterParams[section]
        
        if param.filterId == "time" {
            return CGSize.zero
        }else
        {
            return CGSize(width: Theme.Measure.screenWidth, height: 40)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let param = filterParams[indexPath.section]
        if param.filterId == "time" {
            return CGSize(width: Theme.Measure.screenWidth - 30, height: 62)
        }else if param.filterId == "class" {
            //根据班级名称的大小，改变item的size
            let className = param.options[indexPath.row].title
            let nsStr = NSString(string: className)
            let width = nsStr.boundingRect(with: CGSize(width: CGFloat(MAXFLOAT), height: 21), options: .usesLineFragmentOrigin, attributes: [NSForegroundColorAttributeName: UIColor.black, NSFontAttributeName: UIFont.systemFont(ofSize: 15)], context: nil).width
            
            if width < 80 {
                return CGSize(width: 80, height: 32)
            }else {
                return CGSize(width: width + 30, height: 32)
            }
            
        }else
        {
            return CGSize(width: 80, height: 32)
        }
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
        return CGSize(width: Theme.Measure.screenWidth, height: 0.5)
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        
        if kind == UICollectionElementKindSectionHeader {
            let header = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionElementKindSectionHeader, withReuseIdentifier: "CYJFilterTitleView.self", for: indexPath) as! CYJFilterTitleView
            
            let param = filterParams[indexPath.section]
            header.titleLabel.text = param.title
            return header
            
        }else
        {
            let footer = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionElementKindSectionFooter, withReuseIdentifier: "UICollectionReusableView.self", for: indexPath)
            for view in footer.subviews {
                view.removeFromSuperview()
            }
            
            let line = UIView(frame: CGRect(x: 0, y: 0, width: Theme.Measure.screenWidth, height: 0.5))
            line.theme_backgroundColor = Theme.Color.line
            footer.addSubview(line)
            
            return footer
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        
        return UIEdgeInsetsMake(10, 15, 15, 15)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print("selected")

        let param = filterParams[indexPath.section]
        
        guard param.filterId != "time" else{
            return
        }
        if param.filterId == "year-term" {
            let option1 = param.options[indexPath.row]
            if option1.opId > 1000  { //选年
                //MARK: 年 -- 选择了之后--请求班级数据

                let index = self.yearArray.index(where: { $0.opId == self.listparam.year})

                let optionController = CYJOptionsSelectedController(currentIndex: index!, options: self.yearArray) { [unowned self] (op) in
                    print("\(op.title)")

                    let yearOp = self.yearArray.first(where: { $0.opId == op.opId })
                    
                    param.options[0] = yearOp!
                    self.listparam.year = op.opId
                    self.resetParamFrom(level: "year")
                    
                    self.getClassbyYear()
                    self.collectionView.reloadData()
                }
                
                navigationController?.pushViewController(optionController, animated: true)
            }else {
                
                let index = self.semesterArray.index(where: { $0.opId == self.listparam.semester})
                
                let optionController = CYJOptionsSelectedController(currentIndex: index!, options: self.semesterArray) { (op) in
                    print("\(op.title)")
                    //MARK: 季节 -- 选择了 之后--请求班级数据

                    let semesterOption = self.semesterArray.first { $0.opId == op.opId}

                    param.options[1] = semesterOption!
                    self.listparam.semester = op.opId
                    
                    self.getClassbyYear()
                    self.resetParamFrom(level: "term")
                    
                    self.collectionView.reloadData()
                }
                
                navigationController?.pushViewController(optionController, animated: true)
            }
            
        }else if param.filterId == "grade" {
            //MARK: 选择的是年级
            if param.currentIndex == indexPath.row{
                param.currentIndex = nil
                self.listparam.grade = nil
                self.classInGrade = []

            }else {
                param.currentIndex = indexPath.row
                self.listparam.grade = [param.options[indexPath.row].opId]
                self.classInGrade = []
            }
            self.resetParamFrom(level: "grade")
            
            collectionView.reloadData()
        }else if param.filterId == "class" {
            //MARK: 选择的是班级

            if param.currentIndex == indexPath.row{
                param.currentIndex = nil
                self.listparam.cId = nil

            }else {
                param.currentIndex = indexPath.row
                self.listparam.cId = [param.options[indexPath.row].opId]
            }

            self.collectionView.reloadData()
            
            
        }else if param.filterId == "checkStatus" {
             //MARK: 选择 批阅状态
            if param.currentIndex == indexPath.row{
                param.currentIndex = nil
                self.listparam.isMark = nil

            }else {
                param.currentIndex = indexPath.row
                self.listparam.isMark = param.options[indexPath.row].opId
            }

            self.resetParamFrom(level: "checkStatus")
            
            collectionView.reloadData()
            
        }else if param.filterId == "excellent" {
            if param.currentIndex == indexPath.row{
                param.currentIndex = nil
                self.listparam.isGood = nil

            }else {
                param.currentIndex = indexPath.row
                self.listparam.isGood = param.options[indexPath.row].opId
            }

            self.collectionView.reloadData()
        }
    }
}


enum CYJFilterMode {
    case normal
    case dropDown //右侧箭头
    case time
}

class CYJFilterModel: NSObject {
    
    var title: String!
    var filterId: String!
    var mode: CYJFilterMode = .normal
    
    var minDate: Date?
    var maxDate: Date?
    
    var currentIndex: Int?
    var options: [CYJOption] = []
    
    init(filter: (name: String, id: String), minTime: Date, maxTime: Date) {
        
        title = filter.name
        filterId = filter.id
        self.mode = .time
        self.minDate = minTime
        self.maxDate = maxTime
        
    }
    init(filter: (name: String, id: String), mode: CYJFilterMode, currentIndex: Int?, options:  [CYJOption]) {
        title = filter.name
        filterId = filter.id
        self.mode = mode
        self.options = options
        self.currentIndex = currentIndex
    }
}

class CYJFilterTitleView: UICollectionReusableView {
    
    lazy var titleLabel: UILabel = {
        
        let label = UILabel(frame: CGRect.zero)
        label.numberOfLines = 1
        label.theme_textColor = Theme.Color.textColorlight
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(titleLabel)
        titleLabel.font = UIFont.systemFont(ofSize: 15)
        titleLabel.frame = CGRect(x: 15, y: 15, width: 65, height: 21)
        
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
//MARK: CYJFilterTimeCell
class CYJFilterTimeCell: UICollectionViewCell {
    
    
    typealias FilterTimeHandler = (_ minium: Date, _ maxium: Date) -> Void
    
    var lowerFilterTimeHandler: FilterTimeHandler?
    
    var higherFilterTimeHandler: FilterTimeHandler?
    
    var miniumDate: Date = Date(timeIntervalSince1970: 0)
    var maxiumDate: Date = Date(timeIntervalSinceNow: 0)
    
    var lowerDate: Date?{
        didSet{
            minTimeButton.setTitle(lowerDate?.stringWithYMD(), for: .normal)
        }
    }
    var upperDate: Date? {
        didSet{
            maxTimeButton.setTitle(upperDate?.stringWithYMD(), for: .normal)
        }
    }
    
    lazy var titleLabel: UILabel = {
        
        let label = UILabel(frame: CGRect.zero)
        label.frame = CGRect(x: 0, y: 20, width: 74, height: 20)
        label.numberOfLines = 1
        label.theme_textColor = Theme.Color.textColor
        label.font = UIFont.systemFont(ofSize: 14)
        label.text = "记录时间："
        return label
    }()
    
    lazy var minTimeButton: CYJFilterButton = {
        let minTimeButton = CYJFilterButton(title: "起始日期", complete: { (sender) in
            self.lowAction()
        })
        minTimeButton.filterButtonStyle = .nomal_whithColor_Style
        minTimeButton.frame =  CGRect(x: self.titleLabel.frame.maxX , y: 14, width: 100, height: 32)
        return minTimeButton
    }()
    
    lazy var daoLabel: UILabel = {
        let dao = UILabel(frame: CGRect(x: self.minTimeButton.frame.maxX + 8, y: 20, width: 30, height: 20))
        dao.textColor = self.titleLabel.textColor
        dao.textAlignment = .center
        dao.text = "TO"
        dao.font = UIFont.systemFont(ofSize: 15)
        return dao
    }()
    
    lazy var maxTimeButton: CYJFilterButton = {
        let maxTimeButton = CYJFilterButton(title: "结束日期", complete: { (sender) in
            self.highAction()
        })
        maxTimeButton.filterButtonStyle = .nomal_whithColor_Style
        maxTimeButton.frame = CGRect(x: self.daoLabel.frame.maxX + 8, y: 14, width: 100, height: 32)

        return maxTimeButton
    }()
    
    var cellData: CYJFilterModel? {
        didSet{
            if let minData = cellData?.minDate, let maxData = cellData?.maxDate {
                self.minTimeButton.setTitle(minData.stringWithYMD(), for: .normal)
                self.maxTimeButton.setTitle(maxData.stringWithYMD(), for: .normal)

                self.miniumDate = minData
                self.maxiumDate = maxData
            }
            
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        makeContentView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func makeContentView() {

        addSubview(titleLabel)
        addSubview(minTimeButton)
        addSubview(daoLabel)
        addSubview(maxTimeButton)
    }
    
    func lowAction() {
        
        if upperDate == nil {
            upperDate = maxiumDate
        }
        
        self.lowerFilterTimeHandler!(miniumDate,upperDate!)
    }
    func highAction() {
        if lowerDate == nil {
            lowerDate = miniumDate
        }
        self.higherFilterTimeHandler!(lowerDate!,maxiumDate)
    }
}

class CYJFilterCell: UICollectionViewCell {
    
    static let kFilterMinTimeTag = 989
    static let kFilterMaxTimeTag = 990
    
    lazy var titleLabel: UILabel = {
        
        let label = UILabel(frame: CGRect.zero)
        label.numberOfLines = 1
        label.theme_textColor = Theme.Color.textColorlight
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 14)
//        label.theme_backgroundColor = Theme.Color.textColorDark
        return label
    }()
    
    lazy var imageView: UIImageView = {
        let imageV = UIImageView(image: #imageLiteral(resourceName: "icon_gray_arrow_down_small"))
        return imageV
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        layer.theme_borderColor = "Global.borderColor"
        titleLabel.theme_textColor = Theme.Color.textColorlight
        layer.borderWidth = 1
        layer.cornerRadius = 5;
        layer.masksToBounds = true
        layer.theme_backgroundColor = "Global.backgroundColor"
        
        contentView.addSubview(titleLabel)
        
        titleLabel.snp.makeConstraints { (maker) in
            maker.centerY.equalTo(contentView.snp.centerY)
            maker.centerX.equalTo(contentView.snp.centerX)
        }
        
        contentView.addSubview(imageView)

        imageView.snp.makeConstraints { (maker) in
            maker.right.equalTo(contentView.snp.right).offset(-10)
            maker.centerY.equalTo(contentView.snp.centerY)
            maker.width.equalTo(10)
            maker.height.equalTo(5.5)
        }
    }
    
    /// 筛选的状态
    var isFilterd: Bool = false{
        didSet{
            if isFilterd {
                layer.borderWidth = 1
                layer.masksToBounds = true
                layer.theme_borderColor  = "Nav.barTintColor"
                titleLabel.theme_textColor = "Nav.barTintColor"
                
            }else
            {
                layer.theme_borderColor = "Global.borderColor"
                titleLabel.theme_textColor = Theme.Color.textColorlight
                layer.borderWidth = 1
                layer.masksToBounds = true
                layer.theme_backgroundColor = "Global.backgroundColor"
            }
        }
    }
    var cellData: CYJOption? {
        didSet{
            self.titleLabel.text = cellData?.title
            
            self.titleLabel.sizeToFit()
            self.titleLabel.center = contentView.center
        }
    }
    var mode: CYJFilterMode = .normal {
        didSet{
            if mode == .dropDown {
                imageView.isHidden = false
                
            }else
            {
                imageView.isHidden = true
                
            }
            titleLabel.snp.remakeConstraints { (maker) in
                maker.centerY.equalTo(contentView.snp.centerY)
                maker.centerX.equalTo(contentView.snp.centerX)
            }
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

