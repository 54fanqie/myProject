//
//  CYJArchivedRecordController.swift
//  ZiPingSwift
//
//  Created by kyang on 2017/9/28.
//  Copyright © 2017年 Chinayoujiao. All rights reserved.
//

import UIKit

class CYJArchivedRecordController: KYBaseTableViewController {

    var record: CYJRecord?
    
    var headerView: CYJArchivedRecordHeader!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        view.theme_backgroundColor = "Archived.archivedBackgroundColor"
        
        tableView.frame = CGRect(x: 15, y: 20, width: Theme.Measure.screenWidth - 30, height: Theme.Measure.screenHeight - 80 - 64)
        tableView.separatorStyle =  UITableViewCellSeparatorStyle.none
        tableView.register(UINib(nibName: "CYJArchiveRECCell", bundle: nil), forCellReuseIdentifier: "CYJArchiveRECCell")
    
        let backgroundView = UIView(frame: CGRect(x: 15, y: 20, width: Theme.Measure.screenWidth - 30, height: Theme.Measure.screenHeight - 40 - 64))
        backgroundView.backgroundColor = UIColor.clear
        let backgroundImageView = UIImageView(image: #imageLiteral(resourceName: "dangandai-bg3"))
        
        backgroundImageView.frame = backgroundView.bounds
        backgroundView.addSubview(backgroundImageView)

        view.addSubview(backgroundView)
        
//        tableView.backgroundView = backgroundView
        
        tableView.backgroundColor = UIColor.clear
        
        headerView = CYJArchivedRecordHeader(frame: CGRect(x: 0, y: 0, width: tableView.frame.width, height: 120))
        
        headerView.imageClickedHandler = { [unowned self] in
            
            if self.record?.photo?.first?.filetype == 2 {
//                打开的是视频
                if let url = self.record?.photo?.first?.videoPath {
                    //FIXME: 打开视频
                    if url.hasSuffix(".mp4") {
                        let playerC = PlayViewController()
                        playerC.vedioUrl = url
                        playerC.coverImageUrl = self.record?.photo?.first?.url
                        self.navigationController?.pushViewController(playerC, animated: true)
                    }else {
                        Third.toast.message("视频正在转码中，请稍后")
                    }
                }
            }else
            {
                if let imageUrls = $0.2 {
                    let imagesArr: [KYImageResource] = imageUrls.map({ (url) -> KYImageResource in
                        return KYImageResource(image: nil, imageURLString: url)
                    })
                    KYImageViewer.showImages(imagesArr, atIndex: $0.0, fromSenderArray: $0.3)
                }
                DLog("点击了第 \($0) 个 图片")
            }
        }
        
        if self.record?.photo?.first?.filetype == 2 {
            headerView?.updateLayoutByContend(date: (record?.rTime)!, images: nil, video: self.record?.photo?.first?.url)

        }else {
            let imageUrls = self.record?.photo?.map({ (edia) -> String in
                return edia.url ?? "http://www.chinaxueqian.com.cn"
            })
            headerView?.updateLayoutByContend(date: (record?.rTime)!, images: imageUrls, video: nil)
        }
        
        tableView.tableHeaderView = headerView
        view.bringSubview(toFront: tableView)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

extension CYJArchivedRecordController {
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CYJArchiveRECCell") as? CYJArchiveRECCell
        cell?.selectionStyle = .none
        cell?.backgroundColor = UIColor.clear
        cell?.contentView.backgroundColor = UIColor.clear
        switch indexPath.section {
        case 0:
            cell?.titleLabel.text = "记录描述"
            cell?.contentLabel.text = record?.describe
        case 1:
            cell?.titleLabel.text = "教师评语"
            cell?.contentLabel.text = record?.content
        case 2:
            cell?.titleLabel.text = "家长反馈"
            cell?.contentLabel.text = record?.comment

        default:
            break
        }

        return cell!
    }
}

class CYJArchivedRecordHeader: UIView {
    
    lazy var imageView: UIImageView = {
        let image = UIImageView(frame: CGRect(x: 0, y: 0, width: 171, height: 50))
        image.backgroundColor = UIColor.clear
        image.image = #imageLiteral(resourceName: "dangandai-titbg")
        return image
    }()
    lazy var createdLabel: UILabel = {
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: 200, height: 21))
        label.textColor = UIColor(hex6: 0xED724A)
        label.font = UIFont.boldSystemFont(ofSize: 18)
        label.textAlignment = .center
        return label
    }()
    var imageViewContainer: CYJRECImageViewContainer?
    
    var imageClickedHandler: CYJImagesTapHandler!
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        imageView.frame = CGRect(x: (frame.width - 180) * 0.5, y: 0, width: 180, height: 50)
        
        createdLabel.frame = CGRect(x: 0, y: 0, width:imageView.frame.width - 10, height: 50)
        createdLabel.center = CGPoint(x:imageView.center.x + 10,y:imageView.center.y)
        addSubview(imageView)
        addSubview(createdLabel)
    }
    
    func updateLayoutByContend(date: String, images: [String]?, video: String?){
        
        var viewHeight: CGFloat = 120
        
        createdLabel.text = date
        
        imageViewContainer?.removeFromSuperview()
        
        imageViewContainer = nil
        if let images = images {
            imageViewContainer = CYJRECImageViewContainer(frame: CGRect(x: 0, y: 120, width: frame.width, height: 0))
            imageViewContainer?.imageClickHandler = self.imageClickedHandler
            imageViewContainer?.imageUrls = images
            
            let height = imageViewContainer?.configImageViewRects(imageCount: images.count)
            
            imageViewContainer?.makeImageViewByRects()
            
            imageViewContainer?.frame = CGRect(x: 0, y: 80, width: frame.width, height: height!)
            
            viewHeight += height! + 15
            
            addSubview(imageViewContainer!)
            
        }else if let video = video {
            imageViewContainer = CYJRECImageViewContainer(frame: CGRect(x: 0, y: 120, width: frame.width, height: 0))

            imageViewContainer?.videoUrls = (video, "播放地址未传入")
            imageViewContainer?.imageClickHandler = self.imageClickedHandler
            let height = imageViewContainer?.configImageViewRects(imageCount: 1)
            
            imageViewContainer?.makeImageViewByRects()
            
            imageViewContainer?.frame = CGRect(x: 0, y: 80, width: frame.width, height: height!)
            
            addSubview(imageViewContainer!)

            viewHeight += height! + 15
        }
        
        frame.size.height = viewHeight
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
}

