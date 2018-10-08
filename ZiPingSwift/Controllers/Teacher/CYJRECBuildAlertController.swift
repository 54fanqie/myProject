//
//  CYJRECBuildAlertController.swift
//  ZiPingSwift
//
//  Created by kyang on 2017/9/27.
//  Copyright © 2017年 Chinayoujiao. All rights reserved.
//

import UIKit

class CYJRECBuildAlertController: UIViewController {
    
    var containerView: UIView!
    
    lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 5
        label.lineBreakMode = .byWordWrapping
        label.theme_textColor = Theme.Color.textColorDark
        label.font = UIFont.systemFont(ofSize: 15)
        label.text = "还有幼儿的指标评分或评语建议未添加，是否继续添加。"
        return label
    }()
    
    lazy var firstButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setTitle("不添加", for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 12)
        button.addTarget(self, action: #selector(secondClickAction(_:)), for: .touchUpInside)
        button.theme_setTitleColor(Theme.Color.textColorlight, forState: .normal)
        button.theme_backgroundColor = Theme.Color.viewLightColor
        button.layer.theme_borderColor = "Global.textColorLight"
        button.layer.cornerRadius = 15
        button.layer.borderWidth = 0.5
        
        return button
    }()
    
    lazy var secondButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setTitle("添加", for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 12)
        button.addTarget(self, action: #selector(firstClickAction(_:) ), for: .touchUpInside)
        button.setTitleColor(UIColor.white, for: UIControlState.normal)
        button.theme_backgroundColor = "Nav.barTintColor"
        button.layer.cornerRadius = 15
        
        return button
    }()
    
    //MARK: 分享的界面用到的东西
    
    lazy var buttonsArray: [UIButton] = {
        return []
    }()
    let kButtonTag: Int = 12
    lazy var selectedArr: [Int] = {
        return []
    }()
    
    lazy var extLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 5
        label.lineBreakMode = .byWordWrapping
        label.theme_textColor = Theme.Color.textColorDark
        label.font = UIFont.systemFont(ofSize: 15)
        
        return label
    }()
    
    func showAlert() {
        
        self.modalPresentationStyle = .overCurrentContext
        self.modalTransitionStyle = .crossDissolve
        UIApplication.shared.keyWindow?.topMostWindowController()?.present(self, animated: true, completion: nil)
    }
    var completeHandler: (()->Void)!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        view.backgroundColor = UIColor(white: 0, alpha: 0.3)
        let size = CGSize(width: 300, height: 170)
        let point = CGPoint(x: (view.frame.width - size.width) * 0.5, y: (view.frame.height - size.height) * 0.5)
        containerView = UIView(frame: CGRect(origin: point, size: size))
        
        containerView.backgroundColor = UIColor.white
        containerView.layer.cornerRadius = 10
        view.addSubview(containerView)
        
        
        titleLabel.frame = CGRect(x: 31, y: 34, width: size.width - 2 * 31, height: 40)

        containerView.addSubview(titleLabel)
        
        firstButton.frame = CGRect(x: 50, y: size.height - 32 - 30, width: 85, height: 32)
        secondButton.frame = CGRect(x: 165, y: size.height - 32 - 30, width: 85, height: 32)
        
        containerView.addSubview(firstButton)
        containerView.addSubview(secondButton)
    }
    
    func firstClickAction(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    func secondClickAction(_ sender: UIButton) {
        completeHandler()
        self.dismiss(animated: true, completion: nil)
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
