//
//  QuestionnaireViewController.swift
//  ZiPingSwift
//
//  Created by 番茄 on 7/20/18.
//  Copyright © 2018 Chinayoujiao. All rights reserved.
//

import UIKit
import SwiftTheme
import HandyJSON

class ValuationStatuModel: CYJBaseModel {
    var groupId         : Int = 0 //当前身份，1=园长，2=教师，3=家长
    var status          : Int? // 前状态，0=未开始，1=进行中，2=己结束，3=己毕业
    var title           : String?     //标题
    var historyid       : Int = 0
    var isfinish        : Int?  //  是否提交试卷（1=是，0=否（可能从没做过，也可以是没做完））
    var shijuanid       : Int = 0  //当前标题（state=1时，这里为试卷的标题，否则为对应的状态说明标题）
    var remarks         : String?  //备注提示
    var testStatistics  : NSDictionary? //统计情况 groupId=2时使用，（overComplete=己完成，overStart=己开始，overNoStart=未开始）
    var testTime        : NSArray? //测评时间清单(state=4时，显示这对应数据)
}


class QuestionnaireViewController: KYBaseViewController {
    
    var scrollPageView: ScrollPageView!
    var uid: Int = 0
    var statue :Int = Int()
    var valuatuinStatue : ValuationStatuModel?
    var style : SegmentStyle!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        view.theme_backgroundColor = Theme.Color.ground
        // 这个是必要的设置
        automaticallyAdjustsScrollViewInsets = false
        //        hidesBottomBarWhenPushed = true
        // 滚动条
        style = SegmentStyle()
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
        
      
        //更新界面请求数据
        requestData()
        NotificationCenter.default.addObserver(self, selector: #selector(reloadQuestionnaireViewStatue), name:
            NSNotification.Name("QuestionnaireViewStatue"), object: nil)
        //更新HistoryID
        NotificationCenter.default.addObserver(self, selector: #selector(reloadHistoryID), name: NSNotification.Name("ReloadHistoryID"), object: nil)
        
    }
   
    //刷新页面
    func reloadQuestionnaireViewStatue()  {
        if (self.scrollPageView != nil) {
            self.scrollPageView.removeFromSuperview()
            self.scrollPageView = nil
        }
        requestData()
    }
    func reloadHistoryID(notify :Notification)  {
        print(notify)
        self.valuatuinStatue?.historyid = Int(notify.object as! String)!
    }
    
    
    func requestData(){
        //请求数据查看是否完成
        RequestManager.POST(urlString: APIManager.Valuation.check, params: nil, complete: { [weak self] (data, error) in
            
            guard error == nil else {
                Third.toast.message((error?.localizedDescription)!)
                return
            }
            
            
            if let datas = data as? NSDictionary {
                //遍历，并赋值
                let target = JSONDeserializer<ValuationStatuModel>.deserializeFrom(dict: datas )
                self?.valuatuinStatue = target
                
                self?.scrollPageView = ScrollPageView(frame: CGRect(x: 0, y: Theme.Measure.navigationBarHeight, width: (self?.view.frame.width)!, height: Theme.Measure.screenHeight - Theme.Measure.navigationBarHeight), segmentStyle: (self?.style)!, titles: ["问卷测评", "教师测评结果"], childVcs: (self?.setChildVcs())!, parentViewController: self!)
                
                self?.view.addSubview((self?.scrollPageView)!)
            }
        })
    }
    
    
    /// swiperView 必须实现的
    func setChildVcs() -> [UIViewController] {
        var status : Int = 0
        
        if self.valuatuinStatue?.isfinish == 1 {//未daxie完成问卷
            status = 4
        }else{
            
            if self.valuatuinStatue?.status == 1 {
                if self.valuatuinStatue?.shijuanid == 0 {
                    status = 5
                }else{
                    status = (self.valuatuinStatue?.status)!
                }
            }else {
                status = (self.valuatuinStatue?.status)!
            }
        }
        
        var childVCs: [UIViewController] = []
        switch status {
        case 0:
            //  问卷测评 未开始
            let vc4 = ValuationNoStartViewController()
            vc4.view.backgroundColor = UIColor.white
            vc4.view.frame = CGRect(x: 0, y: 0.5, width: Theme.Measure.screenWidth, height: Theme.Measure.screenHeight - Theme.Measure.navigationBarHeight)
            vc4.valuationStatueInfo = self.valuatuinStatue!
            childVCs.append(vc4)
        case 1:
            //  问卷测评  进行中
            let vc1 = QuestionnaireIngViewController()
            vc1.view.backgroundColor = UIColor.white
            vc1.view.frame = CGRect(x: 0, y: 0.5, width: Theme.Measure.screenWidth, height: Theme.Measure.screenHeight - Theme.Measure.navigationBarHeight)
            vc1.valuationStatueInfo = self.valuatuinStatue!
            childVCs.append(vc1)
        case 2://  问卷测评  已结束
            let vc2 = QuestionnaireEndViewController()
            vc2.view.backgroundColor = UIColor.white
            vc2.view.frame = CGRect(x: 0, y: 0.5, width: Theme.Measure.screenWidth, height: Theme.Measure.screenHeight - Theme.Measure.navigationBarHeight)
            vc2.valuationStatueInfo = self.valuatuinStatue!
            childVCs.append(vc2)
        case 3:
            //  问卷测评  已毕业
            let vc5 = GraduationViewController()
            vc5.view.backgroundColor = UIColor.white
            vc5.view.frame = CGRect(x: 0, y: 0.5, width: Theme.Measure.screenWidth, height: Theme.Measure.screenHeight - Theme.Measure.navigationBarHeight)
            childVCs.append(vc5)
        case 4:
            //  问卷测评  已完成
            let vc3 = QuestionnComplentViewController()
            vc3.view.backgroundColor = UIColor.white
            vc3.view.frame = CGRect(x: 0, y: 0.5, width: Theme.Measure.screenWidth, height: Theme.Measure.screenHeight - Theme.Measure.navigationBarHeight)
            vc3.valuationStatueInfo = self.valuatuinStatue!
            childVCs.append(vc3)
        case 5:
            //  本年级暂不参与集中测评哦~
            let vc5 = NoPartakeViewController()
            vc5.view.backgroundColor = UIColor.white
            vc5.view.frame = CGRect(x: 0, y: 0.5, width: Theme.Measure.screenWidth, height: Theme.Measure.screenHeight - Theme.Measure.navigationBarHeight)
            vc5.titleLab.text = "本年级暂不参与集中测评哦~"
            childVCs.append(vc5)
            
        default:
            //  空白
            let vc = UIViewController()
            vc.view.backgroundColor = UIColor.white
            vc.view.frame = CGRect(x: 0, y: 0.5, width: Theme.Measure.screenWidth, height: Theme.Measure.screenHeight - Theme.Measure.navigationBarHeight)
            childVCs.append(vc)
        }
        //教师测评结果
        let vc = ValuationResultViewController();
        vc.view.backgroundColor = UIColor.white
        vc.userID = String(format: "%d", (LocaleSetting.userInfo()?.uId)!)
        vc.view.frame = CGRect(x: 0, y: 0.5, width: Theme.Measure.screenWidth, height: Theme.Measure.screenHeight - Theme.Measure.navigationBarHeight)
        childVCs.append(vc)
        return childVCs
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
}
