//
//  CYJSmallImageViewContainer.swift
//  ZiPingSwift
//
//  Created by kyang on 2017/9/11.
//  Copyright © 2017年 Chinayoujiao. All rights reserved.
//

import Foundation


class CYJSmallImageViewContainer: UIView {
    
    var padding: Float{
        switch imagePaths.count {
        case 0:
            return 0
        default:
            return 4
        }
    }
    
    lazy var imageViewOne: UIImageView = {
        return UIImageView()
    }()
    lazy var imageViewTwo: UIImageView = {
        return UIImageView()
    }()
    lazy var imageViewThree: UIImageView = {
        return UIImageView()
    }()
    lazy var imageViewFour: UIImageView = {
        return UIImageView()
    }()
    
    lazy var guestureRecognizer: UITapGestureRecognizer = {
        let tapG = UITapGestureRecognizer(target: self, action: #selector(tapGuesture(guesture:)))
        tapG.numberOfTapsRequired = 1
        tapG.numberOfTouchesRequired = 1
        
        return tapG
    }()
    
    var images: [UIImage] = []
    
    var imagePaths: [String] = []
    
    init(_ imagePaths: [String], frame: CGRect) {
        super.init(frame: frame)
        
        self.imagePaths = imagePaths
        
        //添加 Guesture
        isUserInteractionEnabled = true
        addGestureRecognizer(guestureRecognizer)
    }
    
    func makeImageContainer() {
        
        switch imagePaths.count {
        case 1:
            oneImageView()
        case 2:
            twoImageView()
        case 3:
            threeImageView()
        case 4:
            fourImageView()
        default:
            break
        }
    }
    
    func oneImageView() {
        
        imageViewOne.frame = self.bounds
        
        self.addSubview(imageViewOne)
        
    }
    
    func twoImageView() {
        
        let width = (bounds.width - CGFloat(padding)) * 0.5
        imageViewOne.frame = CGRect(x: 0, y: 0, width: width, height: bounds.height)
        imageViewTwo.frame = CGRect(x: bounds.width * 0.5 + CGFloat(padding) * 0.5, y: 0, width: width, height: bounds.height)
        
        addSubview(imageViewOne)
        addSubview(imageViewTwo)
        
    }
    
    func threeImageView() {
        let width = (bounds.width - CGFloat(padding)) * 0.5
        let height = (bounds.height - CGFloat(padding)) * 0.5
        
        imageViewOne.frame = CGRect(x: 0, y: 0, width: width, height: bounds.height)
        
        imageViewTwo.frame = CGRect(x: bounds.width * 0.5 + CGFloat(padding) * 0.5, y: 0, width: width, height: height)
        
        imageViewThree.frame = CGRect(x: bounds.width * 0.5 + CGFloat(padding) * 0.5, y: bounds.height * 0.5 + CGFloat(padding) * 0.5, width: width, height: height)
        
        addSubview(imageViewOne)
        addSubview(imageViewTwo)
        addSubview(imageViewThree)

        
    }
    
    func fourImageView() {
        let width = (bounds.width - CGFloat(padding)) * 0.5
        let height = (bounds.height - CGFloat(padding)) * 0.5
        
        imageViewOne.frame = CGRect(x: 0, y: 0, width: width, height: height)
        
        imageViewTwo.frame = CGRect(x: bounds.width * 0.5 + CGFloat(padding) * 0.5, y: 0, width: width, height: height)
        
        imageViewThree.frame = CGRect(x: 0, y: bounds.height * 0.5 + CGFloat(padding) * 0.5, width: width, height: height)

        imageViewFour.frame = CGRect(x: bounds.width * 0.5 + CGFloat(padding) * 0.5, y: bounds.height * 0.5 + CGFloat(padding) * 0.5, width: width, height: height)
        
        addSubview(imageViewOne)
        addSubview(imageViewTwo)
        addSubview(imageViewThree)
        addSubview(imageViewFour)

        
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    
    func tapGuesture(guesture: UITapGestureRecognizer) {
        
    }
}
