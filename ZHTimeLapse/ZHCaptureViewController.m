//
//  ZHCaptureViewController.m
//  ZHTimeLapse
//
//  Created by Zakk Hoyt on 12/21/15.
//  Copyright © 2015 Zakk Hoyt. All rights reserved.
//

#import "ZHCaptureViewController.h"
#import "GPUImage.h"
#import "NSTimer+Blocks.h"
#import "ZHSession.h"
#import "UIViewController+AlertController.h"

@interface ZHCaptureViewController ()
@property (weak, nonatomic) IBOutlet GPUImageView *filterView;
@property (nonatomic, strong) GPUImageVideoCamera *videoCamera;
@property (nonatomic, strong) GPUImageOutput<GPUImageInput> *filter;
@property (nonatomic, strong) NSTimer *captureTimer;
@property (nonatomic, strong) GPUImageRawDataOutput *rawOutput;

@property (weak, nonatomic) IBOutlet UIImageView *captureImageView;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *startBarButtonItem;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *stopBarButtonItem;
@property (weak, nonatomic) IBOutlet UILabel *frameCountLabel;
@property (nonatomic) NSUInteger frameCounter;
@property (weak, nonatomic) IBOutlet UIButton *startButton;
@property (weak, nonatomic) IBOutlet UIButton *stopButton;
@property (weak, nonatomic) IBOutlet UIButton *closeButton;
@property (nonatomic) AVCaptureDevicePosition cameraPosition;

@property (weak, nonatomic) IBOutlet UIView *bottomToolbarView;
@property (weak, nonatomic) IBOutlet UIView *topToolbarView;
@property (strong, nonatomic) IBOutletCollection(UIView) NSArray *rotatableViews;

@property (nonatomic, strong) UIView *filterSelectionView;
@property (weak, nonatomic) IBOutlet UIButton *frameRateButton;


@end

@implementation ZHCaptureViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
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

        case ZHSessionFilterCannyEdgeDetection:{
            GPUImageCannyEdgeDetectionFilter *filter = [GPUImageCannyEdgeDetectionFilter new];
            self.filter = filter;
        }
            break;
        case ZHSessionFilterPrewittEdgeDetection:{
            GPUImagePrewittEdgeDetectionFilter *filter = [GPUImagePrewittEdgeDetectionFilter new];
            self.filter = filter;
        }
            break;
        case ZHSessionFilterThresholdEdgeDetection:{
            GPUImageThresholdEdgeDetectionFilter *filter = [GPUImageThresholdEdgeDetectionFilter new];
            self.filter = filter;
        }
            break;
        case ZHSessionFilterSobelEdgeDetection:{
            GPUImageSobelEdgeDetectionFilter *filter = [GPUImageSobelEdgeDetectionFilter new];
            self.filter = filter;
        }
            break;
        case ZHSessionFilterSketch:{
            GPUImageSketchFilter *filter = [GPUImageSketchFilter new];
            self.filter = filter;
        }
            break;

        case ZHSessionFilterSmoothToon:{
            GPUImageSmoothToonFilter *filter = [GPUImageSmoothToonFilter new];
            self.filter = filter;
        }
            break;
        case ZHSessionFilterAdaptiveThreshold:{
            GPUImageAdaptiveThresholdFilter *filter = [GPUImageAdaptiveThresholdFilter new];
            [filter setBlurRadiusInPixels:2.0];
            self.filter = filter;
        }
            break;

        case ZHSessionFilterPolkaDot:{
            GPUImagePolkaDotFilter *filter = [GPUImagePolkaDotFilter new];
            self.filter = filter;
        }
            break;
        case ZHSessionFilterNone:
        default:{
            GPUImageFilter *filter = [GPUImageFilter new];
            self.filter = filter;
        }
            break;
    }
    
    
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
    
    self.navigationItem.rightBarButtonItem = self.stopBarButtonItem;
    self.captureTimer = [NSTimer scheduledTimerWithTimeInterval:1/(float)self.session.input.frameRate target:self selector:@selector(captureFrame:) userInfo:nil repeats:YES];
    [self captureFrame:self.captureTimer];
    
    self.stopButton.hidden = NO;
    self.startButton.hidden = YES;
    self.closeButton.hidden = YES;
}

- (IBAction)stopButtonTouchUpInside:(id)sender {
    [self.captureTimer invalidate];
    self.captureTimer = nil;
    self.navigationItem.rightBarButtonItem = self.startBarButtonItem;
    self.stopButton.hidden = YES;
    self.startButton.hidden = NO;
    self.closeButton.hidden = NO;
    
    [self.navigationController popViewControllerAnimated:YES];
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
    
    const CGFloat kLabelHeight = 21;
    
    CGRect frame = CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height);
    self.filterSelectionView = [[UIView alloc]initWithFrame:frame];
    self.filterSelectionView.backgroundColor = [UIColor blackColor];
    self.filterSelectionView.transform = CGAffineTransformMakeScale(0.01, 0.01);
    self.filterSelectionView.alpha = 0;
    
    
    CGFloat thirdWidth = self.filterSelectionView.bounds.size.width / 3.0;
    CGFloat thirdHeight = self.filterSelectionView.bounds.size.height / 3.0;
    
    CGRect frame0 = CGRectMake(0 * thirdWidth, 0 * thirdHeight, thirdWidth, thirdHeight);
    GPUImageView *filterView0 = [[GPUImageView alloc]initWithFrame:frame0];
    GPUImageOutput<GPUImageInput> *filter0 = [GPUImageCannyEdgeDetectionFilter new];
    [self.videoCamera addTarget:filter0];
    [filter0 addTarget:filterView0];
    [self.filterSelectionView addSubview:filterView0];
    
    CGRect labelFrame0 = CGRectMake(0 * thirdWidth, 0 * thirdHeight + (thirdHeight - kLabelHeight), thirdWidth, kLabelHeight);
    UILabel *label0 = [[UILabel alloc]initWithFrame:labelFrame0];
    label0.textAlignment = NSTextAlignmentCenter;
    label0.text = @"Canny";
    label0.textColor = [UIColor whiteColor];
    label0.backgroundColor = [[UIColor darkGrayColor] colorWithAlphaComponent:0.5];
    [self.filterSelectionView addSubview:label0];
    
    CGRect frame1 = CGRectMake(1 * thirdWidth, 0 * thirdHeight, thirdWidth, thirdHeight);
    GPUImageView *filterView1 = [[GPUImageView alloc]initWithFrame:frame1];
    GPUImageOutput<GPUImageInput> *filter1 = [GPUImagePrewittEdgeDetectionFilter new];
    [self.videoCamera addTarget:filter1];
    [filter1 addTarget:filterView1];
    [self.filterSelectionView addSubview:filterView1];

    
    CGRect labelFrame1 = CGRectMake(1 * thirdWidth, 0 * thirdHeight + (thirdHeight - kLabelHeight), thirdWidth, kLabelHeight);
    UILabel *label1 = [[UILabel alloc]initWithFrame:labelFrame1];
    label1.textAlignment = NSTextAlignmentCenter;
    label1.text = @"Prewitt";
    label1.textColor = [UIColor whiteColor];
    label1.backgroundColor = [[UIColor darkGrayColor] colorWithAlphaComponent:0.5];
    [self.filterSelectionView addSubview:label1];

    
    CGRect frame2 = CGRectMake(2 * thirdWidth, 0 * thirdHeight, thirdWidth, thirdHeight);
    GPUImageView *filterView2 = [[GPUImageView alloc]initWithFrame:frame2];
    GPUImageOutput<GPUImageInput> *filter2 = [GPUImageThresholdEdgeDetectionFilter new];
    [self.videoCamera addTarget:filter2];
    [filter2 addTarget:filterView2];
    [self.filterSelectionView addSubview:filterView2];
    
    CGRect labelFrame2 = CGRectMake(2 * thirdWidth, 0 * thirdHeight + (thirdHeight - kLabelHeight), thirdWidth, kLabelHeight);
    UILabel *label2 = [[UILabel alloc]initWithFrame:labelFrame2];
    label2.textAlignment = NSTextAlignmentCenter;
    label2.text = @"Threshold";
    label2.textColor = [UIColor whiteColor];
    label2.backgroundColor = [[UIColor darkGrayColor] colorWithAlphaComponent:0.5];
    [self.filterSelectionView addSubview:label2];


    CGRect frame3 = CGRectMake(0 * thirdWidth, 1 * thirdHeight, thirdWidth, thirdHeight);
    GPUImageView *filterView3 = [[GPUImageView alloc]initWithFrame:frame3];
    GPUImageOutput<GPUImageInput> *filter3 = [GPUImageSobelEdgeDetectionFilter new];
    [self.videoCamera addTarget:filter3];
    [filter3 addTarget:filterView3];
    [self.filterSelectionView addSubview:filterView3];
    
    CGRect labelFrame3 = CGRectMake(0 * thirdWidth, 1 * thirdHeight + (thirdHeight - kLabelHeight), thirdWidth, kLabelHeight);
    UILabel *label3 = [[UILabel alloc]initWithFrame:labelFrame3];
    label3.textAlignment = NSTextAlignmentCenter;
    label3.text = @"Sobel";
    label3.textColor = [UIColor whiteColor];
    label3.backgroundColor = [[UIColor darkGrayColor] colorWithAlphaComponent:0.5];
    [self.filterSelectionView addSubview:label3];

    CGRect frame4 = CGRectMake(1 * thirdWidth, 1 * thirdHeight, thirdWidth, thirdHeight);
    GPUImageView *filterView4 = [[GPUImageView alloc]initWithFrame:frame4];
    GPUImageOutput<GPUImageInput> *filter4 = [GPUImageFilter new];
    [self.videoCamera addTarget:filter4];
    [filter4 addTarget:filterView4];
    [self.filterSelectionView addSubview:filterView4];
    
    CGRect labelFrame4 = CGRectMake(1 * thirdWidth, 1 * thirdHeight + (thirdHeight - kLabelHeight), thirdWidth, kLabelHeight);
    UILabel *label4 = [[UILabel alloc]initWithFrame:labelFrame4];
    label4.textAlignment = NSTextAlignmentCenter;
    label4.text = @"None";
    label4.textColor = [UIColor whiteColor];
    label4.backgroundColor = [[UIColor darkGrayColor] colorWithAlphaComponent:0.5];
    [self.filterSelectionView addSubview:label4];


    CGRect frame5 = CGRectMake(2 * thirdWidth, 1 * thirdHeight, thirdWidth, thirdHeight);
    GPUImageView *filterView5 = [[GPUImageView alloc]initWithFrame:frame5];
    GPUImageOutput<GPUImageInput> *filter5 = [GPUImageSketchFilter new];
    [self.videoCamera addTarget:filter5];
    [filter5 addTarget:filterView5];
    [self.filterSelectionView addSubview:filterView5];
    
    CGRect labelFrame5 = CGRectMake(2 * thirdWidth, 1 * thirdHeight + (thirdHeight - kLabelHeight), thirdWidth, kLabelHeight);
    UILabel *label5 = [[UILabel alloc]initWithFrame:labelFrame5];
    label5.textAlignment = NSTextAlignmentCenter;
    label5.text = @"Sketch";
    label5.textColor = [UIColor whiteColor];
    label5.backgroundColor = [[UIColor darkGrayColor] colorWithAlphaComponent:0.5];
    [self.filterSelectionView addSubview:label5];

    CGRect frame6 = CGRectMake(0 * thirdWidth, 2 * thirdHeight, thirdWidth, thirdHeight);
    GPUImageView *filterView6 = [[GPUImageView alloc]initWithFrame:frame6];
    GPUImageOutput<GPUImageInput> *filter6 = [GPUImageSmoothToonFilter new];
    [self.videoCamera addTarget:filter6];
    [filter6 addTarget:filterView6];
    [self.filterSelectionView addSubview:filterView6];
    
    CGRect labelFrame6 = CGRectMake(0 * thirdWidth, 2 * thirdHeight + (thirdHeight - kLabelHeight), thirdWidth, kLabelHeight);
    UILabel *label6 = [[UILabel alloc]initWithFrame:labelFrame6];
    label6.textAlignment = NSTextAlignmentCenter;
    label6.text = @"Toon";
    label6.textColor = [UIColor whiteColor];
    label6.backgroundColor = [[UIColor darkGrayColor] colorWithAlphaComponent:0.5];
    [self.filterSelectionView addSubview:label6];


    CGRect frame7 = CGRectMake(1 * thirdWidth, 2 * thirdHeight, thirdWidth, thirdHeight);
    GPUImageView *filterView7 = [[GPUImageView alloc]initWithFrame:frame7];
    GPUImageOutput<GPUImageInput> *filter7 = [GPUImageAdaptiveThresholdFilter new];
    [self.videoCamera addTarget:filter7];
    [filter7 addTarget:filterView7];
    [self.filterSelectionView addSubview:filterView7];
    
    CGRect labelFrame7 = CGRectMake(1 * thirdWidth, 2 * thirdHeight + (thirdHeight - kLabelHeight), thirdWidth, kLabelHeight);
    UILabel *label7 = [[UILabel alloc]initWithFrame:labelFrame7];
    label7.textAlignment = NSTextAlignmentCenter;
    label7.text = @"Adaptive";
    label7.textColor = [UIColor whiteColor];
    label7.backgroundColor = [[UIColor darkGrayColor] colorWithAlphaComponent:0.5];
    [self.filterSelectionView addSubview:label7];


    CGRect frame8 = CGRectMake(2 * thirdWidth, 2 * thirdHeight, thirdWidth, thirdHeight);
    GPUImageView *filterView8 = [[GPUImageView alloc]initWithFrame:frame8];
    GPUImageOutput<GPUImageInput> *filter8 = [GPUImagePolkaDotFilter new];
    [self.videoCamera addTarget:filter8];
    [filter8 addTarget:filterView8];
    [self.filterSelectionView addSubview:filterView8];

    CGRect labelFrame8 = CGRectMake(2 * thirdWidth, 2 * thirdHeight + (thirdHeight - kLabelHeight), thirdWidth, kLabelHeight);
    UILabel *label8 = [[UILabel alloc]initWithFrame:labelFrame8];
    label8.textAlignment = NSTextAlignmentCenter;
    label8.text = @"Polka Dots";
    label8.textColor = [UIColor whiteColor];
    label8.backgroundColor = [[UIColor darkGrayColor] colorWithAlphaComponent:0.5];
    [self.filterSelectionView addSubview:label8];

    
    
    [self.view addSubview:self.filterSelectionView];
    
    [UIView animateWithDuration:0.3 animations:^{
        self.filterSelectionView.transform = CGAffineTransformIdentity;
        self.filterSelectionView.alpha = 1.0;
    } completion:^(BOOL finished) {
        
    }];
    
    
    
    
    
    
    
    
    
    
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        
        [UIView animateWithDuration:0.3 animations:^{
            self.filterSelectionView.transform = CGAffineTransformMakeScale(0.01, 0.01);
            self.filterSelectionView.alpha = 0;
        } completion:^(BOOL finished) {
            
            
            
            [self.videoCamera removeTarget:filter0];
            [filter0 removeAllTargets];
            [filterView0 removeFromSuperview];

            [self.videoCamera removeTarget:filter0];
            [filter1 removeAllTargets];
            [filterView1 removeFromSuperview];

            [self.videoCamera removeTarget:filter2];
            [filter2 removeAllTargets];
            [filterView2 removeFromSuperview];

            [self.videoCamera removeTarget:filter3];
            [filter3 removeAllTargets];
            [filterView3 removeFromSuperview];

            [self.videoCamera removeTarget:filter4];
            [filter4 removeAllTargets];
            [filterView4 removeFromSuperview];

            [self.videoCamera removeTarget:filter5];
            [filter5 removeAllTargets];
            [filterView5 removeFromSuperview];

            [self.videoCamera removeTarget:filter6];
            [filter6 removeAllTargets];
            [filterView6 removeFromSuperview];

            [self.videoCamera removeTarget:filter7];
            [filter7 removeAllTargets];
            [filterView7 removeFromSuperview];

            [self.videoCamera removeTarget:filter8];
            [filter8 removeAllTargets];
            [filterView8 removeFromSuperview];

            
            
            
            
            [self.filterSelectionView removeFromSuperview];
            _filterSelectionView = nil;
        }];

    });
    
}


@end

