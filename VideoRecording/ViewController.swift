//
//  ViewController.swift
//  VideoRecording
//
//  Created by goWhere on 16/7/4.
//  Copyright © 2016年 iwhere. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    
    
    
    @IBAction func recordingAction(sender: UIButton) {
        let vc = IWVideoRecordingController()
        navigationController?.pushViewController(vc, animated: true)
    }
}


// MARK: - 临时写个弹窗方法
func HsuAlert(title: String, message: String?, ensureTitle: String, cancleTitle: String?, ensureAction: ((UIAlertAction) -> Void)?, cancleAction: ((UIAlertAction) -> Void)?) {
    let alertVC = UIAlertController(title: title, message: message, preferredStyle: .alert)
    if cancleTitle != nil {
        alertVC.addAction(UIAlertAction(title: cancleTitle, style: .default, handler: cancleAction))
    }
    alertVC.addAction(UIAlertAction(title: ensureTitle, style: .default, handler: ensureAction))
    UIApplication.shared.keyWindow?.rootViewController?.present(alertVC, animated: true, completion: nil)
}

