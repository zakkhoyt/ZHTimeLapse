//
//  ZHInputModel.h
//  ZHTimeLapse
//
//  Created by Zakk Hoyt on 12/21/15.
//  Copyright © 2015 Zakk Hoyt. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GPUImage.h"
#import "ZHFilter.h"

@interface ZHInputSession : NSObject <NSCopying>
@property (nonatomic, strong) ZHFilter *filter;
@property (nonatomic) CGSize size;

-(NSTimeInterval)frameRate;

@property (nonatomic) NSUInteger frameRateFrames;
@property (nonatomic) NSUInteger frameRateSeconds;
@property (nonatomic) NSUInteger frameCount;


@property (nonatomic, strong) NSMutableArray *frames;
@property (nonatomic) AVCaptureDevicePosition captureDevicePosition;
@property (nonatomic) UIDeviceOrientation orientation;

- (instancetype)initWithDictionary:(NSDictionary*)dictionary;
-(NSDictionary*)dictionaryRepresentation;
@end
