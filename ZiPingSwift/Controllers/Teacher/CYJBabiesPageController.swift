//
//  CYJBabiesPageController.swift
//  ZiPingSwift
//
//  Created by kyang on 2017/9/28.
//  Copyright © 2017年 Chinayoujiao. All rights reserved.
//

import UIKit
import SwiftTheme

class CYJBabiesPageController: KYBaseViewController {

    var scrollPageView: ScrollPageView!
    
    var uid: Int = 0
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        view.theme_backgroundColor = Theme.Color.ground
        // 这个是必要的设置
        automaticallyAdjustsScrollViewInsets = false
        //        hidesBottomBarWhenPushed = true
        // 滚动条
        var style = SegmentStyle()
        style.showLine = true        // 颜色渐变
        style.gradualChangeTitleColor = true         // 滚动条颜色
//        style.scrollLineColor =  UIColor(red: 41/255.0, green: 167/255.0, blue: 158/255.0, alpha: 1)
        style.titleMargin = 30        //标题间距
        style.scrollTitle = true// s滚动标题
        style.titleAlignment = true  //整体剧中
//        style.normalTitleColor = UIColor(red: 86/255.0, green: 173/255.0, blue: 235/255.0, alpha: 1)
        style.titleFont = UIFont.systemFont(ofSize: 17)
//        style.selectedTitleColor = UIColor(red: 86/255.0, green: 173/255.0, blue: 235/255.0, alpha: 1)
        let color = ThemeManager.color(for: "Nav.barTintColor")!
        let normalColor = ThemeManager.color(for: "Global.textColorLight")!
        
        style.scrollLineColor =  color
        style.normalTitleColor = normalColor
        style.selectedTitleColor = color
        
        scrollPageView = ScrollPageView(frame: CGRect(x: 0, y: Theme.Measure.navigationBarHeight, width: view.frame.width, height: Theme.Measure.screenHeight - Theme.Measure.navigationBarHeight), segmentStyle: style, titles: ["成长记录", "集中测评结果" ,"档案袋"], childVcs: setChildVcs(), parentViewController: self)
        
        view.addSubview(scrollPageView)
    }
    
    /// swiperView 必须实现的
    func setChildVcs() -> [UIViewController] {
        
        var childVCs: [UIViewController] = []
        
        let vc1 = CYJRECListControllerParent()
        vc1.uid = self.uid
        vc1.title = "成长记录"
        vc1.view.frame = CGRect(x: 0, y: 0.5, width: Theme.Measure.screenWidth, height: Theme.Measure.screenHeight - Theme.Measure.navigationBarHeight)
        
        childVCs.append(vc1)
        
        
        //教师测评结果
        let vc = ValuationResultViewController();
        vc.view.backgroundColor = UIColor.white
        vc.userID = String(format: "%d", self.uid)

        vc.view.frame = CGRect(x: 0, y: 0.5, width: Theme.Measure.screenWidth, height: Theme.Measure.screenHeight - Theme.Measure.navigationBarHeight)
        childVCs.append(vc)
        
        let vc2 = CYJArchiveListViewController()
        vc2.uid = self.uid
        vc2.view.backgroundColor = UIColor.white
        vc2.view.frame = CGRect(x: 0, y: 0.5, width: Theme.Measure.screenWidth, height: Theme.Measure.screenHeight - Theme.Measure.navigationBarHeight)
        vc2.title = "档案袋"
        
        childVCs.append(vc2)
        
        return childVCs
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
