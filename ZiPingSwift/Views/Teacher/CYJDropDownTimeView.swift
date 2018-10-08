//
//  CYJDropDownTimeView.swift
//  ZiPingSwift
//
//  Created by kyang on 2017/9/26.
//  Copyright © 2017年 Chinayoujiao. All rights reserved.
//

import Foundation


class CYJDropDownTimeView: UIView {
    
    let timeArr = ["全部", "本周", "上周", "上上周", "本月" ]
    var timeOptions: [CYJOption]!
    let kleftPadding: CGFloat = 15
    let kinSidePadding: CGFloat = 10
    
    let semesterScope = Date().getSemester()
    var currentScope: (String?, String?)? {
        didSet{
            guard let scope = currentScope else {
                return
            }
            guard let start = scope.0, let end = scope.1 else {
                return
            }
            
            if start == semesterScope.start.stringWithYMD(), end == semesterScope.end.stringWithYMD() {
                // 如果就是👨‍🍳时间，那么忽略他，
            }else {
                let formater = DateFormatter()
                formater.dateFormat = "yyyy-MM-dd"
                formater.timeZone = TimeZone.current
                
                self.startTime = formater.date(from:  start)!
                self.endTime = formater.date(from:  end)!

                self.startButton.setTitle(start, for: .normal)
                self.endButton.setTitle(end, for: .normal)
            }
        }
    }
    
    lazy var titleLabel: UILabel = {
        let label = UILabel(frame: CGRect.zero)
        label.numberOfLines = 1
        label.theme_textColor = Theme.Color.textColor
        label.font = UIFont.systemFont(ofSize: 15)
        label.text = "记录时间:"
        return label
    }()
    
    var miniumDate: Date = Date(timeIntervalSince1970: 0)
    var maxiumDate: Date = Date(timeIntervalSinceNow: 0)
    
    lazy var startButton: UIButton = {
        let button = CYJFilterButton(title: "截止日期", complete: {[unowned self] (sender) in
//            self.startHandler(sender)
        })
        button.filterButtonStyle = .nomal_whithColor_Style
        
        button.theme_setTitleColor(Theme.Color.textColor, forState: .normal)
        button.setTitle("起始日期", for: .normal)
        button.theme_backgroundColor = Theme.Color.ground
        
        button.addTarget(self, action: #selector(startButtonAction(_:)), for: .touchUpInside)
        //FIXME: 给按钮设置两个图片
        return button
    }()
    
    private lazy var toLabel: UILabel = {
        let label = UILabel(frame: CGRect.zero)
        label.numberOfLines = 1
        label.theme_textColor = Theme.Color.textColorDark
        label.font = UIFont.systemFont(ofSize: 15)
        label.textAlignment = .center
        
        label.text = "TO"
        
        return label
    }()
    
    lazy var endButton: UIButton = {
        let button = CYJFilterButton(title: "截止日期", complete: {[unowned self] (sender) in
//            self.endHandler(sender)
        })
        button.filterButtonStyle = .nomal_whithColor_Style
        button.theme_setTitleColor(Theme.Color.textColor, forState: .normal)
        button.setTitle("截止日期", for: .normal)
        button.theme_backgroundColor = Theme.Color.ground
        button.addTarget(self, action: #selector(endButtonAction(_:)), for: .touchUpInside)

        //FIXME: 给按钮设置两个图片
        return button
    }()
    
    lazy var buttonActionView: CYJActionsView = {
        let action = CYJActionsView(frame: CGRect(x: 0, y: 130, width: self.frame.width, height: 62))
        return action
    }()
    
//    var startHandler: ((_ sender: UIButton) -> Void)!
//    var endHandler: ((_ sender: UIButton) -> Void)!
    var timeSelectedHandler: ((_ sender: UIButton) -> Void)!
    var sureButtonHandler: ((_ min: Date, _ max: Date, _ index: Int) -> Void)!

    var selectedTimeIndex: Int = 0
    
    var startTime: Date?
    var endTime: Date?

    var timeOptionButtons: [CYJFilterStyleButton] = []
    
    init(frame: CGRect, currentIndex: Int = 0) {
        selectedTimeIndex = currentIndex
        super.init(frame: frame)

        theme_backgroundColor = Theme.Color.ground
        var options = [CYJOption]()
        let width = (Theme.Measure.screenWidth -  kinSidePadding * CGFloat(self.timeArr.count - 1) - 2 * kleftPadding)/CGFloat(self.timeArr.count)

        let timeSize = CGSize(width: width, height: 32)
        
        for i in 0..<timeArr.count {
            
            let option = CYJOption(title: timeArr[i], opId: i)
            options.append(option)
                        
            let btn = CYJFilterStyleButton(title: timeArr[i],complete: { [unowned self] (sender) in
                self.timeButtonAction(i)
                
            })

            btn.frame = CGRect(origin: CGPoint(x: kleftPadding + (timeSize.width + kinSidePadding) * CGFloat(i), y: 15), size: timeSize)
            
            addSubview(btn)
            timeOptionButtons.append(btn)
            
            //MARK: 设置 -- 初始值
            if selectedTimeIndex == i {
                btn.isSelected = true
                
                let duration = timeArr[i]
                var dalily: (Date, Date)
                switch duration {
                case "本周":
                    dalily = Date().thisWeek()
                case "上周":
                    dalily = Date().lastWeek()
                case "上上周":
                    dalily = Date().lastLastWeek()
                case "本月":
                    dalily = Date().thisMonth()
                default:
                    dalily = Date().getSemester()
                    break
                }
                
                self.startTime = dalily.0
                self.endTime = dalily.1
                
                self.startButton.setTitle(self.startTime!.stringWithYMD(), for: .normal)
                self.endButton.setTitle(self.endTime!.stringWithYMD(), for: .normal)

            }
        }
        
        titleLabel.frame = CGRect(x: 15, y: 76, width: 70, height: 15)
        startButton.frame = CGRect(x: titleLabel.frame.maxX + 10, y: 67, width: 100, height: 32)
        toLabel.frame = CGRect(x: startButton.frame.maxX + 10, y: 67, width: 30, height: 32)
        endButton.frame = CGRect(x: toLabel.frame.maxX + 10, y: 67, width: 100, height: 32)

        addSubview(titleLabel)
        addSubview(toLabel)
        addSubview(startButton)
        addSubview(endButton)
        
        let line = UIView(frame: CGRect(x: 0, y: endButton.frame.maxY + 15, width: frame.width, height: 0.5))
        line.theme_backgroundColor = Theme.Color.line

        addSubview(line)
        
        let resetButton = CYJFilterButton(title: "重置") {[unowned self] (sender) in
            
            if self.selectedTimeIndex < self.timeOptionButtons.count {
                
                let selectedBtn = self.timeOptionButtons[self.selectedTimeIndex]
                selectedBtn.isSelected = false
            }
        }
        resetButton.filterButtonStyle = .circle_light_Style
        let sureButton = CYJFilterButton(title: "确定") { [unowned self] (sender) in
            
            let minDate = self.startTime
            let maxDate = self.endTime
            
            guard minDate! <= maxDate! else {
                Third.toast.message("开始时间不能早于结束时间")
                return
            }

            self.sureButtonHandler(minDate!, maxDate!, self.selectedTimeIndex)
        }
        sureButton.filterButtonStyle = .circle_color_Style
        
        buttonActionView.actions = [resetButton, sureButton]
        buttonActionView.theme_backgroundColor = Theme.Color.ground
        addSubview(buttonActionView)
        
        //设置初始选中
        
        
    }
    
    func timeButtonAction(_ index: Int){
        
//        guard index != selectedTimeIndex else {
//            return
//        }
        let selectedButton = timeOptionButtons[selectedTimeIndex]
        let newButton = timeOptionButtons[index]
        
        selectedButton.isSelected = false
        newButton.isSelected = true
        
        selectedTimeIndex = index
        
        let duration = newButton.title(for: .normal)
        
        var dalily: (Date, Date)
        
        switch duration! {
        case "本周":
            dalily = Date().thisWeek()
        case "上周":
            dalily = Date().lastWeek()
        case "上上周":
            dalily = Date().lastLastWeek()
        case "本月":
            dalily = Date().thisMonth()
        default:
            dalily = Date().getSemester()

            break
        }
        
        self.startTime = dalily.0
        self.endTime = dalily.1
        
        self.startButton.setTitle("\(dalily.0.stringWithYMD())", for: .normal)
        self.endButton.setTitle("\(dalily.1.stringWithYMD())", for: .normal)
    }
    
    func startButtonAction(_ sender: UIButton) {
        
        let datePicker = KYDatePickerController(currentDate: Date(timeIntervalSinceNow: 0), minimumDate: semesterScope.start, maximumDate: semesterScope.end, completeHandler: { [unowned sender]  (selectedDate) in
            self.startTime = selectedDate
            sender.setTitle(selectedDate.stringWithYMD(), for: .normal)
        })
        
        let presenting = UIApplication.shared.keyWindow?.topMostWindowController()
        
        let halfContainer = KYHalfPresentationController(presentedViewController: datePicker, presenting: presenting)
        datePicker.transitioningDelegate = halfContainer;
        
        presenting?.present(datePicker, animated: true, completion: nil)
    }
    func endButtonAction(_ sender: UIButton) {
        
        let datePicker = KYDatePickerController(currentDate: Date(timeIntervalSinceNow: 0), minimumDate: semesterScope.start, maximumDate: semesterScope.end, completeHandler: { [unowned sender]  (selectedDate) in
            self.endTime = selectedDate

            sender.setTitle(selectedDate.stringWithYMD(), for: .normal)
        })
        let presenting = UIApplication.shared.keyWindow?.topMostWindowController()

        let halfContainer = KYHalfPresentationController(presentedViewController: datePicker, presenting: presenting)
        datePicker.transitioningDelegate = halfContainer;
        
        presenting?.present(datePicker, animated: true, completion: nil)
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
