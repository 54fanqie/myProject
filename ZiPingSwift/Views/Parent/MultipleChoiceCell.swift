//
//  MultipleChoiceCell.swift
//  test
//
//  Created by 番茄 on 7/25/18.
//  Copyright © 2018 fanqie. All rights reserved.
//

import UIKit
import SnapKit

@objc protocol MultipleChoiceDelegate : NSObjectProtocol{
    func selectResult(cellIndex : Int ,choesIndex : Int,score:String)
}

class MultipleChoiceCell: UITableViewCell {
    
    init(style: UITableViewCellStyle, reuseIdentifier: String? , cellData: ShiTiDetailModel, index: Int) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.lauoutUI(cellData: cellData ,index: index)
    }
    
    //声明类的代理属性变量名
    var delegate : MultipleChoiceDelegate?
    
    var backView: UIView?
    var titleLab: UILabel?
    var topView: UIView?
    var bottomView: UIView?
    var imageViewMuArray : NSMutableArray?
    var shiTiDetailModel = ShiTiDetailModel()
    
    //题目标题高度
    let topViewHeight = 45
    
    //题目标题left间距
    let titleLeftSpace = 20
    
    //每行选择答案高度
    let subViewHeight = 40
    
    //选择按钮大小
    let imageSize = 20
    
    //选择按钮left间距
    let imageLeftSpace = 20
    
    //选项内容与按钮的间距
    let contentTobuttonSpace = 60
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    func lauoutUI(cellData :ShiTiDetailModel,index: Int)  {
        shiTiDetailModel = cellData
        //问题
        let questionTitle =  String(format:"%d、%@",index + 1,cellData.title!)
        
        //答案
        let questionArray = cellData.choices
        
        
        //大背景
        backView = UIView();
        backView?.layer.cornerRadius = 10
        backView?.layer.masksToBounds = true
        backView?.backgroundColor = UIColor.white
        backView?.layer.borderWidth = 0.1
        backView?.layer.theme_borderColor = "Global.textColorLight"
        self.contentView.addSubview(backView!)
        //选项按钮图片
        imageViewMuArray = NSMutableArray();
        //标题底层背景
        topView = UIView();
        topView?.theme_backgroundColor = Theme.Color.viewLightColor
        backView?.addSubview(topView!)
        
        //标题lab
        titleLab = UILabel();
        titleLab?.text = questionTitle
        titleLab?.theme_textColor = Theme.Color.textColorDark
        titleLab?.numberOfLines = 0 
        titleLab?.font = UIFont.systemFont(ofSize: 15)
        topView?.addSubview(titleLab!)
        
        
        
        //选项背景按钮
        bottomView = UIView();
        bottomView?.backgroundColor = UIColor.white
        backView?.addSubview(bottomView!)
        
        var lastView : UIView?
        for i in 0..<questionArray.count{
            
            let dictDetail = questionArray[i]
            var isSelect : Bool = false
            if dictDetail.answer == 0 {
                isSelect = false
            }else{
                isSelect = true
            }
            
            
            //子选项View
            let subView = UIView()
            bottomView?.addSubview(subView)
            
            let imageView = UIImageView();
            if(isSelect){
                imageView.image = #imageLiteral(resourceName: "cnb-seted")
            }else{
                imageView.image = #imageLiteral(resourceName: "cnb")
            }
            imageView.tag = i
            subView.addSubview(imageView)
            
            imageView.snp.makeConstraints({ (make)in
                make.left.equalTo(subView).offset(imageLeftSpace)
                make.centerY.equalTo(subView)
                make.width.equalTo(imageSize)
                make.height.equalTo(imageSize)
            })
            imageViewMuArray?.add(imageView)
            
            let selButton = UIButton();
            selButton.tag = i
            selButton.addTarget(self, action: #selector(selectAnswner(button:)), for: .touchUpInside)
            subView.addSubview(selButton)
            selButton.snp.makeConstraints({ (make)in
                make.left.equalTo(subView).offset(0)
                make.centerY.equalTo(subView)
                make.width.equalTo(50)
                make.height.equalTo(30)
            })
            
            
            let contentTitle = UILabel();
            contentTitle.text = dictDetail.chose
            contentTitle.font = UIFont.systemFont(ofSize: 15)
            contentTitle.numberOfLines = 0
            contentTitle.theme_textColor = Theme.Color.textColorDark
            subView.addSubview(contentTitle)
            
            
            contentTitle.snp.makeConstraints({ (make)in
                make.left.equalTo(subView).offset(contentTobuttonSpace)
                make.centerY.equalTo(subView)
                make.right.equalTo(subView).offset(-10)
            })
            
            if i==0 {
                subView.snp.makeConstraints({ (make)in
                    make.left.equalTo(bottomView!).offset(0)
                    make.right.equalTo(bottomView!).offset(0)
                    make.top.equalTo(bottomView!).offset(0)
                    make.bottom.equalTo(contentTitle.snp.bottom).offset(10)
                })
            }else{
                subView.snp.makeConstraints({ (make)in
                    make.left.equalTo(bottomView!).offset(0)
                    make.right.equalTo(bottomView!).offset(0)
                    make.top.equalTo((lastView?.snp.bottom)!).offset(0)
                    make.bottom.equalTo(contentTitle.snp.bottom).offset(10)
                })
            }
            
            lastView = subView;
        }
        
        
        titleLab?.snp.makeConstraints({ (make)in
            make.left.equalTo(topView!).offset(titleLeftSpace)
            make.right.equalTo(topView!).offset(-5)
            make.centerY.equalTo(topView!)
        })
        topView?.snp.makeConstraints({ (make)in
            make.left.equalTo(backView!).offset(0)
            make.right.equalTo(backView!).offset(0)
            make.top.equalTo(backView!).offset(0)
            make.bottom.equalTo((titleLab?.snp.bottom)!).offset(17)
        })
        
        
        
        bottomView?.snp.makeConstraints({ (make)in
            make.left.equalTo(backView!).offset(0)
            make.right.equalTo(backView!).offset(0)
            make.top.equalTo(topView!.snp.bottom).offset(10)
            make.height.equalTo(subViewHeight * questionArray.count)
        })
        
        backView?.snp.makeConstraints({ (make) in
            make.left.equalToSuperview().offset(10)
            make.right.equalToSuperview().offset(-10)
            make.top.equalToSuperview().offset(8)
            make.bottom.equalToSuperview().offset(-10)
            make.bottom.equalTo(bottomView!.snp.bottom).offset(4)
        })
    }
    
    @objc func selectAnswner(button:UIButton) {
        for imageView in imageViewMuArray!{
            let imageView = imageView as! UIImageView
            if imageView.tag == button.tag {
                imageView.image = #imageLiteral(resourceName: "cnb-seted")
            }else{
                imageView.image = #imageLiteral(resourceName: "cnb")
            }
        }
    
        let choicesDetailModel =  shiTiDetailModel.choices[button.tag]
        if delegate != nil{
            delegate?.selectResult(cellIndex : self.tag ,choesIndex: choicesDetailModel.scId ,score: String(format: "%d", choicesDetailModel.score))
        }
        
    }
    
    //返回button所在的UITableViewCell
    func superUITableViewCell(of: UIButton) -> UITableViewCell? {
        for view in sequence(first: of.superview, next: { $0?.superview }) {
            if let cell = view as? UITableViewCell {
                return cell
            }
        }
        return nil
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
}
