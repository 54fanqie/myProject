//
//  CYJRECImageViewContainer.swift
//  ZiPingSwift
//
//  Created by kyang on 2017/9/26.
//  Copyright © 2017年 Chinayoujiao. All rights reserved.
//

import Foundation

typealias CYJVideoUrls = (String, String)
typealias CYJImagesTapHandler = (_ index: Int,_ videoUrls: CYJVideoUrls?,_ imageUrls: [String]?, _ viewsArr: [UIView]) -> Void

class CYJRECImageViewContainer: UIView {
    
    var itemRects: [CGRect] = []
    var imageUrls: [String]?
    /// 第一个是 coverImage， 第二个是 playerUrl
    var videoUrls: CYJVideoUrls?
    var defaultImages = [#imageLiteral(resourceName: "default_one"), #imageLiteral(resourceName: "default_two"), #imageLiteral(resourceName: "default_threefour")]
    
    let kImageViewInContainerTag = 2321
    
    var imageSuffix: String = "?imageMogr2/thumbnail/"

    var imageViews: [UIImageView] = []
    var imageClickHandler: CYJImagesTapHandler!
    
    class func view(frame: CGRect, videoUrls: CYJVideoUrls?, imageUrls: [String]?) -> CGRect {
        let recImageView = CYJRECImageViewContainer(frame: frame)
        recImageView.imageUrls = imageUrls
        recImageView.videoUrls = videoUrls
        
        var height: CGFloat = 0
        if let _ = videoUrls {
           height = recImageView.configImageViewRects(imageCount: 1)
        }else if let imageUrls = imageUrls {
            height = recImageView.configImageViewRects(imageCount: imageUrls.count)
        }
        
        let rect = CGRect(x: frame.minX, y: frame.minY, width: frame.width, height: height)
        

        recImageView.frame = rect
        
        return rect
    }
    
    func configImageViewRects(imageCount: Int) -> CGFloat {
        
        let count = imageCount
        
        switch count {
        case 1:
            itemRects.append(CGRect(x: 48, y: 0, width: frame.width - 2 * 48, height: (frame.width - 2 * 48) * 10 / 16))
            
            return (frame.width - 2 * 48) * 10 / 16
        case 2:
            let itemWidth = (frame.width - 2 * 30 - 5) * 0.5
            itemRects.append(CGRect(x: 30, y: 0, width: itemWidth, height: itemWidth * 0.75))
            itemRects.append(CGRect(x: itemWidth + 30 + 5, y: 0, width: itemWidth, height: itemWidth * 0.75))
            return (itemWidth * 0.75)
            
        case 3:
            let itemWidth = (frame.width - 2 * 33 - 10) * 0.3333
            itemRects.append(CGRect(x: 33, y: 0, width: itemWidth, height: itemWidth))
            itemRects.append(CGRect(x: itemWidth + 33 + 5, y: 0, width: itemWidth, height: itemWidth ))
            itemRects.append(CGRect(x:  33 + (5 + itemWidth) * 2, y: 0, width: itemWidth, height: itemWidth))
            return itemWidth
        case 4:
            let itemWidth = (frame.width - 2 * 33 - 10) * 0.3333
            let leftpadding = (frame.width - 2 * itemWidth - 5) * 0.5
            itemRects.append(CGRect(x: leftpadding, y: 0, width: itemWidth, height: itemWidth))
            itemRects.append(CGRect(x: leftpadding + (5 + itemWidth), y: 0, width: itemWidth, height: itemWidth ))
            itemRects.append(CGRect(x:  leftpadding, y: itemWidth + 5, width: itemWidth, height: itemWidth))
            itemRects.append(CGRect(x:  leftpadding + (5 + itemWidth) , y: itemWidth + 5, width: itemWidth, height: itemWidth))

            return itemWidth * 2 + 5
            
        case 5,6,7,8,9:
            let padding: CGFloat = 5
            let itemWidth = (frame.width - 2 * 33 - padding * 2) * 0.3333
            let leftpadding = (frame.width - 3 * itemWidth - padding * 2) * 0.5
            for i in 0..<count {
                itemRects.append(CGRect(x:  leftpadding + (itemWidth + 5) * CGFloat(i%3), y:  (itemWidth + 5) * CGFloat(i/3), width: itemWidth, height: itemWidth))
            }
            var height = (itemWidth) * CGFloat(count/3) + (CGFloat(5) *  CGFloat(count/3 - 1))
            if count%3 > 0 {
                height += (itemWidth + 5)
            }
            
            return height
        default:
            return 0
        }
        
    }
    
    func makeImageViewByRects() {
        
        if let videoUrl = self.videoUrls {
            let imageViewFrame = itemRects[0]
            
            let imageView = UIImageView(frame: imageViewFrame)
            imageView.tag = kImageViewInContainerTag + 0
            imageView.isUserInteractionEnabled = true
            imageView.contentMode = .scaleAspectFill
            imageView.layer.masksToBounds = true
            self.addSubview(imageView)
        
            let imageThrum = imageSuffix + "\(imageViewFrame.width)x"
            imageView.kf.setImage(with: URL(fragmentString:videoUrl.0 + imageThrum) ,placeholder: #imageLiteral(resourceName: "default_one"))
            
            let playImageView = UIImageView(frame: CGRect(x: imageViewFrame.width * 0.5 - 27, y: imageViewFrame.height * 0.5 - 27, width: 54, height: 54))
            playImageView.isUserInteractionEnabled = true
            playImageView.image = #imageLiteral(resourceName: "pic_pause")
            imageView.addSubview(playImageView)
            
            
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(imageClickAction(_:)))
            tapGesture.numberOfTapsRequired = 1
            tapGesture.numberOfTouchesRequired = 1
            
            imageView.addGestureRecognizer(tapGesture)
            
            self.imageViews.append(imageView)
            
        }else if let imageUrls = self.imageUrls {
            
            let morenImageIndex = max(min((imageUrls.count - 1), 2), 0)
            let morenImage = defaultImages[morenImageIndex]
            
            imageUrls.enumerated().forEach { [unowned self] (offset, imageUrl) in
                
                let imageViewFrame = itemRects[offset]
                
                let imageView = UIImageView(frame: imageViewFrame)
                imageView.tag = kImageViewInContainerTag + offset
                imageView.isUserInteractionEnabled = true
                imageView.contentMode = .scaleAspectFill
                imageView.layer.masksToBounds = true
                self.addSubview(imageView)
                let imageThrum = imageSuffix + "\(imageViewFrame.width)x"
                imageView.kf.setImage(with: URL(fragmentString:imageUrl + imageThrum) ,placeholder: morenImage)
                
                let tapGesture = UITapGestureRecognizer(target: self, action: #selector(imageClickAction(_:)))
                tapGesture.numberOfTapsRequired = 1
                tapGesture.numberOfTouchesRequired = 1
                
                imageView.addGestureRecognizer(tapGesture)
                
                self.imageViews.append(imageView)
            }
            
        }

        
    }
    
    @objc func imageClickAction(_ tap: UITapGestureRecognizer){
        guard let tapView = tap.view else {
            return
        }
        let viewIndex = tapView.tag - kImageViewInContainerTag
        
        imageClickHandler(viewIndex, self.videoUrls ,self.imageUrls ,self.imageViews)
    }
}


