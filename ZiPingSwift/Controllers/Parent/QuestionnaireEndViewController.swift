//
//  QuestionnaireEndViewController.swift
//  ZiPingSwift
//
//  Created by 番茄 on 7/20/18.
//  Copyright © 2018 Chinayoujiao. All rights reserved.
//

import UIKit
import HandyJSON
class QuestionnaireEndViewController: KYBaseViewController {

    @IBOutlet weak var applyButton: UIButton!
    var valuationStatueInfo : ValuationStatuModel!
    override func viewDidLoad() {
        super.viewDidLoad()
        applyButton.layer.cornerRadius = 20
        applyButton.layer.masksToBounds = true
        applyButton.theme_backgroundColor = Theme.Color.main
        // Do any additional setup after loading the view.
    }
    //像园长申请分析报告
    @IBAction func applyforMaster(_ sender: Any) {
        RequestManager.POST(urlString: APIManager.Valuation.applyReport, params: ["historyid" : self.valuationStatueInfo.historyid, "shijuanid" :self.valuationStatueInfo.shijuanid],callBackAll : true) { [weak self] (data, error) in
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
