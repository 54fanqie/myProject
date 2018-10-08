//
//  CYJRECDetailViewController.swift
//  ZiPingSwift
//
//  Created by kyang on 2017/8/30.
//  Copyright © 2017年 Chinayoujiao. All rights reserved.
//

import UIKit
import HandyJSON
import SwiftTheme

class CYJRECDetailViewController: KYBaseViewController {
    
    var recordId: Int = 0
    var record: CYJRecord?

    /// 滑动视图
    var scrollPageView: ScrollPageView?
    /// 两个scrollPage的页面
    var infoViewController: CYJRECDetailDescroptionController?
    var evaluateController: CYJRECDetailEvaluateController?
    
    /// 从上一页过来的indexPath，non-nil， 当点赞后使用，刷新上一个页面
    var indexPath: IndexPath?
    var isPraisedHandler: CYJCompleteHandler?

    // 点赞，批阅按钮
    var actionView: CYJActionsView?

    var goodButton: CYJButtonItem?
    var readButton: CYJButtonItem?
    
    var isOtherClass: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        self.title = "成长记录查看"
        view.theme_backgroundColor = Theme.Color.ground

        self.fetchDataSource()
      
        
    }
    
    /// 创建下边的按钮
    func makeMarkButton() {
        
        actionView = CYJActionsView(frame: CGRect(x: 0, y: view.frame.height - 44, width: view.frame.width, height: 44))
        actionView?.theme_backgroundColor = Theme.Color.viewLightColor
        if LocaleSetting.userInfo()?.role == .master {
            actionView?.isFull = true
        }else{
            actionView?.isFull = false
            
            //给加一条线
            let bezial = UIBezierPath()
            bezial.move(to: CGPoint.zero)
            bezial.addLine(to: CGPoint(x: (actionView?.frame.width)!, y: 0))
            
            let shapeLayer = CAShapeLayer()
            shapeLayer.path = bezial.cgPath
            shapeLayer.strokeColor = UIColor(hex6: 0xe3e3e3).cgColor
            shapeLayer.lineWidth = 0.5
            actionView?.layer.addSublayer(shapeLayer)
        }
        actionView?.innerPadding = 0
        view.addSubview(actionView!)

        goodButton = CYJButtonItem(title: " 给老师点赞") { [unowned self] (sender) in
            print("点赞阅")
            self.actionView?.theme_backgroundColor = Theme.Color.viewLightColor
            sender.isUserInteractionEnabled = false
            let parameter: [String: Any]
            if self.isOtherClass == true{
                parameter = ["grId" : self.record?.grId ?? 0, "token": LocaleSetting.token,"isother":1]
            }else{
              parameter = ["grId" : self.record?.grId ?? 0, "token": LocaleSetting.token]
            }
            
            RequestManager.POST(urlString: APIManager.Record.praise, params: parameter) { [unowned sender] (data, error) in
                //如果存在error
                guard error == nil else {
                    sender.isSelected = false
                    sender.isUserInteractionEnabled = true
                    Third.toast.message((error?.localizedDescription)!)
                    return
                }
                sender.isSelected = true
                sender.isUserInteractionEnabled = false
                self.record?.isPraised = 1
                self.record?.newPraise(name: (LocaleSetting.userInfo()?.realName)!)
                self.infoViewController?.tableView.reloadData()
                
                Third.toast.message("点赞成功")

                if let isPra =  self.isPraisedHandler {
                    if let indexP = self.indexPath {
                        isPra(indexP)
                    }
                }
            }
        }
        goodButton?.setImage(#imageLiteral(resourceName: "icon_white_heart"), for: .selected)
        goodButton?.setImage(#imageLiteral(resourceName: "icon_gray_heart"), for: .normal)
        goodButton?.setTitle(" 给老师点赞", for: .normal)
        goodButton?.setTitle(" 已点赞", for: .selected)
//         goodView.backgroundColor = UIColor.red
//        goodButton?.backgroundColorNormal = Theme.Color.ground
//        goodButton?.backgroundColorSelected = Theme.Color.ground
        goodButton?.borderColorNormal = "Global.viewLightGray"
        goodButton?.borderColorSelected = "Global.viewLightGray"
//        goodButton?.borderWidth = 0.5
        goodButton?.theme_setTitleColor(Theme.Color.textColor, forState: .normal)
        goodButton?.theme_setTitleColor(Theme.Color.textColor, forState: .selected)
        
        
        if record?.isPraised == 1 {
            goodButton?.isSelected = true
            goodButton?.isUserInteractionEnabled = false
            actionView?.innerPadding = 0
            actionView?.theme_backgroundColor = Theme.Color.viewLightColor
        }else {
            goodButton?.isSelected = false
            actionView?.theme_backgroundColor = Theme.Color.ground
        }
        
        readButton?.theme_backgroundColor = Theme.Color.main
        
        
        if LocaleSetting.userInfo()?.role == .master {
            
            readButton = CYJButtonItem(title: "批阅") { [unowned self] (sender) in
                print("批阅")
                self.checkButtonAction()
            }
            readButton?.theme_backgroundColor = Theme.Color.main
            readButton?.theme_setTitleColor(Theme.Color.ground, forState: .normal)
            readButton?.backgroundColorSelected = Theme.Color.main
            readButton?.theme_setTitleColor(Theme.Color.ground, forState: .selected)
            readButton?.borderWidth = 0
            if self.record?.isMark == 1 {
                readButton!.setTitle("批阅", for: .normal)
                readButton?.isEnabled = true
               
            }else{
                readButton!.setTitle("已批阅", for: .normal)
                readButton?.isEnabled = false
                readButton!.theme_backgroundColor = Theme.Color.textColorHint
            }
            actionView?.actions = [goodButton!, readButton!]

        }else {
            actionView?.actions = [goodButton!]
        }
    }
    func makeShareButton() {
        
        if self.isOtherClass == false {
            if LocaleSetting.userInfo()?.role == .teacherL {
                if LocaleSetting.userInfo()?.uId == self.record?.uId {
                    //是自己的
                    navigationItem.rightBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "icon_white_share"), style: .plain, target: self, action: #selector(shareButtonAction))
                }
            }else if LocaleSetting.userInfo()?.role == .teacher {
                navigationItem.rightBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "icon_white_share"), style: .plain, target: self, action: #selector(shareButtonAction))
            }
        }
        
    }
    
    /// 下面的滑动视图
    func makeSwiperView() {
        
        // 这个是必要的设置
        automaticallyAdjustsScrollViewInsets = false
        //        hidesBottomBarWhenPushed = true
        
        if let _ = scrollPageView?.superview {
            let viewControllers = setChildVcs()
            let titles = viewControllers.map { $0.title! }
            
            scrollPageView?.reloadChildVcsWithNewTitles(titles, andNewChildVcs: viewControllers)
            
        }else {
            // 滚动条
            var style = SegmentStyle()
            style.showLine = true        // 颜色渐变
            style.gradualChangeTitleColor = true         // 滚动条颜色
            style.titleMargin = 100        //标题间距
            style.scrollTitle = true// s滚动标题
            style.titleAlignment = true  //整体剧中
            
            
            let color = ThemeManager.color(for: "Nav.barTintColor")!
            let normalColor = ThemeManager.color(for: "Global.textColorLight")!

            style.scrollLineColor =  color
            style.normalTitleColor = normalColor
            style.selectedTitleColor = color

            style.titleFont = UIFont.systemFont(ofSize: 17)
            
            let viewControllers = setChildVcs()
            let titles = viewControllers.map { $0.title! }
            
            let scrollRect = CGRect(x: 0, y: Theme.Measure.navigationBarHeight, width: Theme.Measure.screenWidth, height: Theme.Measure.screenHeight - 44)
            scrollPageView = ScrollPageView(frame: scrollRect, segmentStyle: style, titles: titles, childVcs: viewControllers, parentViewController: self)
            
            scrollPageView?.theme_backgroundColor = Theme.Color.viewLightColor
            scrollPageView?.contentView.backgroundColor = UIColor(hex6: 0xE0E0E0)
            view.addSubview(scrollPageView!)
        }
    }
    
    func fetchDataSource() {
        
        let parameter: [String: Any] = ["token" : LocaleSetting.token, "grId" : self.recordId]
        
        RequestManager.POST(urlString: APIManager.Record.info, params: parameter) { [unowned self] (data, error) in
            //如果存在error
            guard error == nil else {
                Third.toast.message((error?.localizedDescription)!)
                return
            }
            if let recordDetail = data as? NSDictionary {
                //遍历，并赋值
                let target = JSONDeserializer<CYJRecord>.deserializeFrom(dict: recordDetail)
                self.record = target
                //createUI
                self.makeSwiperView()
                
                //创建 buttonAction
                self.makeMarkButton()
                self.makeShareButton()
            }
        }
    }
    
    /// swiperView 必须实现的
    func setChildVcs() -> [UIViewController] {
        
        var childVCs: [UIViewController] = []
        let vc1 = CYJRECDetailDescroptionController()
        vc1.title = "描述"
        vc1.record = self.record!
        vc1.view.frame = CGRect(x: 0, y: 0.5, width: Theme.Measure.screenWidth, height: Theme.Measure.screenHeight - Theme.Measure.navigationBarHeight - 44)
        
        childVCs.append(vc1)
        
        let vc2 = CYJRECDetailEvaluateController()
        vc2.grId = self.recordId
        vc2.ownerId = (self.record?.uId)!
        vc2.view.frame = CGRect(x: 0, y: 0.5, width: Theme.Measure.screenWidth, height: Theme.Measure.screenHeight - Theme.Measure.navigationBarHeight - 44)
        vc2.title = "评价"
        
        childVCs.append(vc2)
        
        self.infoViewController = vc1
        self.evaluateController = vc2
        
        return childVCs
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func checkButtonAction() {
        let check = CYJRECCommentViewController()
        check.grId = self.record?.grId ?? 0
        check.markOverActionHandler = { [unowned self] (_) in
            
            self.fetchDataSource()
        }
        navigationController?.pushViewController(check, animated: true)
    }
    
    func shareButtonAction() {
        
        guard let users = self.record?.user else {
            DLog("获取到的数据为空")
            return
        }
        
        let alert = CYJRECSharedAlertController()
        alert.children = users.map({ (child) -> CYJNewRECParam.ChildEvaluate in
            let evaluate = CYJNewRECParam.ChildEvaluate()
            evaluate.bId = child.uId
            evaluate.name = child.realName
            return evaluate
        })
        alert.completeHandler = {[unowned self] in
            print("CYJRECBuildAlertController sure -- continue upload")
            //TODO: 5⃣️ 如果回调的数据存在，那么分享，否则直接销毁
            if $0.count == 0 {
                alert.dismiss(animated: true, completion: nil)
            }else {
                self.shareRecordToParent(uid: $0)
                alert.dismiss(animated: true, completion: nil)
            }
        }
        alert.showAlert()
    }
    
    func jsonStringFromJsonObject(_ object: Any) -> String {
        do {
            let data = try JSONSerialization.data(withJSONObject: object, options: JSONSerialization.WritingOptions.init(rawValue: 0))
            let strJson = String(data: data, encoding: .utf8)
            return strJson ?? ""
        }catch
        {
            return ""
        }
    }
    /// 分享给家长
    ///
    /// - Parameter uid: <#uid description#>
    func shareRecordToParent(uid: [Int]) {
        
//        let uidJson = jsonStringFromJsonObject(uid as Any)
        
        let paramter: [String : Any] = ["token" : LocaleSetting.token, "uId" : uid, "grId" : self.recordId]
        
        RequestManager.POST(urlString: APIManager.Record.share, params: paramter) {(data, error) in
            //如果存在error
            guard error == nil else {
                Third.toast.message((error?.localizedDescription)!)
                return
            }
            //TODO: 6⃣️ 分享成功后，销毁页面
            Third.toast.message("分享成功")
        }
    }
}

