//
//  CYJRECCommentViewController.swift
//  ZiPingSwift
//
//  Created by kyang on 2017/8/30.
//  Copyright © 2017年 Chinayoujiao. All rights reserved.
//

import UIKit

class CYJRECCommentViewController: KYBaseViewController {

    
    lazy var seprateView: UIView = {
        let view = UIView()
        view.theme_backgroundColor = Theme.Color.ground
        return view
    }()
    lazy var scoreTitleLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 1
        label.theme_textColor = Theme.Color.textColorlight
        label.font = UIFont.systemFont(ofSize: 13)
        label.text = "综合评分"
        return label
    }()
    lazy var scoreLabel1: UILabel = {
        let label = UILabel()
        label.numberOfLines = 1
        label.theme_textColor = Theme.Color.textColorDark
        label.font = UIFont.systemFont(ofSize: 15)
        label.text = "描述客观清晰:"
        
        return label
    }()
    lazy var scoreLabel2: UILabel = {
        let label = UILabel()
        label.numberOfLines = 1
        label.theme_textColor = Theme.Color.textColorDark
        label.font = UIFont.systemFont(ofSize: 15)
        label.text = "描述全面细致:"
        
        return label
    }()
    lazy var scoreLabel3: UILabel = {
        let label = UILabel()
        label.numberOfLines = 1
        label.theme_textColor = Theme.Color.textColorDark
        label.font = UIFont.systemFont(ofSize: 15)
        label.text = "评价指标适宜:"
        
        return label
    }()
    lazy var scoreLabel4: UILabel = {
        let label = UILabel()
        label.numberOfLines = 1
        label.theme_textColor = Theme.Color.textColorDark
        label.font = UIFont.systemFont(ofSize: 15)
        label.text = "评价水平准确:"
        return label
    }()
    
    lazy var starView1: StarEvaluateView = {
        let halfStarView = StarEvaluateView(sumCount: 5, starSpace: 20, norImg: UIImage(named: "GoodsDetailCollection"), selImg: UIImage(named: "yellowStar"))
        halfStarView.hasShowHalfStar = false // 是否打开半星

        halfStarView.starCount = 5
        halfStarView.space = 4
        return halfStarView
    }()
    lazy var starView2: StarEvaluateView = {
        let halfStarView = StarEvaluateView(sumCount: 5, starSpace: 20, norImg: UIImage(named: "GoodsDetailCollection"), selImg: UIImage(named: "yellowStar"))
        halfStarView.hasShowHalfStar = false // 是否打开半星

        halfStarView.starCount = 5
        halfStarView.space = 4
        return halfStarView
    }()
    lazy var starView3: StarEvaluateView = {
        let halfStarView = StarEvaluateView(sumCount: 5, starSpace: 20, norImg: UIImage(named: "GoodsDetailCollection"), selImg: UIImage(named: "yellowStar"))
        halfStarView.starCount = 5
        halfStarView.space = 4
        halfStarView.hasShowHalfStar = false // 是否打开半星

        
        return halfStarView
    }()
    lazy var starView4: StarEvaluateView = {
        let halfStarView = StarEvaluateView(sumCount: 5, starSpace: 20, norImg: UIImage(named: "GoodsDetailCollection"), selImg: UIImage(named: "yellowStar"))
        halfStarView.hasShowHalfStar = false // 是否打开半星

        halfStarView.starCount = 5
        halfStarView.space = 4
        return halfStarView
    }()
    
    lazy var evaluateTitleLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 1
        label.theme_textColor = Theme.Color.textColor
        label.font = UIFont.systemFont(ofSize: 13)
        label.text = "综合评语"
        return label
    }()
    
    lazy var evaluateView: UITextView = {
        let textView = UITextView()
        textView.theme_textColor = Theme.Color.textColor
        textView.font = UIFont.systemFont(ofSize: 13)
        textView.layer.theme_borderColor = "Global.textColorLight"
        textView.layer.borderWidth = 0.5
        textView.layer.cornerRadius = 5
        return textView
    }()
    
    lazy var excellentButton: UIButton = {
        let button = UIButton(type: .custom)
        button.theme_setTitleColor(Theme.Color.textColorlight, forState: .normal)
        button.setTitle(" 设为优秀记录", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 13)
        button.addTarget(self, action: #selector(excellentButtonAction), for: .touchUpInside)

        button.setImage(#imageLiteral(resourceName: "icon_gray_circle_normal"), for: .normal)
        button.setImage(#imageLiteral(resourceName: "icon_red_circle_selected"), for: .selected)
        return button
    }()
    lazy var uploadButton: UIButton = {
        let button = UIButton(type: .custom)
        button.theme_setTitleColor("Nav.barTextColor", forState: .normal)
        button.setTitle("提交", for: .normal)
        button.addTarget(self, action: #selector(uploadButtonAction), for: .touchUpInside)
        button.theme_backgroundColor = Theme.Color.main

        return button
    }()
    
    var grId: Int = 0
    var markOverActionHandler: CYJCompleteHandler?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = "批阅"
        
        view.theme_backgroundColor = Theme.Color.ground
        // Do any additional setup after loading the view.
        view.addSubview(scoreTitleLabel)
        view.addSubview(scoreLabel1)
        view.addSubview(scoreLabel2)
        view.addSubview(scoreLabel3)
        view.addSubview(scoreLabel4)
        view.addSubview(starView1)
        view.addSubview(starView2)
        view.addSubview(starView3)
        view.addSubview(starView4)
        
//        view.addSubview(seprateView)
        
        view.addSubview(evaluateTitleLabel)
        view.addSubview(evaluateView)
        view.addSubview(excellentButton)
        view.addSubview(uploadButton)
        
        scoreTitleLabel.frame = CGRect(x: 15, y: Theme.Measure.navigationBarHeight + 20, width: 150, height: 15)
        scoreLabel1.frame = CGRect(x: 15, y: scoreTitleLabel.frame.maxY + 15, width: 100, height: 15)
        scoreLabel2.frame = CGRect(x: 15, y: scoreLabel1.frame.maxY + 15, width: 100, height: 15)
        scoreLabel3.frame = CGRect(x: 15, y: scoreLabel2.frame.maxY + 15, width: 100, height: 15)
        scoreLabel4.frame = CGRect(x: 15, y: scoreLabel3.frame.maxY + 15, width: 100, height: 15)
        starView1.frame = CGRect(x: scoreLabel1.frame.maxX + 10, y: scoreLabel1.frame.minY, width: 92, height: 15)
        starView2.frame = CGRect(x: scoreLabel1.frame.maxX + 10, y: scoreLabel2.frame.minY, width: 92, height: 15)
        starView3.frame = CGRect(x: scoreLabel1.frame.maxX + 10, y: scoreLabel3.frame.minY, width: 92, height: 15)
        starView4.frame = CGRect(x: scoreLabel1.frame.maxX + 10, y: scoreLabel4.frame.minY, width: 92, height: 15)
        
        
//        seprateView.frame = CGRect(x: 0, y: starView4.frame.maxY + 20, width: view.frame.width, height: 10)

        
        evaluateTitleLabel.frame = CGRect(x: 15, y: scoreLabel4.frame.maxY + 20, width: 120, height: 15)
        evaluateView.frame = CGRect(x: 15, y: evaluateTitleLabel.frame.maxY + 15, width: view.frame.width - 30, height: 110)
        excellentButton.frame = CGRect(x: 15, y: evaluateView.frame.maxY + 7, width: 110, height: 30)
        uploadButton.frame = CGRect(x: 0, y: view.frame.maxY - 44, width: view.frame.width, height: 44)
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    func excellentButtonAction() {
        
        self.excellentButton.isSelected = !self.excellentButton.isSelected
        
    }
    
    func uploadButtonAction() {
        //FIXME: uploadButtonAction
        
        guard self.starView1.star > 0, self.starView2.star > 0, self.starView3.star > 0, self.starView4.star > 0 else {
            Third.toast.message("评分不能为空")
            return
        }
        guard let evaluateText = self.evaluateView.text else {
            Third.toast.message("评语不能为空")
            return
        }
        guard !evaluateText.isEmpty else {
            Third.toast.message("评语不能为空")
            return
        }
        
        
        let parameter: [String: Any] = [
            "token" : LocaleSetting.token,
            "grId" : self.grId,
            "scoreA" : self.starView1.star,
            "scoreB" : self.starView2.star,
            "scoreC" : self.starView3.star,
            "scoreD" : self.starView4.star,
            "content" : evaluateText,
            "isGood" : self.excellentButton.isSelected ? 1 : 2]
        
        RequestManager.POST(urlString: APIManager.Record.mark, params: parameter) { [unowned self] (data, error) in
            //如果存在error
            guard error == nil else {
                Third.toast.message((error?.localizedDescription)!)
                return
            }
            Third.toast.message("批阅成功")
            
            if let completeHandler = self.markOverActionHandler {
                completeHandler(nil)
            }
            self.navigationController?.popViewController(animated: true)
        }

        
    }
}
