//
//  CYJRECSharedAlertController.swift
//  ZiPingSwift
//
//  Created by kyang on 2017/9/27.
//  Copyright © 2017年 Chinayoujiao. All rights reserved.
//

import UIKit

class CYJRECSharedAlertController: UIViewController {

    
    var containerView: UIView!
    
    lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 5
        label.lineBreakMode = .byWordWrapping
        label.theme_textColor = Theme.Color.textColorDark
        label.font = UIFont.systemFont(ofSize: 15)
        label.numberOfLines = 0
        label.text = "是否要将本条记录分享给以下幼儿的家长，如不分享则家长看不到"
        
        return label
    }()
    
    lazy var firstButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setTitle("再看看", for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 12)
        button.addTarget(self, action: #selector(firstClickAction(_:)), for: .touchUpInside)
        button.theme_setTitleColor(Theme.Color.textColorlight, forState: .normal)
        button.theme_backgroundColor =  Theme.Color.viewLightColor
        button.layer.cornerRadius = 15
        button.layer.borderWidth = 0.5
        button.layer.borderColor = UIColor.lightGray.cgColor
        return button
    }()
    
    lazy var secondButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setTitle("提交", for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 12)
        button.addTarget(self, action: #selector(secondClickAction(_:)), for: .touchUpInside)
        button.theme_backgroundColor = "Nav.barTintColor"
        button.setTitleColor(UIColor.white, for: UIControlState.normal)
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
    lazy var lineView: UIView = {
        let view = UIView()
        view.theme_backgroundColor = Theme.Color.line
        return view
    }()
    
    lazy var extLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 5
        label.lineBreakMode = .byWordWrapping
        label.theme_textColor = Theme.Color.textColorlight
        label.font = UIFont.systemFont(ofSize: 10)
        label.text = "注：提交后即不可进行修改操作,已勾选后即默认为分享。"
        return label
    }()
    
    var children: [CYJNewRECParam.ChildEvaluate] = []
    var completeHandler: ((_ uids: [Int])->Void)!

    func showAlert() {
        
        self.modalPresentationStyle = .overCurrentContext
        self.modalTransitionStyle = .crossDissolve
         UIApplication.shared.keyWindow?.topMostWindowController()?.present(self, animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        view.backgroundColor = UIColor(white: 0, alpha: 0.3)

        var size = CGSize(width: 300, height: 365 - 150)
        containerView = UIView(frame: CGRect.zero)
        
        containerView.backgroundColor = UIColor.white
        containerView.layer.cornerRadius = 10
        
        view.addSubview(containerView)

        titleLabel.frame = CGRect(x: 31, y: 34, width: size.width - 2 * 31, height: 40)
        
        containerView.addSubview(titleLabel)
        
        for i in 0..<children.count {
            let button = UIButton(type: .custom)
            button.setTitle("\(children[i].name ?? "幼儿")-家长", for: .normal)
            button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 12)
            button.theme_setTitleColor(Theme.Color.textColorlight, forState: .normal)
            button.theme_setTitleColor(Theme.Color.main, forState: .selected)

            button.layer.cornerRadius = 5
            button.layer.borderWidth = 0.5
            
            button.tag = kButtonTag + i
            button.addTarget(self, action: #selector(selectAction(_:)), for: .touchUpInside)
            
            button.frame = CGRect(x: 50 + (85 + 30) * CGFloat(i % 2), y: 94 + (15 + 32) * CGFloat(i / 2), width: 85, height: 32)
            
            containerView.addSubview(button)
            
            // 全部默认选中
            button.layer.theme_borderColor = "Nav.barTintColor"
            button.isSelected = true
            selectedArr.append(i)
        }
        
        let buttonHeight = children.count > 0 ? CGFloat(25 + 47 * (children.count / 2 + 1)) : 0
        size.height = size.height + buttonHeight
        
        //设置contentVIew的frame
        let point = CGPoint(x: (view.frame.width - size.width) * 0.5, y: (view.frame.height - size.height) * 0.5)

        containerView.frame = CGRect(origin: point, size: size)
        

        
        extLabel.frame = CGRect(x: 30, y: 65 + buttonHeight, width: size.width - 60, height: 45)
        containerView.addSubview(extLabel)
        
        lineView.frame = CGRect(x: 15, y: extLabel.frame.maxY + 5 , width: size.width - 30, height: 0.5)
        containerView.addSubview(lineView)
        
        firstButton.frame = CGRect(x: 50, y: size.height - 32 - 30, width: 85, height: 32)
        secondButton.frame = CGRect(x: 165, y: size.height - 32 - 30, width: 85, height: 32)
        
        containerView.addSubview(firstButton)
        containerView.addSubview(secondButton)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    func selectAction(_ sender: UIButton)  {
        
        if let contains = selectedArr.index(of: sender.tag - kButtonTag) {
            selectedArr.remove(at: contains)
            sender.isSelected = false
            sender.layer.theme_borderColor = "Global.textColorLight"

        }else
        {
            selectedArr.append(sender.tag - kButtonTag)
            sender.isSelected = true
            sender.layer.theme_borderColor = "Nav.barTintColor"
        }
    }

    func firstClickAction(_ sender: UIButton) {
        
        self.dismiss(animated: true, completion: nil)
        //取消的话，回调一个空数组
//        completeHandler([])
    }
    func secondClickAction(_ sender: UIButton) {
        
        let users = selectedArr.map {[unowned self] (tag) -> Int in
            let evaluate = self.children[tag]
            return evaluate.bId
        }
        completeHandler(users)
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
