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

@interface ZHCaptureViewController ()
@property (weak, nonatomic) IBOutlet GPUImageView *filterView;
@property (nonatomic, strong) GPUImageVideoCamera *videoCamera;
@property (nonatomic, strong) GPUImageFilter *filter;
@property (nonatomic, strong) NSTimer *captureTimer;
@property (nonatomic, strong) NSArray *frames;
@property (nonatomic, strong) GPUImageRawDataOutput *rawOutput;
@property (nonatomic) CGSize frameSize;
@property (weak, nonatomic) IBOutlet UIImageView *captureImageView;
@end

@implementation ZHCaptureViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.filterView.fillMode = kGPUImageFillModePreserveAspectRatioAndFill;
    
    self.videoCamera = [[GPUImageVideoCamera alloc] initWithSessionPreset:AVCaptureSessionPreset640x480 cameraPosition:AVCaptureDevicePositionFront];
    self.videoCamera.outputImageOrientation = UIInterfaceOrientationPortrait;
    
    self.filter = [GPUImageSepiaFilter new];
    [self.filter addTarget:self.filterView];
    
    self.frameSize = CGSizeMake(480, 640);
    self.rawOutput = [[GPUImageRawDataOutput alloc]initWithImageSize:self.frameSize resultsInBGRAFormat:YES];
    [self.filter addTarget:self.rawOutput];
    
    [self.videoCamera addTarget:self.filter];
    [self.videoCamera startCameraCapture];
    

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark IBActions

- (IBAction)startBarButtonAction:(id)sender {
    self.frames = [[NSMutableArray alloc]init];
    self.captureTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(captureFrame:) userInfo:nil repeats:YES];
}

- (IBAction)stopBarButtonAction:(id)sender {
    
}

#pragma mark Private methods
-(void)captureFrame:(NSTimer*)sender {
    
    NSUInteger width = self.frameSize.width;
    NSUInteger height = self.frameSize.height;
    
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
    
    UIImage *newImage = [UIImage imageWithCGImage:imageRef];
    
    NSLog(@"UIImage: width:%lu, height:%lu",
          (unsigned long)newImage.size.width,
          (unsigned long)newImage.size.height);
    
    self.captureImageView.image = newImage;
    
}


@end
