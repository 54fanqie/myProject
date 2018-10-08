//
//  ValuationController.swift
//  ZiPingSwift
//
//  Created by 番茄 on 7/21/18.
//  Copyright © 2018 Chinayoujiao. All rights reserved.
//

import UIKit
import HandyJSON
class ValuationController: KYBaseViewController {
    var target : ValuationStatuModel!
    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = "集中测评"
        if target.status == 0 {
            if self.target.shijuanid == 0{
                self.target.status = 3
            }
        }else if target.status == 1 {
            //当本年级一个专项测评都没有完成时
            let s = self.target.testStatistics?.object(forKey: "overComplete") as! String
            if s.isEmpty {
                
            }else{
                self.view.theme_backgroundColor = "Nav.barTintColor"
            }
            
        }
        
        //根据请求的数据，显示是否状态
        goToVC(index: (target?.status)!, target: target!)
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.isNavigationBarHidden  = false
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if target.status == 1 {
            self.navigationController?.isNavigationBarHidden  = true
        }
    }

    func goToVC( index : Int,target : ValuationStatuModel)  {
        let statue = index
        switch statue {
        case 0://未开始
          
            let  noStartVC = ValuationNoStartViewController();
            noStartVC.view.frame = CGRect(x: 0, y: Theme.Measure.navigationBarHeight, width: Theme.Measure.screenWidth, height: Theme.Measure.screenHeight - Theme.Measure.navigationBarHeight)
            view.addSubview(noStartVC.view)
            noStartVC.valuationStatueInfo = target
            addChildViewController(noStartVC)
            
            
        case 1://进行中并完成
            let completeVC = ValuationCompleteController();
            completeVC.view.frame = CGRect(x: 0, y: Theme.Measure.navigationStatueBarHeight, width: Theme.Measure.screenWidth, height: Theme.Measure.screenHeight - Theme.Measure.navigationStatueBarHeight)
            //添加获取到的视图控制器的视图
            completeVC.valuationStatuModel = target
            view.addSubview(completeVC.view)
            addChildViewController(completeVC)
            
        case 2://已结束
            let  endVC = ValuationEndViewController();
            endVC.view.frame = CGRect(x: 0, y: 0, width: Theme.Measure.screenWidth, height: Theme.Measure.screenHeight - Theme.Measure.navigationBarHeight)
            view.addSubview(endVC.view)
            addChildViewController(endVC)
        case 3://本年级暂未参与集中测评哦~
            let  nopart = NoPartakeViewController();
            nopart.view.frame = CGRect(x: 0, y: 0, width: Theme.Measure.screenWidth, height: Theme.Measure.screenHeight - Theme.Measure.navigationBarHeight)
            view.addSubview(nopart.view)
            addChildViewController(nopart)
            
        default:
            let completeVC = ValuationCompleteController();
            completeVC.view.frame = CGRect(x: 0, y: Theme.Measure.navigationBarHeight, width: Theme.Measure.screenWidth, height: Theme.Measure.screenHeight - Theme.Measure.navigationBarHeight)
            view.addSubview(completeVC.view)
            addChildViewController(completeVC)
        }
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
