//
//  ZHInputModel.m
//  ZHTimeLapse
//
//  Created by Zakk Hoyt on 12/21/15.
//  Copyright © 2015 Zakk Hoyt. All rights reserved.
//

#import "ZHInputSession.h"
#import "ZHDefines.h"

@implementation ZHInputSession

- (instancetype)init {
    self = [super init];
    if (self) {
        [self commonInit];
    }
    return self;
}



-(void)commonInit {
    _frameRateFrames = 4;
    _frameRateSeconds = 1;
    _captureDevicePosition = AVCaptureDevicePositionFront;
    _size = CGSizeMake(720, 1280);
    _filter = [[ZHFilter alloc]initWithFilterType:ZHFilterTypeThresholdSketch];
}

- (instancetype)initWithDictionary:(NSDictionary*)dictionary {
    self = [super init];
    if(self) {
        [self commonInit];
        
        NSString *sizeString = dictionary[@"size"];
        if(sizeString) {
            _size = CGSizeFromString(sizeString);
        }
        
        NSNumber *frameRateFramesNumber = dictionary[@"frameRateFrames"];
        if(frameRateFramesNumber) {
            _frameRateFrames = frameRateFramesNumber.doubleValue;
        }
        
        NSNumber *frameRateSecondsNumber = dictionary[@"frameRateSeconds"];
        if(frameRateSecondsNumber) {
            _frameRateSeconds = frameRateSecondsNumber.doubleValue;
        }

        
        NSNumber *filterNumber = dictionary[@"filter"];
        if(filterNumber) {
            ZHFilterType filterType = (ZHFilterType)filterNumber.unsignedIntegerValue;
            _filter = [[ZHFilter alloc]initWithFilterType:filterType];
        }
        
        NSNumber *captureDevicePositionNumber = dictionary[@"captureDevicePosition"];
        if(captureDevicePositionNumber) {
            _captureDevicePosition = captureDevicePositionNumber.unsignedIntegerValue;
        }
        
        NSNumber *orientationNumber = dictionary[@"orientation"];
        if(orientationNumber) {
            _orientation = orientationNumber.unsignedIntegerValue;
        }

    }
    return self;
}


-(NSDictionary*)dictionaryRepresentation {

    NSMutableDictionary *dictionary = [@{}mutableCopy];
    dictionary[@"size"] = NSStringFromCGSize(_size);
    dictionary[@"frameRateFrames"] = @(_frameRateFrames);
    dictionary[@"frameRateSeconds"] = @(_frameRateSeconds);
    dictionary[@"filter"] = @(_filter.filterType);
    dictionary[@"captureDevicePosition"] = @(_captureDevicePosition);
    dictionary[@"orientation"] = @(_orientation);
    
    return dictionary;
}

- (id)copyWithZone:(nullable NSZone *)zone{
    ZHInputSession *input = [ZHInputSession new];
    input.filter = [_filter copy];
    input.size = _size;
    input.frameRateFrames = _frameRateFrames;
    input.frameRateSeconds = _frameRateSeconds;
    input.captureDevicePosition = _captureDevicePosition;
    input.orientation = _orientation;
    return input;
}

-(NSTimeInterval)frameRate {
    return (NSTimeInterval)(_frameRateFrames / (NSTimeInterval)_frameRateSeconds);
}

@end
