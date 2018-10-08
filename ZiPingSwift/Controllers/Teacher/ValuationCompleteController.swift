//
//  ValuationCompleteController.swift
//  ZiPingSwift
//
//  Created by 番茄 on 7/18/18.
//  Copyright © 2018 Chinayoujiao. All rights reserved.
//

import UIKit

class ValuationCompleteController: KYBaseViewController {
    
    @IBOutlet weak var topView: UIView!
    @IBOutlet weak var bigTitleLab: UILabel!
    @IBOutlet weak var scopetitleLab: UILabel!
    
    @IBOutlet weak var compentLab: UILabel!
    @IBOutlet weak var noCompentLab: UILabel!
    @IBOutlet weak var noStartLab: UILabel!
    
    var valuationStatuModel : ValuationStatuModel!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        let color = UIColor.init(red: 246/255.0, green: 76/255.0, blue: 128/255.0, alpha: 1)
        topView.backgroundColor = color
        self.title = "集中测评"
       
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        bigTitleLab.text = valuationStatuModel.title
        scopetitleLab.text = valuationStatuModel.remarks
        let dict  = valuationStatuModel.testStatistics

        compentLab.text = dict?["overComplete"] as? String
        noCompentLab.text = dict?["overStart"] as? String
        noStartLab.text = dict?["overNoStart"] as? String
    }
 
    @IBAction func backButtonAction(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
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
