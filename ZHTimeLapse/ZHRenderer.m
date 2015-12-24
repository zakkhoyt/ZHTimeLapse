//
//  ZHRenderer.m
//  ZHTimeLapse
//
//  Created by Zakk Hoyt on 12/24/15.
//  Copyright © 2015 Zakk Hoyt. All rights reserved.
//

#import "ZHRenderer.h"
@import AVFoundation;
#import "ZHSession.h"
#import "PHAsset+Utility.h"
#import "ZHFileManager.h"


@interface ZHRenderer ()
@property (nonatomic, strong) AVAssetWriter *videoWriter;
@end

@implementation ZHRenderer


//-(void)renderSession:(ZHSession*)session progressBlock:(ZHRendererProgressBlock)progressBlock completionBlock:(ZHRendererCompletionBlock)completionBlock {
//    NSError *error = nil;
//    AVAssetWriter *videoWriter = [[AVAssetWriter alloc] initWithURL:
//                                  [NSURL fileURLWithPath:somePath] fileType:AVFileTypeQuickTimeMovie
//                                                              error:&error];
//    NSParameterAssert(videoWriter);
//    
//    NSDictionary *videoSettings = [NSDictionary dictionaryWithObjectsAndKeys:
//                                   AVVideoCodecH264, AVVideoCodecKey,
//                                   [NSNumber numberWithInt:640], AVVideoWidthKey,
//                                   [NSNumber numberWithInt:480], AVVideoHeightKey,
//                                   nil];
//    AVAssetWriterInput* writerInput = [[AVAssetWriterInput
//                                        assetWriterInputWithMediaType:AVMediaTypeVideo
//                                        outputSettings:videoSettings] retain]; //retain should be removed if ARC
//    
//    NSParameterAssert(writerInput);
//    NSParameterAssert([videoWriter canAddInput:writerInput]);
//    [videoWriter addInput:writerInput];
//    
//    
//    
//    [videoWriter startWriting];
//    [videoWriter startSessionAtSourceTime:…] //use kCMTimeZero if unsure
//    
//    
//    
//    
//    // Or you can use AVAssetWriterInputPixelBufferAdaptor.
//    // That lets you feed the writer input data from a CVPixelBuffer
//    // that’s quite easy to create from a CGImage.
//    [writerInput appendSampleBuffer:sampleBuffer];
//    
//    
//    [writerInput markAsFinished];
//    [videoWriter endSessionAtSourceTime:…]; //optional can call finishWriting without specifiying endTime
//    [videoWriter finishWriting]; //deprecated in ios6
//    /*
//     [videoWriter finishWritingWithCompletionHandler:...]; //ios 6.0+
//     */
//    
//    
//}
//
//- (CVPixelBufferRef) newPixelBufferFromCGImage: (CGImageRef) image
//{
//    NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:
//                             [NSNumber numberWithBool:YES], kCVPixelBufferCGImageCompatibilityKey,
//                             [NSNumber numberWithBool:YES], kCVPixelBufferCGBitmapContextCompatibilityKey,
//                             nil];
//    CVPixelBufferRef pxbuffer = NULL;
//    CVReturn status = CVPixelBufferCreate(kCFAllocatorDefault, frameSize.width,
//                                          frameSize.height, kCVPixelFormatType_32ARGB, (CFDictionaryRef) options,
//                                          &pxbuffer);
//    NSParameterAssert(status == kCVReturnSuccess && pxbuffer != NULL);
//    
//    CVPixelBufferLockBaseAddress(pxbuffer, 0);
//    void *pxdata = CVPixelBufferGetBaseAddress(pxbuffer);
//    NSParameterAssert(pxdata != NULL);
//    
//    CGColorSpaceRef rgbColorSpace = CGColorSpaceCreateDeviceRGB();
//    CGContextRef context = CGBitmapContextCreate(pxdata, frameSize.width,
//                                                 frameSize.height, 8, 4*frameSize.width, rgbColorSpace,
//                                                 kCGImageAlphaNoneSkipFirst);
//    NSParameterAssert(context);
//    CGContextConcatCTM(context, frameTransform);
//    CGContextDrawImage(context, CGRectMake(0, 0, CGImageGetWidth(image),
//                                           CGImageGetHeight(image)), image);
//    CGColorSpaceRelease(rgbColorSpace);
//    CGContextRelease(context);
//    
//    CVPixelBufferUnlockBaseAddress(pxbuffer, 0);
//    
//    return pxbuffer;
//}



-(void)renderSession:(ZHSession*)session progressBlock:(ZHRendererProgressBlock)progressBlock completionBlock:(ZHRendererCompletionBlock)completionBlock {
    
    [ZHFileManager deleteFileAtURL:session.output.outputURL];
    
    
    NSError *error = nil;
//    self.videoWriter = [[AVAssetWriter alloc] initWithURL:session.output.outputURL fileType:AVFileTypeMPEG4 error:&error];
    self.videoWriter = [[AVAssetWriter alloc]initWithURL:session.output.outputURL fileType:AVFileTypeQuickTimeMovie error:&error];
    // Codec compression settings
    NSDictionary *videoSettings = @{
                                    AVVideoCodecKey : AVVideoCodecH264,
                                    AVVideoWidthKey : @(session.output.size.width),
                                    AVVideoHeightKey : @(session.output.size.height),
                                    AVVideoCompressionPropertiesKey : @{
                                            AVVideoAverageBitRateKey : @(20000*1000), // 20 000 kbits/s
                                            AVVideoProfileLevelKey : AVVideoProfileLevelH264High40,
                                            AVVideoMaxKeyFrameIntervalKey : @(1)
                                            }
                                    };
    
    AVAssetWriterInput* videoWriterInput = [AVAssetWriterInput assetWriterInputWithMediaType:AVMediaTypeVideo outputSettings:videoSettings];
    
    AVAssetWriterInputPixelBufferAdaptor *adaptor = [AVAssetWriterInputPixelBufferAdaptor
                                                     assetWriterInputPixelBufferAdaptorWithAssetWriterInput:videoWriterInput
                                                     sourcePixelBufferAttributes:nil];
    
    videoWriterInput.expectsMediaDataInRealTime = NO;
    [self.videoWriter addInput:videoWriterInput];
    [self.videoWriter startWriting];
    [self.videoWriter startSessionAtSourceTime:kCMTimeZero];
    
    [adaptor.assetWriterInput requestMediaDataWhenReadyOnQueue:dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0) usingBlock:^{
//        CMTime time = CMTimeMakeWithSeconds(0, 30);

        for(NSUInteger index = 0; index < session.frameCount; index++) {
            UIImage* image = [session imageForIndex:index];
            if(image == nil) {
                NSLog(@"Error Frame not found: ");
                break;
            }
            
            CVPixelBufferRef buffer = [self pixelBufferFromImage:image withImageSize:session.output.size];
            [self appendToAdapter:adaptor pixelBuffer:buffer atTime:CMTimeMake(index, 30)];
            CVPixelBufferRelease(buffer);
//            
//            CMTime millisecondsDuration = CMTimeMake(index+1, 30);
//            time = CMTimeAdd(time, millisecondsDuration);
            
            if(progressBlock) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    progressBlock(index, session.frameCount);
                });
            }
        }
        
        [videoWriterInput markAsFinished];
        [self.videoWriter endSessionAtSourceTime:CMTimeMake(session.frameCount, 30)];
        [self.videoWriter finishWritingWithCompletionHandler:^{
            
            if(self.videoWriter.status == AVAssetWriterStatusCompleted){
                NSLog(@"Video writer has finished creating video");
                
                [PHAsset saveVideoAtURL:session.output.outputURL location:nil completionBlock:^(PHAsset *asset, BOOL success) {
                    NSLog(@"Exported video to camera roll");
                    
                    if(completionBlock) {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            completionBlock(session);
                        });
                    }
                }];

            } else if (self.videoWriter.status == AVAssetWriterStatusFailed){
                NSLog(@"Error: %@", self.videoWriter.error.localizedDescription);
            } else {
                NSLog(@"Unknown condition");
            }
            
        }];
    }];
}

- (CVPixelBufferRef)pixelBufferFromImage:(UIImage*)image withImageSize:(CGSize)size{
    CGImageRef cgImage = image.CGImage;
    NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:
                             [NSNumber numberWithBool:YES], kCVPixelBufferCGImageCompatibilityKey,
                             [NSNumber numberWithBool:YES], kCVPixelBufferCGBitmapContextCompatibilityKey,
                             nil];
    CVPixelBufferRef pxbuffer = NULL;
    
    CVReturn status = CVPixelBufferCreate(kCFAllocatorDefault,
                                          size.width,
                                          size.height,
                                          kCVPixelFormatType_32ARGB,
                                          (__bridge CFDictionaryRef) options,
                                          &pxbuffer);
    if (status != kCVReturnSuccess){
        NSLog(@"Failed to create pixel buffer");
    }
    
    CVPixelBufferLockBaseAddress(pxbuffer, 0);
    void *pxdata = CVPixelBufferGetBaseAddress(pxbuffer);
    
    CGColorSpaceRef rgbColorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef context = CGBitmapContextCreate(pxdata, size.width, size.height, 8, 4*size.width, rgbColorSpace, 2);
    CGContextConcatCTM(context, CGAffineTransformMakeRotation(0));
    CGContextDrawImage(context, CGRectMake(0, 0, CGImageGetWidth(cgImage), CGImageGetHeight(cgImage)), cgImage);
    CGColorSpaceRelease(rgbColorSpace);
    CGContextRelease(context);
    
    CVPixelBufferUnlockBaseAddress(pxbuffer, 0);
    
    return pxbuffer;
}

-(BOOL)appendToAdapter:(AVAssetWriterInputPixelBufferAdaptor*)adaptor
            pixelBuffer:(CVPixelBufferRef)buffer
                 atTime:(CMTime)time{
    while (!adaptor.assetWriterInput.readyForMoreMediaData) {
        [[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.1]];
    }
    return [adaptor appendPixelBuffer:buffer withPresentationTime:time];
}
@end
