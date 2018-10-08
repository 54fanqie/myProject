//
//  CYJArchiveDetailController.swift
//  ZiPingSwift
//
//  Created by kyang on 2017/9/28.
//  Copyright © 2017年 Chinayoujiao. All rights reserved.
//

import UIKit
import HandyJSON

class CYJArchiveDetailController: KYBaseViewController {

    var pageViewController: UIPageViewController!
    
    var viewControllers: [UIViewController] = []
    
    var arId: Int!
    
    var archive: CYJArchive?
    
    /// 封面 + 记录 + 表 + 封地
    var totalCount: Int {
        guard let archive = self.archive else {
            return 2
        }
        return archive.record.count + archive.grId.count + 2
    }
    var recordCount: Int {
        guard let archive = self.archive else {
            return 0
        }
        return archive.record.count
    }
    
    var pageIndex = 0 {
        didSet{
            
        }
    }
    
    var pageLabel: UILabel! //页码

    var currentController: UIViewController?
    enum QADirection {
        case none
        case last
        case next
    }
    var direction: QADirection = .none

    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        title = "档案袋查看"
        //背景
        let backgroundView = UIImageView(frame: view.bounds)
        backgroundView.theme_backgroundColor = "Archived.archivedBackgroundColor"
        view.addSubview(backgroundView)
      
        //当前页码
        pageLabel = UILabel(frame: CGRect(x: view.frame.width - 90 - 15, y: 56, width: 90, height: 35))
        pageLabel.textAlignment = .center
        pageLabel.textColor = UIColor.purple
        pageLabel.font = UIFont.systemFont(ofSize: 15)
        
        view.addSubview(pageLabel)
        
        self.fetchRecordInfoFormServer()
     }
    
    func fetchRecordInfoFormServer() {
        
        let parameter: [String : Any] = ["arId" : self.arId , "token" : LocaleSetting.token]
        
        RequestManager.POST(urlString: APIManager.Archive.info, params: parameter) { [unowned self] (data, error) in
            //如果存在error
            guard error == nil else {
                Third.toast.message((error?.localizedDescription)!)
                return
            }
            if let archiveData = data as? NSDictionary {
                //遍历，并赋值
                let target = JSONDeserializer<CYJArchive>.deserializeFrom(dict: archiveData )
                self.archive = target
                
                // 去创建UI
                self.makePageViewController()
            }
        }
    }

    /// 成长记录的主体部分
    func makePageViewController() {
        //主体答题位置，设置样式为 pageCurl ，
        pageViewController =  UIPageViewController(transitionStyle: .pageCurl, navigationOrientation: .horizontal, options: [UIPageViewControllerOptionSpineLocationKey: NSNumber(value:UIPageViewControllerSpineLocation.min.rawValue)])
        pageViewController.view.frame = CGRect(x: 0, y: Theme.Measure.navigationBarHeight , width: view.frame.width, height: view.frame.height)
        pageViewController.delegate = self
        pageViewController.dataSource = self
        
        pageViewController.isDoubleSided = false //单面
//        pageViewController.cancleSideTouch()  //自定义，取消了边缘响应点击事件
        
        pageViewController.view.backgroundColor = UIColor.clear
        
        //MARK: make controllers 并赋值
        for i in 0..<self.totalCount {
            
            switch i {
            case 0:
                let vc = CYJArchivedTitlePageController()
                vc.archive = self.archive!
                viewControllers.append(vc)
            case 1..<(self.recordCount+1):
                let vc = CYJArchivedRecordController()
                vc.record = self.archive?.record[i - 1]
                viewControllers.append(vc)
            case (self.recordCount + 1)..<(self.totalCount - 1):
                let vc = CYJArchivedBarChartController()
                vc.grId = (self.archive?.grId[i - 1 - self.recordCount])!
                viewControllers.append(vc)
            case self.totalCount - 1:
                //就剩了最后一个了
                let vc = CYJArchivedSummaryController()
                vc.archive = self.archive!
                viewControllers.append(vc)
                
            default:
                break
            }
            
//            if i == 0 {
//
//            }else if i - 1 < self.recordCount { //成长记录
//                let vc = CYJArchivedRecordController()
//                vc.record = self.archive?.record[i - 1]
//                viewControllers.append(vc)
//            }else if i - 1 - self.recordCount < self.totalCount - 1{
//                let vc = CYJArchivedBarChartController()
//                vc.grId = (self.archive?.grId[i - 1 - self.recordCount])!
//                viewControllers.append(vc)
//            }else {
//                //就剩了最后一个了
//                let vc = CYJArchivedSummaryController()
//                vc.archive = self.archive!
//                viewControllers.append(vc)
//            }
        }
        
        pageIndex = 0
        currentController = viewControllers.first
        
        pageViewController.setViewControllers([(viewControllers.first)!], direction: .forward, animated: true) { (bool) in
            print("设置完成")
            
            self.addChildViewController(self.pageViewController)
            
            self.view.addSubview(self.pageViewController.view)
            self.pageLabel.text = "1/\(self.totalCount)"

            self.pageViewController.didMove(toParentViewController: self) //前面两句已经加了，这句是什么意思？
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}

//MARK: UIPageController的代理事件
extension CYJArchiveDetailController : UIPageViewControllerDelegate, UIPageViewControllerDataSource{
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        print("after- \(pageIndex)")
        if (pageIndex == totalCount - 1)// || translateLock
        { //最后一条
            return nil
        }
        direction = .next
        return viewControllers[pageIndex + 1]
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        print("before")
        
        if pageIndex == 0 //|| translateLock
        { //当前页是第一页，那么
            return nil
        }
        direction = .last
        return viewControllers[pageIndex - 1]
    }
    
    func pageViewControllerSupportedInterfaceOrientations(_ pageViewController: UIPageViewController) -> UIInterfaceOrientationMask {
        return .allButUpsideDown
    }
    
    //将要到--
    func pageViewController(_ pageViewController: UIPageViewController, willTransitionTo pendingViewControllers: [UIViewController]) {
        //        translateLock = true
        if direction == .last {//想上 print("will Trans to last")
            pageIndex -= 1
        }else if direction == .next{// print("will Trans to next")
            pageIndex += 1
        }else{
            print("direction 出错了")
        }
    }
    func pageViewControllerPreferredInterfaceOrientationForPresentation(_ pageViewController: UIPageViewController) -> UIInterfaceOrientation {
        return .portrait
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        //判断是否成功，不成功，重新设置回去
        print("complete \(completed)")

        if !completed {
            if direction == .last {
                pageIndex += 1
            }else if direction == .next
            {
                pageIndex -= 1
            }else
            {
                print("direction 出错了")
            }

            currentController = previousViewControllers.first as? CYJArchivedRecordController
        }
        self.pageLabel.text = "\(pageIndex + 1)/\(self.totalCount)"

    }
}

//MARK: 拓展UIPageViewController，取消了边缘的点击事件
//extension UIPageViewController: UIGestureRecognizerDelegate {
//
//    /// 拓展一个方法，取消UIPageViewController的点击边界翻页
//    fileprivate func cancleSideTouch() {
//        for ges in gestureRecognizers {
//            ges.delegate=self;
//        }
//    }
//
//    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
//        guard gestureRecognizer is UITapGestureRecognizer else {
//            return true
//        }
//        return false
//    }
//}

