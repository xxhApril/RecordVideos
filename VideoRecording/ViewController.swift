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
        
        
        let dd = getDeviceIP()
        print(dd)
    }
    
    
    
    
    /**
     获取设备外网IP地址
     
     - returns: 地址
     */
    func getDeviceIP() -> NSDictionary? {
        
        let ipUrl = NSURL.init(string: "http://pv.sohu.com/cityjson?ie=utf-8")
        if var needIP = try? String.init(contentsOfURL: ipUrl!, encoding: NSUTF8StringEncoding) {
            //  判断字符串是否是所需数据
            if needIP.hasPrefix("var returnCitySN = ") {
                //  对字符串进行处理，然后进行Json解析，删除字符串多与字符
                for _ in 0 ..< 19 {
                    needIP.removeAtIndex(needIP.startIndex)
                }
                
                //  截取字符串
                let nowIP = needIP.substringToIndex(needIP.startIndex.advancedBy(needIP.characters.count - 1))
                //  将字符串换成二进制进行Json解析
                let data = nowIP.dataUsingEncoding(NSUTF8StringEncoding)
                
                if let needData = try? NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.MutableContainers) {
                    return needData as? NSDictionary
                } else {
                    print("解析外网地址失败")
                    return nil
                }
            }
        } else {
            print("获取外网地址失败")
        }
        
        return nil
    }
    
    
    
    
    @IBAction func recordingAction(sender: UIButton) {
        let vc = IWVideoRecordingController()
        navigationController?.pushViewController(vc, animated: true)
    }
}


