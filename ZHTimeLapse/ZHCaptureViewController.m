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

@end

@implementation ZHCaptureViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    self.captureImageView.layer.borderWidth = 1.0;
    self.captureImageView.layer.borderColor = self.view.tintColor.CGColor;
    
    self.cameraPosition = AVCaptureDevicePositionBack;

    self.frameCountLabel.text = @"";
    self.frameCounter = 0;

    self.stopButton.hidden = YES;

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

        case ZHSessionFilterToon:{
            GPUImageToonFilter *filter = [GPUImageToonFilter new];
            self.filter = filter;
        }
            break;
        case ZHSessionFilterSmoothToon:{
            GPUImageSmoothToonFilter *filter = [GPUImageSmoothToonFilter new];
            self.filter = filter;
        }
            break;
            
            
            
        case ZHSessionFilterDilation:{
            GPUImageDilationFilter *filter = [GPUImageDilationFilter new];
            self.filter = filter;
        }
            break;
            
        case ZHSessionFilterErosion:{
            GPUImageErosionFilter *filter = [GPUImageErosionFilter new];
            self.filter = filter;
        }
            break;

        case ZHSessionFilterMosaic:{
            GPUImageMosaicFilter *filter = [GPUImageMosaicFilter new];
            self.filter = filter;
        }
            break;

        case ZHSessionFilterGlassSphere:{
            GPUImageGlassSphereFilter *filter = [GPUImageGlassSphereFilter new];
            self.filter = filter;
        }
            break;

        case ZHSessionFilterAdaptiveThreshold:{
            GPUImageAdaptiveThresholdFilter *filter = [GPUImageAdaptiveThresholdFilter new];
            self.filter = filter;
        }
            break;

        case ZHSessionFilterPolkaDot:{
            GPUImagePolkaDotFilter *filter = [GPUImagePolkaDotFilter new];
            self.filter = filter;
        }
            break;
            
        case ZHSessionFilterHalftone:{
            GPUImageHalftoneFilter *filter = [GPUImageHalftoneFilter new];
            self.filter = filter;
        }
            break;

        case ZHSessionFilterHoughLineDetection:{
            GPUImageHoughTransformLineDetector *filter = [GPUImageHoughTransformLineDetector new];
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


@end

