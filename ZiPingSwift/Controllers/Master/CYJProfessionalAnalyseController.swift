//
//  CYJProfessionalAnalyseController.swift
//  ZiPingSwift
//
//  Created by kyang on 2017/10/13.
//  Copyright © 2017年 Chinayoujiao. All rights reserved.
//

import UIKit
import HandyJSON
class CYJProfessionalAnalyseController: KYBaseViewController {
    
    @IBOutlet weak var label1: UILabel!
    
    @IBOutlet weak var label2: UILabel!
    
    @IBOutlet weak var textField: UITextField!
    
    @IBOutlet weak var uploadButton: UIButton!
    var isValuation : Bool = false
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        title = "申请专业分析"
        
        label1.theme_textColor = Theme.Color.textColorDark
        label2.theme_textColor = Theme.Color.textColorlight
        
//        uploadButton.theme_setTitleColor(Theme.Color.main, forState: .normal)
        
        uploadButton.layer.cornerRadius = 20
        uploadButton.layer.borderWidth = 0.5
        uploadButton.layer.theme_borderColor = "Nav.barTintColor"
        
        
    }
    
    @IBAction func uploadAction(_ sender: Any) {
        
       
        guard let email = textField.text else {
            Third.toast.message("请填写正确的邮箱格式")
            return
        }
        guard email.isVaildEmail else {
            Third.toast.message("请填写正确的邮箱格式")
            return
        }
        Third.toast.show {
            
        }
        
        //集中测评分析申请
        if isValuation == true{
            RequestManager.POST(urlString: APIManager.Valuation.teacherApplyReport, params: nil ,callBackAll : true) { [] (data, error) in
                guard error == nil else {
                    Third.toast.message((error?.localizedDescription)!)
                    return
                }
                let custom = JSONDeserializer<CustomResponds>.deserializeFrom(dict: data as? NSDictionary)
                if custom?.status == 200 {
                    Third.toast.hide {
                        
                    }
                    let alert = ValuationAlertController()
                    alert.message = custom?.message
                    alert.completeHandler = { [] in
                        alert.dismiss(animated:true, completion: nil)
                    }
                    alert.showAlert()
                }else{
                    Third.toast.message((custom?.message)!)
                }
                
               
            }
        }else{
            //其他申请
            RequestManager.POST(urlString: APIManager.Tongji.analPro, params: ["token": LocaleSetting.token, "email": email]) { [unowned self] (data, error) in
                //如果存在error
                Third.toast.hide {
                    
                }
                guard error == nil else {
                    Third.toast.message((error?.localizedDescription)!)
                    return
                }
                let alert = UIAlertController(title: nil, message: "申请已提交成功，请耐心等待，注意查收", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "确定", style: .default, handler: { [unowned self] (action) in
                    self.navigationController?.popViewController(animated: true)
                }))
                
                self.present(alert, animated: true, completion: nil)
            }
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
