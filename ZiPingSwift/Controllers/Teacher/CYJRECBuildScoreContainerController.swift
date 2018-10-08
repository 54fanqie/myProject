//
//  CYJRECBuildScoreContainerController.swift
//  ZiPingSwift
//
//  Created by kyang on 2017/9/26.
//  Copyright © 2017年 Chinayoujiao. All rights reserved.
//

import Foundation
import SwiftTheme

class CYJRECBuildScoreContainerController: KYBaseViewController {
    var scrollPageView: ScrollPageView!
    
    /// 整个界面通过recordParam 创建
    var recordParam : CYJNewRECParam {
        return CYJRECBuildHelper.default.recordParam
    }
    
    var allDomains: [CYJDomain]!
    
    var childIndex: Int = 0
    /// 代理，把界面状态变化，传递出去
    weak var delegate: CYJRECBuildSubViewChangeDelegate?
    
    var childVCStatus: (Bool, Bool) = (false, false)
    
    var firstViewController: CYJRECBuildFirstViewController!
    var secondViewController: CYJRECBuildSecondViewController!
    

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        view.theme_backgroundColor = Theme.Color.viewLightColor
        // 这个是必要的设置
        automaticallyAdjustsScrollViewInsets = false
        //        hidesBottomBarWhenPushed = true
        // 滚动条
        var style = SegmentStyle()
        style.showLine = true        // 颜色渐变
        style.gradualChangeTitleColor = true         // 滚动条颜色
        style.titleMargin = 30        //标题间距
        style.scrollTitle = true// s滚动标题
        style.titleAlignment = true  //整体剧中
        style.titleFont = UIFont.systemFont(ofSize: 17)
        let color = ThemeManager.color(for: "Nav.barTintColor")!
        let normalColor = ThemeManager.color(for: "Global.textColorLight")!
        
        style.scrollLineColor =  color
        style.normalTitleColor = normalColor
        style.selectedTitleColor = color
        
        
         scrollPageView = ScrollPageView(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: Theme.Measure.screenHeight - 58  - Theme.Measure.navigationBarHeight - 1), segmentStyle: style, titles: ["指标评分", "评语/建议"], childVcs: setChildVcs(), parentViewController: self)
        scrollPageView.delegate = self
        view.addSubview(scrollPageView)
        //监听向上还是向下滑动
        NotificationCenter.default.addObserver(self, selector: #selector(dropView), name: NSNotification.Name(rawValue:"dropScrollerView"), object: nil)
    }
    func dropView(info:NSNotification)  {
        print(info.object ?? 0)
        
        //向上、向下方向: 0 初始展开状态  1收缩折叠状态
        if info.object as! Int == 1  {
            UIView.animate(withDuration: 0.2) {
                //列表视图y轴向上移动headerHeight 高度增加headerHeight
                self.scrollPageView.frame = CGRect(x: 0, y: -35, width: self.view.frame.width, height: Theme.Measure.screenHeight  - Theme.Measure.navigationBarHeight - 44  + 10)
            }
        }else{
            UIView.animate(withDuration: 0.2) {
                //复位
                self.scrollPageView.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: Theme.Measure.screenHeight - 58 - 8 - Theme.Measure.navigationBarHeight - 1)
            }
        }
    }
    /// swiperView 必须实现的
    func setChildVcs() -> [UIViewController] {
        
        var childVCs: [UIViewController] = []
        
        let vc1 = CYJRECBuildFirstViewController()
        vc1.allDomains = self.allDomains
        //设置一个flag 方便取evaluete的对象
        vc1.flag = self.childIndex
        vc1.title = "指标评分"
        vc1.IamChangedHandler = {[weak self] in
            if let changed = $0 as? Bool {
                self?.childVCStatus.0 = changed
                self?.childViewControllersChanged()
            }
        }
        vc1.view.frame = CGRect(x: 0, y: 100, width: Theme.Measure.screenWidth, height: Theme.Measure.screenHeight - 58 - 8 - 64 - 44)
        self.firstViewController = vc1
        childVCs.append(vc1)
        
        let vc2 = CYJRECBuildSecondViewController()
        vc2.IamChangedHandler = {[weak self] in
            if let changed = $0 as? Bool {
                self?.childVCStatus.1 = changed
                self?.childViewControllersChanged()
            }
        }
        vc2.childIndex = self.childIndex
        vc2.view.backgroundColor = UIColor.white
        vc2.view.frame = CGRect(x: 0, y: 0.5, width: Theme.Measure.screenWidth, height: Theme.Measure.screenHeight - 58 - 8 - 64 - 44)
        vc2.title = "评语建议"
        
        self.secondViewController = vc2
        childVCs.append(vc2)
        
        return childVCs
    }
    
    
    func childViewControllersChanged() {
        if let del = delegate {
            let changed = (self.childVCStatus.0 || self.childVCStatus.1)
            del.subViewChanged(index: childIndex, highlight: changed )
        }
    }
}

extension CYJRECBuildScoreContainerController: ScrollPageViewDelegate {
    
    func scrollPageView(scrollPageView: ScrollPageView, willScrollTo index: Int) {
        self.secondViewController.view.endEditing(true)
    }
    func scrollPageView(scrollPageView: ScrollPageView, DidScrollTo index: Int) {
        self.secondViewController.view.endEditing(true)
    }
    
    
}
