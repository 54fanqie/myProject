//
//  CYJRECDetailDescroptionController.swift
//  ZiPingSwift
//
//  Created by kyang on 2017/10/30.
//  Copyright © 2017年 Chinayoujiao. All rights reserved.
//

import Foundation

/// 分页详情的描述页面
class CYJRECDetailDescroptionController: KYBaseTableViewController {
    
    var record: CYJRecord!
    
    lazy var infoCellFrame: CYJRECDetailCellFrame = {
        
        return CYJRECDetailCellFrame(record: self.record, role: nil)
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.frame = CGRect(x: 0, y: 0, width: Theme.Measure.screenWidth, height: Theme.Measure.screenHeight - 44 - Theme.Measure.navigationBarHeight)
        self.tableView.separatorStyle = UITableViewCellSeparatorStyle.none
        tableView.register(CYJRECDetailInfoCell.self, forCellReuseIdentifier: "CYJRECDetailInfoCell")
        tableView.register(CYJRECDetailReadOverCell.self, forCellReuseIdentifier: "CYJRECDetailReadOverCell")
        self.tableView.contentInset = UIEdgeInsetsMake(0, 0, 49, 0)

    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        if record.isMark == 1 {
            return 1
        }
        return 2
    }
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        switch indexPath.section {
        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: "CYJRECDetailInfoCell") as? CYJRECDetailInfoCell
            cell?.selectionStyle = .none
            
            cell?.imageClickHandler = { [unowned self] in
                
                if self.record?.photo?.first?.filetype == 2 {
                    //FIXME: 打开视频
                    
                    if let url = self.record?.photo?.first?.videoPath {
                        //FIXME: 打开视频
                        if url.hasSuffix(".mp4") {
                            let playerC = CYJPlayerViewController()
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
                }
            }
            cell?.infoFrame = infoCellFrame
            
            return cell!
        case 1:
            let cell = tableView.dequeueReusableCell(withIdentifier: "CYJRECDetailReadOverCell") as? CYJRECDetailReadOverCell
            cell?.selectionStyle = .none
            
            cell?.infoFrame = infoCellFrame
            
            return cell!
        default:
            return UITableViewCell()
        }
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        //
        switch indexPath.section {
        case 0:
            return infoCellFrame.infoCellHeight
        case 1:
            return infoCellFrame.evaluateCellHeight
        default:
            return 0
        }
    }
    
}
