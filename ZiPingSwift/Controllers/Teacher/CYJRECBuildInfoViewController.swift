//
//  CYJRECBuildInfoViewController.swift
//  ZiPingSwift
//
//  Created by kyang on 2017/8/30.
//  Copyright © 2017年 Chinayoujiao. All rights reserved.
//

import UIKit
import Photos
import AVKit
import HandyJSON
import IQKeyboardManagerSwift

class CYJRECBuildInfoViewController: KYBaseCollectionViewController {
    
    var grId: Int = 0
    //FIXME: record 仅存在在 暂存记录中编辑的情况，通过record改变recordParam，达到改变界面的目的
    var record: CYJRecord?
    
    var children: [CYJNewRECParam.ChildEvaluate]?
    
    var evaluates = [CYJRecordEvaluate]()
    
    /// 整个界面通过recordParam 创建
    let recordBuildHelper = CYJRECBuildHelper.default
    
    var recordParam: CYJNewRECParam {
        return recordBuildHelper.recordParam
    }
    var isActionNext: Bool = false //默认为暂存
    
    /// 图片上传的 管理
    var mediaUploader = CYJMediaUploader.default
    
    /// 显示图片 和 相册 选取
    var imageSectionExamples: [String] = ["Library", "Camera"]
    
    /// 可选的本地图片的个数
    var enableSelectedCount: Int = 9
    
    /// 网络图片的容器， 当是编辑的时候，改变他 ---- 当为视频时，里面只有一个对象，就是视频
    var uploadedImages: [CYJMediaImage] = [] {
        didSet{
            //刷新可选本地图片的最大个数
            if let first = uploadedImages.first {
                if first.fileType == 2 {
                    //判断，如果是视频的话，不允许再添加
                    self.imageSectionExamples.removeAll()
                }else
                { // 图片 -- 当可选择的本地图片 数量比0 大的时候，可以继续选择
                    self.enableSelectedCount = 9 - uploadedImages.count
                    if  self.enableSelectedCount > 0 {
                        self.imageSectionExamples = ["Library", "Camera"]
                    }else {
                        self.imageSectionExamples.removeAll()
                    }
                }
            }else
            {
                //当什么都没存在的时候，重设
                self.imageSectionExamples = ["Library", "Camera"]

                self.enableSelectedCount = 9 - uploadedImages.count
            }
        }
    }
    /// 可选本地图片的容器
    var selectedAssets: [PHAsset] = [] {
        didSet{
            //当 本地图片的容器 改变是，改变 “相册” 和 “视频”
            if let firstAsset = selectedAssets.first { //存在！
                if firstAsset.mediaType == .video { //并且是视频
                    self.recordParam.filetype = 2
                    self.imageSectionExamples.removeAll()
                }else {
                    self.recordParam.filetype = 1
                    if selectedAssets.count >= enableSelectedCount  {
                        self.imageSectionExamples.removeAll()
                    }else
                    {
                        self.imageSectionExamples = ["Library", "Camera"]
                    }
                }
            }else
            {
                self.recordBuildHelper.recordParam.filetype = 0
                self.imageSectionExamples = ["Library", "Camera"]
            }
            self.collectionView.reloadData()
        }
    }
    
    /// 操作bar
    var actionView: CYJActionsView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        automaticallyAdjustsScrollViewInsets = false
        
        // Do any additional setup after loading the view.
        navigationItem.title = "添加成长记录"
        
        // add Cancel button
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "关闭", style: .plain, target: self, action: #selector(dismissSelfNavigationController))
        
        navigationController?.navigationBar.shouldHideToolbarPlaceholder = false
        navigationController?.navigationBar.isHidden = false
        
        registerTableViewCellAndReuseView()
        
        makeActionsView()
        
        //TODO: 如果是从编辑进入页面，请求数据
        switch recordBuildHelper.buildStep {
        case .cached(_):
            fetchRecordInfoSource()
        default:
            break
        }
        //        if recordBuildHelper.buildStep != .new {
        //            recordBuildHelper.buildStep = .editInfo
        //            fetchRecordInfoSource()
        //        }
        recordBuildHelper.resetParam()
        
        //TODO: 设置图片及视频上传的代理
        mediaUploader.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //MARK: 设置recordView的父识图
        CYJASRRecordor.share.containerView = self.view
        
        recordParam.mark = 0
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        //MARK: 设置recordView的父识图
        CYJASRRecordor.share.containerView = nil
        Third.toast.hide {}
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //TODO: 注册Cell and header and footer
    func registerTableViewCellAndReuseView() {
        
        collectionView.frame = CGRect(x: 0, y: 0, width: Theme.Measure.screenWidth, height: Theme.Measure.screenHeight )
        
        collectionView.register(UINib(nibName: "CYJRECBuildCVC", bundle: nil), forCellWithReuseIdentifier: CYJRECBuildCVC.CYJRECBuildCVCTime)
        collectionView.register(UINib(nibName: "CYJRECBuildCVC", bundle: nil), forCellWithReuseIdentifier: CYJRECBuildCVC.CYJRECBuildCVCChild)
        collectionView.register(UINib(nibName: "CYJRECBuildCVC", bundle: nil), forCellWithReuseIdentifier: CYJRECBuildCVC.CYJRECBuildCVCDescription)
        collectionView.register(UINib(nibName: "CYJRECImageAddCell", bundle: nil), forCellWithReuseIdentifier: "CYJRECImageAddCell")
        
        collectionView.register(CYJRECBuildChildFooterView.self, forSupplementaryViewOfKind: UICollectionElementKindSectionFooter, withReuseIdentifier: "CYJRECBuildChildFooterView")
        collectionView.register(CYJRECBuildInfoHeaderView.self, forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: "CYJRECBuildInfoHeaderView")
        collectionView.register(CYJRECBuildLineFooterView.self, forSupplementaryViewOfKind: UICollectionElementKindSectionFooter, withReuseIdentifier: "UICollectionReusableViewLineFooter")
        collectionView.register(CYJRECBuildLineHeaderView.self, forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: "UICollectionReusableViewLineHeader")
        
    }
    
    func makeActionsView() {
        actionView = CYJActionsView(frame: CGRect(x: 0, y: view.frame.height - 44, width: view.frame.width, height: 44))
        actionView.innerPadding = 0.5
        actionView.isFull = true
        
        let saveButton = UIButton(type: .custom)
        saveButton.theme_setTitleColor(Theme.Color.textColorlight, forState: .normal)
        saveButton.theme_backgroundColor = Theme.Color.ground
        saveButton.setTitle("暂存", for: .normal)
        saveButton.titleLabel?.font = UIFont.systemFont(ofSize: 15)
        saveButton.addTarget(self, action: #selector(saveREC), for: .touchUpInside)
        
        let nextButton = UIButton(type: .custom)
        nextButton.theme_setTitleColor(Theme.Color.ground, forState: .normal)
        nextButton.theme_backgroundColor = Theme.Color.main
        nextButton.setTitle("去评析", for: .normal)
        nextButton.titleLabel?.font = UIFont.systemFont(ofSize: 15)
        nextButton.addTarget(self, action: #selector(nextREC), for: .touchUpInside)
        actionView.actions = [saveButton, nextButton]
        
        view.addSubview(actionView)
    }
    
    func fetchRecordInfoSource() {
        
        Third.toast.show {}
        let parameter: [String: Any] = ["token" : LocaleSetting.token, "grId" : self.grId]
        
        RequestManager.POST(urlString: APIManager.Record.info, params: parameter) { [unowned self] (data, error) in
            //如果存在error
            guard error == nil else {
                Third.toast.hide {}
                Third.toast.message((error?.localizedDescription)!)
                return
            }
            
            if let recordDict = data as? NSDictionary{
                let target = JSONDeserializer<CYJRecord>.deserializeFrom(dict: recordDict)
                self.recordParam.getValues(record: target!)
                //MARK: 创建当前界面的数据并刷新出来，
                self.uploadedImages = self.recordParam.photo
                self.collectionView.reloadData()
                Third.toast.hide {}
            }
        }
    }
}
// MARK: - 点击时间，上传及暂存
extension CYJRECBuildInfoViewController {
    
    func dismissSelfNavigationController() {
        switch CYJRECBuildHelper.default.buildStep {
        case .cached(_), .uploaded:
            NotificationCenter.default.post(name: CYJNotificationName.recordChanged, object: "cached")
//        case .published(let _):
//            NotificationCenter.default.post(name: CYJNotificationName.recordChanged, object: "published")
        default :
            break
        }
        
        self.navigationController?.dismiss(animated: true, completion: {
            //
        })
    }
    
    func uploadImage() {
        //只调upload ，回调放在代理里面
        
        let uploadedImages = self.selectedAssets.filter { (asset) -> Bool in
            let contained = self.recordParam.photo.contains(where: { (uploaded) -> Bool in
                return uploaded.localIdentifier == asset.localIdentifier
            })
            
            return !contained
        }
        if uploadedImages.count > 0 {
            CYJMediaUploader.default.uploadAssets(assets: uploadedImages, dir: "pic")
        }else
        {
            //就算没有图片，也得把参数的位置刷新掉
            self.recordParam.photo = self.uploadedImages
            self.saveIt()
        }
    }
    
    func uploadVideo() {
        
        if let asset = self.selectedAssets.first {
            
            let videoRequestOption = PHVideoRequestOptions()
            videoRequestOption.deliveryMode = .automatic
            
            PHImageManager.default().requestAVAsset(forVideo: asset, options: videoRequestOption, resultHandler: { (avasset, mix, context) in
                //
                if let urlAsset = avasset as? AVURLAsset
                {
                    let url = urlAsset.url
                    CYJMediaUploader.default.uploadVideoToCOS(assetUrl: url)
                }
            })
        }else {
            //TODO: 本处增加判断，是否已经上传过视频
            if uploadedImages.first?.fileType == 2 {
            }else {
                //没有视频，把参数的对象置空
                self.recordParam.fileId = nil
            }
            
            saveIt()
        }
    }
    
    //暂存成长记录
    func saveREC() {
        
        if self.recordParam.info.count == 0 || self.record?.user.count == 0{
            Third.toast.message("您至少要选择一个幼儿")
            return
        }
        
        var result: Bool = false
        
        if let describe = self.recordParam.describe {
            if !describe.isEmpty {
                result = true
            }
        }
        
        if self.uploadedImages.count > 0 {
            result = true
        }
        
        if self.selectedAssets.count > 0 {
            result = true
        }
        
        if !result {
            Third.toast.message("行为表现描述内容、照片、视频至少填写一个")
            return
        }
        
        //        if self.recordParam.describe == nil {
        //            Third.toast.message("请填写行为表现描述内容")
        //            return
        //        }
        //        if (self.recordParam.describe?.isEmpty)! {
        //            Third.toast.message("请填写行为表现描述内容")
        //            return
        //        }
        
        isActionNext = false
        //        CYJRECBuildHelper.default.buildStep.saveInfo()
        
        //TODO: 暂存成长记录
        startUploading()
    }
    //MARK: 下一页
    func nextREC() {
        
        if self.recordParam.info.count == 0 || self.record?.user.count == 0{
            Third.toast.message("您至少要选择一个幼儿")
            return
        }
        
        
        var result: Bool = false
        
        if let describe = self.recordParam.describe {
            if !describe.isEmpty {
                result = true
            }
        }
        
        if self.uploadedImages.count > 0 {
            result = true
        }
        
        if self.selectedAssets.count > 0 {
            result = true
        }
        
        if !result {
            Third.toast.message("行为表现描述内容、照片、视频至少填写一个")
            return
        }
        
        isActionNext = true
        //        CYJRECBuildHelper.default.buildStep.nextStep()
        startUploading()
    }
    
    // 启动上传流程
    func startUploading() {
        
        Third.toast.show {}
        //使 actionView 禁用
        actionView.makeButtonDisabled()
        
        // 上传 ： 1 上传图片或视频
        if self.recordParam.filetype == 2 {
            self.uploadVideo()
        }else if self.recordParam.filetype == 1 {
            self.uploadImage()
        }else {//没有图片也没有视频，直接保存
            saveIt()
        }
    }
    
    /// 保存到本地
    func saveIt() {
        self.uploadParamToServer(atFirst: self.recordParam.grId == 0) // grId == 0 => true
    }
    
    /// 上传
    ///
    /// - Parameter atFirst: 区分第一次上传
    func uploadParamToServer(atFirst: Bool) {
        
        let param = self.recordParam.encodeToDictionary()
        
        let urlString = atFirst ? APIManager.Record.add : APIManager.Record.edit
        
        RequestManager.POST(urlString: urlString, params: param ) { [unowned self] (data, error) in
            //如果存在error
            Third.toast.hide {
            }
            //使 actionView 启用
            self.actionView.makeButtonEnabled()
            guard error == nil else {
                Third.toast.message((error?.localizedDescription)!)
                return
            }
            Third.toast.message("暂存成功")
            self.recordBuildHelper.buildStep.next()
            
            if let dict = data as? Dictionary<String, Any>{
                self.recordParam.grId = Int((dict["grId"] as? String)!)!
            }
            //MARK: 如果是 下一步 -- 跳转到下一个页面
//            LocaleSetting.share.recordChanged = true
            if self.isActionNext {
                let score = CYJRECBuildScoreViewController()
                self.navigationController?.pushViewController(score, animated: true)
            }
        }
    }
}

// MARK: - collectionView 相关代理
extension CYJRECBuildInfoViewController {
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 4
        
    }
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch section {
        case 0:
            return 1
        case 1:
            if recordParam.info.count > 0  //选择了孩子
            {
                return recordParam.info.count
            }else if let children = self.children //本地孩子有，返回本地孩子的信息
            {
                return children.count
            }else
            {
                return 0
            }
            
        case 2:
            return imageSectionExamples.count + selectedAssets.count + uploadedImages.count
        case 3:
            return 1
        default:
            return 0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        switch indexPath.section {
        case 0:
            return CGSize(width: view.frame.size.width, height: 50)
        case 1:
            let width = (view.frame.width - 15*2 - 3*10) * 0.25
            return CGSize(width: width, height: 35)
        case 2:
            let width = (view.frame.width - 15*2 - 3*10) * 0.25
            return CGSize(width: width, height: width)
        case 3:
            return CGSize(width: view.frame.width, height: 200)
        default:
            return CGSize.zero
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        switch section {
        case 0:
            return UIEdgeInsetsMake(0, 0, 0, 0)
        case 1:
            return UIEdgeInsetsMake(0, 15, 0, 15)
        case 2:
            return UIEdgeInsetsMake(0, 15, 15, 15)
        case 3:
            return UIEdgeInsetsMake(0, 0, 0, 0)
        default:
            return UIEdgeInsets.zero
        }
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        if section == 0 {
            return CGSize(width: collectionView.frame.width, height: 0)
        }
        return CGSize(width: view.frame.width, height: 42)
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
        if section == 1{
            return CGSize(width: view.frame.width, height: 60)
        }else if section == 0{
            return CGSize(width: view.frame.width, height: 8)
        }else
        {
            return CGSize(width: view.frame.width, height: 0.5)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        
        if kind == UICollectionElementKindSectionHeader {
            switch indexPath.section {
            case 0:
                let header = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionElementKindSectionHeader, withReuseIdentifier: "UICollectionReusableViewLineHeader", for: indexPath)
                return header
                
            case 1:
                let header = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionElementKindSectionHeader, withReuseIdentifier: "CYJRECBuildInfoHeaderView", for: indexPath) as? CYJRECBuildInfoHeaderView
                header?.titleLabel.text = "选择幼儿"
               
                return header!
            case 2:
                let header = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionElementKindSectionHeader, withReuseIdentifier: "CYJRECBuildInfoHeaderView", for: indexPath) as? CYJRECBuildInfoHeaderView
                header?.titleLabel.text = "选择照片或视频(0-9张图片或1个视频):"
                
                return header!
            case 3:
                let header = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionElementKindSectionHeader, withReuseIdentifier: "CYJRECBuildInfoHeaderView", for: indexPath) as? CYJRECBuildInfoHeaderView
                header?.titleLabel.text = "行为表现描述"
                header?.theme_backgroundColor = Theme.Color.viewLightColor
                return header!
            default:
                return UICollectionReusableView()
            }
        }else
        {
            switch indexPath.section {
            case 1:
                
                let footer = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionElementKindSectionFooter, withReuseIdentifier: "CYJRECBuildChildFooterView", for: indexPath) as? CYJRECBuildChildFooterView
                footer?.addActionHandler = {[unowned self] in
                    
                    //TODO: 去选择幼儿了
                    let childrenVC = CYJRECBuildAddChildController()
                    
                    let beforeSelected = self.recordParam.info.map({ (evaluate) -> CYJChild in
                        let child = CYJChild()
                        child.uId = evaluate.bId
                        child.realName = evaluate.name
                        return child
                    })
                    childrenVC.selectedChildren = beforeSelected
                    
                    childrenVC.hasSelected = { [unowned self] children in
                        if let selectedchildren = children as? [CYJChild] {
                            //选择出来的幼儿要加到param里面去, 完全刷新
                            if selectedchildren.count > 0 {
                                Third.toast.message("添加成功")
                            }
                            self.recordParam.info = selectedchildren.map({ (child) -> CYJNewRECParam.ChildEvaluate in
                                let eva = CYJNewRECParam.ChildEvaluate()
                                eva.name = child.realName
                                eva.bId = child.uId
                                eva.avatar = child.avatar
                                return eva
                            })
                            self.collectionView.reloadData()
                        }
                    }
                    
                    self.navigationController?.pushViewController(childrenVC, animated: true)
                    
                }
                return footer!
            default:
                let footer = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionElementKindSectionFooter, withReuseIdentifier: "UICollectionReusableViewLineFooter", for: indexPath)
                footer.theme_backgroundColor = Theme.Color.line
                return footer
            }
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        switch indexPath.section {
        case 0:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CYJRECBuildCVC.CYJRECBuildCVCTime, for: indexPath) as? CYJRECBuildCVC
            
            cell?.timeDetailLabel.text = self.recordParam.rTime
            //            cell?.timeEditOver = { [unowned self] in
            //                self.recordParam.rTime = $0.stringWithYMD()
            //            }
            
            return cell!
        case 1:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CYJRECBuildCVC.CYJRECBuildCVCChild, for: indexPath) as? CYJRECBuildCVC
            //设置孩子信息
            if self.recordParam.info.count > 0 {
                let child = self.recordParam.info[indexPath.row]
                cell?.childNameLabel.text = child.name
            }else if let children = self.children{
                let child = children[indexPath.row]
                cell?.childNameLabel.text = child.name
            }
            return cell!
        case 2:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CYJRECImageAddCell", for: indexPath) as? CYJRECImageAddCell
            cell?.delegate = self
            //TODO: 根据情况，决定图片显示数据的来源
            
            if indexPath.row < self.uploadedImages.count {
                //将要显示网络图片
                
                let mediaImage = self.uploadedImages[indexPath.row]
                cell?.status = .added
                cell?.timeLabel.isHidden = true
                cell?.imageView.kf.setImage(with: URL(fragmentString: mediaImage.url) ,placeholder: #imageLiteral(resourceName: "default_threefour"))
                
                
            }else if indexPath.row < (self.uploadedImages.count + self.selectedAssets.count) {
                // 显示本地图片
                let imageAsset = selectedAssets[indexPath.row - self.uploadedImages.count]
                cell?.status = .added
                let width = (view.frame.width - 15*2 - 3*10) * 0.25
                //图片大一倍，够不够清楚
                let itemSize = CGSize(width: width * 2, height: width * 2)
                
                PHImageManager.default().requestImage(for: imageAsset, targetSize: itemSize, contentMode: PHImageContentMode.default, options: nil, resultHandler: { (image, nil) in
                    if imageAsset.mediaType == .image {
                        cell?.timeLabel.isHidden = true
                    }else
                    {
                        cell?.timeLabel.isHidden = false
                        cell?.timeLabel.text = "\(imageAsset.duration.toTimeScope())"
                    }
                    cell?.imageView.image = image
                })
            }else
            {
                let example = imageSectionExamples[indexPath.row - self.selectedAssets.count - self.uploadedImages.count]
                if example == "Library" {
                    cell?.status = .toLibrary
                }else if example == "Camera" {
                    cell?.status = .toCamera
                }else
                {
                    DLog("media type not found")
                }
            }
            
            cell?.backgroundColor = UIColor.gray
            return cell!
        case 3:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CYJRECBuildCVC.CYJRECBuildCVCDescription, for: indexPath) as? CYJRECBuildCVC
            
            cell?.textViewUpdating = {
                self.recordParam.describe = $0
            }
            cell?.textView.text = self.recordParam.describe
            if (cell?.textView.text)!.count > 0 {
                cell?.placeholderLabel.isHidden = true
            }
            
            return cell!
        default:
            return UICollectionViewCell()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        switch indexPath.section {
        case 0:
            if let cell = collectionView.cellForItem(at: indexPath) as? CYJRECBuildCVC {
                //TODO: 选择时间
                let nowDate = Date(timeIntervalSinceNow: 0)
                let semester = nowDate.getSemester()
                let datePicker = KYDatePickerController(currentDate: nowDate, minimumDate:
                    semester.start, maximumDate: nowDate, completeHandler: { [unowned cell, unowned self]  (selectedDate) in
                        
                        let dateText = selectedDate.stringWithYMD()
                        cell.timeDetailLabel.text = dateText
                        self.recordParam.rTime = dateText
                })
                
                let halfContainer = KYHalfPresentationController(presentedViewController: datePicker, presenting: UIApplication.shared.keyWindow?.topMostWindowController())
                datePicker.transitioningDelegate = halfContainer;
                UIApplication.shared.keyWindow?.topMostWindowController()?.present(datePicker, animated: true, completion: nil)
            }
            
        case 2:
            collectionView.deselectItem(at: indexPath, animated: true)
            
            let cell = collectionView.cellForItem(at: indexPath) as! CYJRECImageAddCell
            // 如果已经有图片了，那么返回
            if cell.status == .added {
                if indexPath.row < self.uploadedImages.count {
                    //将要显示网络图片,或者网络视频
                    let media = self.uploadedImages[indexPath.row]
                    
                    if media.fileType == 2 {
                        //点了视频， 放视频
                        
                        if let url = media.videoPath {
                            //FIXME: 打开视频
                            if url.hasSuffix(".mp4") {
                                let playerC = PlayViewController()
                                playerC.vedioUrl = url
                                playerC.coverImageUrl = media.url
                                self.navigationController?.pushViewController(playerC, animated: true)
                            }else {
                                Third.toast.message("视频正在转码中，请稍后")
                            }
                        }
                    }else
                    { // 这里将处理 本地图片和网络图片
                        
                        var imagesArr: [KYImageResource] = []
                        var viewsArr: [UIView] = []
                        
                        for i in 0..<self.uploadedImages.count {
                            
                            let media = self.uploadedImages[i]
                            imagesArr.append( KYImageResource(image: nil, imageURLString: media.url))
                            let cell = collectionView.cellForItem(at: IndexPath(row: i, section: 2))
                            viewsArr.append(cell!)
                        }
                        
                        for j in 0..<self.selectedAssets.count {
                            imagesArr.append(KYImageResource(asset: (selectedAssets[j] )))
                            let cell = collectionView.cellForItem(at: IndexPath(row: j, section: 2))
                            viewsArr.append(cell!)
                        }
                        KYImageViewer.showImages(imagesArr, atIndex: indexPath.row, fromSenderArray: viewsArr)
                    }
                }else if indexPath.row < (self.uploadedImages.count + self.selectedAssets.count) {
                    
                    //这里只需要 处理网路图片
                    let asset = selectedAssets[indexPath.row - self.uploadedImages.count]
                    if asset.mediaType == .video {
                        
                        //展示视频
                        let requestOptions = PHVideoRequestOptions()
                        requestOptions.deliveryMode = .automatic
                        requestOptions.version = .current
                        
                        
                        PHImageManager.default().requestPlayerItem(forVideo: asset, options: requestOptions, resultHandler: { [weak self](playerItem, hash) in
                            DLog("Call VideoPlayer Init")
                            
                            DispatchQueue.main.async {[weak self] in
                                let avPlayer = AVPlayerViewController()
                                avPlayer.player = AVPlayer(playerItem: playerItem)
                                avPlayer.player?.play()
                                
                                self?.present(avPlayer, animated: true, completion: nil)
                            }
                        })
                    }else {
                        
                        var imagesArr: [KYImageResource] = []
                        var viewsArr: [UIView] = []
                        
                        for i in 0..<self.uploadedImages.count {
                            
                            let media = self.uploadedImages[i]
                            imagesArr.append( KYImageResource(image: nil, imageURLString: media.url))
                            let cell = collectionView.cellForItem(at: IndexPath(row: i, section: 2))
                            viewsArr.append(cell!)
                        }
                        
                        for j in 0..<self.selectedAssets.count {
                            imagesArr.append(KYImageResource(asset: (selectedAssets[j] )))
                            let cell = collectionView.cellForItem(at: IndexPath(row: j, section: 2))
                            viewsArr.append(cell!)
                        }
                        KYImageViewer.showImages(imagesArr, atIndex: indexPath.row, fromSenderArray: viewsArr)
                    }
                }
            }else if cell.status == .toLibrary {
                self.toLibrary()
            }else  if cell.status == .toCamera{
                self.toCamera()
            }
            
        default:
            break
        }
    }
    
}
// MARK: - 相机和相册相关逻辑
extension CYJRECBuildInfoViewController: UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    
    func toLibrary() {
        //打开相册
        let mutipicker = KYMutiPickerController(maxCount: self.enableSelectedCount - selectedAssets.count)
        let nav = UINavigationController(rootViewController: mutipicker)
        //如果已经存在选中，那么只能继续选择图片
        
        if self.uploadedImages.count > 0, self.uploadedImages.first?.fileType == 1 {
            mutipicker.isImageOnly = true
        }
        
        if self.selectedAssets.count > 0, selectedAssets.first?.mediaType == .image {
            mutipicker.isImageOnly = true
        }
        
        mutipicker.completeHandler = {[unowned self](assets) in
            // 设置选中的图片
            self.selectedAssets.append(contentsOf: assets)
        }
        UIApplication.shared.keyWindow?.ky_topMostController()?.present(nav, animated: true, completion: {
            //
        })
    }
    
    func toCamera() {
        
        let alert = UIAlertController(title: "请选择拍照片或视频", message: nil, preferredStyle: UIAlertControllerStyle.actionSheet)
        
        alert.popoverPresentationController?.sourceView = view
        alert.popoverPresentationController?.sourceRect = view.bounds
        
        alert.addAction(UIAlertAction(title: "拍照", style: UIAlertActionStyle.default, handler: {[unowned self] (action) in
            self.toTakePhotos()
        }))
        
        if selectedAssets.count == 0 , self.uploadedImages.count == 0 {
            alert.addAction(UIAlertAction(title: "拍视频", style: UIAlertActionStyle.default, handler: {[unowned self] (action) in
                self.toTakeVideo()
            }))
        }
        
        
        alert.addAction(UIAlertAction(title: "取消", style: UIAlertActionStyle.cancel, handler: nil))
        
        self.present(alert, animated: true, completion: nil)
        
    }
    
    func toTakePhotos() {
        //检查一下？
        AuthorizationManager.share.fetchAuthorityCamera { (authStatus) in
            if authStatus {
                if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.camera) {
                    let picker = UIImagePickerController()
                    picker.sourceType = UIImagePickerControllerSourceType.camera
                    picker.allowsEditing = false
                    picker.delegate = self
                    UIApplication.shared.keyWindow?.ky_topMostController()?.present(picker, animated: false, completion: nil)
                }
            }
        }
    }
    
    func toTakeVideo() {
        
        //检查相册的权限
        AuthorizationManager.share.fetchAuthorityLibrary { (authStatus) in
            if authStatus {
                NotificationCenter.default.addObserver(self, selector: #selector(self.videoSaveToLibrarySuccess(notify:)), name: CYJNotificationName.videoSelectedFinish, object: nil)
                
                let videoConfig = VideoConfigure()
                videoConfig.videoRatio = .VIDEO_ASPECT_RATIO_9_16
                videoConfig.videoResolution = .VIDEO_RESOLUTION_540_960
                
                let record = VideoRecordViewController(configure: videoConfig)
                
                UIApplication.shared.keyWindow?.ky_topMostController()?.present(record!, animated: false, completion: nil)
            }
        }
    }
    
    
    //    权限判断
    func fetchAuthority(_ success: @escaping ()->Void) {
        //相册权限
        let author = PHPhotoLibrary.authorizationStatus()
        
        if (author == PHAuthorizationStatus.notDetermined){
            //无权限 引导去开启
            PHPhotoLibrary.requestAuthorization({ (sta) in
                if sta == .authorized {
                    success()
                }
            })
        }else if author == .denied || author == .restricted
        {
            let alert = UIAlertController(title: "我们没有权限访问您的相册", message: "请到系统 设置->隐私->照片 以允许我们访问您的相册", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "确定", style: .default, handler: nil))
            
            DispatchQueue.main.async {
                self.present(alert, animated: true, completion: nil)
            }
        }
        else
        {
            success()
        }
    }
    
    func videoSaveToLibrarySuccess(notify: Notification) -> Void {
        //TODO: 视频 选择完毕
        let assetUrl = notify.object as? URL
        
        AuthorizationManager.share.fetchAuthorityLibrary { _ in
            
            let fetchResult = PHAsset.fetchAssets(withALAssetURLs: [assetUrl!], options: nil)
            
            if let asset = fetchResult.firstObject {
                if asset.mediaType == .video {
                    self.selectedAssets = [asset]
                    self.recordParam.filetype = 2
                    
                    DispatchQueue.main.async { [unowned self] in
                        self.collectionView.reloadData()
                    }
                }else {
                    DLog("获取到的不是视频")
                }
            }else
            {
                DLog("获取不到视频")
            }
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        //
        let image = info[UIImagePickerControllerOriginalImage] as! UIImage
        // 设置筛选条件
        let allPhotosOptions = PHFetchOptions()
        // 按图片生成时间排序
        allPhotosOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        //选择普通照片
        allPhotosOptions.predicate = NSPredicate(format: "mediaType = %d", PHAssetMediaType.image.rawValue)
        
        //本地路径，代替ReferenceURL
        var localIdentifier: String = ""
        
        //通过存储图片到本地路径，顺便拿到Url
        PHPhotoLibrary.shared().performChanges({
            //获取根据change对象拿到localIndentifier
            let createdAssetID = PHAssetChangeRequest.creationRequestForAsset(from: image).placeholderForCreatedAsset?.localIdentifier
            localIdentifier = createdAssetID!
            
            print("createdAssetID:\(createdAssetID ?? "nil")")
        }) { (success, error) in
            //通过localIdentifier 拿到PHAsset对象
            let assets = PHAsset.fetchAssets(withLocalIdentifiers: [localIdentifier], options: allPhotosOptions)
            if assets.firstObject != nil
            {
                DispatchQueue.main.async {
                    //直接appand， 断绝了修改图片的问题，只能删除然后新增～所以直接appand
                    self.selectedAssets.append(assets.firstObject!)
                    self.collectionView.reloadData()
                }
            }
        }
        
        picker.dismiss(animated: true) {
            //
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        //
        picker.dismiss(animated: true, completion: nil)
    }
}


// MARK: - CYJRECImageAddCellDelegate - 删除图片的代理
extension CYJRECBuildInfoViewController: CYJRECImageAddCellDelegate {
    
    func deleteImage(_ cell: CYJRECImageAddCell) {
        
        if let index = collectionView.indexPath(for: cell) {
            if index.row < self.uploadedImages.count {
                uploadedImages.remove(at: index.row)
            }else if (index.row - self.uploadedImages.count) < self.selectedAssets.count {
                selectedAssets.remove(at: (index.row - self.uploadedImages.count))
            }
            self.collectionView.reloadData()
        }
    }
}

// MARK: - CYJMediaUploaderDelegate 图片和视频完成的事件
extension CYJRECBuildInfoViewController: CYJMediaUploaderDelegate {
    
    func imagesUploadComplete(mediaImage: [CYJMediaImage]?, error: Error?) {
        
        if let images = mediaImage {
            // 这里图片是本地图片加上，可以上传的图片
            
            //加到uploadedImages里面
            self.uploadedImages += images
            
            self.recordParam.photo = self.uploadedImages
            self.recordParam.filetype = 1
            //TODO: 图片上传完毕，保存
            self.saveIt()
        }else {
            self.actionView.makeButtonEnabled()
        }
        
    }
    
    func videoUploadComplete(_ urlString: String) {
        // TODO: 把phpto 置空 ，肯定没有

        if urlString == "error" {
            Third.toast.hide {}
            Third.toast.message("视频上传失败")
            //TODO: 视频上传失败 - 让暂存再次可以点击
            self.actionView.makeButtonEnabled()

        }else {
            
            self.recordParam.photo = []
            self.recordParam.fileId = urlString
            self.recordParam.filetype = 2
            //TODO: 视频上传完毕，保存
            self.saveIt()
        }
        
    }
}
