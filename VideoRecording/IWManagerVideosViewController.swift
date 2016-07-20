//
//  IWManagerVideosViewController.swift
//  VideoRecording
//
//  Created by goWhere on 16/7/6.
//  Copyright © 2016年 iwhere. All rights reserved.
//

 /// 管理全部本地视频

import UIKit
import AVKit
import AVFoundation

class IWManagerVideosViewController: UIViewController,
UICollectionViewDelegateFlowLayout,
UICollectionViewDataSource {
    
    //  MARK: - Static constant
    private let Margin:CGFloat = 5
    private let ViewHeight:CGFloat = 50
    private let cellIdentifier = "videoCell"
    
    //  MARK: - Properties
    //  所有视频完整路径
    private var allVideosHolePaths: [String]?
    private var allImageArray = [UIImage]()
    //  表示是否被选中的数组
    private var nsnumberArray = [NSNumber]()
    //  载体 collectionView
    private var videosCollectionView: UICollectionView?
    //  视频是否处于可选择状态
    private var videoIsSelectedAble = false
    //  操作数组
    private var operatorVideosArray = [String]()
    //  选中cell的图片
    private var operatorVideosImage = [UIImage]()
    //  上传、删除按钮
    private var bottomView: UIView?
    //  操作数量Label
    private var countLabel = UILabel()
    

    //  MARK: - LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "视频管理"
        //  获取全部本地视频路径
        allVideosHolePaths = getAllVideoPaths()

        //  collectionView
        videosCollectionView = prepareCollectionView()
        
        //  添加选择按钮
        addChooseButton()
        
        //  添加操作视图
        addBottomView()
        
        //  获取截图
        getVideoImages(allVideosHolePaths!)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //  MARK: - Private Methods
    /**
     获取全部视频了路径
     
     - returns: 路径数组
     */
    func getAllVideoPaths() -> [String] {
        var pathArray = [String]()
        //  Documents 文件夹
        let pathFolder = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)
        //  文件夹路径
        let pathString = pathFolder[0] as String
        //  拼接获取每一个文件的完整路径
        if let lists =  try? NSFileManager.defaultManager().contentsOfDirectoryAtPath(pathString) {
            for item in lists {
                pathArray.append(pathString + "/" + item)
            }
        }
        
        //  添加标识数组
        for _ in pathArray {
            nsnumberArray.append(1)
        }
        
        return pathArray
    }
    
    /**
     添加 collectionView
     
     - returns: collectionVIew
     */
    func prepareCollectionView() -> UICollectionView {
        let flowLayout = UICollectionViewFlowLayout()
        let collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: flowLayout)
        view.addSubview(collectionView)
        
        collectionView.delegate = self
        collectionView.dataSource = self
        
        flowLayout.itemSize = CGSizeMake((view.bounds.width - 5 * Margin) / 4, (view.bounds.width - 5 * Margin) / 4)
        collectionView.contentInset = UIEdgeInsetsMake(Margin, Margin
            , Margin, Margin)
        flowLayout.minimumLineSpacing = Margin
        flowLayout.minimumInteritemSpacing = Margin
        
        collectionView.registerClass(videoCollectionViewCell.self, forCellWithReuseIdentifier: cellIdentifier)
        collectionView.backgroundColor = UIColor.whiteColor()
        
        return collectionView
    }
    
    /**
     添加选择按钮
     */
    func addChooseButton() {
        let chooseButton = UIButton(frame: CGRectMake(0, 0, 60, 30))
        chooseButton.setTitle("选择", forState: .Normal)
        chooseButton.setTitle("取消", forState: .Selected)
        chooseButton.setTitleColor(UIColor.blueColor(), forState: .Normal)
        chooseButton.addTarget(self, action: #selector(chooseButtonAction(_:)), forControlEvents: .TouchUpInside)
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: chooseButton)
    }
    
    /**
     底部操作视图
     */
    func addBottomView() {
        bottomView = UIView(frame: CGRectMake(0, view.bounds.height, view.bounds.width, ViewHeight))
        view.addSubview(bottomView!)
        
        let uploadBtn = setBottomButtons("上传", center: CGPointMake(view.bounds.width / 4, ViewHeight / 2))
        let deleteBtn = setBottomButtons("删除", center: CGPointMake(view.bounds.width * 3 / 4, ViewHeight / 2))
        
        uploadBtn.addTarget(self, action: #selector(uploadAction), forControlEvents: .TouchUpInside)
        deleteBtn.addTarget(self, action: #selector(deleteAction), forControlEvents: .TouchUpInside)
        
        //  数量
        countLabel.frame = CGRectMake(0, 0, 30, 30)
        countLabel.clipsToBounds = true
        countLabel.layer.cornerRadius = 15
        countLabel.backgroundColor = UIColor.redColor()
        countLabel.textColor = UIColor.whiteColor()
        countLabel.textAlignment = .Center
        countLabel.text = "0"
        countLabel.center = CGPointMake(bottomView!.bounds.width / 2, bottomView!.bounds.height / 2)
        bottomView?.addSubview(countLabel)
    }
    
    //  是否展示下面的操作安妮
    func showBottomView(isShow: Bool) {
        if isShow {
            UIView.animateWithDuration(0.2, delay: 0, usingSpringWithDamping: 0.75, initialSpringVelocity: 10, options: UIViewAnimationOptions.CurveEaseInOut, animations: { 
                self.bottomView?.frame.origin.y -= self.ViewHeight
                }, completion: nil)
        } else {
            UIView.animateWithDuration(0.2, animations: { 
                self.bottomView?.frame.origin.y += self.ViewHeight
            })
        }
    }
    
    //  统一风格上传、删除按钮
    func setBottomButtons(title: String, center: CGPoint) -> UIButton {
        let button = UIButton(frame: CGRectMake(0, 0, view.bounds.width / 3, ViewHeight - 10))
        button.center = center
        button.backgroundColor = UIColor.redColor()
        button.clipsToBounds = true
        button.layer.cornerRadius = 15
        button.setTitle(title, forState: .Normal)
        button.setTitleColor(UIColor.whiteColor(), forState: .Normal)
        bottomView?.addSubview(button)
        
        return button
    }
    
    //  删除事件
    func deleteAction() {
        
        //  删除本地文件
        for item in operatorVideosArray {
            do {
              try NSFileManager.defaultManager().removeItemAtPath(item)
            } catch let error as NSError {
                print("删除失败: \(error)")
            }
        }
        
        //  删除界面元素
        for index in 0 ..< operatorVideosArray.count {
            let img = operatorVideosImage[index]
            let currentIndex = allImageArray.indexOf(img)
            allImageArray.removeAtIndex(currentIndex!)
        }
        
        //  重新解析地址
        allVideosHolePaths?.removeAll()
        operatorVideosImage.removeAll()
        allVideosHolePaths = getAllVideoPaths()
        
        operatorVideosArray.removeAll()
        countLabel.text = "0"
        
        //  刷新
        handleChooseAction(true)
    }
    //  上传事件
    func uploadAction() {
        
    }
    
    //  点击选择按钮事件
    func chooseButtonAction(btn: UIButton) {
        btn.selected = !btn.selected
        showBottomView(btn.selected)

        handleChooseAction(btn.selected)
    }
    //  处理
    func handleChooseAction(isChoose: Bool) {
        videoIsSelectedAble = isChoose
        operatorVideosArray.removeAll()
        if videoIsSelectedAble {
            for index in 0 ..< nsnumberArray.count {
                nsnumberArray[index] = 0
            }
        } else {
            for index in 0 ..< nsnumberArray.count {
                nsnumberArray[index] = 1
            }
        }
        
        videosCollectionView?.reloadData()

    }
    //  通过文件路径获取截图:
    func getVideoImage(videoUrl: NSURL) -> UIImage? {
        //  获取截图
        let videoAsset = AVURLAsset(URL: videoUrl)
        let cmTime = CMTime(seconds: 1, preferredTimescale: 10)
        let imageGenerator = AVAssetImageGenerator(asset: videoAsset)
        if let cgImage = try? imageGenerator.copyCGImageAtTime(cmTime, actualTime: nil) {
            let image = UIImage(CGImage: cgImage)
            return image
        } else {
            print("获取缩略图失败")
        }

        return nil
    }
    
    //  通过文件路径获取截图:
    func getVideoImages(videoUrls: [String]) {
        
            //  获取截图
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), { 
                for item in videoUrls {
                    let videoAsset = AVURLAsset(URL: NSURL(fileURLWithPath: item))
                    let cmTime = CMTime(seconds: 1, preferredTimescale: 10)
                    let imageGenerator = AVAssetImageGenerator(asset: videoAsset)
                    if let cgImage = try? imageGenerator.copyCGImageAtTime(cmTime, actualTime: nil) {
                        let image = UIImage(CGImage: cgImage)
                        self.allImageArray.append(image)
                    } else {
                        print("获取缩略图失败")
                    }
                }
                dispatch_async(dispatch_get_main_queue(), {
                    self.videosCollectionView?.reloadData()
                })
            })

    }
    
    // MARK: -  CollectionView delegate / dataSouorce
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return allVideosHolePaths!.count
    }
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(cellIdentifier, forIndexPath: indexPath) as! videoCollectionViewCell

        if  allVideosHolePaths?.count == allImageArray.count {
            cell.videoInterface?.image = allImageArray[indexPath.row]
        }
        
        //  蒙版状态
        if videoIsSelectedAble {
            //  确认选中状态

            cell.selectedButton.hidden = false
            cell.videoIsChooose = nsnumberArray[indexPath.row] as Bool
        } else {
            cell.selectedButton.hidden = true
            cell.videoIsChooose = nsnumberArray[indexPath.row] as Bool
        }
        
        
        
        
        return cell
    }

    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        
        let cell = collectionView.cellForItemAtIndexPath(indexPath) as! videoCollectionViewCell
        guard videoIsSelectedAble else{
            //  不可选择，点击预览
            let player = AVPlayer.init(URL: NSURL(fileURLWithPath: allVideosHolePaths![indexPath.row]))
            let playerController = AVPlayerViewController()
            playerController.player = player
            presentViewController(playerController, animated: true, completion: nil)
            return
        }
        
        //  可选择
        cell.videoIsChooose = !cell.videoIsChooose!
        
        if cell.videoIsChooose == true {
            operatorVideosArray.append(allVideosHolePaths![indexPath.row])
            operatorVideosImage.append(allImageArray[indexPath.row])
        } else {
            let index = operatorVideosArray.indexOf(allVideosHolePaths![indexPath.row])
            operatorVideosArray.removeAtIndex(index!)
            operatorVideosImage.removeAtIndex(index!)
        }
        
        countLabel.text = "\(operatorVideosArray.count)"
        
        nsnumberArray[indexPath.row] = cell.videoIsChooose!

    }
}


//  MARK: - Define Cell
class videoCollectionViewCell: UICollectionViewCell {
    
    //  封面
    var videoInterface: UIImageView?
    //  蒙版
    var effectView = UIVisualEffectView()
    //  是否选中图标
    var selectedButton = UIButton()
    
    var videoIsChooose: Bool? {
        willSet {
           selectedButton.selected = newValue!
            if newValue == true {
                effectView.alpha = 0
            } else {
                effectView.alpha = 0.4
            }
        }
    }
    
    //  初始化调用方法
    override init(frame: CGRect) {
        super.init(frame: frame)
        videoIsChooose = false
        self.backgroundColor = UIColor.groupTableViewBackgroundColor()
        
        makeInterfaceImage()
    }
    
    // 添加封面
    func makeInterfaceImage() {
        videoInterface = UIImageView(frame: self.contentView.bounds)
        self.contentView.addSubview(videoInterface!)
        
        //  添加图标
        let playIconImageView = UIImageView(frame: CGRectMake(0, 0, 40, 40))
        playIconImageView.image = UIImage(named: "iw_playIcon")
        playIconImageView.center = CGPointMake(videoInterface!.bounds.width / 2, videoInterface!.bounds.height / 2)
        videoInterface?.addSubview(playIconImageView)
        
        //  添加是否选中图标
        selectedButton.frame =  CGRectMake(3, 3, 20, 20)
        selectedButton.setBackgroundImage(UIImage(named: "iw_unselected"), forState: .Normal)
        selectedButton.setBackgroundImage(UIImage(named: "iw_selected"), forState: .Selected)
        videoInterface?.addSubview(selectedButton)
        selectedButton.hidden = true
        
        //  添加蒙版
        effectView.frame = videoInterface!.bounds
        effectView.effect = UIBlurEffect(style: .Dark)
        effectView.alpha = 0.0
        videoInterface?.addSubview(effectView)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}