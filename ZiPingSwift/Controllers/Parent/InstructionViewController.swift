//
//  InstructionViewController.swift
//  ZiPingSwift
//
//  Created by 番茄 on 7/24/18.
//  Copyright © 2018 Chinayoujiao. All rights reserved.
//

import UIKit

class InstructionViewController: KYBaseViewController {
    var shiJuanModel : ShiJuanModel!
    
    @IBOutlet weak var contentLab: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "问卷测评"
        // Do any additional setup after loading the view.
    
        contentLab.text = shiJuanModel.content
    }

  
    @IBAction func startQuestionnaireAction(_ sender: Any) {
        let muVC = MultipleChoiceController();
        muVC.shiJuanModel = shiJuanModel
        self.navigationController?.pushViewController(muVC, animated: true);
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
