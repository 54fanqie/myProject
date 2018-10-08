//
//  RecordAlertController.swift
//  ZiPingSwift
//
//  Created by fanqie on 2018/9/22.
//  Copyright © 2018年 Chinayoujiao. All rights reserved.
//

import UIKit

class RecordAlertController: UIViewController {

    
     var message : String!
    
//    var containerView : UIImageView = {
//        let imageView = UIImageView()
////        imageVI.image = #imageLiteral(resourceName: "tc-zb-icon")
//        imageView.layer.cornerRadius = 10
//        imageView.backgroundColor = UIColor.white
//        return imageView
//    }()
    
    var containerView : UIView = {
        let ibackview = UIView()
        ibackview.layer.cornerRadius = 10
        ibackview.backgroundColor = UIColor.white
        return ibackview
    }()
   
    lazy var logImagevIew: UIImageView = {
        let imageVI = UIImageView()
        imageVI.image = #imageLiteral(resourceName: "tc-zb-icon")
        return imageVI
    }()
    lazy var juliLabel: UILabel = {
        let label = UILabel()
        label.lineBreakMode = .byWordWrapping
        label.textAlignment = NSTextAlignment.left
        label.textColor = UIColor(hex: "E47913", alpha: 1)
        label.font = UIFont.systemFont(ofSize: 14)
        label.text = "指标举例"
        return label
    }()
    
    //关闭
    lazy var closeButton: UIButton = {
        let button = UIButton(type: .custom)
        button.addTarget(self, action: #selector(firstClickAction(_:) ), for: .touchUpInside)
        button.setImage(#imageLiteral(resourceName: "tc-icon"), for: UIControlState())
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
    
    
    lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        label.textAlignment = NSTextAlignment.left
        label.theme_textColor = Theme.Color.textColorDark
        label.font = UIFont.systemFont(ofSize: 14)
        label.text = "指标1的指导策略，指导策略内容，指导策略的内容不是很多吧，看我我就是指导策略。指标1的指导策略，指导策略内容，指导策略的内容不"
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
        view.addSubview(containerView)
        containerView.addSubview(logImagevIew)
        containerView.addSubview(juliLabel)
        containerView.addSubview(titleLabel)
        containerView.addSubview(closeButton)
        
        
        //计算位置
        let popViewWidth = Theme.Measure.screenWidth - 30
        
        logImagevIew.frame = CGRect(x: 15 , y: 15, width: 16, height: 16)
        juliLabel.frame = CGRect(x: 15 + 16 + 7, y: 15, width: 60, height: 16)
        closeButton.frame = CGRect(x: popViewWidth - 30 - 10 , y: 14, width: 30, height: 30)
        closeButton.center.y = logImagevIew.center.y
        
        
        // 计算文字尺寸
        let contentsize = (message as NSString).boundingRect(with: CGSize(width: popViewWidth - 30, height: 0.0), options: .usesLineFragmentOrigin, attributes: [NSFontAttributeName: titleLabel.font], context: nil)
        //文本大小
        titleLabel.frame = CGRect(x: 15, y: 46, width: popViewWidth - 30, height: contentsize.height)
        titleLabel.text = message
        
        let size = CGSize(width: popViewWidth , height: contentsize.height  + 46 + 30)
        let point = CGPoint(x: (view.frame.width - size.width) * 0.5, y: (view.frame.height - size.height) * 0.5)
        containerView.frame = CGRect(origin: point, size: size)
        containerView.center.x = view.center.x
        containerView.center.y = view.center.y
        
    
        
        
        
        let tapGes = UITapGestureRecognizer(target: self, action: #selector(self.titleLabelOnClick(_:)))
        view.addGestureRecognizer(tapGes)
        
    }
    func titleLabelOnClick(_ tapGes: UITapGestureRecognizer) {
        self.dismiss(animated: true, completion: nil)
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
