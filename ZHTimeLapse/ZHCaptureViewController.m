//
//  ZHCaptureViewController.m
//  ZHTimeLapse
//
//  Created by Zakk Hoyt on 12/21/15.
//  Copyright © 2015 Zakk Hoyt. All rights reserved.
//
//  https://github.com/rehatkathuria/SnappingSlider

#import "ZHCaptureViewController.h"
#import "ZHDefines.h"
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
#import "ZHDefines.h"
#import "ZHMenuViewController.h"

static NSString *SegueCaptureToFrameRateMenu = @"SegueCaptureToFrameRateMenu";
static NSString *SegueCaptureToResolutionMenu = @"SegueCaptureToResolutionMenu";

@interface ZHCaptureViewController ()

// GPUImage stuff
@property (weak, nonatomic) IBOutlet GPUImageView *filterView;
@property (nonatomic, strong) GPUImageVideoCamera *videoCamera;
@property (nonatomic, strong) GPUImageRawDataOutput *rawOutput;
@property (nonatomic, strong) GPUImageUIElement *uiElementInput;

// UI Stuff
@property (weak, nonatomic) IBOutlet UIImageView *captureImageView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *captureImageViewHeightConstraint;
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

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if([segue.identifier isEqualToString:SegueCaptureToFrameRateMenu]){
        ZHMenuViewController *vc = segue.destinationViewController;
        [vc setTitle:@"Frame Rate" type:ZHMenuViewControllerTypeFrameRate frameRateBlock:^(NSUInteger seconds, NSUInteger frames) {
 
        } cancelBlock:^{
 
        }];
    } else  if([segue.identifier isEqualToString:SegueCaptureToResolutionMenu]){
        ZHMenuViewController *vc = segue.destinationViewController;
        [vc setTitle:@"Resolution" type:ZHMenuViewControllerTypeResolution frameRateBlock:^(NSUInteger seconds, NSUInteger frames) {
 
        } cancelBlock:^{
 
        }];
    }
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
            _lastOrientation = [UIDevice currentDevice].orientation;
            [self updateUIForOrientation];
        }
    } repeats:YES];
    [self updateUIForOrientation];
}

-(void)updateUIForOrientation {
    NSLog(@"%s", __FUNCTION__);
    
    [UIView animateWithDuration:0.3 animations:^{
        [self updateResolutionLabel];
        [self.rotatableViews enumerateObjectsUsingBlock:^(UIView  * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            switch (_lastOrientation) {
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
        
        if([_videoCamera.inputCamera isFocusPointOfInterestSupported]&&[_videoCamera.inputCamera isFocusModeSupported:AVCaptureFocusModeAutoFocus]) {
            if([_videoCamera.inputCamera lockForConfiguration :nil]) {
                [_videoCamera.inputCamera setFocusPointOfInterest :touchPoint];
                [_videoCamera.inputCamera setFocusMode :AVCaptureFocusModeLocked];
                
                if([_videoCamera.inputCamera isExposurePointOfInterestSupported]) {
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
    
    
    switch (_lastOrientation) {
        case UIDeviceOrientationLandscapeLeft:
        case UIDeviceOrientationLandscapeRight:
            self.resolutionLabel.text = [NSString stringWithFormat:@"%lu\n%lu",
                                         (unsigned long)_session.input.size.height,
                                         (unsigned long)_session.input.size.width];
            
            break;
        case UIDeviceOrientationPortrait:
        case UIDeviceOrientationPortraitUpsideDown:
            self.resolutionLabel.text = [NSString stringWithFormat:@"%lu\n%lu",
                                         (unsigned long)_session.input.size.width,
                                         (unsigned long)_session.input.size.height];
            
            break;
        default:
            
            break;
    }
    
    
    
    
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

-(void)setupUI {
    
    //    UIImage *exportImage = [[UIImage imageNamed:@"export"]imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    //    [self.exportButton setImage:exportImage forState:UIControlStateNormal];
    //    [self.exportButton setTitle:@"" forState:UIControlStateNormal];
    
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
    
    
    CGFloat height = _captureImageView.bounds.size.width * _session.input.size.height / _session.input.size.width;
    _captureImageViewHeightConstraint.constant = height;
    [UIView animateWithDuration:0.3 animations:^{
        [self.bottomToolbarView layoutIfNeeded];
    }];
    
    
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
    
    self.videoCamera = [[GPUImageVideoCamera alloc] initWithSessionPreset:preset cameraPosition:_session.input.captureDevicePosition];
    self.videoCamera.outputImageOrientation = UIInterfaceOrientationPortrait;
    self.videoCamera.horizontallyMirrorFrontFacingCamera = YES;
    
    
    [self.paramSlider setMinimumValue:_session.input.filter.paramMin];
    [self.paramSlider setMaximumValue:_session.input.filter.paramMax];
    [self.paramSlider setValue:_session.input.filter.paramValue];
    
    // Force initial values
    [self paramSliderValueChanged:self.paramSlider];
    
    BOOL useWatermark = YES;
    
    if(useWatermark) {
        GPUImageOutput<GPUImageInput> *zhFilter = _session.input.filter.gpuFilter;
        
        GPUImageAlphaBlendFilter *blendFilter = [[GPUImageAlphaBlendFilter alloc] init];
        blendFilter.mix = 1.0;
        
        NSDate *startTime = [NSDate date];
        
        UILabel *timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0, 0.0, 240.0f, 320.0f)];
        timeLabel.font = [UIFont systemFontOfSize:17.0f];
        timeLabel.text = @"Time: 0.0 s";
        timeLabel.textAlignment = NSTextAlignmentCenter;
        timeLabel.backgroundColor = [UIColor clearColor];
        timeLabel.textColor = [UIColor whiteColor];
        
        _uiElementInput = [[GPUImageUIElement alloc] initWithView:timeLabel];
        
        [zhFilter addTarget:blendFilter];
        [_uiElementInput addTarget:blendFilter];
        
        __unsafe_unretained GPUImageUIElement *weakUIElementInput = _uiElementInput;
        
        [zhFilter setFrameProcessingCompletionBlock:^(GPUImageOutput * filter, CMTime frameTime){
            timeLabel.text = [NSString stringWithFormat:@"Time: %f s", -[startTime timeIntervalSinceNow]];
            [weakUIElementInput update];
        }];
        
        
        
        [self.videoCamera addTarget:zhFilter];
        [blendFilter addTarget:_filterView];

    } else {
        [self.session.input.filter.gpuFilter addTarget:self.filterView];
        
        self.rawOutput = [[GPUImageRawDataOutput alloc]initWithImageSize:self.session.input.size resultsInBGRAFormat:NO];
        [self.session.input.filter.gpuFilter addTarget:self.rawOutput];
        
        [self.videoCamera addTarget:self.session.input.filter.gpuFilter];
    }
    
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
        //    NSLog(@"rawData: width:%lu, height:%lu", (unsigned long)CGImageGetWidth(imageRef), (unsigned long)CGImageGetHeight(imageRef));
        
        UIImage *image = [UIImage imageWithCGImage:imageRef];
        //    NSLog(@"UIImage: width:%lu, height:%lu", (unsigned long)image.size.width, (unsigned long)image.size.height);
        
        // Update our UI on the main thread
        dispatch_async(dispatch_get_main_queue(), ^{
            self.captureImageView.image = image;
            self.frameCountLabel.text = [NSString stringWithFormat:@"%lu frames\n%.2f seconds",
                                         (unsigned long) _session.input.frameCount,
                                         [_session timeLength]];
//            [self.shutterButton tick];
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
    self.session.input.orientation = [UIDevice currentDevice].orientation;
    [self.session saveConfig];
    
    NSLog(@"orientation: %lu", (unsigned long) self.session.input.orientation);
    
    // Hide top toolbar while recording
    [UIView animateWithDuration:0.3 animations:^{
        self.topToolbarView.alpha = 0;
    } completion:^(BOOL finished) {
        self.topToolbarView.hidden = YES;
    }];
    
    // Disable screensaver
    [UIApplication sharedApplication].idleTimerDisabled = YES;
    
    // Set capture block
    __weak typeof(self) welf = self;
    NSTimeInterval captureInterval =  (NSTimeInterval)_session.input.frameRateSeconds / (NSTimeInterval)_session.input.frameRateFrames;
    __block NSDate *nextCaptureDate = [[NSDate date] dateByAddingTimeInterval:captureInterval];
    
    [self.rawOutput setNewFrameAvailableBlock:^{
        NSDate *now = [NSDate date];
        NSTimeInterval nowTick = [now timeIntervalSince1970];
        NSTimeInterval nextCaptureTick = [nextCaptureDate timeIntervalSince1970];
        NSTimeInterval diff = nowTick - nextCaptureTick;
        if(diff > 0) {
            nextCaptureDate = [nextCaptureDate dateByAddingTimeInterval:captureInterval];
            [welf captureFrame:nil];
        }
    }];
    
    
}

- (void)stopRecording {
    
    // Nil out our capture block
    [self.rawOutput setNewFrameAvailableBlock:nil];
    
    // Show top toolbar
    self.topToolbarView.hidden = NO;
    [UIView animateWithDuration:0.3 animations:^{
        self.topToolbarView.alpha = 1.0;
    }];
    
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

- (IBAction)exportButtonTouchUpInside:(id)sender {
    if ([[UIApplication sharedApplication]
         canOpenURL:[NSURL URLWithString:@"photos://"]]) {
        
        // Waze is installed. Launch Waze and start navigation
        NSString *urlStr = [NSString stringWithFormat:@"photos://"];
        
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:urlStr]];
        
    } else {
        ZH_LOG_DEBUG(@"Cannot open Photos app");
    }
}


- (IBAction)swapButtonTouchUpInside:(id)sender {
    if(_session.input.captureDevicePosition == AVCaptureDevicePositionBack) {
        _session.input.captureDevicePosition = AVCaptureDevicePositionFront;
    } else {
        _session.input.captureDevicePosition = AVCaptureDevicePositionBack;
    }
    [self setupCaptureSession];
}


- (IBAction)resolutionButtonTouchUpInside:(id)sender {
    
//    [self performSegueWithIdentifier:SegueCaptureToResolutionMenu sender:nil];
    
    UIAlertController *ac = [UIAlertController alertControllerWithTitle:@"Resolution" message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    
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
    
    //    [ac addAction:[UIAlertAction actionWithTitle:@"1080x1920" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
    //        _session.input.size = CGSizeMake(1080, 1920);
    //        _session.output.size = _session.input.size;
    //        [self updateResolutionLabel];
    //        [self setupCaptureSession];
    //    }]];
    
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
    
//    [self performSegueWithIdentifier:SegueCaptureToFrameRateMenu sender:nil];
    
    UIAlertController *ac = [UIAlertController alertControllerWithTitle:@"Capture Frame Rate" message:@"Swipe button left/right for fine control or select from the following:" preferredStyle:UIAlertControllerStyleActionSheet];
    
    [ac addAction:[UIAlertAction actionWithTitle:@"4 every second" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        _session.input.frameRateSeconds = 1;
        _session.input.frameRateFrames = 4;
        [self updateFrameRateLabel];
    }]];

    [ac addAction:[UIAlertAction actionWithTitle:@"3 every second" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        _session.input.frameRateSeconds = 1;
        _session.input.frameRateFrames = 3;
        [self updateFrameRateLabel];
    }]];

    [ac addAction:[UIAlertAction actionWithTitle:@"2 every second" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        _session.input.frameRateSeconds = 1;
        _session.input.frameRateFrames = 2;
        [self updateFrameRateLabel];
    }]];

    [ac addAction:[UIAlertAction actionWithTitle:@"1 every second" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        _session.input.frameRateSeconds = 1;
        _session.input.frameRateFrames = 1;
        [self updateFrameRateLabel];
    }]];
    
    [ac addAction:[UIAlertAction actionWithTitle:@"1 every 2 seconds" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        _session.input.frameRateSeconds = 2;
        _session.input.frameRateFrames = 1;
        [self updateFrameRateLabel];
    }]];

    [ac addAction:[UIAlertAction actionWithTitle:@"1 every 5 seconds" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        _session.input.frameRateSeconds = 5;
        _session.input.frameRateFrames = 1;
        [self updateFrameRateLabel];
    }]];

    [ac addAction:[UIAlertAction actionWithTitle:@"1 every 10 seconds" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        _session.input.frameRateSeconds = 10;
        _session.input.frameRateFrames = 1;
        [self updateFrameRateLabel];
    }]];

    [ac addAction:[UIAlertAction actionWithTitle:@"1 every 30 seconds" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        _session.input.frameRateSeconds = 30;
        _session.input.frameRateFrames = 1;
        [self updateFrameRateLabel];
    }]];

    [ac addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
    }]];
    
    [self presentViewController:ac animated:YES completion:nil];
}

- (IBAction)filterButtonTouchUpInside:(id)sender {
    [self showFilterView];
}

- (IBAction)closeButtonTouchUpInside:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}





@end

