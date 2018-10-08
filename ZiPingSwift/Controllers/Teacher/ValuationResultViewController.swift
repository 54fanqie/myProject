//
//  ValuationResultViewController.swift
//  ZiPingSwift
//
//  Created by 番茄 on 7/21/18.
//  Copyright © 2018 Chinayoujiao. All rights reserved.
//

import UIKit
import HandyJSON
class TeacherResult: CYJBaseModel {
    var shijuanid :String?
    var title : String?
    var historyid : String?
    var isfinish : String?
    var scoreTotal : String?
    var part1 : String?
    var part2 : String?
    var part3 : String?
    var part4 : String?
    var rangeTime : String?
}



class ValuationResultViewController: KYBaseViewController {
    
    var userID : String?
    var uploadButton: UIButton!
    var formView : ValuationResultView!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        formView = ValuationResultView(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: Theme.Measure.screenHeight - 64 ))
        view.addSubview(formView)
        
        if LocaleSetting.userInfo()?.role == .teacher {
            //            教师、园长申请生成报告
            uploadButton = UIButton(type: .custom)
            uploadButton.setTitle("向园长申请专业分析", for: .normal)
            uploadButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 12)
            uploadButton.addTarget(self, action: #selector(uploadAction), for: UIControlEvents.touchUpInside)
            uploadButton.setTitleColor(UIColor.white, for: UIControlState.normal)
            uploadButton.theme_backgroundColor = "Nav.barTintColor"
            uploadButton.layer.cornerRadius = 19
//            view.addSubview(uploadButton)
//            uploadButton.snp.makeConstraints { (make) in
//                make.centerX.equalTo(view).offset(0)
//                make.height.equalTo(40)
//                make.width.equalTo(172)
//                make.bottom.equalTo(view).offset(-20)
//            }  
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        print("申请测评结果: userID" + userID!)
        RequestManager.POST(urlString: APIManager.Valuation.teacherResult , params: ["userid" : userID!]) { [weak self] (data, error) in
            
            guard error == nil else {
                Third.toast.message((error?.localizedDescription)!)
                return
            }
            if let datas = data as? NSArray {
                var  resultList = [TeacherResult]()
                
                //遍历，并赋值
                datas.forEach({ [] in
                    let target = JSONDeserializer<TeacherResult>.deserializeFrom(dict: $0 as? NSDictionary)
                    resultList.append(target!)
                    
                })
                self?.formView.teacherResultList = resultList
            }
            
        }
    }
    
    
    func uploadAction() {
        
        var params = [String : Any]()
        var urlString : String!
        var titleMeasge : String?
        
        
        if LocaleSetting.userInfo()?.role == .child {//家长向园长申请生成报告
            
            urlString = APIManager.Valuation.applyReport
            params = ["historyid" : 1]
            titleMeasge = "集中测评专业分析申请已发送给园长，将由园长与平台沟通哦~"
        } else { //教师、园长申请生成报告
            titleMeasge = "集中测评专业分析申请已发送给园长，将由园长与平台沟通哦~"
            urlString = APIManager.Valuation.teacherApplyReport
        }
        
        RequestManager.POST(urlString: urlString, params: params ) { [weak self] (data, error) in
            guard error == nil else {
                Third.toast.message((error?.localizedDescription)!)
                return
            }
            
            let custom = JSONDeserializer<CustomResponds>.deserializeFrom(dict: data as? NSDictionary)
            if custom?.status == 200 {
                
            }else
            {
                
            }
            let alert = ValuationAlertController()
            if titleMeasge == nil {
                titleMeasge == custom?.message
            }
            alert.message = titleMeasge
            alert.completeHandler =  { [] in
                alert.dismiss(animated:true, completion: nil)
            }
            alert.showAlert()
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
