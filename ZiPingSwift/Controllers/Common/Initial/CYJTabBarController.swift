//
//  CYJTabBarController.swift
//  ZiPingSwift
//
//  Created by kyang on 2017/9/5.
//  Copyright © 2017年 Chinayoujiao. All rights reserved.
//

import UIKit
import ESTabBarController_swift
import SideMenu
import SwiftTheme

class CYJTabBarController: ESTabBarController {
    
    var role: CYJRole {
        return (LocaleSetting.userInfo()?.role)!
    }
    
    var teacherStatisticController: CYJRECStatisticC?
    
    var messageButton: SwipeButtonWithBadge!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        //        navigationItem.title = "主页"
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "icon_white_hamburger"), style: .plain, target: self, action:  #selector(presentMine))
        self.tabBar.shadowImage = UIImage()
        self.tabBar.backgroundImage = initWithImage()
        self.tabBar.backgroundImage = UIImage(named: "tab-bg")
        
        switch role {
        case .master:
            makeMasterTabbar()
        case .teacher:
            makeTeacherTabbar()
        case .teacherL:
            makeTeacherLTabbar()
        case .child:
            makeChildrenTabbar()
        case .none,.noGarden,.noClass:
            
            messageButton = SwipeButtonWithBadge(type: .custom)
            messageButton.setImage( #imageLiteral(resourceName: "icon_white_news"), for: .normal)
            messageButton.frame = CGRect(x: 0, y: 0, width: 33, height: 25)
            messageButton.addTarget(self, action: #selector(pushNotice), for: .touchUpInside)
            //TODO: 更新 按钮的 红点
            messageButton.badge = LocaleSetting.share.unReadMessageCount.sumCount > 0
            
            let messageButtonItem = UIBarButtonItem(customView: messageButton)
            navigationItem.rightBarButtonItems = [messageButtonItem]
            
            self.tabBar.isHidden = true
            self.view.backgroundColor = UIColor.white
            
            let label = UILabel(frame: CGRect(x: 35, y: 150, width: Theme.Measure.screenWidth - 70, height: 100))
            label.font = UIFont.systemFont(ofSize: 17)
            label.text = "对不起，您现在无所属班级，请联系园长给您分配所属的班级，如有疑问请联系平台客服。"
            label.theme_textColor = Theme.Color.textColorDark
            label.numberOfLines = 0
            label.lineBreakMode = .byCharWrapping
            
            view.addSubview(label)
            break
        }
        
        //不论如何，先创建messageButton
        //TODO: 获取消息通知！
        LocaleSetting.share.fetchUnreadMessageCount()
        
        tabBar.theme_barTintColor = "Tab.barTintColor"
        tabBar.theme_tintColor = "Tab.barTextColor"
//        if #available(iOS 10.0, *) {
//            tabBar.unselectedItemTintColor = UIColor(hex6: 0xFFFFFF, alpha: 0.5)
//        } else {
//            // Fallback on earlier versions
//        }
        
        setupSideMenu()
        
        NotificationCenter.default.addObserver(self, selector: #selector(messageCountChanged), name: CYJNotificationName.unreadMessageCountChanged, object: nil)
    }
    func initWithImage()->UIImage{
        let rect = CGRect(x: 0,y: 0,width: self.view.frame.size.width,height: self.view.frame.size.height)
        UIGraphicsBeginImageContext(rect.size)
        let context = UIGraphicsGetCurrentContext()
        context!.setFillColor(UIColor.clear.cgColor)
        context!.fill(rect)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image!
    }
    
    override var selectedIndex: Int {
        didSet{
            
            //TODO: 更新标题文字
            let vc = viewControllers![selectedIndex]
            navigationItem.title = vc.title
            
            
            messageButton = SwipeButtonWithBadge(type: .custom)
            messageButton.setImage( #imageLiteral(resourceName: "icon_white_news"), for: .normal)
            //            messageButton.theme_setImage("Tab.midItemImage", forState: .normal)
            messageButton.frame = CGRect(x: 0, y: 0, width: 33, height: 25)
            messageButton.addTarget(self, action: #selector(pushNotice), for: .touchUpInside)
            //MARK: 更新 按钮的 红点
            messageButton.badge = LocaleSetting.share.unReadMessageCount.sumCount > 0
            
            let messageButtonItem = UIBarButtonItem(customView: messageButton)
            
            //           if role == .teacher, selectedIndex == 0 {
            //                navigationItem.rightBarButtonItems = [ messageButtonItem, UIBarButtonItem(title: "暂存", style: .plain, target: self, action: #selector(pushHistory))]
            //
            //            }else
            if role == .teacher, selectedIndex == 3{
                
                navigationItem.rightBarButtonItems = [messageButtonItem, UIBarButtonItem(title: "筛选", style: .plain, target: self, action: #selector(pushSift))]
//                  navigationItem.rightBarButtonItems = [messageButtonItem, UIBarButtonItem(image: UIImage(named:"nav-czpj-filter"), style: .plain, target: self, action: #selector(pushSift))]
                
            }else if role == .teacherL, selectedIndex == 3 {
                navigationItem.rightBarButtonItems = [messageButtonItem, UIBarButtonItem(title: "筛选", style: .plain, target: self, action: #selector(pushSift))]
                
//                 navigationItem.rightBarButtonItems = [messageButtonItem, UIBarButtonItem(image: UIImage(named:"nav-czpj-filter"), style: .plain, target: self, action: #selector(pushSift))]
            }
            else{
                navigationItem.rightBarButtonItems = [messageButtonItem]
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //        SideMenuManager.menuAddPanGestureToPresent(toView: self.navigationController!.navigationBar)
        //        SideMenuManager.menuAddScreenEdgePanGesturesToPresent(toView: self.navigationController!.view)
        
    }
    
    
    
    func presentMine() {
        present(SideMenuManager.menuLeftNavigationController!, animated: true) {
            //
        }
    }
    
    func pushNotice() {
        //TODO: 角色不同，去不同的地方
        if role == .master {
            let notice = MessageControllerMaster()
            
            navigationController?.pushViewController(notice, animated: true)
        }else if role == .child
        {
            let notice = CYJMessageControllerChild()
            
            navigationController?.pushViewController(notice, animated: true)
        }else
        {
            let notice = CYJMessageControllerTeacher()
            
            navigationController?.pushViewController(notice, animated: true)
        }
    }
    
    func pushHistory() {
        
        let recList = CYJRECCacheViewController()
        
        navigationController?.pushViewController(recList, animated: true)
    }
    func pushSift() {
        
        let domains = (teacherStatisticController?.allDomains)!
        
        guard domains.count > 0 else {
            Third.toast.message("该年级园长暂未设置评价指标")
            return
        }
        
        let recList = CYJDomainMutiSelector()
        recList.title = "选择领域"
        recList.dataSource = domains
        recList.selectedDomain = (teacherStatisticController?.selectedDomain)!
        
        recList.completeAction = {[unowned self] in
            self.teacherStatisticController?.selectedDomain = $0
            recList.navigationController?.popViewController(animated: true)
        }
        
        navigationController?.pushViewController(recList, animated: true)
    }
    
    fileprivate func setupSideMenu() {
        // Define the menus
        
        let mineVC = CYJMineViewController()
        let mineNav = UISideMenuNavigationController(rootViewController: mineVC)
        SideMenuManager.menuLeftNavigationController = mineNav
        
        SideMenuManager.menuPresentMode = .menuSlideIn
        SideMenuManager.menuPushStyle = .popWhenPossible
        SideMenuManager.menuAnimationFadeStrength = 0.3
        //        SideMenuManager.menuLeftNavigationController = storyboard!.instantiateViewController(withIdentifier: "LeftMenuNavigationController") as? UISideMenuNavigationController
        
        //        SideMenuManager.menuRightNavigationController = storyboard!.instantiateViewController(withIdentifier: "RightMenuNavigationController") as? UISideMenuNavigationController
        
        // Enable gestures. The left and/or right menus must be set up above for these to work.
        // Note that these continue to work on the Navigation Controller independent of the View Controller it displays!
        
        
        // Set up a cool background image for demo purposes
        SideMenuManager.menuAnimationBackgroundColor = UIColor.white
        //UIColor(patternImage: UIImage(named: "background")!)
        SideMenuManager.menuFadeStatusBar = false
    }
    
    func messageCountChanged() {
        DLog("⭕️⭕️⭕️⭕️ 改变消息的红点")
        self.messageButton.badge = LocaleSetting.share.unReadMessageCount.sumCount > 0
        //更新系统红点数目
        UIApplication.shared.applicationIconBadgeNumber = LocaleSetting.share.unReadMessageCount.sumCount
        JPUSHService.setBadge(LocaleSetting.share.unReadMessageCount.sumCount)
    }
    
    //MARK: 创建 tabbarItems
    /// 园长端
    func makeMasterTabbar() {
        
        let first = CYJRECListControllerMaster()
        first.title = "成长记录"
        let firstItem =  UITabBarItem(title: "成长记录", image: #imageLiteral(resourceName: "tab-czjl").withRenderingMode(.alwaysOriginal), selectedImage: #imageLiteral(resourceName: "tab-czjl-on").withRenderingMode(.alwaysOriginal))
        first.tabBarItem = firstItem
        
        let forth = CYJAnalyseViewController()
        forth.title = "成长分析"
        let forthItem = UITabBarItem(title: "成长分析", image: #imageLiteral(resourceName: "tab-czfx").withRenderingMode(.alwaysOriginal), selectedImage: #imageLiteral(resourceName: "tab-czfx-on").withRenderingMode(.alwaysOriginal))
        forth.tabBarItem = forthItem
        
   
        let fifth = CYJAttentionAnalyseController()
        fifth.title = "关注度统计"
        let fifthItem = UITabBarItem(title: "关注度统计", image: #imageLiteral(resourceName: "tab-gzdtj").withRenderingMode(.alwaysOriginal), selectedImage: #imageLiteral(resourceName: "tabgzdtj-on").withRenderingMode(.alwaysOriginal))
        fifth.tabBarItem = fifthItem
     
        viewControllers = [first,forth,fifth];
        
    }
    
    /// 教师端(班长)
    func makeTeacherTabbar() {
        let first = CYJRECListViewControllerTeacher(.grouped)
        first.title = "成长记录"
        let firstItem =  UITabBarItem(title: "成长记录", image: #imageLiteral(resourceName: "tab-czjl").withRenderingMode(.alwaysOriginal), selectedImage: #imageLiteral(resourceName: "tab-czjl-on").withRenderingMode(.alwaysOriginal))
        first.tabBarItem = firstItem
        
        let second = CYJRECCacheViewController()
        second.title = "暂存记录"
        let secondItem = UITabBarItem(title: "暂存记录", image: #imageLiteral(resourceName: "tab-zcjl").withRenderingMode(.alwaysOriginal), selectedImage: #imageLiteral(resourceName: "tab-zcjl-on").withRenderingMode(.alwaysOriginal))
        second.tabBarItem = secondItem
        
        let third = CYJBasicViewController()
        third.title = "发布"
        let thirdItem = CYJThemeTabBarItem( CYJThemeTabBarItemContentView(), themetitle: "发布", imagePicker: "Tab.midItemImage" , selectedImagePicker: "Tab.midItemImage", tag: 2)
        
        
        third.tabBarItem = thirdItem
        
        
        
        let forth = CYJRECStatisticC()
        forth.title = "成长评价"
        let forthItem = UITabBarItem(title: "成长评价", image: #imageLiteral(resourceName: "tab-czcp").withRenderingMode(.alwaysOriginal), selectedImage: #imageLiteral(resourceName: "tab-czcp-on").withRenderingMode(.alwaysOriginal))
        forth.tabBarItem = forthItem
        
        teacherStatisticController = forth
        
        
        
        let fifth = CYJBabysViewController()
        fifth.title = "查看幼儿"
        let fifthItem = UITabBarItem(title: "查看幼儿", image: #imageLiteral(resourceName: "tab-icon-bb").withRenderingMode(.alwaysOriginal), selectedImage: #imageLiteral(resourceName: "tab-icon-bb-on").withRenderingMode(.alwaysOriginal))
        fifth.tabBarItem = fifthItem
        
        viewControllers = [first, second, third, forth, fifth]
        
        shouldHijackHandler = { return $0.2 == 2}
        
        didHijackHandler = { (Void)-> Void in
            
            let buildFirst = CYJRECBuildInfoViewController()
            CYJRECBuildHelper.default.buildStep = .new
            let buildNav = KYNavigationController(rootViewController: buildFirst)
            self.present(buildNav, animated: true, completion: nil)
        }
    }
    
    // 教师2（配班教师）
    func makeTeacherLTabbar() {
        let first = CYJRECListViewControllerTeacher(.grouped)
        first.title = "成长记录"
        let firstItem =  UITabBarItem(title: "成长记录", image: #imageLiteral(resourceName: "tab-czjl").withRenderingMode(.alwaysOriginal), selectedImage: #imageLiteral(resourceName: "tab-czjl-on").withRenderingMode(.alwaysOriginal))
        first.tabBarItem = firstItem
        
        let second = CYJRECCacheViewController()
        second.title = "暂存记录"
        let secondItem = UITabBarItem(title: "暂存记录", image: #imageLiteral(resourceName: "tab-zcjl").withRenderingMode(.alwaysOriginal), selectedImage: #imageLiteral(resourceName: "tab-zcjl-on").withRenderingMode(.alwaysOriginal))
        second.tabBarItem = secondItem
        
        let third = CYJBasicViewController()
        third.title = "发布"
        let thirdItem = CYJThemeTabBarItem( CYJThemeTabBarItemContentView(), themetitle: "发布", imagePicker: "Tab.midItemImage" , selectedImagePicker: "Tab.midItemImage", tag: 2)
        third.tabBarItem = thirdItem
        
        let forth = CYJRECStatisticC()
        forth.title = "成长评价"
        let forthItem = UITabBarItem(title: "成长评价", image: #imageLiteral(resourceName: "tab-czcp").withRenderingMode(.alwaysOriginal), selectedImage: #imageLiteral(resourceName: "tab-czcp-on").withRenderingMode(.alwaysOriginal))
        forth.tabBarItem = forthItem
        teacherStatisticController = forth
        
        let fifth = CYJBabysViewController()
        fifth.title = "查看幼儿"
        let fifthItem = UITabBarItem(title: "查看幼儿", image: #imageLiteral(resourceName: "tab-icon-bb").withRenderingMode(.alwaysOriginal), selectedImage: #imageLiteral(resourceName: "tab-icon-bb-on").withRenderingMode(.alwaysOriginal))
        
        fifth.tabBarItem = fifthItem
        
        viewControllers = [first, second, third, forth, fifth]
        
        shouldHijackHandler = { return $0.2 == 2}
        
        didHijackHandler = { (Void)-> Void in
            let buildFirst = CYJRECBuildInfoViewController()
            CYJRECBuildHelper.default.buildStep = .new
            let buildNav = KYNavigationController(rootViewController: buildFirst)
            self.present(buildNav, animated: true, completion: nil)
        }
    }
    
    
    /// 学生（家长）
    func makeChildrenTabbar() {
        let first = CYJRECListControllerParent()
        first.title = "成长记录"
        let firstItem =  UITabBarItem(title: "成长记录", image: #imageLiteral(resourceName: "tab-czjl").withRenderingMode(.alwaysOriginal), selectedImage: #imageLiteral(resourceName: "tab-czjl-on").withRenderingMode(.alwaysOriginal))
        first.tabBarItem = firstItem
        
        let second = CYJArchiveListViewController()
        second.title = "档案袋"
        let secondItem = UITabBarItem(title: "档案袋", image: #imageLiteral(resourceName: "tab-dangandai").withRenderingMode(.alwaysOriginal), selectedImage: #imageLiteral(resourceName: "tab-dangandai-on").withRenderingMode(.alwaysOriginal))
        second.tabBarItem = secondItem
        
        viewControllers = [first, second]
    }
}
