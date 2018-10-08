//
//  CYJRECBuildScoreViewController.swift
//  ZiPingSwift
//
//  Created by kyang on 2017/8/30.
//  Copyright © 2017年 Chinayoujiao. All rights reserved.
//

import UIKit

import HandyJSON
import SwiftTheme

protocol CYJRECBuildSubViewChangeDelegate : class{
    func subViewChanged(index: Int, highlight: Bool) -> Void
}
class Children: NSObject {
    //名字
    var childrenName : String?
    //以评论数
    var selectCount : Int?
}


class CYJRECBuildScoreViewController: KYBaseViewController {
    
    /// 需要从上一个页面传递过来， required  grId != 0
    var recordParam : CYJNewRECParam {
        return CYJRECBuildHelper.default.recordParam
    }
    var sharedUIds = [Int]()
    /// 创建 segmentView 所需数据
    var children: [Children] {
        
        let children  = self.recordParam.info.map { (evaluate) -> Children in
            let tmp = Children()
            tmp.childrenName = evaluate.name
            tmp.selectCount = evaluate.lId.count
            return tmp
        }
        return children
    }
    
    /// 创建 segmentView 所需数据
    var images: [String] {
        let avatars = self.recordParam.info.map { (evaluate) -> String in
            return evaluate.avatar ?? "http://www.jkhahk.com"
        }
        return avatars
    }
    
    var allDomains: [CYJDomain] = []
    var buttonActionView: UIView!
    //MARK: View Properties
    var segView: CustomScrollSegmentView!
    var segmentStyle: SegmentStyle!
    var contentView: ContentView!
    
    
    var headerHeight : CGFloat = 68
    var bottomButtonHeight : CGFloat = 44
    
    var oldFrame : CGRect = CGRect.zero
    //内含横向controller列表
    var listVCs: [UIViewController] = []
    
    var contentViewControllers: [CYJRECBuildScoreContainerController] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        title = "评分评价"
        view.theme_backgroundColor = Theme.Color.viewLightColor
        // 这个是必要的设置
        automaticallyAdjustsScrollViewInsets = false
        
        // 关闭返回，让只能通过暂存按钮返回上个页面
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "关闭", style: .plain, target: self, action: #selector(dismissSelfNavigationController))
        
        //TODO: First 请求 student 的评价数据
        
        switch CYJRECBuildHelper.default.buildStep {
        case .uploaded:
            //TODO: third 请求评价信息后，创建当前界面的数据并刷新出来，
            //这时候已经存在了幼儿数据
            self.makeSegmentView()
            //直接请求domain 数据
            self.fetchDominsFromServer()
            self.requestStudentDataFromServer()
        case .cached(_):
            self.requestStudentDataFromServer()
        default:
            break
        }
        Third.toast.show { };
        // makeActionsView
        self.makeActionsView()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.isNavigationBarHidden  = true
        //MARK: 设置recordView的父识图
        CYJASRRecordor.share.containerView = self.view
        
        //到了第二部，要更新mark
        recordParam.mark = 1
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.isNavigationBarHidden  = false
        //MARK: 设置recordView的父识图
        CYJASRRecordor.share.containerView = nil
        Third.toast.hide {}
    }
    
    
    /// 关闭成长记录 -- 未暂存的就没有啦
    func dismissSelfNavigationController() {
        print(CYJRECBuildHelper.default.buildStep)
        switch CYJRECBuildHelper.default.buildStep {
        case .cached(let indexPath):
            if self.recordParam.type == 2 {
                NotificationCenter.default.post(name: CYJNotificationName.recordChanged, object: indexPath)
            }else
            {
                NotificationCenter.default.post(name: CYJNotificationName.recordChanged, object: "cached")
            }
        case .published(let indexPath):
            if self.recordParam.type == 2 {
                NotificationCenter.default.post(name: CYJNotificationName.recordChanged, object: indexPath)
            }
        default :
            NotificationCenter.default.post(name: CYJNotificationName.recordChanged, object: nil)
        }
        
        self.navigationController?.dismiss(animated: true, completion: {})
    }
}
// MARK: - UI extension
extension CYJRECBuildScoreViewController {
    
    func makeSegmentView() {
        
        var titles = [String]()
        var status = [Int]()
        
        self.children.forEach {(children) in
            titles.append(children.childrenName!)
            status.append(children.selectCount!)
        }
         let color = UIColor.init(red: 246/255.0, green: 76/255.0, blue: 128/255.0, alpha: 1)
        // 滚动条
        segView = CustomScrollSegmentView(frame: CGRect(x: 0, y: Theme.Measure.navigationBarHeight, width: view.frame.width, height: headerHeight), titles : titles , statues : status, images: images)
        segView.backgroundColor = color
        view.addSubview(segmentView)
        
       
        
        //自定导航栏
        let navigationBarView = UIView()
        navigationBarView.backgroundColor = color
        view.addSubview(navigationBarView)
        
        navigationBarView.snp.makeConstraints { (make) in
            make.top.equalTo(view).offset(0)
            make.height.equalTo(Theme.Measure.navigationBarHeight)
            make.width.equalTo(Theme.Measure.screenWidth)
            make.left.equalTo(view).offset(0)
        }
        let backButton = UIButton(type: .custom)
        //        backButton.setTitle("关闭", for: .normal)
        //        backButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 12)
        backButton.setBackgroundImage(#imageLiteral(resourceName: "icon_white_arrow"), for: .normal)
        backButton.addTarget(self, action: #selector(backAction), for: UIControlEvents.touchUpInside)
        navigationBarView.addSubview(backButton)
        
        backButton.snp.makeConstraints { (make) in
            make.left.equalTo(navigationBarView).offset(15)
            make.height.equalTo(17)
            make.width.equalTo(10)
            make.bottom.equalTo(navigationBarView).offset(-12)
        }
        
        let titleLab = UILabel()
        titleLab.text = "评分评价"
        titleLab.font = UIFont.boldSystemFont(ofSize: 18)
        titleLab.textColor = UIColor.white
        navigationBarView.addSubview(titleLab)
        titleLab.snp.makeConstraints { (make) in
            make.centerX.equalTo(navigationBarView).offset(0)
            make.bottom.equalTo(navigationBarView).offset(-12)
        }
        
        
 
        
        //监听向上还是向下滑动
        NotificationCenter.default.addObserver(self, selector: #selector(dropView), name: NSNotification.Name(rawValue:"dropScrollerView"), object: nil)
        
    }
    func backAction() {
        self.navigationController?.popViewController(animated: true)
    }
    func makeActionsView() {
        buttonActionView = UIView(frame: CGRect(x: 0, y: view.frame.height - 44, width: view.frame.width, height: 44))
        view.addSubview(buttonActionView)
        
        let lastButton = UIButton(frame: CGRect(x: 0, y: 0, width: buttonActionView.frame.width  * 0.6 * 0.5 - 0.5, height: 44))
        lastButton.theme_setTitleColor(Theme.Color.textColorlight, forState: .normal)
        lastButton.theme_backgroundColor = Theme.Color.ground
        lastButton.setTitle("去描述", for: .normal)
        lastButton.titleLabel?.font = UIFont.systemFont(ofSize: 15)
        lastButton.addTarget(self, action: #selector(lastREC), for: .touchUpInside)
        buttonActionView.addSubview(lastButton)
        
        let lineLab = UILabel(frame: CGRect(x: buttonActionView.frame.width  * 0.6 * 0.5, y:0, width: 0.5, height: 44))
        lineLab.theme_backgroundColor = Theme.Color.viewLightColor
        buttonActionView.addSubview(lineLab)
        
        let saveButton = UIButton(frame: CGRect(x: 0.5 + buttonActionView.frame.width  * 0.6 * 0.5, y: 0, width: buttonActionView.frame.width  * 0.6 * 0.5, height: 44))
        saveButton.theme_setTitleColor(Theme.Color.textColorlight, forState: .normal)
        saveButton.theme_backgroundColor = Theme.Color.ground
        saveButton.setTitle("暂存", for: .normal)
        saveButton.titleLabel?.font = UIFont.systemFont(ofSize: 15)
        saveButton.addTarget(self, action: #selector(saveREC), for: .touchUpInside)
        buttonActionView.addSubview(saveButton)
        let nextButton = UIButton(frame: CGRect(x: buttonActionView.frame.width  * 0.6, y: 0, width: buttonActionView.frame.width  * 0.4, height: 44))
        nextButton.theme_setTitleColor(Theme.Color.ground, forState: .normal)
        nextButton.theme_backgroundColor = Theme.Color.main
        nextButton.setTitle("提交并完成该记录", for: .normal)
        nextButton.titleLabel?.font = UIFont.systemFont(ofSize: 15)
        nextButton.addTarget(self, action: #selector(nextREC), for: .touchUpInside)
        buttonActionView.addSubview(nextButton)
        
        let lineView = UIView(frame: CGRect(x: 0, y: -1, width: buttonActionView.frame.width  * 0.6 * 0.5 * 2, height: 1))
        lineView.theme_backgroundColor = Theme.Color.viewLightColor
        buttonActionView.addSubview(lineView)
    }
    func dropView(info:NSNotification)  {
        print(info.object ?? 0)
        
        //向上、向下方向: 0 初始展开状态  1收缩折叠状态
        if info.object as! Int == 1  {
            UIView.animate(withDuration: 0.2) {
                //列表视图y轴向上移动headerHeight 高度增加headerHeight
                self.contentView.frame = CGRect(x: 0, y: Theme.Measure.navigationBarHeight, width: self.view.frame.width, height: self.view.frame.height - Theme.Measure.navigationBarHeight - 44)
                
                //头像滚动列表视图y轴向上移动headerHeight
                self.segView.frame = CGRect(x: 0, y: Theme.Measure.navigationBarHeight - self.headerHeight, width: self.view.frame.width, height: self.headerHeight)
            }
        }else{
            UIView.animate(withDuration: 0.2) {
                //复位
                self.contentView.frame = self.oldFrame
                self.segView.frame = CGRect(x: 0, y: Theme.Measure.navigationBarHeight , width: self.view.frame.width, height: self.headerHeight)
            }
        }
    }
    
    
    /// 创建 主要内容的视图
    func makeContentView() {
        
        contentView = ContentView(frame: CGRect(x: 0, y: Theme.Measure.navigationBarHeight + headerHeight, width: view.frame.width, height: view.frame.height - (Theme.Measure.navigationBarHeight + 1 + headerHeight + 44)), childVcs: setChildVcs(), parentViewController: self)
        contentView.delegate = self
        // 避免循环引用
        segView.titleBtnOnClick = {[unowned self] (label: UILabel, index: Int) in
            // 切换内容显示(update content)
            UIApplication.shared.keyWindow?.endEditing(true)
            self.contentView.setContentOffSet(CGPoint(x: self.contentView.bounds.size.width * CGFloat(index), y: 0), animated: true)
        }
        contentView.backgroundColor =  UIColor.white
        self.oldFrame = contentView.frame
        view.addSubview(contentView)
        
       view.bringSubview(toFront: buttonActionView)
        
    }
    
    
    /// swiperView 必须实现的
    func setChildVcs() -> [UIViewController] {
        
        var childVCs: [UIViewController] = []
        
        for i in 0..<children.count {
            
            let vc = CYJRECBuildScoreContainerController()
            vc.delegate = self
            
            vc.title = children[i].childrenName
            vc.childIndex = i
            vc.allDomains = self.allDomains
            vc.view.frame = CGRect(x: 0, y: 8, width: Theme.Measure.screenWidth, height: Theme.Measure.screenHeight - Theme.Measure.navigationBarHeight - 50 - 44)
            childVCs.append(vc)
            listVCs.append(vc)
        }
        
        self.contentViewControllers = childVCs as! [CYJRECBuildScoreContainerController]
        return childVCs
    }
}

// MARK: - 数据请求
extension CYJRECBuildScoreViewController {
    
    /// 请求评价信息
    func requestStudentDataFromServer() {
//        Third.toast.show { }
        RequestManager.POST(urlString: APIManager.Record.student, params: ["token" : LocaleSetting.token, "grId": "\(self.recordParam.grId)"]) { [unowned self] (data, error) in
            //如果存在error
            guard error == nil else {
//                Third.toast.hide {}
                Third.toast.message((error?.localizedDescription)!)
                return
            }
            if let evaluates = data as? NSArray {
                //遍历，并赋值
                var tmpEvaluates = [CYJRecordEvaluate]()
                evaluates.forEach({
                    let target = JSONDeserializer<CYJRecordEvaluate>.deserializeFrom(dict: $0 as? NSDictionary)
                    tmpEvaluates.append(target!)
                })
                //TODO: second 请求评价信息后，将评价信息放到参数里面
                
                self.recordParam.getValues(evaluates: tmpEvaluates)
                
                //TODO: third 请求评价信息后，创建当前界面的数据并刷新出来，
                self.makeSegmentView()
                
                self.fetchDominsFromServer()
                
//                Third.toast.hide {}
            }
        }
    }
    /// 请求所用的domain
    func fetchDominsFromServer() {
        
        let domainParam: [String: Any] = [
            "level": "4",
            "year" :  "2017",
            "semester" : "1",
            "grade" : "1",
            "token" : LocaleSetting.token ]
        
        RequestManager.POST(urlString: APIManager.Record.tree, params: domainParam ) { [unowned self] (data, error) in
            //如果存在error
            guard error == nil else {
                Third.toast.message((error?.localizedDescription)!)
                return
            }
            if let fields = data as? NSArray {
                //遍历，并赋值
                var tmp = [CYJDomain]()
                fields.forEach({
                    let target = JSONDeserializer<CYJDomain>.deserializeFrom(dict: $0 as? NSDictionary)
                    tmp.append(target!)
                    
                })
                self.allDomains = tmp
                
                self.makeContentView()
//                Third.toast.hide {
//
//                }
            }
        }
    }
    
    
    /// 上传对象到Object      需要与 self.recordParam.type 配对使用
    
    func uploadObjectToServer(_ finish: Int) {
        let paramter = self.recordParam.encodeToDictionary()
        
        //        self.alertShare()
        //        return
        //        self.actionView.makeButtonDisabled()
        
        RequestManager.POST(urlString: APIManager.Record.edit, params: paramter) { [unowned self] (data, error) in
            //            self.actionView.makeButtonEnabled()
            //如果存在error
            guard error == nil else {
                Third.toast.message((error?.localizedDescription)!)
                return
            }
            //改变LocaleSetting的状态，用以需要的地方刷新页面使用
            //            LocaleSetting.share.recordChanged = true
            
            
            if finish == 0 {
                Third.toast.message("暂存成功")
                self.navigationController?.popViewController(animated: true)
            }else if finish == 1{
                Third.toast.message("暂存成功")
            }else if finish == 2 {
                // 更新状态到发布
                
                if self.recordParam.type == 2 {
                    //TODO: 4⃣️ 执行的操作是最后的提交，分享的话
                    CYJRECBuildHelper.default.buildStep.publish()
                    
                    self.shareRecordToParent(uid: self.sharedUIds)
                    
                }else {
                    //TODO: 4⃣️ 保存成功之后，弹出一个alert，让用户选择是否分享
                    DispatchQueue.main.async { [unowned self] in
                        self.alertShare()
                    }
                }
            }
        }
    }
    
    /// 分享给家长
    ///
    /// - Parameter uid: <#uid description#>
    func shareRecordToParent(uid: [Int]) {
        
        if uid.count > 0 {
            // 有哦孩子，去分享
            let paramter: [String : Any] = ["token" : LocaleSetting.token, "uId" : uid, "grId" : "\(self.recordParam.grId)"]
            
            RequestManager.POST(urlString: APIManager.Record.share, params: paramter) { [unowned self] (data, error) in
                //如果存在error
                guard error == nil else {
                    Third.toast.message((error?.localizedDescription)!)
                    return
                }
                
                Third.toast.message("提交成功", hide: {
                    DispatchQueue.main.async { [unowned self] in
                        //TODO: 6⃣️ 分享成功后，销毁页面
                        self.recordParam.type = 2
                        self.dismissSelfNavigationController()
                        
                    }
                })
            }
            
        }else {
            // 否则，直接让界面消失
            self.dismissSelfNavigationController()
        }
    }
    
    
}

//MARK: Actions
extension CYJRECBuildScoreViewController {
    
    func lastREC() {
        getlIds()
        //暂存时，要上传
        self.recordParam.type = 1
        uploadObjectToServer(0)
        
        navigationController?.popViewController(animated: true)
    }
    
    /// 暂存，
    func saveREC() {
        
        getlIds()
        //暂存时，要上传
        self.recordParam.type = 1
        uploadObjectToServer(1)
    }
    
    /// 下一步 -- 完成，上传到服务器
    func nextREC() {
        
        getlIds()
        //TODO: 1⃣️ 遍历，查看所有孩子的 描述，如果有没填的，弹出第一个alert
        let unContent = self.recordParam.info.filter { (evaluate) -> Bool in
            if evaluate.content == nil {
                return true
            }
            if (evaluate.content?.isEmpty)! {
                return true
            }
            return false
        }
        if unContent.count > 0 {
            let alert = CYJRECBuildAlertController()
            
            alert.completeHandler = { [unowned self] in
                print("CYJRECBuildAlertController sure -- continue upload")
                //TODO: 2⃣️ 如果继续的话，那么，提交 -- ⚠️此时继续执行暂存的操作
                self.recordParam.type = 1
                self.uploadObjectToServer(2)
            }
            alert.showAlert()
            return
        }
        
        //TODO: 1⃣️ 遍历，查看所有孩子的 评分，如果有没填的，弹出第一个alert
        let unEvaluate = self.recordParam.info.filter { $0.lId.count == 0}
        if unEvaluate.count > 0 {
            let alert = CYJRECBuildAlertController()
            
            alert.completeHandler = { [unowned self] in
                print("CYJRECBuildAlertController sure -- continue upload")
                //TODO: 2⃣️ 如果继续的话，那么，提交 -- ⚠️此时继续执行暂存的操作
                self.recordParam.type = 1
                self.uploadObjectToServer(2)
            }
            alert.showAlert()
            return
        }
        
        //不弹一的话，直接弹2？
        
        self.recordParam.type = 1
        self.uploadObjectToServer(2)
        
    }
    
    /// 拿到lId数据，放到
    func getlIds() {
        //TODO: 0⃣️ 把选中的level 从数据中取出来
        self.contentViewControllers.forEach { (container) in
            var lids = [String]()
            container.firstViewController.selectedNodes.forEach({
                lids.append($0.ext!["lId"]!)
            })
            
            let evaluate = self.recordParam.info[container.childIndex]
            evaluate.lId = lids
        }
    }
    
    func alertShare() {
        
        let alert = CYJRECSharedAlertController()
        alert.children = self.recordParam.info
        alert.completeHandler = {[unowned self] in
            print("CYJRECBuildAlertController sure -- continue upload")
            //先把alert 消化掉？
            alert.dismiss(animated: false, completion: nil)
            //TODO: 5⃣️ 如果回调的数据存在，那么分享，否则什么也不做
            self.sharedUIds = $0
            self.recordParam.type = 2
            self.uploadObjectToServer(2)
        }
        
        alert.modalPresentationStyle = .overCurrentContext
        alert.modalTransitionStyle = .crossDissolve
        self.navigationController?.present(alert, animated: true, completion: nil)
    }
}

extension CYJRECBuildScoreViewController: ContentViewDelegate
{
    var segmentView: ScrollSegmentBase
    {
        return segView
    }
    
    func contentViewMoveToIndex(_ fromIndex: Int, toIndex: Int, progress: CGFloat) {
        UIApplication.shared.keyWindow?.endEditing(true)
    }
}
extension CYJRECBuildScoreViewController: CYJRECBuildSubViewChangeDelegate {
    
    func subViewChanged(index: Int, highlight: Bool) {
        //        segView.hightlightLabel(index: index, highlight: highlight)
    }
}



