//
//  JLScanViewController.m
//  JLQrCodePractice
//
//  Created by JackLin on 2017/3/24.
//  Copyright © 2017年 JackLin. All rights reserved.
//

#import "JLScanViewController.h"
#import <AVFoundation/AVFoundation.h>

@interface JLScanViewController ()<AVCaptureMetadataOutputObjectsDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate>{
    
    AVCaptureDevice *_device;
    AVCaptureDeviceInput *_deviceInput;
    AVCaptureMetadataOutput *_metadataOutput;
    AVCaptureSession *_session;
    AVCaptureVideoPreviewLayer *_previewLayer;
    
}

@property (nonatomic, strong) UIButton *backButton;
@property (nonatomic, strong) UILabel *hintLabel;
@property (nonatomic, strong) UIImageView *scanImageView;
@property (nonatomic, strong) UILabel *scanHintLabel;
@property (nonatomic, strong) UILabel *resultLabel;
@end

@implementation JLScanViewController
#pragma mark - Life Cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"扫一扫";
    self.view.backgroundColor = [UIColor whiteColor];
    [self p_configueNavigationBar];
    [self p_isAvailableCamera];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    if (_session) {
        [_session startRunning];
    }
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    if (_session) {
        [_session stopRunning];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Getters
- (UIButton *)backButton{
    if (!_backButton) {
        _backButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _backButton.frame = CGRectMake(0, 0, 62, 62);
        [_backButton setImage:[UIImage imageNamed:@"btn_return"] forState:UIControlStateNormal];
        [_backButton setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
        [_backButton setImageEdgeInsets:UIEdgeInsetsMake(0, -12, 0, 0)];
        [_backButton setBackgroundColor:[UIColor clearColor]];
        [_backButton addTarget:self
                        action:@selector(onClickBackButton:)
              forControlEvents:UIControlEventTouchUpInside];
    }
    return _backButton;
}

- (UILabel *)hintLabel{
    if (!_hintLabel) {
        _hintLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 200, 30)];
        _hintLabel.center = self.view.center;
        _hintLabel.font = [UIFont systemFontOfSize:16];
        _hintLabel.textColor = [UIColor orangeColor];
        _hintLabel.backgroundColor = [UIColor clearColor];
        _hintLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _hintLabel;
}

- (UIImageView *)scanImageView{
    if (!_scanImageView) {
        _scanImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.frame), CGRectGetHeight(self.view.frame))];
        _scanImageView.image = [UIImage imageNamed:@"img_qrCode"];
    }
    return _scanImageView;
}

- (UILabel *)scanHintLabel{
    if (!_scanHintLabel) {
        _scanHintLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, CGRectGetHeight(self.view.frame)/2 + 120, CGRectGetWidth(self.view.frame), 40)];
        _scanHintLabel.font = [UIFont systemFontOfSize:16];
        _scanHintLabel.textColor = [UIColor orangeColor];
        _scanHintLabel.backgroundColor = [UIColor clearColor];
        _scanHintLabel.textAlignment = NSTextAlignmentCenter;
        _scanHintLabel.text = @"将二维码/条码放在框内，即可自动扫描";
    }
    return _scanHintLabel;
}

- (UILabel *)resultLabel{
    if (!_resultLabel) {
        _resultLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(self.scanHintLabel.frame) + 10,  CGRectGetWidth(self.view.frame), 80)];
        _resultLabel.backgroundColor = [UIColor clearColor];
        _resultLabel.font = [UIFont systemFontOfSize:16];
        _resultLabel.textColor = [UIColor grayColor];
        _resultLabel.textAlignment = NSTextAlignmentCenter;
        _resultLabel.numberOfLines = 0;
    }
    return _resultLabel;
}
#pragma mark - Action
- (void)onClickBackButton:(UIButton *)sender{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)onClickPhotoBarItem:(UIBarButtonItem *)sender{
    UIImagePickerController *imagePickerVirewController = [[UIImagePickerController alloc] init];
    imagePickerVirewController.allowsEditing = YES;
    imagePickerVirewController.delegate = self;
    imagePickerVirewController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    [self presentViewController:imagePickerVirewController animated:YES completion:^{
        if (_session) {
            [_session stopRunning];
        }
    }];
}

#pragma mark - Private
- (void)p_configueNavigationBar{
    self.navigationController.navigationBar.translucent = YES;
    UIBarButtonItem *leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:self.backButton];
    self.navigationItem.leftBarButtonItem = leftBarButtonItem;
    UIBarButtonItem*rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"相册"
                                                                          style:UIBarButtonItemStylePlain
                                                                         target:self
                                                                         action:@selector(onClickPhotoBarItem:)];
    self.navigationItem.rightBarButtonItem = rightBarButtonItem;
}

- (void)p_isAvailableCamera{
    BOOL isAvailable = [UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera];
    if (isAvailable) {
        [self p_getCameraAuthorizationStatus];
    }else{
        //摄像头不支持
        [self p_showCameraNotAvailableView];
    }
}

- (void)p_getCameraAuthorizationStatus{
    
    AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    if (authStatus == AVAuthorizationStatusNotDetermined) {
        __weak typeof(self) weakSelf = self;
        [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
            if (granted) {
                //授权成功
                dispatch_async(dispatch_get_main_queue(), ^{
                    [weakSelf p_startScanningQrCode];
                    [weakSelf p_setupCustomView];
                });
                
            }else{
                //授权失败
                dispatch_async(dispatch_get_main_queue(), ^{
                     [self p_showNotDeterminedView];
                });
               
            }
        }];
    }else if (authStatus == AVAuthorizationStatusAuthorized){
        //已授权
        [self p_startScanningQrCode];
        [self p_setupCustomView];
    }else{
        //受限，未授权
        [self p_showNotDeterminedView];
    }
}

- (void)p_showCameraNotAvailableView{
    [self.view addSubview:self.hintLabel];
    self.hintLabel.text = @"摄像头不可用";
}

- (void)p_showNotDeterminedView{
    [self.view addSubview:self.hintLabel];
    self.hintLabel.text = @"未授权摄像头";
}

- (void)p_startScanningQrCode{
    _device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    
    if (!_session){
        _session = [[AVCaptureSession alloc] init];
    }
    
    NSError *error;
    _deviceInput = [AVCaptureDeviceInput deviceInputWithDevice:_device error:&error];
    if ([_session canAddInput:_deviceInput]) {
        [_session addInput:_deviceInput];
    }else{
        if (error) {
            NSLog(@"%@", error.description);
        }
    }
    
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0) {
        //7.0以上系统支持二维码扫描
        
        //元数据输出对象
        _metadataOutput = [[AVCaptureMetadataOutput alloc]init];
        //设置有效扫描区域
        [_metadataOutput setRectOfInterest:CGRectMake(0.22,0.16,0.43,0.68)];
        [_metadataOutput setMetadataObjectsDelegate:self queue:dispatch_get_main_queue()];
        //设置质量等级
        [_session setSessionPreset:AVCaptureSessionPresetHigh];
        if ([_session canAddOutput:_metadataOutput]) {
            [_session addOutput:_metadataOutput];
        }
        
        //设置条码类型
        _metadataOutput.metadataObjectTypes = @[AVMetadataObjectTypeQRCode];
        //添加扫描页面
        _previewLayer = [AVCaptureVideoPreviewLayer layerWithSession:_session];
        _previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
        _previewLayer.frame = self.view.layer.bounds;
        [self.view.layer insertSublayer:_previewLayer atIndex:0];
        [_session startRunning];
        
    }else{
        //考虑使用第三方库
    }
    
}

- (void)p_setupCustomView{
    [self.view addSubview:self.scanImageView];
    [self.view addSubview:self.scanHintLabel];
    [self.view addSubview:self.resultLabel];
}

- (NSString *)p_decodeImage:(UIImage *)image{
    NSData *imageData = UIImagePNGRepresentation(image);
    CIImage *ciimage = [CIImage imageWithData:imageData];
    if (!ciimage) {
        return nil;
    }
    CIDetector *qrDetector = [CIDetector detectorOfType:CIDetectorTypeQRCode
                                                context:[CIContext contextWithOptions:@{kCIContextUseSoftwareRenderer: @(YES)}]
                                                options:@{CIDetectorAccuracy : CIDetectorAccuracyHigh}];
    NSArray *resultArray = [qrDetector featuresInImage:ciimage];
    if (!resultArray.count) {
        return nil;
    }
    
    CIFeature *feature = resultArray.firstObject;
    CIQRCodeFeature *qrFeature = (CIQRCodeFeature *)feature;
    NSString *result = qrFeature.messageString;
    return result;
}

#pragma mark - AVCaptureMetadataOutputObjectsDelegate
- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects fromConnection:(AVCaptureConnection *)connection{
    //扫描有结果，就停止扫描
    if ([metadataObjects count] > 0) {
        [_session stopRunning];
        
        AVMetadataMachineReadableCodeObject *metaDataObject = metadataObjects.firstObject;
        NSString *result = metaDataObject.stringValue;
        NSLog(@"result = %@", result);
        
        self.resultLabel.text = [NSString stringWithFormat:@"扫描结果：%@", result];
    }
}

#pragma mark - UIImagePickerControllerDelegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info{
    
    UIImage *selectedImage = info[@"UIImagePickerControllerEditedImage"];
    NSString *result = [self p_decodeImage:selectedImage];
    __weak typeof(self) weakSelf = self;
    [self dismissViewControllerAnimated:YES completion:^{
        if (result) {
            weakSelf.resultLabel.text = [NSString stringWithFormat:@"扫描结果：%@", result];
        }
    }];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker{
    if (_session) {
        [_session startRunning];
    }
}

@end
