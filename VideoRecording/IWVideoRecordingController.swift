//
//  IWVideoRecordingController.swift
//  VideoRecording
//
//  Created by goWhere on 16/7/4.
//  Copyright © 2016年 iwhere. All rights reserved.
//

import UIKit
import AVFoundation
import Photos

class IWVideoRecordingController: UIViewController {
    
    //  最常视频录制时间，单位 秒
    let MaxVideoRecordTime = 6000
    
    //  MARK: - Properties
    //  视频捕获会话，他是 input 和 output 之间的桥梁，它协调着 input 和 output 之间的数据传输
    let captureSession = AVCaptureSession()
    //  视频输入设备，前后摄像头
    var camera: AVCaptureDevice?
    //  展示界面
    var previewLayer: AVCaptureVideoPreviewLayer!
    //  HeaderView 
    var headerView: UIView!
    
    //  音频输入设备
    let audioDevice = AVCaptureDevice.default(for: AVMediaType.audio)
    //  将捕获到的视频输出到文件
    let fileOut = AVCaptureMovieFileOutput()
    
    //  开始、停止按钮
    var startButton, stopButton: UIButton!
    //  前后摄像头转换、闪光灯 按钮
    var cameraSideButton, flashLightButton: UIButton!
    //  录制时间 Label
    var totolTimeLabel: UILabel!
    //  录制时间Timer
    var timer: Timer?
    var secondCount = 0
    
    //  视频操作View
    var operatorView: IWVideoOperatorView!
    
    //  表示当时是否在录像中
    var isRecording = false
    
    
    //  MARK: - LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //  录制视频基本设置
        setupAVFoundationSettings()
        
        //  UI 布局
        setupButton()
        setupHeaderView()

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.isNavigationBarHidden = true
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.isNavigationBarHidden = false
    }
    
    //  MARK: - Private Methods
    /// 对视频进行基本设置
    private func setupAVFoundationSettings() {
        // 相机
        camera = cameraWithPosition(position: AVCaptureDevice.Position.back)
        
        //  设置视频清晰度
        captureSession.sessionPreset = AVCaptureSession.Preset.vga640x480
        
        //  添加视频、音频输入设备
        if let videoInput = try? AVCaptureDeviceInput(device: camera!) {
            captureSession.addInput(videoInput)
        }
        if audioDevice != nil,
           let audioInput = try? AVCaptureDeviceInput(device: audioDevice!) {
            captureSession.addInput(audioInput)
        }
        
        //  添加视频捕获输出
        self.captureSession.addOutput(fileOut)
        
        //  使用 AVCaptureVideoPreviewLayer 可以将摄像头拍到的实时画面显示在 ViewController 上
        let videoLayer = AVCaptureVideoPreviewLayer(session: self.captureSession)
        videoLayer.frame = view.bounds
        videoLayer.videoGravity = AVLayerVideoGravity.resizeAspectFill
        view.layer.addSublayer(videoLayer)
        
        previewLayer = videoLayer
        
        //  启动 Session 回话
        self.captureSession.startRunning()
    }
    
    /// 选择摄像头
    private func cameraWithPosition(position: AVCaptureDevice.Position) -> AVCaptureDevice? {
        let devices = AVCaptureDevice.devices(for: AVMediaType.video)
        for item in devices {
            if item.position == position {
                return item
            }
        }
        return nil
    }
    
    
    //  MARK: - UI Settings
    /**
     创建按钮
     */
    private func setupButton() {
        //  开始按钮
        startButton = prepareButtons(btnTitle: "开始", btnSize: CGSize(width: 120, height: 50), btnCenter: CGPoint(x: view.bounds.width / 2 - 70, y: view.bounds.height - 50))
        startButton.backgroundColor = UIColor.red
        startButton.addTarget(self, action: #selector(onClickedStartButton(startButton:)), for: .touchUpInside)
        
        //  结束按钮
        stopButton = prepareButtons(btnTitle: "结束", btnSize: CGSize(width: 120, height: 50), btnCenter: CGPoint(x: view.bounds.width / 2 + 70, y: view.bounds.height - 50))
        stopButton.backgroundColor = UIColor.lightGray
        stopButton.isUserInteractionEnabled = false
        stopButton.addTarget(self, action: #selector(onClickedEndButton(endButton:)), for: .touchUpInside)
    }
    
    //  开始、结束按钮风格统一
    private func prepareButtons(btnTitle title: String, btnSize size: CGSize, btnCenter center: CGPoint) -> UIButton {
        let button = UIButton(frame: CGRect(x: 0, y: 0, width: size.width, height: size.height))
        button.center = center
        button.clipsToBounds = true
        button.layer.cornerRadius = 20
        button.setTitle(title, for: .normal)
        button.setTitleColor(UIColor.white, for: .normal)
        view.addSubview(button)
        return button
    }
    
    //  headerView
    private func setupHeaderView() {
        headerView = UIView(frame: CGRect(x: 0, y: 0, width: view.bounds.width, height: 64))
        headerView.backgroundColor = UIColor.black.withAlphaComponent(0.3)
        view.addSubview(headerView)
        
        let centerY = headerView.center.y + 5
        let defaultWidth: CGFloat = 40
        
        //  返回、摄像头调整、时间、闪光灯四个按钮
        let backButton = UIButton(frame: CGRect(x: 0, y: 0, width: 20, height: 20))
        backButton.setBackgroundImage(UIImage(named: "iw_back"), for: .normal)
        backButton.addTarget(self, action: #selector(backAction), for: .touchUpInside)
        backButton.center = CGPoint(x: 25, y: centerY)
        headerView.addSubview(backButton)
        
        cameraSideButton = UIButton(frame: CGRect(x: 0, y: 0, width: defaultWidth, height: defaultWidth * 68 / 99.0))
        cameraSideButton.setBackgroundImage(UIImage(named: "iw_cameraSide"), for: .normal)
        cameraSideButton.center = CGPoint(x: 100, y: centerY)
        cameraSideButton.addTarget(self, action: #selector(changeCamera(cameraSideButton:)), for: .touchUpInside)
        headerView.addSubview(cameraSideButton)
        
        totolTimeLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 100, height: 20))
        totolTimeLabel.center = CGPoint(x: headerView.center.x, y: centerY)
        totolTimeLabel.textColor = UIColor.white
        totolTimeLabel.textAlignment = .center
        totolTimeLabel.font = UIFont.systemFont(ofSize: 19)
        totolTimeLabel.text = "00:00:00"
        view.addSubview(totolTimeLabel)
        
        flashLightButton = UIButton(frame: CGRect(x: 0, y: 0, width: defaultWidth, height: defaultWidth * 68 / 99.0))
        flashLightButton.setBackgroundImage(UIImage(named: "iw_flashOn"), for: .selected)
        flashLightButton.setBackgroundImage(UIImage(named: "iw_flashOff"), for: .normal)
        flashLightButton.center = CGPoint(x: headerView.bounds.width - 100, y: centerY)
        flashLightButton.addTarget(self, action: #selector(switchFlashLight(flashButton:)), for: .touchUpInside)
        headerView.addSubview(flashLightButton)
        
    }
    
    //  MARK: - UIButton Actions
    //  按钮点击事件
    //  点击开始录制视频
    @objc private func onClickedStartButton(startButton: UIButton) {
        hiddenHeaderView(isHidden: true)
        //  开启计时器
        timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(videoRecordingTotolTime), userInfo: nil, repeats: true)
        if !isRecording {
            //  记录状态： 录像中 ...
            isRecording = true
            captureSession.startRunning()

            
            //  设置录像保存地址，在 Documents 目录下，名为 当前时间.mp4
            let path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
            let documentDirectory = path[0] as String
            let filePath: String? = "\(documentDirectory)/\(Date()).mp4"
            let fileUrl: URL? = URL(fileURLWithPath: filePath!)
            //  启动视频编码输出
            fileOut.startRecording(to: fileUrl!, recordingDelegate: self)
            
            //  开始、结束按钮改变颜色
            startButton.backgroundColor = UIColor.lightGray
            stopButton.backgroundColor = UIColor.red
            startButton.isUserInteractionEnabled = false
            stopButton.isUserInteractionEnabled = true
        }
        
    }
    
    //  点击停止按钮，停止了录像
    @objc private func onClickedEndButton(endButton: UIButton) {
        hiddenHeaderView(isHidden: false)
        
        //  关闭计时器
        timer?.invalidate()
        timer = nil
        secondCount = 0
        
        if isRecording {
            //  停止视频编码输出
            captureSession.stopRunning()
            
            //  记录状态： 录像结束 ...
            isRecording = false
            
            //  开始结束按钮颜色改变
            startButton.backgroundColor = UIColor.red
            stopButton.backgroundColor = UIColor.lightGray
            startButton.isUserInteractionEnabled = true
            stopButton.isUserInteractionEnabled = false
        }
        
        //  弹出View
        operatorView = (Bundle.main.loadNibNamed("IWVideoOperatorView", owner: self, options: nil)?.first as! IWVideoOperatorView)
        operatorView.getSuperViewController(superController: self)
        
        operatorView.frame = CGRect(x: 0, y: view.bounds.height, width: view.bounds.width, height: view.bounds.height)
        view.addSubview(operatorView)
        
        UIView.animate(withDuration: 0.3) {
            self.operatorView.frame.origin.y = 0
        }
    }
    
    //  录制时间
    @objc private func videoRecordingTotolTime() {
        secondCount += 1
        
        //  判断是否录制超时
        if secondCount == MaxVideoRecordTime {
            timer?.invalidate()
            HsuAlert(title: "最常只能录制十分钟呢", message: nil, ensureTitle: "确定", cancleTitle: nil, ensureAction: nil, cancleAction: nil)
        }
        
        let hours = secondCount / 3600
        let mintues = (secondCount % 3600) / 60
        let seconds = secondCount % 60
        
        totolTimeLabel.text = String(format: "%02d", hours) + ":" + String(format: "%02d", mintues) + ":" + String(format: "%02d", seconds)
    }
    
    //  是否隐藏 HeaderView
    func hiddenHeaderView(isHidden: Bool) {
        if isHidden {
            UIView.animate(withDuration: 0.2) {
               self.headerView.frame.origin.y -= 64
            }
        } else {
            UIView.animate(withDuration: 0.2) {
                self.headerView.frame.origin.y += 64
            }
        }
    }
    
    //  返回上一页
    @objc private func backAction() {
        self.navigationController?.popViewController(animated: true)
    }
    
    //  调整摄像头
    @objc private func changeCamera(cameraSideButton: UIButton) {
        cameraSideButton.isSelected = !cameraSideButton.isSelected
        captureSession.stopRunning()
        //  首先移除所有的 input
        if let  allInputs = captureSession.inputs as? [AVCaptureDeviceInput] {
            for input in allInputs {
                captureSession.removeInput(input)

            }
        }
        
        changeCameraAnimate()
        
        //  添加音频输出
        if audioDevice != nil,
            let audioInput = try? AVCaptureDeviceInput(device: audioDevice!) {
            self.captureSession.addInput(audioInput)
        }

        if cameraSideButton.isSelected {
            camera = cameraWithPosition(position: .front)
            if let input = try? AVCaptureDeviceInput(device: camera!) {
                captureSession.addInput(input)
            }
            
            if flashLightButton.isSelected {
                flashLightButton.isSelected = false
            }
        } else {
            camera = cameraWithPosition(position: .back)
            if let input = try? AVCaptureDeviceInput(device: camera!) {
                captureSession.addInput(input)
            }
        }
    }
    
    //  切换动画
    private func changeCameraAnimate() {
        let changeAnimate = CATransition()
        changeAnimate.delegate = self
        changeAnimate.duration = 0.4
        changeAnimate.type = CATransitionType(rawValue: "oglFlip")
        changeAnimate.subtype = CATransitionSubtype.fromRight
        previewLayer.add(changeAnimate, forKey: "changeAnimate")
    }
    
    //  开启闪光灯
    @objc private func switchFlashLight(flashButton: UIButton) {
        if self.camera?.position == AVCaptureDevice.Position.front {
            return
        }
        let camera = cameraWithPosition(position: .back)
        if camera?.torchMode == AVCaptureDevice.TorchMode.off {
            do {
                try camera?.lockForConfiguration()
            } catch let error as NSError {
                print("开启闪光灯失败 ： \(error)")
            }
            
            camera?.torchMode = AVCaptureDevice.TorchMode.on
            camera?.flashMode = AVCaptureDevice.FlashMode.on
            camera?.unlockForConfiguration()
            
            flashButton.isSelected = true
        } else {
            do {
                try camera?.lockForConfiguration()
            } catch let error as NSError {
                print("关闭闪光灯失败： \(error)")
            }
            
            camera?.torchMode = AVCaptureDevice.TorchMode.off
            camera?.flashMode = AVCaptureDevice.FlashMode.off
            camera?.unlockForConfiguration()
            
            flashButton.isSelected = false
        }
    }
    
    override var shouldAutorotate: Bool {
        return false
    }
    
    override var preferredInterfaceOrientationForPresentation: UIInterfaceOrientation {
        return .portrait
    }
}

// MARK: - CAAnimationDelegate
extension IWVideoRecordingController: CAAnimationDelegate {
    /// 动画开始
    func animationDidStart(_ anim: CAAnimation) {
        captureSession.startRunning()
    }
    
    /// 动画结束
    func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
    }
}

// MARK: - AVCaptureFileOutputRecordingDelegate
extension IWVideoRecordingController: AVCaptureFileOutputRecordingDelegate {
    /// 开始录制
    func fileOutput(_ output: AVCaptureFileOutput, didStartRecordingTo fileURL: URL, from connections: [AVCaptureConnection]) {
        
    }
    
    /// 结束录制
    func fileOutput(_ output: AVCaptureFileOutput, didFinishRecordingTo outputFileURL: URL, from connections: [AVCaptureConnection], error: Error?) {
        operatorView.getVideoUrl(videoUrl: outputFileURL)
    }
}

