//
//  JLScanViewController.swift
//  JLQrCodePractice
//
//  Created by Sunxiaolin on 17/3/25.
//  Copyright © 2017年 JackLin. All rights reserved.
//

import UIKit
import AVFoundation

class JLScanViewController: UIViewController {
    
    private var captureDevice: AVCaptureDevice?
    private var deviceInput: AVCaptureDeviceInput?
    private var metadataOutput: AVCaptureMetadataOutput?
    fileprivate var captureSession: AVCaptureSession!
    private var previewLayer: AVCaptureVideoPreviewLayer?

    private lazy var backButton:UIButton! = {
        var button = UIButton(type: UIButtonType.custom)
        button.frame = CGRect(x: 0, y: 0, width: 62, height: 62)
        button.backgroundColor = UIColor.clear
        button.setTitle("扫一扫", for: UIControlState.normal)
        button.setTitleColor(UIColor.orange, for: UIControlState.normal)
        button.backgroundColor = UIColor.lightGray
        button.addTarget(self, action: #selector(onClickLeftBarItem(sender:)), for: UIControlEvents.touchUpInside)
        button.layer.borderWidth = 2.0
        button.layer.cornerRadius = 3.0
        button.clipsToBounds = true
        
        return button
    }()
    
    private lazy var hintLabel:UILabel! = {
        var label = UILabel(frame: CGRect(x: 0, y: 0, width: 200, height: 30))
        label.center = self.view.center
        label.font = UIFont.systemFont(ofSize: 16)
        label.textColor = UIColor.orange
        label.backgroundColor = UIColor.clear
        label.textAlignment = NSTextAlignment.center
        return label
    }()
    
    private lazy var scanImageView:UIImageView! = {
        var imageView = UIImageView(image: UIImage(named: "img_qrCode"))
        imageView.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height)
        return imageView
    }()
    
    private lazy var scanHintLabel:UILabel! = {
        var label = UILabel(frame: CGRect(x: 0, y: self.view.frame.height/2 + 120, width: self.view.frame.width, height: 40))
        label.center = self.view.center
        label.font = UIFont.systemFont(ofSize: 16)
        label.textColor = UIColor.orange
        label.backgroundColor = UIColor.clear
        label.textAlignment = NSTextAlignment.center
        label.text = "将二维码/条码放在框内，即可自动扫描"
        return label
    }()
    
    fileprivate lazy var resultLabel:UILabel! = {
        var label = UILabel(frame: CGRect(x: 0, y: self.scanHintLabel.frame.maxY + 10, width: self.view.frame.width, height: 80))
        label.font = UIFont.systemFont(ofSize: 16)
        label.textColor = UIColor.orange
        label.backgroundColor = UIColor.clear
        return label
    }()
    
    
    //MARK: Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = "扫一扫"
        self.view.backgroundColor = UIColor.white
        configueNavigationBar()
        isAvailableCamera()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated);
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK: Private
    private func configueNavigationBar(){
        
        let leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "btn_return"), style: UIBarButtonItemStyle.plain, target: self, action: #selector(onClickLeftBarItem(sender:)))
        self.navigationItem.leftBarButtonItem = leftBarButtonItem
        
        let rightBarButtonItem = UIBarButtonItem(title: "相册", style: UIBarButtonItemStyle.plain, target: self, action: #selector(onClickRightBarItem(sender:)))
        self.navigationItem.rightBarButtonItem = rightBarButtonItem
    }
    
    func isAvailableCamera(){
        
        let isAvailable = UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.camera)
        if isAvailable{
            getCameraAuthorizationStatus()
        }else{
            showCameraNotAvailableView()
        }
        
    }
    
    func getCameraAuthorizationStatus(){
        let authStatus = AVCaptureDevice.authorizationStatus(forMediaType: AVMediaTypeVideo)
        if authStatus == AVAuthorizationStatus.notDetermined{
            
            AVCaptureDevice.requestAccess(forMediaType: AVMediaTypeVideo, completionHandler: { (granted) -> Void in
                if granted{
                    DispatchQueue.main.async {
                        self.startScanningCode()
                        self.setupCustomView()
                    }
                    
                }else{
                    DispatchQueue.main.async {
                        self.showCameraNotDeterminedView()
                    }
                }
            })
            
        }else if authStatus == AVAuthorizationStatus.authorized{
            self.startScanningCode()
            self.setupCustomView()
            
        }else{
            showCameraNotDeterminedView()
        }
    }
    
    func startScanningCode(){
        captureDevice = AVCaptureDevice.defaultDevice(withMediaType: AVMediaTypeVideo)
        if (captureSession == nil){
            captureSession = AVCaptureSession()
        }
        do{
            deviceInput = try AVCaptureDeviceInput.init(device: captureDevice)
        }catch let error as NSError{
            print(error.description)
        }
        
        captureSession.addInput(deviceInput)
        
        let systemVer = Double(UIDevice.current.systemVersion)!

        if systemVer > 7.0 {
            
            metadataOutput = AVCaptureMetadataOutput()
            //set scan rectange
            metadataOutput?.rectOfInterest = CGRect(x: 0.22, y: 0.16, width: 0.43, height: 0.68)
            metadataOutput?.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
            captureSession?.canSetSessionPreset(AVCaptureSessionPresetHigh)
            if ((captureSession?.canAddOutput(metadataOutput)) != nil){
                captureSession?.addOutput(metadataOutput)
            }
            
            //set code type
            if #available(iOS 9.0, *) {
                metadataOutput?.metadataObjectTypes = [AVMediaTypeMetadataObject]
                
                previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
                previewLayer?.videoGravity = AVLayerVideoGravityResizeAspectFill
                previewLayer?.frame = self.view.bounds
                self.view.layer.insertSublayer(previewLayer!, at: 0)
                captureSession?.startRunning()
                
            } else {
                // Fallback on earlier versions
            }
            
            
        }else{
            //need third lib to supported
        }
    }
    
    func setupCustomView(){
        self.view.addSubview(self.scanImageView)
        self.view.addSubview(self.scanHintLabel)
        self.view.addSubview(self.resultLabel)
        
    }
    
    func showCameraNotAvailableView(){
        self.view.addSubview(self.hintLabel)
        self.hintLabel.text = "摄像头不可用"
    }
    
    func showCameraNotDeterminedView(){
        self.view.addSubview(self.hintLabel)
        self.hintLabel.text = "未授权摄像头"
    }
    
    func decodeImage(decodedImage:UIImage)->String{
        let data = UIImagePNGRepresentation(decodedImage)
        
        guard let ciimage = CIImage(data: data!) else{
            return ""
        }
        
        let qrDtector = CIDetector(ofType: CIDetectorTypeQRCode, context: CIContext(options: [kCIContextUseSoftwareRenderer: (true)]), options: [CIDetectorAccuracy: CIDetectorAccuracyHigh])
        
        let resultArray = qrDtector?.features(in: ciimage)
        if (resultArray?.count)! > 0
        {
            
            let feature = resultArray?.first
            let qrFeature = feature as! CIQRCodeFeature
            return qrFeature.messageString!
            
        }else{
            return ""
        }
        
    }
    
    
    
    //MARK: Acrion Method
    func onClickLeftBarItem(sender:UIBarButtonItem){
        self.navigationController?.popViewController(animated: true)
    }
    
    func onClickRightBarItem(sender:UIBarButtonItem){
        let imagePickerViewController = UIImagePickerController()
        imagePickerViewController.allowsEditing = true
        imagePickerViewController.delegate = self
        imagePickerViewController.sourceType = UIImagePickerControllerSourceType.photoLibrary
        self.present(imagePickerViewController, animated: true) { () -> Void in
            if self.captureSession != nil{
                self.captureSession?.stopRunning()
            }
        }
    }
    

}

extension JLScanViewController:AVCaptureMetadataOutputObjectsDelegate{
    
    func captureOutput(_ captureOutput: AVCaptureOutput!, didOutputMetadataObjects metadataObjects: [Any]!, from connection: AVCaptureConnection!){
        
        if metadataObjects.count > 0{
            self.captureSession?.stopRunning()
            
            let metadataObject = metadataObjects.first as! AVMetadataMachineReadableCodeObject
            
            guard let result = metadataObject.stringValue else{
                return
            }
            
            print(result)
            self.resultLabel.text = result
        }
    }
}

extension JLScanViewController:UINavigationControllerDelegate, UIImagePickerControllerDelegate{
    private func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        let selectedImage = info["UIImagePickerControllerEditedImage"] as! UIImage
        let result = self.decodeImage(decodedImage: selectedImage)
        
        print("result:\(result)")
        
        self.dismiss(animated: true) { () -> Void in
            if result != ""{
                self.resultLabel.text = result
            }
        }
        
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        if self.captureSession != nil{
            captureSession?.startRunning()
        }
    }
}
