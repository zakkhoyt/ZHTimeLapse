//
//  ZHRenderer.m
//  ZHTimeLapse
//
//  Created by Zakk Hoyt on 12/24/15.
//  Copyright © 2015 Zakk Hoyt. All rights reserved.
//
//  Info on how to make a gif:
//  http://stackoverflow.com/questions/14915138/create-and-and-export-an-animated-gif-via-ios


#import "ZHRenderer.h"
@import AVFoundation;
@import ImageIO;
@import  MobileCoreServices;

#import "ZHDefines.h"
#import "ZHSession.h"
#import "PHAsset+Utility.h"
#import "ZHFileManager.h"


@interface ZHRenderer ()
@property (nonatomic, strong) AVAssetWriter *videoWriter;
@end

@implementation ZHRenderer


- (UIImage*)rotateImage:(UIImage*)sourceImage orientation:(UIImageOrientation)orientation {
    CGSize size = sourceImage.size;
    UIGraphicsBeginImageContext(CGSizeMake(size.height, size.width));
    UIImage *rotatedImage = [UIImage imageWithCGImage:[sourceImage CGImage] scale:1.0 orientation:orientation];
    [rotatedImage drawInRect:CGRectMake(0,0,size.height ,size.width)];
    UIImage* newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return newImage;
}

-(void)renderSessionToVideo:(ZHSession*)session progressBlock:(ZHRendererProgressBlock)progressBlock completionBlock:(ZHRendererCompletionBlock)completionBlock {
    
    // Delete any existing file first.
    [ZHFileManager deleteFileAtURL:session.output.outputURL];
    
    // Create our video writer and configure
    NSError *error = nil;
    self.videoWriter = [[AVAssetWriter alloc]initWithURL:session.output.outputURL fileType:AVFileTypeQuickTimeMovie error:&error];
    NSDictionary *videoSettings = nil;
    
    
    if(session.input.orientation == UIDeviceOrientationLandscapeRight ||
       session.input.orientation == UIDeviceOrientationLandscapeLeft) {
        videoSettings = @{AVVideoCodecKey : AVVideoCodecH264,
                          AVVideoWidthKey : @(session.output.size.height),
                          AVVideoHeightKey : @(session.output.size.width),
                          };
        
    } else {
        videoSettings = @{AVVideoCodecKey : AVVideoCodecH264,
                          AVVideoWidthKey : @(session.output.size.width),
                          AVVideoHeightKey : @(session.output.size.height),
                          };
    }
    
    
    
    
    AVAssetWriterInput* videoWriterInput = [AVAssetWriterInput assetWriterInputWithMediaType:AVMediaTypeVideo outputSettings:videoSettings];
    
    AVAssetWriterInputPixelBufferAdaptor *adaptor = [AVAssetWriterInputPixelBufferAdaptor
                                                     assetWriterInputPixelBufferAdaptorWithAssetWriterInput:videoWriterInput
                                                     sourcePixelBufferAttributes:nil];
    
    videoWriterInput.expectsMediaDataInRealTime = NO;
    [self.videoWriter addInput:videoWriterInput];
    [self.videoWriter startWriting];
    [self.videoWriter startSessionAtSourceTime:kCMTimeZero];
    
    [adaptor.assetWriterInput requestMediaDataWhenReadyOnQueue:dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0) usingBlock:^{
        
        // Iterate over each frame we have until one isn't found or we've rendered them all.
        for(NSUInteger index = 0; index < session.input.frameCount; index++) {
            do {
                [NSThread sleepForTimeInterval:0.01]; // 10 ms
            } while ([adaptor.assetWriterInput isReadyForMoreMediaData] == NO);
            
            @autoreleasepool {
                UIImage* image = [session imageForIndex:index];
                if(image == nil) {
                    NSLog(@"Error Frame not found for index: %lu", (unsigned long)index);
                    break;
                }
                
                // rotate frames if needed
                CGSize outputSize = CGSizeZero;
                // TODO: Support upside down. NEed to modify rotate function.
                //                if(session.input.orientation == UIDeviceOrientationPortraitUpsideDown) {
                //                    outputSize = session.output.size;
                //                    image = [self rotateImage:image orientation:UIImageOrientationDownMirrored];
                //                } else
                if(session.input.orientation == UIDeviceOrientationLandscapeRight) {
                    outputSize = CGSizeMake(session.output.size.height, session.output.size.width);
                    image = [self rotateImage:image orientation:UIImageOrientationRight];
                } else if(session.input.orientation == UIDeviceOrientationLandscapeLeft) {
                    outputSize = CGSizeMake(session.output.size.height, session.output.size.width);
                    image = [self rotateImage:image orientation:UIImageOrientationLeft];
                } else {
                    // portrait, unknown, face down, face up.
                    outputSize = session.output.size;
                }
                
                CVPixelBufferRef buffer = [self pixelBufferFromImage:image withImageSize:outputSize];
                [self appendToAdapter:adaptor pixelBuffer:buffer atTime:CMTimeMake(index, session.output.frameRate)];
                CVPixelBufferRelease(buffer);
                
                // Update our caller
                if(progressBlock) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        progressBlock(index+1, session.input.frameCount);
                    });
                }
            }
        }
        
        // Finished writing frames. Finish up.
        [videoWriterInput markAsFinished];
        [self.videoWriter endSessionAtSourceTime:CMTimeMake(session.input.frameCount, session.output.frameRate)];
        
        // Add a small delay to make sure the session is finished.
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.25 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self.videoWriter finishWritingWithCompletionHandler:^{
                
                if(self.videoWriter.status == AVAssetWriterStatusCompleted){
                    NSLog(@"Video writer has finished creating video");
                    
                    [PHAsset saveVideoAtURL:session.output.outputURL location:nil completionBlock:^(PHAsset *asset, BOOL success) {
                        NSLog(@"Exported video to camera roll");
                        
                        if (success == YES) {
                            NSBundle* bundle = [NSBundle mainBundle];
                            NSString *executable = [bundle objectForInfoDictionaryKey:@"CFBundleName"];

                            [asset saveToAlbum:executable completionBlock:^(BOOL success) {
                                NSLog(@"Linking video to photo album");
                            }];
                        }
                        
                        if(completionBlock) {
                            dispatch_async(dispatch_get_main_queue(), ^{
                                if(success == YES) {
                                    completionBlock(YES, session);
                                } else {
                                    completionBlock(NO, nil);
                                }
                            });
                        }
                    }];
                    
                } else if (self.videoWriter.status == AVAssetWriterStatusFailed){
                    NSLog(@"Error: %@", self.videoWriter.error.localizedDescription);
                    if(completionBlock) {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            completionBlock(NO, nil);
                        });
                    }
                    
                } else {
                    NSLog(@"Unknown condition");
                    if(completionBlock) {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            completionBlock(NO, nil);
                        });
                    }
                }
            }];
        });
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





-(void)renderSessionToGIF:(ZHSession*)session
            progressBlock:(ZHRendererProgressBlock)progressBlock
          completionBlock:(ZHRendererCompletionBlock)completionBlock {
    
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        
        
        NSUInteger frameCount = session.input.frameCount;
        
        NSDictionary *fileProperties = @{
                                         (__bridge id)kCGImagePropertyGIFDictionary: @{
                                                 (__bridge id)kCGImagePropertyGIFLoopCount: @0, // 0 means loop forever
                                                 }
                                         };
        
        NSDictionary *frameProperties = @{
                                          (__bridge id)kCGImagePropertyGIFDictionary: @{
                                                  (__bridge id)kCGImagePropertyGIFDelayTime: @0.033f, // a float (not double!) in seconds, rounded to centiseconds in the GIF data
                                                  }
                                          };
        
        
        CGImageDestinationRef destination = CGImageDestinationCreateWithURL((__bridge CFURLRef)session.output.outputGIF, kUTTypeGIF, frameCount, NULL);
        CGImageDestinationSetProperties(destination, (__bridge CFDictionaryRef)fileProperties);
        
        for (NSUInteger index = 0; index < frameCount; index++) {
            @autoreleasepool {
                UIImage* image = [session imageForIndex:index];
                if(image == nil) {
                    NSLog(@"Error Frame not found for index: %lu", (unsigned long)index);
                    break;
                }
                
                // rotate frames if needed
                CGSize outputSize = CGSizeZero;
                // TODO: Support upside down. NEed to modify rotate function.
                //                if(session.input.orientation == UIDeviceOrientationPortraitUpsideDown) {
                //                    outputSize = session.output.size;
                //                    image = [self rotateImage:image orientation:UIImageOrientationDownMirrored];
                //                } else
                if(session.input.orientation == UIDeviceOrientationLandscapeRight) {
                    outputSize = CGSizeMake(session.output.size.height, session.output.size.width);
                    image = [self rotateImage:image orientation:UIImageOrientationRight];
                } else if(session.input.orientation == UIDeviceOrientationLandscapeLeft) {
                    outputSize = CGSizeMake(session.output.size.height, session.output.size.width);
                    image = [self rotateImage:image orientation:UIImageOrientationLeft];
                } else {
                    // portrait, unknown, face down, face up.
                    outputSize = session.output.size;
                }
                
                CGImageDestinationAddImage(destination, image.CGImage, (__bridge CFDictionaryRef)frameProperties);
                
                // Update our caller
                if(progressBlock) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        progressBlock(index+1, session.input.frameCount);
                    });
                }
            }
        }
        
        BOOL success = YES;
        if (!CGImageDestinationFinalize(destination)) {
            NSLog(@"Error: failed to finalize image destination");
        } else {
            NSLog(@"Success! Rendered GIF");
        }
        
        // Cleanup
        CFRelease(destination);
        
        // Completion
        if(completionBlock) {
            dispatch_async(dispatch_get_main_queue(), ^{
                completionBlock(success, session);
            });
        }
    });
}


@end




