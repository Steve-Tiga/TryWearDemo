//
//  TryWearViewController.m
//  TryWearDemo
//
//  Created by mac on 2019/5/8.
//  Copyright © 2019年 BSurprise. All rights reserved.
//

#import "TryWearViewController.h"
#import <AVFoundation/AVFoundation.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import "Masonry/Masonry.h"
#import "EditViewController.h"
#import "UIView+Extention.h"

#define ScreenW [UIScreen mainScreen].bounds.size.width
#define ScreenH [UIScreen mainScreen].bounds.size.height

//十六进制颜色
#define UIColorFromRGB(rgbValue) [UIColor \
colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 \
green:((float)((rgbValue & 0xFF00) >> 8))/255.0 \
blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]

// 只要添加了这个宏，就不用带mas_前缀
#define MAS_SHORTHAND
// 只要添加了这个宏，equalTo就等价于mas_equalTo
#define MAS_SHORTHAND_GLOBALS

@interface TryWearViewController ()<UIGestureRecognizerDelegate>

//捕获设备，通常是前置摄像头，后置摄像头，麦克风（音频输入）
@property (nonatomic, strong) AVCaptureDevice *device;
/**
 *  AVCaptureSession对象来执行输入设备和输出设备之间的数据传递
 */
@property (nonatomic,strong)AVCaptureSession *session;
//AVCaptureDeviceInput 代表输入设备，他使用AVCaptureDevice 来初始化
@property (nonatomic, strong) AVCaptureDeviceInput *input;

//输出图片
@property (nonatomic ,strong) AVCaptureStillImageOutput *imageOutput;
/**
 *  预览图层
 */
@property (nonatomic,strong)AVCaptureVideoPreviewLayer *previewLayer;
@property (nonatomic,strong)UIImage *image;
//闪光灯
@property (nonatomic,strong)UIButton *flash;
//镜头切换
@property (nonatomic,strong)UIButton *conversion;
//戒指界面
@property (nonatomic,strong)UIImageView *ringImgview;
//背景界面
@property (nonatomic,strong)UIView *backview;
//大图界面
@property (nonatomic,strong)UIImageView *bigImgView;

//试戴图片
@property (nonatomic,strong)UIImageView *backImg;
//第一view
@property (nonatomic,strong)UIView *firstView;

@property (nonatomic,strong)UIButton *cancel;
@end

@implementation TryWearViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    BOOL open = [self canUserCamear];
    
    if (open){
        
        [self cameraDistrict];
        [self ringView];
    }else{
        return;
    }
    [self netWorKOfRing];
}
- (void)netWorKOfRing{
//    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
//    dic[@"goods_unique_id"] = self.goodsid;
//    [NetWorkRequest sendRequestWithUrl:@"/api/apiShowTryThumb" withParameters:dic withType:@"post" success:^(id responseObject) {
//        TBLog(@"%@",responseObject);
//        if ([[responseObject valueForKey:@"code"]isEqual:@2000]){
//            self.imgString = [NSString stringWithFormat:@"%@",[[responseObject valueForKey:@"data"] valueForKey:@"goods_try_thumb"]];
//            [self.ringImgview sd_setImageWithURL:[NSURL URLWithString:self.imgString] placeholderImage:nil];
//        }
//    } failure:^(NSError *error) {
//        TBLog(@"%@",error);
//    }];
    [self.ringImgview setImage:self.tryImage];
}
- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
}
- (void)viewDidDisappear:(BOOL)animated{
    
    [super viewDidDisappear:YES];
    
    if (self.session) {
        
        [self.session stopRunning];
    }
}
#pragma mark - 检查相机权限
- (BOOL)canUserCamear{
    AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    if (authStatus == AVAuthorizationStatusDenied) {
        UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"请打开相机权限" message:@"设置-隐私-相机" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:@"取消", nil];
        alertView.tag = 100;
        [alertView show];
        return NO;
    }
    else{
        return YES;
    }
    return YES;
}
- (void)cameraDistrict
{
    //        AVCaptureDevicePositionBack  后置摄像头
    //        AVCaptureDevicePositionFront 前置摄像头
    if ([self.type isEqualToString:@"2"]){
        self.device = [self cameraWithPosition:AVCaptureDevicePositionBack];
    }else if ([self.type isEqualToString:@"5"]||[self.type isEqualToString:@"6"]){
        self.device = [self cameraWithPosition:AVCaptureDevicePositionBack];
    }else if ([self.type isEqualToString:@"1"]||[self.type isEqualToString:@"3"]||[self.type isEqualToString:@"4"]){
        self.device = [self cameraWithPosition:AVCaptureDevicePositionFront];
    }
    
    //    self.device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    self.input = [[AVCaptureDeviceInput alloc] initWithDevice:self.device error:nil];
    
    self.imageOutput = [[AVCaptureStillImageOutput alloc] init];
    
    self.session = [[AVCaptureSession alloc] init];
    //     拿到的图像的大小可以自行设定
    //    AVCaptureSessionPreset320x240
    //    AVCaptureSessionPreset352x288
    //    AVCaptureSessionPreset640x480
    //    AVCaptureSessionPreset960x540
    //    AVCaptureSessionPreset1280x720
    //    AVCaptureSessionPreset1920x1080
    //    AVCaptureSessionPreset3840x2160
    //    self.session.sessionPreset = AVCaptureSessionPreset640x480;
    //输入输出设备结合
    if ([self.session canAddInput:self.input]) {
        [self.session addInput:self.input];
    }
    if ([self.session canAddOutput:self.imageOutput]) {
        [self.session addOutput:self.imageOutput];
    }
    //预览层的生成
    self.previewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:self.session];
    self.previewLayer.frame = CGRectMake(0, 0, ScreenW, ScreenH);
    self.previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    [self.view.layer addSublayer:self.previewLayer];
    //设备取景开始
    [self.session startRunning];
    if ([_device lockForConfiguration:nil]) {
        //自动闪光灯，
        if ([_device isFlashModeSupported:AVCaptureFlashModeAuto]) {
            [_device setFlashMode:AVCaptureFlashModeAuto];
        }
        //自动白平衡,但是好像一直都进不去
        if ([_device isWhiteBalanceModeSupported:AVCaptureWhiteBalanceModeAutoWhiteBalance]) {
            [_device setWhiteBalanceMode:AVCaptureWhiteBalanceModeAutoWhiteBalance];
        }
        [_device unlockForConfiguration];
    }
    
    [self createUI];
    
}
- (void)createUI{
    self.backImg = [[UIImageView alloc]init];
    /***
     *  1.吊坠
     *  2.戒指
     *  3.项链
     *  4.耳环
     *  5.手链
     *  6.手镯
     ***/
    if ([self.type isEqualToString:@"2"]){
        self.backImg.image = [UIImage imageNamed:@"camera_hand"];
    }else if ([self.type isEqualToString:@"5"]||[self.type isEqualToString:@"6"]){
        self.backImg.image = [UIImage imageNamed:@"商品详情 试戴 手镯"];
    }else if ([self.type isEqualToString:@"1"]||[self.type isEqualToString:@"3"]||[self.type isEqualToString:@"4"]){
        self.backImg.image = [UIImage imageNamed:@"camera_head"];
    }
    
    self.backImg.frame = CGRectMake(0, 0, ScreenW, ScreenH);
    [self.view addSubview:self.backImg];
    
    UIView *headView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, ScreenW, 64)];
    headView.backgroundColor = [UIColorFromRGB(0xffcac4) colorWithAlphaComponent:0.85];
    [self.view addSubview:headView];
    
    UILabel *label = [[UILabel alloc]init];
    label.text = @"拍摄照片";
    label.font = [UIFont systemFontOfSize:17];
    label.textColor = UIColorFromRGB(0x323232);
    [headView addSubview:label];
    [label mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(20);
        make.centerX.mas_equalTo(headView);
        make.top.mas_equalTo(headView.top).offset(33);
    }];
    
    self.cancel = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.cancel setTitle:@"返回" forState:UIControlStateNormal];
    [self.cancel setTitleColor:UIColorFromRGB(0x323232) forState:UIControlStateNormal];
    self.cancel.titleLabel.font = [UIFont systemFontOfSize:15];
    [self.cancel addTarget:self action:@selector(backHome:) forControlEvents:UIControlEventTouchUpInside];
    [headView addSubview:self.cancel];
    [self.cancel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(64);
        make.left.mas_equalTo(headView.left).offset(20);
        make.centerY.mas_equalTo(label.centerY);
    }];

    UIView *footview = [[UIView alloc]initWithFrame:CGRectMake(0, ScreenH - 80, ScreenW, 80)];
    footview.backgroundColor = [UIColorFromRGB(0xffcac4) colorWithAlphaComponent:0.85];
    [self.view addSubview:footview];


    UIImage *imag = [UIImage imageNamed:@"btn_on_camera"];
    CGFloat I = imag.size.width/imag.size.height;


    UIButton *takePhoto = [UIButton buttonWithType:UIButtonTypeCustom];
    [takePhoto setImage:[UIImage imageNamed:@"btn_off_camera"] forState:UIControlStateNormal];
    [takePhoto setImage:[UIImage imageNamed:@"btn_on_camera"] forState:UIControlStateHighlighted];
    [takePhoto addTarget:self action:@selector(photoBtnDidClick) forControlEvents:UIControlEventTouchUpInside];
    [footview addSubview:takePhoto];
    [takePhoto mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(60 * I, 60));
        make.centerX.equalTo(footview);
        make.centerY.equalTo(footview);
    }];




    UIImage *image = [UIImage imageNamed:@"闪光"];
    CGFloat A = image.size.width/image.size.height;

    self.flash = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.flash setImage:[UIImage imageNamed:@"闪光"] forState:UIControlStateNormal];
    [self.flash addTarget:self action:@selector(flashButtonClick) forControlEvents:UIControlEventTouchUpInside];
    [footview addSubview:self.flash];
    [self.flash mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(30 * A, 30));
        make.left.mas_equalTo(footview.left).offset(40);
        make.centerY.equalTo(footview);
    }];


    UIImage *ima = [UIImage imageNamed:@"自拍"];
    CGFloat B = ima.size.width/ima.size.height;

    self.conversion = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.conversion setImage:[UIImage imageNamed:@"自拍"] forState:UIControlStateNormal];
    [self.conversion addTarget:self action:@selector(changeCamera) forControlEvents:UIControlEventTouchUpInside];
    [footview addSubview:self.conversion];
    [self.conversion mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(30, 30/B));
        make.right.mas_equalTo(footview.right).offset(-40);
        make.centerY.equalTo(footview);
    }];
    
}
#pragma mark -- 戒指界面
- (void)ringView{
    
    self.bigImgView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, ScreenW, ScreenH)];
    //    self.bigImgView.layer.masksToBounds = YES;
    
    self.firstView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, ScreenW, ScreenH)];
    self.firstView.backgroundColor = [[UIColor whiteColor]colorWithAlphaComponent:0.0];
    
    
    
    self.backview = [[UIView alloc]initWithFrame:CGRectMake(0, 0, ScreenW, ScreenH)];
    self.backview.backgroundColor = [[UIColor whiteColor]colorWithAlphaComponent:0.0];
    [self.firstView addSubview:self.backview];
    
    UIView *view = [[UIView alloc]initWithFrame:CGRectMake(0, 0, ScreenW, ScreenW)];
    view.backgroundColor = [[UIColor whiteColor]colorWithAlphaComponent:0.0];
    
    [self.backview addSubview:view];
    
    UIImage *image = [UIImage imageNamed:@"ring7"];
    CGFloat H = image.size.width/image.size.height;
    
    
    if ([self.type isEqualToString:@"2"]){
        self.ringImgview = [[UIImageView alloc]initWithFrame:CGRectMake((ScreenW  - 80)/2, (ScreenW - 80/H)/2, 80, 80/H)];
    }else if ([self.type isEqualToString:@"5"]||[self.type isEqualToString:@"6"]){
        self.ringImgview = [[UIImageView alloc]initWithFrame:CGRectMake((ScreenW - 200)/2, (ScreenW - 200/H)/2, 200, 200/H)];
    }else if ([self.type isEqualToString:@"1"]||[self.type isEqualToString:@"3"]||[self.type isEqualToString:@"4"]){
        self.ringImgview = [[UIImageView alloc]initWithFrame:CGRectMake((ScreenW - 200)/2, (ScreenW - 200/H)/2, 200, 200/H)];
    }
    
    
    
    
    [view addSubview:self.ringImgview];
    
    view.userInteractionEnabled = YES;
    
    //拖动手势
    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(handlePan:)];
    pan.delegate = self;
    [view addGestureRecognizer:pan];
    
    //缩放手势
    UIPinchGestureRecognizer *pinch = [[UIPinchGestureRecognizer alloc]initWithTarget:self action:@selector(handlePinch:)];
    pinch.delegate = self;
    [view addGestureRecognizer:pinch];
    
    //旋转手势
    UIRotationGestureRecognizer *rotation = [[UIRotationGestureRecognizer alloc]initWithTarget:self action:@selector(handleRotation:)];
    rotation.delegate = self;
    [view addGestureRecognizer:rotation];
    
    UIButton *edit = [UIButton buttonWithType:UIButtonTypeCustom];
    [edit setTitleColor:UIColorFromRGB(0x323232) forState:UIControlStateNormal];
    [edit setTitle:@"编辑" forState:UIControlStateNormal];
    edit.titleLabel.font = [UIFont systemFontOfSize:15];
    [edit addTarget:self action:@selector(editImage) forControlEvents:UIControlEventTouchUpInside];
    [self.firstView addSubview:edit];
    [edit mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(64, 64));
        make.right.mas_equalTo(_firstView.right);
        make.top.mas_equalTo(_firstView.top);
    }];

    UIButton *cancel = [UIButton buttonWithType:UIButtonTypeCustom];
    [cancel setTitle:@"取消" forState:UIControlStateNormal];
    [cancel setTitleColor:UIColorFromRGB(0x323232) forState:UIControlStateNormal];
    cancel.titleLabel.font = [UIFont systemFontOfSize:15];
    //    [cancel addTarget:self action:@selector(editImage) forControlEvents:UIControlEventTouchUpInside];
    [cancel addTarget:self action:@selector(cancelClick) forControlEvents:UIControlEventTouchUpInside];
    
    [self.firstView addSubview:cancel];
    [cancel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(40);
        make.left.mas_equalTo(self->_firstView.left).offset(40);
        make.centerY.mas_equalTo(self->_firstView.bottom).offset(-40);
    }];
    
    UIButton *save = [UIButton buttonWithType:UIButtonTypeCustom];
    [save setTitle:@"分享" forState:UIControlStateNormal];
    [save setTitleColor:UIColorFromRGB(0x323232) forState:UIControlStateNormal];
    save.titleLabel.font = [UIFont systemFontOfSize:15];
    [save addTarget:self action:@selector(saveClick) forControlEvents:UIControlEventTouchUpInside];
    [self.firstView addSubview:save];
    [save mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(40);
        make.right.mas_equalTo(self->_firstView.right).offset(-40);
        make.centerY.mas_equalTo(self->_firstView.bottom).offset(-40);
    }];
}

- (void)handlePan:(UIPanGestureRecognizer *)recognizer{
    CGPoint tanslation = [recognizer translationInView:self.backview];
    recognizer.view.center = CGPointMake(recognizer.view.center.x + tanslation.x, recognizer.view.center.y + tanslation.y);
    [recognizer setTranslation:CGPointZero inView:self.backview];
}
- (void)handlePinch:(UIPinchGestureRecognizer *)recognizer{
    recognizer.view.transform = CGAffineTransformScale(recognizer.view.transform, recognizer.scale, recognizer.scale);
    recognizer.scale = 1;
}
- (void)handleRotation:(UIRotationGestureRecognizer *)recognizer{
    recognizer.view.transform = CGAffineTransformRotate(recognizer.view.transform, recognizer.rotation);
    recognizer.rotation = 0;
}
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer{
    return YES;
}
- (AVCaptureDevice *)cameraWithPosition:(AVCaptureDevicePosition)position{
    NSArray *devices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    for ( AVCaptureDevice *device in devices )
        if ( device.position == position ){
            return device;
        }
    return nil;
}
#pragma mark -- 拍照
- (void)photoBtnDidClick{
    AVCaptureConnection *conntion = [self.imageOutput connectionWithMediaType:AVMediaTypeVideo];
    if (!conntion){
        NSLog(@"拍照失败");
        return;
    }
    [self.imageOutput captureStillImageAsynchronouslyFromConnection:conntion completionHandler:^(CMSampleBufferRef imageDataSampleBuffer, NSError *error) {
        if (imageDataSampleBuffer == nil){
            return ;
        }
        NSData *imageData = [AVCaptureStillImageOutput jpegStillImageNSDataRepresentation:imageDataSampleBuffer];
        self.image = [UIImage imageWithData:imageData];
        [self.session stopRunning];
        
        
        self.bigImgView.image = self->_image;
        
        [self addringview];
    }];
}
#pragma mark -- flash
- (void)flashButtonClick {
    
    NSLog(@"flashButtonClick");
    //修改前必须先锁定
    [_device lockForConfiguration:nil];
    //必须判定是否有闪光灯，否则如果没有闪光灯会崩溃
    if ([_device hasFlash]) {
        
        if (_device.flashMode == AVCaptureFlashModeOff) {
            _device.flashMode = AVCaptureFlashModeOn;
            
            [self.flash setImage:[UIImage imageNamed:@"开启"] forState:UIControlStateNormal];
        } else if (_device.flashMode == AVCaptureFlashModeOn) {
            _device.flashMode = AVCaptureFlashModeAuto;
            [self.flash setImage:[UIImage imageNamed:@"闪光"] forState:UIControlStateNormal];
        } else if (_device.flashMode == AVCaptureFlashModeAuto) {
            _device.flashMode = AVCaptureFlashModeOff;
            [self.flash setImage:[UIImage imageNamed:@"guanbi"] forState:UIControlStateNormal];
        }
        
    } else {
        
        NSLog(@"设备不支持闪光灯");
    }
    [_device unlockForConfiguration];
}
#pragma mark -- 前后摄像头切换
- (void)changeCamera{
    NSUInteger cameraCount = [[AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo] count];
    if (cameraCount > 1) {
        NSError *error;
        //给摄像头的切换添加翻转动画
        CATransition *animation = [CATransition animation];
        animation.duration = .5f;
        animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
        animation.type = @"oglFlip";
        
        AVCaptureDevice *newCamera = nil;
        AVCaptureDeviceInput *newInput = nil;
        //拿到另外一个摄像头位置
        AVCaptureDevicePosition position = [[_input device] position];
        if (position == AVCaptureDevicePositionFront){
            newCamera = [self cameraWithPosition:AVCaptureDevicePositionBack];
            animation.subtype = kCATransitionFromLeft;//动画翻转方向
        }
        else {
            newCamera = [self cameraWithPosition:AVCaptureDevicePositionFront];
            animation.subtype = kCATransitionFromRight;//动画翻转方向
        }
        //生成新的输入
        newInput = [AVCaptureDeviceInput deviceInputWithDevice:newCamera error:nil];
        [self.previewLayer addAnimation:animation forKey:nil];
        if (newInput != nil) {
            [self.session beginConfiguration];
            [self.session removeInput:self.input];
            if ([self.session canAddInput:newInput]) {
                [self.session addInput:newInput];
                self.input = newInput;
                
            } else {
                [self.session addInput:self.input];
            }
            [self.session commitConfiguration];
            
        } else if (error) {
            NSLog(@"toggle carema failed, error = %@", error);
        }
    }
}

#pragma mark - 保存至相册
- (void)saveImageToPhotoAlbum:(UIImage*)savedImage
{
    
    UIImageWriteToSavedPhotosAlbum(savedImage, self, @selector(image:didFinishSavingWithError:contextInfo:), NULL);
    
}
#pragma mark - 指定回调方法

- (void)image: (UIImage *) image didFinishSavingWithError: (NSError *) error contextInfo: (void *) contextInfo

{
    NSString *msg = nil ;
    if(error != NULL){
        msg = @"保存图片失败" ;
    }else{
        msg = @"保存图片成功" ;
    }
    //    [JProgressHUD showPopViewAtView:self.firstView WithImage:[UIImage imageNamed:@"bj"] WithTitle:msg WithViewH:(ScreenH - 64) WithY:0.4];
}
- (void)addringview{
    
    [self.view insertSubview:_bigImgView aboveSubview:self.backImg];
    self.cancel.hidden = YES;
    
    [self.view addSubview:self.firstView];
    self.flash.hidden = YES;
    self.conversion.hidden = YES;
    
}
- (void)cancelClick{
    self.cancel.hidden = NO;
    
    [self.bigImgView removeFromSuperview];
    [self.firstView removeFromSuperview];
    self.flash.hidden = NO;
    self.conversion.hidden = NO;
    [self.session startRunning];
}
- (void)saveClick{
    
    
    
    
    UIImage *image = [self captureCurrentView:self.bigImgView];
    UIImage *img = [self captureCurrentView:self.backview];
    
    
    //    UIImage *img = self.ringImgview.image;
    
    CGImageRef imgRef = img.CGImage;
    CGFloat w = CGImageGetWidth(imgRef);
    CGFloat h = CGImageGetHeight(imgRef);
    
    //以拍好的图片大小为底图
    //    UIImage *image = self.bigImgView.image;
    CGImageRef imageRef = image.CGImage;
    CGFloat W1 = CGImageGetWidth(imageRef);
    CGFloat H1 = CGImageGetHeight(imageRef);
    
    //以拍好的图片大小为画布创建上下文
    UIGraphicsBeginImageContext(CGSizeMake(W1, H1));
    [image drawInRect:CGRectMake(0, 0, W1, H1)];//先把大图画到上下文
    [img drawInRect:CGRectMake(0, 0, w, h)];//再把小图放在上下文中
    UIImage *resultImg = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndPDFContext();
    [self saveImageToPhotoAlbum:resultImg];
    
    NSArray *arr = @[resultImg];
//    [Share shareWithImage:arr Url:nil Title:nil Content:nil];
    
}
- (void)editImage{
    UIImage *image = [self captureCurrentView:self.bigImgView];
    UIImage *img = [self captureCurrentView:self.backview];
    
    
    //    UIImage *img = self.ringImgview.image;
    
    CGImageRef imgRef = img.CGImage;
    CGFloat w = CGImageGetWidth(imgRef);
    CGFloat h = CGImageGetHeight(imgRef);
    
    //以拍好的图片大小为底图
    //    UIImage *image = self.bigImgView.image;
    CGImageRef imageRef = image.CGImage;
    CGFloat W1 = CGImageGetWidth(imageRef);
    CGFloat H1 = CGImageGetHeight(imageRef);
    
    //以拍好的图片大小为画布创建上下文
    UIGraphicsBeginImageContext(CGSizeMake(W1, H1));
    [image drawInRect:CGRectMake(0, 0, W1, H1)];//先把大图画到上下文
    [img drawInRect:CGRectMake(0, 0, w, h)];//再把小图放在上下文中
    UIImage *resultImg = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndPDFContext();
    EditViewController *edit = [[EditViewController alloc]init];
    edit.image = resultImg;
    [self presentViewController:edit animated:YES completion:nil];
}
#pragma mark -- 截取view为img
- (UIImage *)captureCurrentView:(UIView *)view {
    CGRect frame = view.frame;
    //    UIGraphicsBeginImageContext(frame.size);
    //创建一个上下文，size为新创建的位图在上下文的大小，是否透明，scale因子（缩放因子）
    UIGraphicsBeginImageContextWithOptions(frame.size, NO, 0.0);
    CGContextRef contextRef = UIGraphicsGetCurrentContext();
    [view.layer renderInContext:contextRef];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}
- (void)backHome:(UIButton *)button{
    if ([button.titleLabel.text isEqualToString:@"取消"]){
        [self cancelClick];
    }else{
        
        
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

@end
