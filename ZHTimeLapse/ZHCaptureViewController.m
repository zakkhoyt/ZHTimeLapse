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
@end

@implementation ZHCaptureViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.frameCountLabel.text = @"";
    self.frameCounter = 0;
    
    self.captureImageView.layer.borderWidth = 1.0;
    self.captureImageView.layer.borderColor = [UIColor greenColor].CGColor;
    
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
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/


#pragma mark Private methods

-(void)setupCaptureSession{
    self.captureImageView.hidden = YES;
    self.filterView.fillMode = kGPUImageFillModePreserveAspectRatioAndFill;
    
    // Clean up
    if(self.videoCamera) {
        [self.videoCamera stopCameraCapture];
        [self.videoCamera removeAllTargets];
        [self.filter removeAllTargets];
        self.rawOutput = nil;
        self.videoCamera = nil;
    }
    
    
    
    self.videoCamera = [[GPUImageVideoCamera alloc] initWithSessionPreset:AVCaptureSessionPreset1280x720 cameraPosition:AVCaptureDevicePositionBack];
    self.videoCamera.outputImageOrientation = UIInterfaceOrientationPortrait;
    self.videoCamera.horizontallyMirrorFrontFacingCamera = YES;
    
    self.filter = [GPUImageCannyEdgeDetectionFilter new];
//    self.filter = [GPUImagePrewittEdgeDetectionFilter new];
//    self.filter = [GPUImageThresholdEdgeDetectionFilter new];
    [self.filter addTarget:self.filterView];
    

    self.rawOutput = [[GPUImageRawDataOutput alloc]initWithImageSize:self.session.input.size resultsInBGRAFormat:NO];
    [self.filter addTarget:self.rawOutput];
    
    [self.videoCamera addTarget:self.filter];
    [self.videoCamera startCameraCapture];

}

#pragma mark IBActions

- (IBAction)startButtonTouchUpInside:(id)sender {

    // Save our config
    self.session.input.captureDevicePosition = self.videoCamera.cameraPosition;
    self.session.input.orientation = [UIDevice currentDevice].orientation;
    [self.session saveConfig];
    
    NSLog(@"orientation: %lu", self.session.input.orientation);
    
    self.navigationItem.rightBarButtonItem = self.stopBarButtonItem;
    self.captureImageView.hidden = NO;
    self.frameCountLabel.hidden = NO;
    self.captureTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(captureFrame:) userInfo:nil repeats:YES];
    self.stopButton.hidden = NO;
    self.startButton.hidden = YES;
}

- (IBAction)stopButtonTouchUpInside:(id)sender {
    self.captureImageView.hidden = YES;
    self.frameCountLabel.hidden = YES;
    [self.captureTimer invalidate];
    self.captureTimer = nil;
    self.navigationItem.rightBarButtonItem = self.startBarButtonItem;
    self.stopButton.hidden = YES;
    self.startButton.hidden = NO;
    
    [self.navigationController popViewControllerAnimated:YES];

}

- (IBAction)swapButtonTouchUpInside:(id)sender {
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
    
    // Clean up
    image = nil;
    CGImageRelease(imageRef);
    CGColorSpaceRelease(colorSpaceRef);
    CGDataProviderRelease(provider);
//    self.frameCountLabel.text = [NSString stringWithFormat:@"%lu", (unsigned long) self.session.frame.count];
    
}


@end

