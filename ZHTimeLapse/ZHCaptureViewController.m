//
//  ZHCaptureViewController.m
//  ZHTimeLapse
//
//  Created by Zakk Hoyt on 12/21/15.
//  Copyright © 2015 Zakk Hoyt. All rights reserved.
//
//  https://github.com/rehatkathuria/SnappingSlider

#import "ZHCaptureViewController.h"
#import "GPUImage.h"
#import "NSTimer+Blocks.h"
#import "ZHSession.h"
#import "UIViewController+AlertController.h"
#import "ZHFiltersViewController.h"
#import "ZHShutterButton.h"
#import "ZHRenderer.h"
#import "MBProgressHUD.h"
#import "ZHFileManager.h"
#import "ZHUserDefaults.h"

@interface ZHCaptureViewController ()

// GPUImage stuff
@property (weak, nonatomic) IBOutlet GPUImageView *filterView;
@property (nonatomic, strong) GPUImageVideoCamera *videoCamera;
@property (nonatomic, strong) GPUImageRawDataOutput *rawOutput;
@property (nonatomic, strong) NSTimer *captureTimer;

// UI Stuff
@property (weak, nonatomic) IBOutlet UIImageView *captureImageView;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *startBarButtonItem;
@property (weak, nonatomic) IBOutlet UILabel *frameCountLabel;
@property (weak, nonatomic) IBOutlet UIView *bottomToolbarView;
@property (weak, nonatomic) IBOutlet UIView *topToolbarView;
@property (strong, nonatomic) IBOutletCollection(UIView) NSArray *rotatableViews;
@property (weak, nonatomic) IBOutlet UIButton *frameRateButton;
@property (weak, nonatomic) IBOutlet UILabel *frameRateLabel;
@property (weak, nonatomic) IBOutlet UIView *frameRateView;


@property (weak, nonatomic) IBOutlet UIButton *exportButton;
@property (weak, nonatomic) IBOutlet ZHShutterButton *shutterButton;
@property (weak, nonatomic) IBOutlet UIButton *resolutionButton;
@property (weak, nonatomic) IBOutlet UILabel *resolutionLabel;
@property (weak, nonatomic) IBOutlet UIView *resolutionView;

@property (weak, nonatomic) IBOutlet UISlider *paramSlider;
@property (weak, nonatomic) IBOutlet UIButton *cameraButton;
@property (weak, nonatomic) IBOutlet UIButton *filterButton;
@property (weak, nonatomic) IBOutlet UIButton *closeButton;

// i-vars

@property (nonatomic) AVCaptureDevicePosition cameraPosition;
@property (nonatomic, strong) UIView *filterSelectionView;

@property (nonatomic) UIDeviceOrientation lastOrientation;
@property (nonatomic) BOOL isRecording;
@end

@implementation ZHCaptureViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if(_session == nil) {
        _session = [ZHSession session];
    }

    
    [self addOrientationMonitor];
    [self setupUI];
    [self setupCaptureSession];
    
}


-(void)addOrientationMonitor {
    NSLog(@"%s", __FUNCTION__);
    _lastOrientation = [UIDevice currentDevice].orientation;
    [NSTimer scheduledTimerWithTimeInterval:0.1 block:^{
        
        if(_isRecording) {
            //            NSLog(@"Ignoring rotate because we are recording");
            return;
        }
        
        UIDeviceOrientation orientation = [UIDevice currentDevice].orientation;
        if(orientation != _lastOrientation) {
            [self updateUIForOrientation:orientation];
            _lastOrientation = [UIDevice currentDevice].orientation;
        }
    } repeats:YES];
    [self updateUIForOrientation:_lastOrientation];
}

-(void)updateUIForOrientation:(UIDeviceOrientation)orientation {
    NSLog(@"%s", __FUNCTION__);
    [UIView animateWithDuration:0.3 animations:^{
        [self.rotatableViews enumerateObjectsUsingBlock:^(UIView  * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            switch (orientation) {
                case UIDeviceOrientationLandscapeLeft:
                    obj.transform = CGAffineTransformMakeRotation(M_PI_2);
                    break;
                case UIDeviceOrientationLandscapeRight:
                    obj.transform = CGAffineTransformMakeRotation(-M_PI_2);
                    break;
                case UIDeviceOrientationPortraitUpsideDown:
                    obj.transform = CGAffineTransformMakeRotation(M_PI);
                    break;
                default:
                    obj.transform = CGAffineTransformIdentity;
                    break;
            }
        }];
    }];
    
}




-(void)shutterButtonAction:(ZHShutterButton*)sender {
    NSLog(@"");
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = YES;
    [UIApplication sharedApplication].statusBarHidden = YES;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(BOOL)prefersStatusBarHidden {
    return YES;
}


-(void)singleTap:(UITapGestureRecognizer*)sender {
    if(sender.state == UIGestureRecognizerStateEnded) {
        CGPoint touchPoint = [sender locationInView:sender.view];
        NSLog(@"Tap to Focus");
        
        if([_videoCamera.inputCamera isFocusPointOfInterestSupported]&&[_videoCamera.inputCamera isFocusModeSupported:AVCaptureFocusModeAutoFocus])
        {
            
            if([_videoCamera.inputCamera lockForConfiguration :nil])
            {
                [_videoCamera.inputCamera setFocusPointOfInterest :touchPoint];
                [_videoCamera.inputCamera setFocusMode :AVCaptureFocusModeLocked];
                
                if([_videoCamera.inputCamera isExposurePointOfInterestSupported])
                {
                    [_videoCamera.inputCamera setExposurePointOfInterest:touchPoint];
                    [_videoCamera.inputCamera setExposureMode:AVCaptureExposureModeLocked];
                }
                [_videoCamera.inputCamera unlockForConfiguration];
            }
        }
    }
}

#pragma mark Private methods

-(void)updateResolutionLabel {
    self.resolutionLabel.text = [NSString stringWithFormat:@"%lu\n%lu",
                                 (unsigned long)_session.input.size.width,
                                 (unsigned long)_session.input.size.height];

}

-(void)swipeFramerateAction:(UISwipeGestureRecognizer*)sender {
    
    if(sender.state == UIGestureRecognizerStateEnded) {
        if(sender.direction == UISwipeGestureRecognizerDirectionRight) {
            // Increase
            
            // 1/3
            if(_session.input.frameRate < 1){
                _session.input.frameRateSeconds -= 1;
            }
            // 1/1
            else {
                _session.input.frameRateFrames += 1;
            }
        } else if(sender.direction == UISwipeGestureRecognizerDirectionLeft) {
            if(_session.input.frameRate <= 1){
                _session.input.frameRateSeconds += 1;
            } else {
                _session.input.frameRateFrames -= 1;
            }
        }
        [self updateFrameRateLabel];
    }
}

//-(void)swipeResolutionAction:(UISwipeGestureRecognizer*)sender {
//    if(sender.state == UIGestureRecognizerStateEnded) {
//        if(sender.direction == UISwipeGestureRecognizerDirectionRight) {
//            // Increase
//            
//            // 1/3
//            if(_session.input.frameRate < 1){
//                _session.input.frameRateSeconds -= 1;
//            }
//            // 1/1
//            else {
//                _session.input.frameRateFrames += 1;
//            }
//        } else if(sender.direction == UISwipeGestureRecognizerDirectionLeft) {
//            if(_session.input.frameRate <= 1){
//                _session.input.frameRateSeconds += 1;
//            } else {
//                _session.input.frameRateFrames -= 1;
//            }
//        }
//        [self updateFrameRateLabel];
//    }
//    
//}

-(void)setupUI {
    
    UIImage *exportImage = [[UIImage imageNamed:@"export"]imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    [self.exportButton setImage:exportImage forState:UIControlStateNormal];
    [self.exportButton setTitle:@"" forState:UIControlStateNormal];

    UIImage *resolutionImage = [[UIImage imageNamed:@"resolution"]imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    [self.resolutionButton setImage:resolutionImage forState:UIControlStateNormal];
    [self.resolutionButton setTitle:@"" forState:UIControlStateNormal];
    
    UIImage *closeImage = [[UIImage imageNamed:@"close"]imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    [self.closeButton setImage:closeImage forState:UIControlStateNormal];
    [self.closeButton setTitle:@"" forState:UIControlStateNormal];
    
    UIImage *filterImage = [[UIImage imageNamed:@"filter"]imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    [self.filterButton setImage:filterImage forState:UIControlStateNormal];
    [self.filterButton setTitle:@"" forState:UIControlStateNormal];
    
    UIImage *frameRateImage = [[UIImage imageNamed:@"framerate"]imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    [self.frameRateButton setImage:frameRateImage forState:UIControlStateNormal];
    [self.frameRateButton setTitle:@"" forState:UIControlStateNormal];
    
    UIImage *cameraImage = [[UIImage imageNamed:@"camera"]imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    [self.cameraButton setImage:cameraImage forState:UIControlStateNormal];
    [self.cameraButton setTitle:@"" forState:UIControlStateNormal];
    
    [self.shutterButton setStartBlock:^{
        [self startRecording];
    }];
    
    [self.shutterButton setStopBlock:^{
        [self stopRecording];
    }];
    
    self.captureImageView.layer.borderWidth = 1.0;
    self.captureImageView.layer.borderColor = self.view.tintColor.CGColor;
    
    self.cameraPosition = AVCaptureDevicePositionBack;
    
    self.frameCountLabel.text = @"";
    
    [self updateFrameRateLabel];
    [self updateResolutionLabel];
    
    UISwipeGestureRecognizer *leftSwipeFramerateGesture = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(swipeFramerateAction:)];
    leftSwipeFramerateGesture.direction = UISwipeGestureRecognizerDirectionLeft;
    [self.frameRateView addGestureRecognizer:leftSwipeFramerateGesture];
    
    UISwipeGestureRecognizer *rightSwipeFramerateGesture = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(swipeFramerateAction:)];
    rightSwipeFramerateGesture.direction = UISwipeGestureRecognizerDirectionRight;
    [self.frameRateView addGestureRecognizer:rightSwipeFramerateGesture];
}

-(void)updateFrameRateLabel {
    self.frameRateLabel.text = [NSString stringWithFormat:@"%luf\n%lus",
                                (unsigned long) _session.input.frameRateFrames,
                                (unsigned long) _session.input.frameRateSeconds];
}


-(void)setupCaptureSession{
    
    
    self.filterView.fillMode = kGPUImageFillModePreserveAspectRatioAndFill;
    self.shutterButton.session = _session;
    
    // Clean up
    if(self.videoCamera) {
        [self.videoCamera stopCameraCapture];
        [self.videoCamera removeAllTargets];
        [self.session.input.filter.gpuFilter removeAllTargets];
        self.rawOutput = nil;
        self.videoCamera = nil;
    }
    
    
    CGRect frame = CGRectMake(self.captureImageView.frame.origin.x,
                              self.captureImageView.frame.origin.y,
                              self.captureImageView.frame.size.height * 720 / 1280.0,
                              self.captureImageView.frame.size.height);
    self.captureImageView.frame = frame;
    
    
    NSString *preset = nil;
    if(_session.input.size.width == 288) {
        preset = AVCaptureSessionPreset352x288;
    } else if(_session.input.size.width == 480) {
        preset = AVCaptureSessionPreset640x480;
    } else if(_session.input.size.width == 720) {
        preset = AVCaptureSessionPreset1280x720;
    } else if(_session.input.size.width == 1080) {
        preset = AVCaptureSessionPreset1920x1080;
    }
    
    self.videoCamera = [[GPUImageVideoCamera alloc] initWithSessionPreset:preset cameraPosition:self.cameraPosition];
    self.videoCamera.outputImageOrientation = UIInterfaceOrientationPortrait;
    self.videoCamera.horizontallyMirrorFrontFacingCamera = YES;
    
    
    [self.paramSlider setMinimumValue:_session.input.filter.paramMin];
    [self.paramSlider setMaximumValue:_session.input.filter.paramMax];
    [self.paramSlider setValue:_session.input.filter.paramValue];
    
    // Force initial values
    [self paramSliderValueChanged:self.paramSlider];
    
    [self.session.input.filter.gpuFilter addTarget:self.filterView];
    
    self.rawOutput = [[GPUImageRawDataOutput alloc]initWithImageSize:self.session.input.size resultsInBGRAFormat:NO];
    [self.session.input.filter.gpuFilter addTarget:self.rawOutput];
    
    [self.videoCamera addTarget:self.session.input.filter.gpuFilter];
    [self.videoCamera startCameraCapture];
    
}


-(void)captureFrame:(NSTimer*)sender {
    // This is a pretty resource intensive function so use a BG queue .
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        // Get current frame from GPUImage and convert to UIImage
        NSUInteger width = self.session.input.size.width;
        NSUInteger height = self.session.input.size.height;
        GLubyte *rawData = self.rawOutput.rawBytesForImage;
        CGDataProviderRef provider = CGDataProviderCreateWithData(NULL,
                                                                  rawData,
                                                                  width*height*4,
                                                                  NULL);
        
        CGColorSpaceRef colorSpaceRef = CGColorSpaceCreateDeviceRGB();
        CGBitmapInfo bitmapInfo = kCGBitmapByteOrderDefault;
        CGColorRenderingIntent renderingIntent = kCGRenderingIntentDefault;
        CGImageRef imageRef = CGImageCreate(width,
                                            height,
                                            8,
                                            32,
                                            4*width,colorSpaceRef,
                                            bitmapInfo,
                                            provider,NULL,NO,renderingIntent);
        //    NSLog(@"rawData: width:%lu, height:%lu",
        //          (unsigned long)CGImageGetWidth(imageRef),
        //          (unsigned long)CGImageGetHeight(imageRef));
        
        UIImage *image = [UIImage imageWithCGImage:imageRef];
        
        //    NSLog(@"UIImage: width:%lu, height:%lu",
        //          (unsigned long)image.size.width,
        //          (unsigned long)image.size.height);
        
        
        
        // Update our UI on the main thread
        dispatch_async(dispatch_get_main_queue(), ^{
            self.captureImageView.image = image;
            self.frameCountLabel.text = [NSString stringWithFormat:@"%lu frames\n%.2f seconds",
                                         (unsigned long) _session.input.frameCount,
                                         [_session timeLength]];
            [self.shutterButton tick];
        });
        
        [self.session cacheImage:image index:_session.input.frameCount];
        _session.input.frameCount++;
        
        
        
        // Clean up
        image = nil;
        CGImageRelease(imageRef);
        CGColorSpaceRelease(colorSpaceRef);
        CGDataProviderRelease(provider);
    });
    
    
}



-(void)showFilterView {
    __weak ZHFiltersViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"ZHFiltersViewController"];
    
    CGAffineTransform scaleTransform = CGAffineTransformMakeScale(0.3, 0.3);
    NSTimeInterval duration = 0.3;
    [vc setVideoCamera:self.videoCamera completionBlock:^(ZHFilter *filter) {
        
        [UIView animateWithDuration:duration animations:^{
            vc.view.transform = scaleTransform;
            vc.view.alpha = 0;
        } completion:^(BOOL finished) {
            [vc.view removeFromSuperview];
            [vc removeFromParentViewController];
            
            // TODO (watch): We used to have to add a small delay here because of filter preview cleanup happening after the completion block is fired.
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                _session.input.filter = filter;
                [self setupCaptureSession];
            });
        }];
    }];
    
    [self addChildViewController:vc];
    vc.view.frame = self.view.bounds;
    vc.view.transform = scaleTransform;
    vc.view.alpha = 0;
    [self.view addSubview:vc.view];
    [vc didMoveToParentViewController:self];
    
    [UIView animateWithDuration:duration animations:^{
        vc.view.transform = CGAffineTransformIdentity;
        vc.view.alpha = 1.0;
    } completion:NULL];
}


-(void)shareItems:(NSArray*)items{
    NSMutableArray *activities = [@[]mutableCopy];
    UIActivityViewController *activityViewController = [[UIActivityViewController alloc]initWithActivityItems:items
                                                                                        applicationActivities:activities];
    
    [activityViewController setCompletionWithItemsHandler:^(NSString *activityType, BOOL completed, NSArray *returnedItems, NSError *activityError){
        if(completed){
            //            [self dismissViewControllerAnimated:YES completion:NULL];
        }
    }];
    
    //    activityViewController.excludedActivityTypes = @[UIActivityTypePostToTwitter];
    [self presentViewController:activityViewController animated:YES completion:nil];
}


-(void)renderGIF {
    [_session renderGIFFromViewController:self completionBlock:^(BOOL success, NSData *data) {
        if(success) {
            [self shareItems:@[data]];
        }
    }];
}




-(void)renderVideo{
    
    [_session renderVideoFromViewController:self completionBlock:^(BOOL success) {
        // New session
        [ZHFileManager deleteSession:_session];
        
        _session = [ZHSession sessionFromSession:_session];
        [self setupUI];
        [self setupCaptureSession];
    }];
    
}


- (void)startRecording{
    
    self.isRecording = YES;
    
    
    // Save our config
    self.session.input.captureDevicePosition = self.videoCamera.cameraPosition;
    self.session.input.orientation = [UIDevice currentDevice].orientation;
    [self.session saveConfig];
    
    NSLog(@"orientation: %lu", self.session.input.orientation);
    
    self.captureTimer = [NSTimer scheduledTimerWithTimeInterval:1/(float)self.session.input.frameRate target:self selector:@selector(captureFrame:) userInfo:nil repeats:YES];
    [self captureFrame:self.captureTimer];
    
    // Hide top toolbar while recording
    [UIView animateWithDuration:0.3 animations:^{
        self.topToolbarView.alpha = 0;
    } completion:^(BOOL finished) {
        self.topToolbarView.hidden = YES;
    }];
    
    // Disable screensaver
    [UIApplication sharedApplication].idleTimerDisabled = YES;
    
    
}

- (void)stopRecording {
    
    // Show top toolbar
    self.topToolbarView.hidden = NO;
    [UIView animateWithDuration:0.3 animations:^{
        self.topToolbarView.alpha = 1.0;
    }];
    
    
    [self.captureTimer invalidate];
    self.captureTimer = nil;
    self.navigationItem.rightBarButtonItem = self.startBarButtonItem;
    
    self.isRecording = NO;
    
    // Enable screensaver
    [UIApplication sharedApplication].idleTimerDisabled = NO;
    
    if([ZHUserDefaults renderAsGIF]) {
        [self renderGIF];
    } else {
        [self renderVideo];
    }
}


#pragma mark IBActions

- (IBAction)swapButtonTouchUpInside:(id)sender {
    
    if(self.cameraPosition == AVCaptureDevicePositionBack) {
        self.cameraPosition = AVCaptureDevicePositionFront;
    } else {
        self.cameraPosition = AVCaptureDevicePositionBack;
    }
    
    [self setupCaptureSession];
}


- (IBAction)resolutionButtonTouchUpInside:(id)sender {
    UIAlertController *ac = [UIAlertController alertControllerWithTitle:@"Resolution" message:nil preferredStyle:UIAlertControllerStyleAlert];
    
    [ac addAction:[UIAlertAction actionWithTitle:@"288x352" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        _session.input.size = CGSizeMake(288, 352);
        _session.output.size = _session.input.size;
        [self updateResolutionLabel];
        [self setupCaptureSession];
    }]];
    
    [ac addAction:[UIAlertAction actionWithTitle:@"480x640" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        _session.input.size = CGSizeMake(480, 640);
        _session.output.size = _session.input.size;
        [self updateResolutionLabel];
        [self setupCaptureSession];
    }]];
    
    [ac addAction:[UIAlertAction actionWithTitle:@"720x1280" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        _session.input.size = CGSizeMake(720, 1280);
        _session.output.size = _session.input.size;
        [self updateResolutionLabel];
        [self setupCaptureSession];
    }]];
    
    [ac addAction:[UIAlertAction actionWithTitle:@"1080x1920" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        _session.input.size = CGSizeMake(1080, 1920);
        _session.output.size = _session.input.size;
        [self updateResolutionLabel];
        [self setupCaptureSession];
    }]];
    
    [ac addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
    }]];
    
    [self presentViewController:ac animated:YES completion:nil];
}


- (IBAction)shutterButtonTouchUpInside:(id)sender {
    NSLog(@"%s", __FUNCTION__);
}



- (IBAction)paramSliderValueChanged:(UISlider*)sender {
    [_session.input.filter updateParamValue:sender.value];
}

- (IBAction)frameRateButtonTouchUpInside:(id)sender {
    [self presentAlertDialogWithMessage:@"Swipe left/right to change frame rate."];
}

- (IBAction)filterButtonTouchUpInside:(id)sender {
    [self showFilterView];
}

- (IBAction)closeButtonTouchUpInside:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}





@end

