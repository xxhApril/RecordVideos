//
//  IWVideoOperatorView.swift
//  VideoRecording
//
//  Created by goWhere on 16/7/5.
//  Copyright © 2016年 iwhere. All rights reserved.
//

/// 视频操作视图

import UIKit
import AVKit
import Photos

class IWVideoOperatorView: UIView {
    
    private var controller: UIViewController!
    private var url: URL!

    // MARK: 公有方法
    internal func getSuperViewController(superController: UIViewController) {
        self.controller = superController
    }
    internal func getVideoUrl(videoUrl: URL) {
        self.url = videoUrl
    }
    
    /**
     按钮点击事件。用枚举更好些
     - parameter sender: tag 值 -- 预览：20，保存：21，上传：22，保存并上传：23，管理：24，取消：25
     */
    @IBAction func singleButtonClickedAction(sender: UIButton) {
        switch sender.tag {
        case 20:      //  预览
            guard let videoUrl = url else { break }
            let player = AVPlayer(url: videoUrl)
            let playerController = AVPlayerViewController()
            playerController.player = player
            self.controller.present(playerController, animated: true, completion: nil)
        case 21:       //  保存到本地相册
            saveVideoToAlbum(videoUrl: url)
        case 24:        //  管理所有本地视频
            managerAllVideos()
        case 25:
            UIView.animate(withDuration: 0.25, animations: {
                self.frame.origin.y = UIScreen.main.bounds.height
            }) { _ in
                self.removeFromSuperview()
            }
        default:
            let alertVC = UIAlertController(title: "不慌", message: "没写。。", preferredStyle: .alert)
            alertVC.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            controller.present(alertVC, animated: true, completion: nil)
        }
    }

    /**
     将视频保存到本地
     
     - parameter videoUrl: 保存链接
     */
    private func saveVideoToAlbum(videoUrl: URL) {
        var info = ""
        PHPhotoLibrary.shared().performChanges({
            PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: videoUrl)
        }) { (success, error) in
            if success {
                info = "保存成功"
            } else {
                info = "保存失败，err = \(error.debugDescription)"
            }
            
            DispatchQueue.main.async {
                let alertVC = UIAlertController(title: info, message: nil, preferredStyle: .alert)
                alertVC.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                self.controller.present(alertVC, animated: true, completion: nil)
            }
        }
    }
    
    /**
     管理 Document 文件夹下 所有视频
     */
    private func managerAllVideos() {
        let path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
        let pathString = path[0] as String
        let list = try? FileManager.default.contentsOfDirectory(atPath: pathString)
        if let _ = list {
            let managerVideoVC = IWManagerVideosViewController()
            self.controller.navigationController?.pushViewController(managerVideoVC, animated: true)
        } else {
            let alertVC = UIAlertController(title: "没有更多视频", message: nil, preferredStyle: .alert)
            alertVC.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.controller.present(alertVC, animated: true, completion: nil)
        }
    }
}
