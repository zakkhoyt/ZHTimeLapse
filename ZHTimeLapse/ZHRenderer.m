//
//  ZHRenderer.m
//  ZHTimeLapse
//
//  Created by Zakk Hoyt on 12/24/15.
//  Copyright © 2015 Zakk Hoyt. All rights reserved.
//

#import "ZHRenderer.h"
@import AVFoundation;

@implementation ZHRenderer


//-(void) writeImagesToMovieAtPath:(NSString *) path withSize:(CGSize) size {
//    NSLog(@"Write Started");
//    
//    NSError *error = nil;
//    
//    AVAssetWriter *videoWriter = [[AVAssetWriter alloc] initWithURL:
//                                  [NSURL fileURLWithPath:path] fileType:AVFileTypeQuickTimeMovie
//                                                              error:&error];
//    NSParameterAssert(videoWriter);
//    
//    NSDictionary *videoSettings = [NSDictionary dictionaryWithObjectsAndKeys:
//                                   AVVideoCodecH264, AVVideoCodecKey,
//                                   [NSNumber numberWithInt:size.width], AVVideoWidthKey,
//                                   [NSNumber numberWithInt:size.height], AVVideoHeightKey,
//                                   nil];
//    
//    AVAssetWriterInput* videoWriterInput = [AVAssetWriterInput
//                                            assetWriterInputWithMediaType:AVMediaTypeVideo
//                                            outputSettings:videoSettings];
//    
//    
//    AVAssetWriterInputPixelBufferAdaptor *adaptor = [AVAssetWriterInputPixelBufferAdaptor
//                                                     assetWriterInputPixelBufferAdaptorWithAssetWriterInput:videoWriterInput
//                                                     sourcePixelBufferAttributes:nil];
//    
//    NSParameterAssert(videoWriterInput);
//    NSParameterAssert([videoWriter canAddInput:videoWriterInput]);
//    videoWriterInput.expectsMediaDataInRealTime = YES;
//    [videoWriter addInput:videoWriterInput];
//    
//    //Start a session:
//    [videoWriter startWriting];
//    [videoWriter startSessionAtSourceTime:kCMTimeZero];
//    
//    CVPixelBufferRef buffer = NULL;
//    
//    //convert uiimage to CGImage.
//    
//    int frameCount = 0;
//    
//    for(UIImage * img in imageArray)
//    {
//        buffer = [self pixelBufferFromCGImage:[img CGImage] andSize:size];
//        
//        BOOL append_ok = NO;
//        int j = 0;
//        while (!append_ok && j < 30)
//        {
//            if (adaptor.assetWriterInput.readyForMoreMediaData)
//            {
//                printf("appending %d attemp %d\n", frameCount, j);
//                
//                CMTime frameTime = CMTimeMake(frameCount,(int32_t) kRecordingFPS);
//                append_ok = [adaptor appendPixelBuffer:buffer withPresentationTime:frameTime];
//                
//                if(buffer)
//                    CVBufferRelease(buffer);
//                [NSThread sleepForTimeInterval:0.05];
//            }
//            else
//            {
//                printf("adaptor not ready %d, %d\n", frameCount, j);
//                [NSThread sleepForTimeInterval:0.1];
//            }
//            j++;
//        }
//        if (!append_ok) {
//            printf("error appending image %d times %d\n", frameCount, j);
//        }
//        frameCount++;
//    }
//
//
//    //Finish the session:
//    [videoWriterInput markAsFinished];
//    [videoWriter finishWriting];
//    NSLog(@"Write Ended");
//}
//
//
//- (CVPixelBufferRef) pixelBufferFromCGImage: (CGImageRef) image andSize:(CGSize) size
//{
//    NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:
//                             [NSNumber numberWithBool:YES], kCVPixelBufferCGImageCompatibilityKey,
//                             [NSNumber numberWithBool:YES], kCVPixelBufferCGBitmapContextCompatibilityKey,
//                             nil];
//    CVPixelBufferRef pxbuffer = NULL;
//    
//    CVReturn status = CVPixelBufferCreate(kCFAllocatorDefault, size.width,
//                                          size.height, kCVPixelFormatType_32ARGB, (CFDictionaryRef) options,
//                                          &pxbuffer);
//    NSParameterAssert(status == kCVReturnSuccess && pxbuffer != NULL);
//    
//    CVPixelBufferLockBaseAddress(pxbuffer, 0);
//    void *pxdata = CVPixelBufferGetBaseAddress(pxbuffer);
//    NSParameterAssert(pxdata != NULL);
//    
//    CGColorSpaceRef rgbColorSpace = CGColorSpaceCreateDeviceRGB();
//    CGContextRef context = CGBitmapContextCreate(pxdata, size.width,
//                                                 size.height, 8, 4*size.width, rgbColorSpace,
//                                                 kCGImageAlphaNoneSkipFirst);
//    NSParameterAssert(context);
//    CGContextConcatCTM(context, CGAffineTransformMakeRotation(0));
//    CGContextDrawImage(context, CGRectMake(0, 0, CGImageGetWidth(image),
//                                           CGImageGetHeight(image)), image);
//    CGColorSpaceRelease(rgbColorSpace);
//    CGContextRelease(context);
//    
//    CVPixelBufferUnlockBaseAddress(pxbuffer, 0);
//    
//    return pxbuffer;
//}
@end
