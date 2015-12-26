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

@interface ZHCaptureViewController ()
@property (weak, nonatomic) IBOutlet GPUImageView *filterView;
@property (nonatomic, strong) GPUImageVideoCamera *videoCamera;
@property (nonatomic, strong) GPUImageOutput<GPUImageInput> *filter;
@property (nonatomic, strong) NSTimer *captureTimer;
@property (nonatomic, strong) GPUImageRawDataOutput *rawOutput;

@property (weak, nonatomic) IBOutlet UIImageView *captureImageView;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *startBarButtonItem;
@property (weak, nonatomic) IBOutlet UILabel *frameCountLabel;
@property (nonatomic) NSUInteger frameCounter;
@property (weak, nonatomic) IBOutlet UIButton *startButton;
@property (weak, nonatomic) IBOutlet UIButton *stopButton;
@property (nonatomic) AVCaptureDevicePosition cameraPosition;

@property (weak, nonatomic) IBOutlet UIView *bottomToolbarView;
@property (weak, nonatomic) IBOutlet UIView *topToolbarView;
@property (strong, nonatomic) IBOutletCollection(UIView) NSArray *rotatableViews;

@property (nonatomic, strong) UIView *filterSelectionView;
@property (weak, nonatomic) IBOutlet UIButton *frameRateButton;


@property (weak, nonatomic) IBOutlet UISlider *paramSlider;


@end

@implementation ZHCaptureViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
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

    [self.frameRateButton setTitle:[NSString stringWithFormat:@"%.2f fps", _session.input.frameRate] forState:UIControlStateNormal];
    
    self.stopButton.hidden = YES;
    
    UISwipeGestureRecognizer *leftSwipeGesture = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(swipeAction:)];
    leftSwipeGesture.direction = UISwipeGestureRecognizerDirectionLeft;
    [self.topToolbarView addGestureRecognizer:leftSwipeGesture];

    UISwipeGestureRecognizer *rightSwipeGesture = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(swipeAction:)];
    rightSwipeGesture.direction = UISwipeGestureRecognizerDirectionRight;
    [self.topToolbarView addGestureRecognizer:rightSwipeGesture];


    [self setupCaptureSession];
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



#pragma mark Private methods

-(void)swipeAction:(UISwipeGestureRecognizer*)sender {
    
    if(sender.state == UIGestureRecognizerStateEnded) {
        if(sender.direction == UISwipeGestureRecognizerDirectionRight) {
            if(_session.input.frameRate < 1){
                _session.input.frameRate += 0.1;
            } else {
                _session.input.frameRate += 1;
            }
        } else if(sender.direction == UISwipeGestureRecognizerDirectionLeft) {
            if(_session.input.frameRate <= 1){
                _session.input.frameRate -= 0.1;
            } else {
                _session.input.frameRate -= 1;
            }
        }
        
        [self.frameRateButton setTitle:[NSString stringWithFormat:@"%.2f fps", _session.input.frameRate] forState:UIControlStateNormal];
    }
}



-(void)setupCaptureSession{

    self.filterView.fillMode = kGPUImageFillModePreserveAspectRatioAndFill;
    
    // Clean up
    if(self.videoCamera) {
        [self.videoCamera stopCameraCapture];
        [self.videoCamera removeAllTargets];
        [self.filter removeAllTargets];
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
    
    
    // sobel edge
    // mask
    // toon
    // dilation
    // erosion
    // mosiac
    // smooth toon
    // glass sphere
    
    // adaptive threshold
    // polka dot
    // halftone
    // hough line detection

    switch (self.session.input.filter) {

        case ZHSessionInputFilterCannyEdgeDetection:{
            [self.paramSlider setMinimumValue:0.0];
            [self.paramSlider setMaximumValue:1.0];
            [self.paramSlider setValue:1.0];

            GPUImageCannyEdgeDetectionFilter *filter = [GPUImageCannyEdgeDetectionFilter new];
            self.filter = filter;
        }
            break;
        case ZHSessionInputFilterPrewittEdgeDetection:{
            [self.paramSlider setMinimumValue:0.0];
            [self.paramSlider setMaximumValue:1.0];
            [self.paramSlider setValue:1.0];
            
            GPUImagePrewittEdgeDetectionFilter *filter = [GPUImagePrewittEdgeDetectionFilter new];
            self.filter = filter;
        }
            break;
        case ZHSessionInputFilterThresholdEdgeDetection:{
            
            [self.paramSlider setMinimumValue:0.0];
            [self.paramSlider setMaximumValue:1.0];
            [self.paramSlider setValue:0.25];

            GPUImageThresholdEdgeDetectionFilter *filter = [GPUImageThresholdEdgeDetectionFilter new];
            self.filter = filter;
        }
            break;
        case ZHSessionInputFilterSobelEdgeDetection:{
            
            [self.paramSlider setMinimumValue:0.0];
            [self.paramSlider setMaximumValue:1.0];
            [self.paramSlider setValue:0.25];

            GPUImageSobelEdgeDetectionFilter *filter = [GPUImageSobelEdgeDetectionFilter new];
            self.filter = filter;
        }
            break;
        case ZHSessionInputFilterSketch:{
            
            [self.paramSlider setMinimumValue:0.0];
            [self.paramSlider setMaximumValue:1.0];
            [self.paramSlider setValue:0.25];

            GPUImageSketchFilter *filter = [GPUImageSketchFilter new];
            self.filter = filter;
        }
            break;

        case ZHSessionInputFilterSmoothToon:{
            [self.paramSlider setMinimumValue:1.0];
            [self.paramSlider setMaximumValue:6.0];
            [self.paramSlider setValue:1.0];
            
            GPUImageSmoothToonFilter *filter = [GPUImageSmoothToonFilter new];
            self.filter = filter;
        }
            break;
        case ZHSessionInputFilterAdaptiveThreshold:{
            [self.paramSlider setMinimumValue:1.0];
            [self.paramSlider setMaximumValue:20.0];
            [self.paramSlider setValue:1.0];

            GPUImageAdaptiveThresholdFilter *filter = [GPUImageAdaptiveThresholdFilter new];
            self.filter = filter;
        }
            break;

        case ZHSessionInputFilterPolkaDot:{
            [self.paramSlider setValue:0.05];
            [self.paramSlider setMinimumValue:0.0];
            [self.paramSlider setMaximumValue:0.3];

            GPUImagePolkaDotFilter *filter = [GPUImagePolkaDotFilter new];
            self.filter = filter;
        }
            break;
        case ZHSessionInputFilterNone:
        default:{
            GPUImageFilter *filter = [GPUImageFilter new];
            self.filter = filter;
        }
            break;
    }
    
    // Force initial values
    [self paramSliderValueChanged:self.paramSlider];
    
    
//    //    // Add mask to video
//    self.filter = [GPUImageMaskFilter new];
//    GPUImagePicture *sourcePicture = [[GPUImagePicture alloc] initWithImage:[UIImage imageNamed:@"ZHTimeLapse_512"] smoothlyScaleOutput:YES];
//    [sourcePicture processImage];
//    [sourcePicture addTarget:self.filter];

    
    
    [self.filter addTarget:self.filterView];
    
    self.rawOutput = [[GPUImageRawDataOutput alloc]initWithImageSize:self.session.input.size resultsInBGRAFormat:NO];
    [self.filter addTarget:self.rawOutput];
    
    [self.videoCamera addTarget:self.filter];
    [self.videoCamera startCameraCapture];

}

#pragma mark IBActions
- (IBAction)paramSliderValueChanged:(UISlider*)sender {
    switch (_session.input.filter) {
            
        case ZHSessionInputFilterCannyEdgeDetection:{
            [(GPUImageCannyEdgeDetectionFilter*)_filter setBlurTexelSpacingMultiplier:sender.value];
        }
            break;
        case ZHSessionInputFilterPrewittEdgeDetection:{
             [(GPUImagePrewittEdgeDetectionFilter*)_filter setEdgeStrength:sender.value];
        }
            break;
        case ZHSessionInputFilterThresholdEdgeDetection:{
            [(GPUImageLuminanceThresholdFilter*)_filter setThreshold:sender.value];
        }
            break;
        case ZHSessionInputFilterSobelEdgeDetection:{
            [(GPUImageSobelEdgeDetectionFilter*)_filter setEdgeStrength:sender.value];
        }
            break;
        case ZHSessionInputFilterSketch:{
            [(GPUImageSketchFilter*)_filter setEdgeStrength:sender.value];
        }
            break;
        case ZHSessionInputFilterSmoothToon:{
            [(GPUImageSmoothToonFilter*)_filter setBlurRadiusInPixels:sender.value];
        }
            break;
        case ZHSessionInputFilterAdaptiveThreshold:{
            [(GPUImageAdaptiveThresholdFilter*)_filter setBlurRadiusInPixels:sender.value];
        }
            break;
        case ZHSessionInputFilterPolkaDot:{
            [(GPUImagePolkaDotFilter*)_filter setFractionalWidthOfAPixel:sender.value];
        }
            break;
        case ZHSessionInputFilterNone: {
            
        }
            break;
        default:{
        }
            break;
    }
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
    

    
    // Enable screensaver
    [UIApplication sharedApplication].idleTimerDisabled = NO;

//    // Pop
//    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)swapButtonTouchUpInside:(id)sender {
    
    if(self.cameraPosition == AVCaptureDevicePositionBack) {
        self.cameraPosition = AVCaptureDevicePositionFront;
    } else {
        self.cameraPosition = AVCaptureDevicePositionBack;
    }
    
    [self setupCaptureSession];
}

#pragma mark Private methods
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
    
    
}



-(void)showFilterView {
    __weak ZHFiltersViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"ZHFiltersViewController"];

    CGAffineTransform scaleTransform = CGAffineTransformMakeScale(0.3, 0.3);
    NSTimeInterval duration = 0.3;
    [vc setVideoCamera:self.videoCamera completionBlock:^(ZHSessionInputFilter filter) {

        [UIView animateWithDuration:duration animations:^{
//        [UIView animateWithDuration:0.3 delay:0 usingSpringWithDamping:0.6 initialSpringVelocity:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
            vc.view.transform = scaleTransform;
            vc.view.alpha = 0;
        } completion:^(BOOL finished) {
            [vc.view removeFromSuperview];
            [vc removeFromParentViewController];
        }];
        

        _session.input.filter = filter;
        [self setupCaptureSession];
    }];
    
    [self addChildViewController:vc];
    vc.view.frame = self.view.bounds;
    vc.view.transform = scaleTransform;
    vc.view.alpha = 0;
    [self.view addSubview:vc.view];
    [vc didMoveToParentViewController:self];
    
    [UIView animateWithDuration:duration animations:^{
//    [UIView animateWithDuration:0.3 delay:0 usingSpringWithDamping:0.6 initialSpringVelocity:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        vc.view.transform = CGAffineTransformIdentity;
        vc.view.alpha = 1.0;
    } completion:NULL];
    
}
@end

