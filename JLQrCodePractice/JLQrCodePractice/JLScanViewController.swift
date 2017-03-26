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
    private var captureSession: AVCaptureSession?
    private var previewLayer: AVCaptureVideoPreviewLayer?

    private lazy var backButton:UIButton! = {
        var button = UIButton(type: UIButtonType.Custom)
        button.frame = CGRect(x: 0, y: 0, width: 62, height: 62)
        button.backgroundColor = UIColor.clearColor()
        button.setTitle("扫一扫", forState: UIControlState.Normal)
        button.setTitleColor(UIColor.orangeColor(), forState: UIControlState.Normal)
        button.backgroundColor = UIColor.lightGrayColor()
        button.addTarget(self, action: Selector("onClickScanButton:"), forControlEvents: UIControlEvents.TouchUpInside)
        button.layer.borderWidth = 2.0
        button.layer.cornerRadius = 3.0
        button.clipsToBounds = true
        
        return button
    }()
    
    private lazy var hintLabel:UILabel! = {
        var label = UILabel(frame: CGRect(x: 0, y: 0, width: 200, height: 30))
        label.center = self.view.center
        label.font = UIFont.systemFontOfSize(16)
        label.textColor = UIColor.orangeColor()
        label.backgroundColor = UIColor.clearColor()
        label.textAlignment = NSTextAlignment.Center
        return label
    }()
    
    private lazy var scanImageView:UIImageView! = {
        var imageView = UIImageView(image: UIImage(named: "img_qrCode"))
        imageView.frame = CGRect(x: 0, y: 0, width: CGRectGetWidth(self.view.frame), height: CGRectGetHeight(self.view.frame))
        return imageView
    }()
    
    private lazy var scanHintLabel:UILabel! = {
        var label = UILabel(frame: CGRect(x: 0, y: CGRectGetHeight(self.view.frame) + 120, width: CGRectGetWidth(self.view.frame), height: 40))
        label.center = self.view.center
        label.font = UIFont.systemFontOfSize(16)
        label.textColor = UIColor.orangeColor()
        label.backgroundColor = UIColor.clearColor()
        label.textAlignment = NSTextAlignment.Center
         label.text = "将二维码/条码放在框内，即可自动扫描"
        return label
    }()
    
    private lazy var resultLabel:UILabel! = {
        var label = UILabel(frame: CGRect(x: 0, y: CGRectGetMaxY(self.scanHintLabel.frame) + 10, width: CGRectGetWidth(self.view.frame), height: 80))
        label.font = UIFont.systemFontOfSize(16)
        label.textColor = UIColor.orangeColor()
        label.backgroundColor = UIColor.clearColor()
        return label
    }()
    
    
    //MARK: Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = "扫一扫"
        self.view.backgroundColor = UIColor.whiteColor()
        configueNavigationBar()
        isAvailableCamera()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK: Private
    private func configueNavigationBar(){
        
        let leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "btn_return"), style: UIBarButtonItemStyle.Plain, target: self, action: Selector("onClickLeftBarItem:"))
        self.navigationItem.leftBarButtonItem = leftBarButtonItem
        
        let rightBarButtonItem = UIBarButtonItem(title: "相册", style: UIBarButtonItemStyle.Plain, target: self, action: Selector("onClickRightBarItem:"))
        self.navigationItem.rightBarButtonItem = rightBarButtonItem
    }
    
    func isAvailableCamera(){
        
        let isAvailable = UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.Camera)
        if isAvailable{
            getCameraAuthorizationStatus()
        }else{
            showCameraNotAvailableView()
        }
        
    }
    
    func getCameraAuthorizationStatus(){
        let authStatus = AVCaptureDevice.authorizationStatusForMediaType(AVMediaTypeVideo)
        if authStatus == AVAuthorizationStatus.NotDetermined{
            
            AVCaptureDevice.requestAccessForMediaType(AVMediaTypeVideo, completionHandler: { (granted) -> Void in
                if granted{
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        self.startScanningCode()
                        self.setupCustomView()
                    })
                    
                }else{
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        self.showCameraNotDeterminedView()
                    })
                }
            })
            
        }else if authStatus == AVAuthorizationStatus.Authorized{
            self.startScanningCode()
            self.setupCustomView()
            
        }else{
            showCameraNotDeterminedView()
        }
    }
    
    func startScanningCode(){
        captureDevice = AVCaptureDevice.defaultDeviceWithMediaType(AVMediaTypeVideo)
        if (captureSession == nil){
            captureSession = AVCaptureSession()
        }
        do{
            deviceInput = try AVCaptureDeviceInput.init(device: captureDevice)
        }catch let error as NSError{
            print(error.description)
        }
        
        if ((captureSession?.canAddInput(deviceInput)) != nil){
            captureSession?.addInput(deviceInput)
        }
        
        let systemVer = UIDevice.currentDevice().systemVersion

        if Float(systemVer) >= 7.0{
            
            metadataOutput = AVCaptureMetadataOutput()
            //set scan rectange
            metadataOutput?.rectOfInterest = CGRect(x: 0.22, y: 0.16, width: 0.43, height: 0.68)
            metadataOutput?.setMetadataObjectsDelegate(self, queue: dispatch_get_main_queue())
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
                self.view.layer.insertSublayer(previewLayer!, atIndex: 0)
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
        
        let resultArray = qrDtector.featuresInImage(ciimage)
        if resultArray.count > 0
        {
            
            let feature = resultArray.first
            let qrFeature = feature as! CIQRCodeFeature
            return qrFeature.messageString
            
        }else{
            return ""
        }
        
    }
    
    
    
    //MARK: Acrion Method
    func onClickLeftBarItem(sender:UIBarButtonItem){
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    func onClickRightBarItem(sender:UIBarButtonItem){
        let imagePickerViewController = UIImagePickerController()
        imagePickerViewController.allowsEditing = true
        imagePickerViewController.delegate = self
        imagePickerViewController.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
        self.presentViewController(imagePickerViewController, animated: true) { () -> Void in
            if self.captureSession != nil{
                self.captureSession?.stopRunning()
            }
        }
    }
    

}

extension JLScanViewController:AVCaptureMetadataOutputObjectsDelegate{
    
    func captureOutput(captureOutput: AVCaptureOutput!, didOutputMetadataObjects metadataObjects: [AnyObject]!, fromConnection connection: AVCaptureConnection!){
        
        if metadataObjects.count > 0{
            captureSession?.stopRunning()
            
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
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        let selectedImage = info["UIImagePickerControllerEditedImage"] as! UIImage
        let result = self.decodeImage(selectedImage)
        
        print("result:\(result)")
        
        self.dismissViewControllerAnimated(true) { () -> Void in
            if result != ""{
                self.resultLabel.text = result
            }
        }
        
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        if self.captureSession != nil{
            captureSession?.startRunning()
        }
    }
}