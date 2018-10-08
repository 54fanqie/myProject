//
//  CYJRECImageAddCell.swift
//  ZiPingSwift
//
//  Created by kyang on 2017/9/26.
//  Copyright © 2017年 Chinayoujiao. All rights reserved.
//

import UIKit

protocol CYJRECImageAddCellDelegate {
    
    /// 删除当前图片
    ///
    /// - Parameter image: <#image description#>
    /// - Returns: <#return value description#>
    func deleteImage(_ cell: CYJRECImageAddCell) -> Void
}


class CYJRECImageAddCell: UICollectionViewCell {
    
    enum AddCellStatus {
        case toLibrary
        case toCamera
        case added
    }
    enum AddCellMediaType {
        case image
        case video
    }
    
    @IBOutlet weak var imageView: UIImageView!
    
    @IBOutlet weak var deleteButton: UIButton!
    
    @IBOutlet weak var timeLabel: UILabel!
    
//    @IBOutlet weak var addView: UIView!
//    @IBOutlet weak var addViewImageView: UIImageView!
//    @IBOutlet weak var addViewLabel: UILabel!
    
    var delegate: CYJRECImageAddCellDelegate?
    
    var hasAdd: Bool = false
    
    var status: AddCellStatus = .toLibrary {
        didSet {
            switch status {
            case .toLibrary:
                self.imageView.image = #imageLiteral(resourceName: "icon_gray_pho")
                
                self.timeLabel.isHidden = true
                self.deleteButton.isHidden = true
            case .toCamera:

                self.imageView.image = #imageLiteral(resourceName: "icon_gray_video")
                self.timeLabel.isHidden = true
                self.deleteButton.isHidden = true
                
            case .added:
                self.timeLabel.isHidden = false
                self.deleteButton.isHidden = false
                
            default:
                break
            }
        }
    }
    
//    func setImage(image: UIImage?) {
//
//        if let image = image {
//            imageView.image = image
//            deleteButton.isHidden = false
//            hasAdd = true
//        }else
//        {
//            imageView.image = KYMutiPickerHeader().bundleImage("Add")
//            deleteButton.isHidden = true
//            hasAdd = false
//        }
//    }
    
    
    @IBAction func deleteAction(_ sender: Any) {
        
        if delegate != nil{
            delegate?.deleteImage(self)
        }
    }
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
}
