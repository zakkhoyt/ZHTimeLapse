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
@property (weak, nonatomic) IBOutlet UIButton *startButton;
@property (weak, nonatomic) IBOutlet UIButton *stopButton;
@property (weak, nonatomic) IBOutlet UIView *bottomToolbarView;
@property (weak, nonatomic) IBOutlet UIView *topToolbarView;
@property (strong, nonatomic) IBOutletCollection(UIView) NSArray *rotatableViews;
@property (weak, nonatomic) IBOutlet UIButton *frameRateButton;
@property (weak, nonatomic) IBOutlet UILabel *frameRateLabel;
@property (weak, nonatomic) IBOutlet UIButton *exportButton;
@property (weak, nonatomic) IBOutlet ZHShutterButton *shutterButton;

@property (weak, nonatomic) IBOutlet UISlider *paramSlider;
@property (weak, nonatomic) IBOutlet UIButton *cameraButton;
@property (weak, nonatomic) IBOutlet UIButton *filterButton;
@property (weak, nonatomic) IBOutlet UIButton *closeButton;

// i-vars
@property (nonatomic) NSUInteger frameCounter;
@property (nonatomic) AVCaptureDevicePosition cameraPosition;
@property (nonatomic, strong) UIView *filterSelectionView;

@property (nonatomic) UIDeviceOrientation lastOrientation;
@property (nonatomic) BOOL isRecording;
@end

@implementation ZHCaptureViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
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
- (IBAction)shutterButtonTouchUpInside:(id)sender {
    NSLog(@"%s", __FUNCTION__);
}

-(void)swipeAction:(UISwipeGestureRecognizer*)sender {
    
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

-(void)setupUI {

    UIImage *exportImage = [[UIImage imageNamed:@"export"]imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    [self.exportButton setImage:exportImage forState:UIControlStateNormal];
    [self.exportButton setTitle:@"" forState:UIControlStateNormal];

    
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
        [self startButtonTouchUpInside:self.startButton];
    }];
    
    [self.shutterButton setStopBlock:^{
        [self stopButtonTouchUpInside:self.stopButton];
    }];
    
    self.startButton.layer.cornerRadius = self.startButton.bounds.size.width / 2.0;
    self.startButton.layer.masksToBounds = YES;
    self.startButton.layer.borderWidth = 1.0;
    self.startButton.layer.borderColor = self.startButton.tintColor.CGColor;
    
    self.stopButton.layer.cornerRadius = self.stopButton.bounds.size.width / 2.0;
    self.stopButton.layer.masksToBounds = YES;
    self.stopButton.layer.borderWidth = 1.0;
    self.stopButton.layer.borderColor = self.stopButton.tintColor.CGColor;
    
    self.captureImageView.layer.borderWidth = 1.0;
    self.captureImageView.layer.borderColor = self.view.tintColor.CGColor;
    
    self.cameraPosition = AVCaptureDevicePositionBack;
    
    self.frameCountLabel.text = @"";
    self.frameCounter = 0;
    
    [self updateFrameRateLabel];
    
    self.stopButton.hidden = YES;
    
    UISwipeGestureRecognizer *leftSwipeGesture = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(swipeAction:)];
    leftSwipeGesture.direction = UISwipeGestureRecognizerDirectionLeft;
    [self.topToolbarView addGestureRecognizer:leftSwipeGesture];
    
    UISwipeGestureRecognizer *rightSwipeGesture = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(swipeAction:)];
    rightSwipeGesture.direction = UISwipeGestureRecognizerDirectionRight;
    [self.topToolbarView addGestureRecognizer:rightSwipeGesture];
    
//    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(singleTap:)];
//    [self.filterView addGestureRecognizer:tapGesture];
    
    // ************ TODO: Work on a custom shutter button w/animations
    //    ZHShutterButton *shutterButton = [[[NSBundle mainBundle] loadNibNamed:@"ZHShutterButton" owner:self options:nil] firstObject];
    //    _shutterButton = shutterButton;
    //    _shutterButton.frame = CGRectMake(self.bottomToolbarView.bounds.size.width - 68,
    //                                      self.bottomToolbarView.bounds.size.height - 68,
    //                                      60,
    //                                      60);
    //    [_shutterButton setTitle:@"Test" forState:UIControlStateNormal];
    //    [_shutterButton setBackgroundColor:[UIColor orangeColor]];
    //    [self.shutterButton addTarget:self action:@selector(shutterButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    //    [self.bottomToolbarView addSubview:_shutterButton];


}

-(void)updateFrameRateLabel {
//    if(_session.input.frameRate < 1) {
//        double f = 1.0 / _session.input.frameRate;
//        self.frameRateLabel.text = [NSString stringWithFormat:@"1f/%.1fs", f];
//    } else {
//        self.frameRateLabel.text = [NSString stringWithFormat:@"%luf/1s", (unsigned long) _session.input.frameRate];
//    }
    self.frameRateLabel.text = [NSString stringWithFormat:@"%luf/%lus",
                                (unsigned long) _session.input.frameRateFrames,
                                (unsigned long) _session.input.frameRateSeconds];
}


-(void)setupCaptureSession{

    self.filterView.fillMode = kGPUImageFillModePreserveAspectRatioAndFill;
    
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
    
    self.videoCamera = [[GPUImageVideoCamera alloc] initWithSessionPreset:AVCaptureSessionPreset1280x720 cameraPosition:self.cameraPosition];
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
    NSLog(@"rawData: width:%lu, height:%lu",
          (unsigned long)CGImageGetWidth(imageRef),
          (unsigned long)CGImageGetHeight(imageRef));
    
    UIImage *image = [UIImage imageWithCGImage:imageRef];
    
    NSLog(@"UIImage: width:%lu, height:%lu",
          (unsigned long)image.size.width,
          (unsigned long)image.size.height);
    
    self.captureImageView.image = image;
    
    [self.session cacheImage:image index:self.frameCounter];
    self.frameCounter++;
    
    // Label
    self.frameCountLabel.text = [NSString stringWithFormat:@"%lu frames\n%.2f seconds",
                                 (unsigned long) self.frameCounter,
                                 [_session timeLength]];
    
    
    // Clean up
    image = nil;
    CGImageRelease(imageRef);
    CGColorSpaceRelease(colorSpaceRef);
    CGDataProviderRelease(provider);
    
    [self.shutterButton addTick];
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

#pragma mark IBActions
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

- (IBAction)startButtonTouchUpInside:(id)sender {

    self.isRecording = YES;
    
    // Save our config
    self.session.input.captureDevicePosition = self.videoCamera.cameraPosition;
    self.session.input.orientation = [UIDevice currentDevice].orientation;
    [self.session saveConfig];
    
    NSLog(@"orientation: %lu", self.session.input.orientation);
    
    self.captureTimer = [NSTimer scheduledTimerWithTimeInterval:1/(float)self.session.input.frameRate target:self selector:@selector(captureFrame:) userInfo:nil repeats:YES];
    [self captureFrame:self.captureTimer];
    
    self.stopButton.hidden = NO;
    self.startButton.hidden = YES;
    
    // Hide top toolbar while recording
    [UIView animateWithDuration:0.3 animations:^{
        self.topToolbarView.alpha = 0;
    } completion:^(BOOL finished) {
        self.topToolbarView.hidden = YES;
    }];
    
    // Disable screensaver
    [UIApplication sharedApplication].idleTimerDisabled = YES;
}

- (IBAction)stopButtonTouchUpInside:(id)sender {
    
    // Show top toolbar
    self.topToolbarView.hidden = NO;
    [UIView animateWithDuration:0.3 animations:^{
        self.topToolbarView.alpha = 1.0;
    }];

    
    [self.captureTimer invalidate];
    self.captureTimer = nil;
    self.navigationItem.rightBarButtonItem = self.startBarButtonItem;
    self.stopButton.hidden = YES;
    self.startButton.hidden = NO;
    
    self.isRecording = NO;
    
    // Enable screensaver
    [UIApplication sharedApplication].idleTimerDisabled = NO;
}

- (IBAction)swapButtonTouchUpInside:(id)sender {
    
    if(self.cameraPosition == AVCaptureDevicePositionBack) {
        self.cameraPosition = AVCaptureDevicePositionFront;
    } else {
        self.cameraPosition = AVCaptureDevicePositionBack;
    }
    
    [self setupCaptureSession];
}


@end

