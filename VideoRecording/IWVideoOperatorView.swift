//
//  IWVideoOperatorView.swift
//  VideoRecording
//
//  Created by goWhere on 16/7/5.
//  Copyright © 2016年 iwhere. All rights reserved.
//

import UIKit
import AVKit
import AVFoundation
import Photos

class IWVideoOperatorView: UIView {
    
    private var controller: UIViewController!
    private var url: NSURL!

    //  MARK: 公有方法
    internal func getSuperViewController(superController: UIViewController) {
        self.controller = superController
    }
    internal func getVideoUrl(videoUrl: NSURL) {
        self.url = videoUrl
    }
    
    /**
     按钮点击事件
     
     - parameter sender: tag 值 -- 预览：20，保存：21，上传：22，保存并上传：23，管理：24，取消：25
     */
    @IBAction func singleButtonClickedAction(sender: UIButton) {
        switch sender.tag {
        case 20:      //  预览
            if let videoUrl = self.url {
                let player = AVPlayer(URL: videoUrl)
                let playerController = AVPlayerViewController()
                playerController.player = player
                self.controller.presentViewController(playerController, animated: true, completion: nil)
            }
            
        case 21:       //  保存到本地相册
            saveVideoToAlbum(self.url)
        case 24:        //  管理所有本地视频
            managerAllVideos()
        case 25:
            UIView.animateWithDuration(0.25, animations: {
                self.frame.origin.y = UIScreen.mainScreen().bounds.height
                }, completion: { (let success) in
                    self.removeFromSuperview()
            })
        default:
            return
        }
    }

    /**
     将视频保存到本地
     
     - parameter videoUrl: 保存链接
     */
    func saveVideoToAlbum(videoUrl: NSURL?) {
        var message: String!
        if let url = videoUrl {
            PHPhotoLibrary.sharedPhotoLibrary().performChanges({ 
                PHAssetChangeRequest.creationRequestForAssetFromVideoAtFileURL(url)
                }, completionHandler: { (success: Bool, error: NSError?) in
                    if success {
                        message = "保存成功"
                    } else {
                        message = "保存失败: \(error)"
                    }
                    
                    //  回到主线程，弹框提醒
                    dispatch_async(dispatch_get_main_queue(), { 
                        let alertC = UIAlertController(title: message, message: nil, preferredStyle: .Alert)
                        alertC.addAction(UIAlertAction(title: "确定", style: .Cancel, handler: nil))
                        self.controller.presentViewController(alertC, animated: true, completion: nil)
                    })
            })
        }
    }
    
    /**
     管理 Document 文件夹下 所有视频
     */
    func managerAllVideos() {
        let path = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)
        let pathString = path[0] as String
        let list = try? NSFileManager.defaultManager().contentsOfDirectoryAtPath(pathString)
        
        if let _ = list {
            let managerVideoVC = IWManagerVideosViewController()
            self.controller.navigationController?.pushViewController(managerVideoVC, animated: true)
        }
    }
}
