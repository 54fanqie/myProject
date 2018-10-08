//
//  CYJPlayerViewController.swift
//  ZiPingSwift
//
//  Created by kyang on 2017/11/13.
//  Copyright © 2017年 Chinayoujiao. All rights reserved.
//

import Foundation
import Kingfisher

class CYJPlayerViewController: PlayViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        self.backgroundImageView.kf.setImage(with: URL(string: self.coverImageUrl)!)
        
        ImageDownloader.default.downloadImage(with: URL(string: self.coverImageUrl)!, options: [.cacheMemoryOnly], progressBlock: { (length, max) in
            print("\(length) - \(max)")
        }) { (image, error, url, data) in
            
            DispatchQueue.main.async {
                self.backgroundImageView.image = image
            }
            print("\(image?.size)- url: \(url?.absoluteString ?? "??") - \(error?.localizedDescription ?? "??")")
        }
    }
    
    
}
