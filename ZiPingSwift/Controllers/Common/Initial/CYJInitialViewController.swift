//
//  CYJInitialViewController.swift
//  ZiPingSwift
//
//  Created by kyang on 2017/9/4.
//  Copyright © 2017年 Chinayoujiao. All rights reserved.
//

import UIKit
import ESTabBarController_swift

class CYJInitialViewController: UIViewController{
    
    /// 引导页面s
    var leadingView: LeadingScrollView?
    /// 对应引导页面的pageControl
    var pageControl: UIPageControl?
    
    /// 系统版本
    var oldVersion: String?
    
    /// 当前系统版本
    var nowVersion: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        view.backgroundColor = UIColor.white
        //MARK: if is first load
        guard !isFirstLoad() else {
            showLeadingPage()
            return
        }
        
        performSelector(onMainThread: #selector(setRootViewController), with: nil, waitUntilDone: false)
    }
    
    /// 跳转登陆页
    func setLoginController() {
        
        let loginVC = CYJLoginViewController()
        
        let nav = KYNavigationController(rootViewController: loginVC)
        
        UIApplication.shared.keyWindow?.rootViewController = nav
        
    }
    
    /// 设置主页面
    func setRootViewController() {
        
        //没有，或者不相同，只弹出一次，让重新登录--一定安装了新版本
        let infoDictionary = Bundle.main.infoDictionary
        
        let minorVersion : String! = infoDictionary! ["CFBundleShortVersionString"] as! String
        
        if minorVersion == "2.0.2" {
            
            //MARK: 升级新版后后应该清除登陆信息，让重新登录
            let sandboxVersion = UserDefaults.standard.string(forKey: CYJUserDefaultKey.updatedVersion)
            
            if sandboxVersion != minorVersion {
                print("设置新的")
                //false
                LocaleSetting.logout()
                UserDefaults.standard.set(minorVersion, forKey: CYJUserDefaultKey.updatedVersion)
            }
        }
        
        guard (LocaleSetting.userInfo()?.token) == nil else {
            make2TabbarController()
            return
        }
        setLoginController()
    }
    /// 判断是否是第一次运行
    ///
    /// - Returns: bool
    func isFirstLoad() -> Bool {
        //
        let infoDictionary = Bundle.main.infoDictionary
        let minorVersion : AnyObject? = infoDictionary! ["CFBundleShortVersionString"] as AnyObject
        
        nowVersion = minorVersion as? String
        
        if let oldVersion = UserDefaults.standard.string(forKey: CYJUserDefaultKey.leadingVersion), oldVersion == nowVersion{
            return false
            
        }else
        {
            return true
        }
    }
    
    /// 去主页面
    func make2TabbarController() {
        
        let masterTab = CYJTabBarController()
        let masterNav = KYNavigationController(rootViewController: masterTab)
        
        UIApplication.shared.keyWindow?.rootViewController = masterNav
    }
    
    //MARK: 引导页
    func showLeadingPage(){
        
        leadingView = LeadingScrollView(images: [#imageLiteral(resourceName: "y750-1"),#imageLiteral(resourceName: "y750-2"),#imageLiteral(resourceName: "y750-3")], intoHandler: {[weak self] in
            self?.finshLeading()
        })
        
        view.addSubview(leadingView!)
    }
    /// 引导页结束
    func finshLeading() {
        //保存当前版本到本地
        
        leadingView?.removeFromSuperview()
        
        UserDefaults.standard.set(nowVersion, forKey: CYJUserDefaultKey.leadingVersion)
        UserDefaults.standard.synchronize()
        setRootViewController()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    deinit {
        DLog("CYJInitialViewController deinit ❌❌❌")
    }
}

class LeadingScrollView: UIView , UIScrollViewDelegate{
    
    var leadingView: UIScrollView!
    var pageControl: UIPageControl!
    
    var completeHandler: (()->Void)!
    
    init(images: [UIImage], intoHandler: @escaping ()->Void) {
        completeHandler = intoHandler
        super.init(frame: CGRect(x: 0, y: 0, width: Theme.Measure.screenWidth, height: Theme.Measure.screenHeight))

        /// 显示引导页
        leadingView = UIScrollView(frame: CGRect(x: 0, y: 0, width: Theme.Measure.screenWidth, height: Theme.Measure.screenHeight))
        leadingView?.bounces = false
        leadingView?.showsHorizontalScrollIndicator = false
        leadingView?.isPagingEnabled = true
        leadingView?.backgroundColor = UIColor.white
        leadingView?.delegate = self
        self.addSubview(leadingView!)
        
        leadingView?.contentSize = CGSize(width: Theme.Measure.screenWidth * CGFloat(images.count), height: Theme.Measure.screenHeight)
        
        var rect = bounds
        for i in 0..<images.count {
            
            let image = images[i]
            
            let imageView = UIImageView(frame: rect)
            imageView.image = image
            
            leadingView?.addSubview(imageView)
            
            
            if i == images.count - 1 {
                imageView.isUserInteractionEnabled = true
                let button = UIButton(title: "立即体验", frame: CGRect(x: 60, y: Theme.Measure.screenHeight - 100, width: Theme.Measure.screenWidth - 120, height: 44))
                imageView.addSubview(button)
                button.addTarget(self, action: #selector(finshLeading), for: UIControlEvents.touchUpInside)
            }
            
            //更新下一个图片的位置
            rect.origin.x += rect.width
        }
        
        
        pageControl = UIPageControl(frame: CGRect(x: 0, y: Theme.Measure.screenHeight - 130, width: Theme.Measure.screenWidth, height: 20))
        pageControl?.pageIndicatorTintColor = UIColor.lightGray
        pageControl?.currentPageIndicatorTintColor = UIColor.gray
        pageControl?.numberOfPages = images.count
        pageControl?.currentPage = 0
        pageControl?.isUserInteractionEnabled = false
        pageControl.theme_tintColor = Theme.Color.main
        
        self.addSubview(pageControl)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func finshLeading() {
        completeHandler()
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offsetX = scrollView.contentOffset.x
        
        let index = Int(offsetX / frame.width)
        pageControl.currentPage = index
    }
}


