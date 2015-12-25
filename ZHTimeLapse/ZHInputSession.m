//
//  ZHInputModel.m
//  ZHTimeLapse
//
//  Created by Zakk Hoyt on 12/21/15.
//  Copyright © 2015 Zakk Hoyt. All rights reserved.
//

#import "ZHInputSession.h"

@implementation ZHInputSession

- (instancetype)init {
    self = [super init];
    if (self) {
        [self commonInit];
        
    }
    return self;
}


-(void)commonInit {
    _frameRate = 2;
    _size = CGSizeMake(720, 1280);
    _filter = ZHSessionFilterCannyEdgeDetection;
}

- (instancetype)initWithDictionary:(NSDictionary*)dictionary {
    self = [super init];
    if(self) {
        [self commonInit];
        
        NSString *sizeString = dictionary[@"size"];
        if(sizeString) {
            _size = CGSizeFromString(sizeString);
        }
        
        NSNumber *frameRateNumber = dictionary[@"frameRate"];
        if(frameRateNumber) {
            _frameRate = frameRateNumber.doubleValue;
        }
        
        NSNumber *filterNumber = dictionary[@"filter"];
        if(filterNumber) {
            _filter = (ZHSessionFilter)filterNumber.unsignedIntegerValue;
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
    dictionary[@"frameRate"] = @(_frameRate);
    dictionary[@"filter"] = @(_filter);
    dictionary[@"captureDevicePosition"] = @(_captureDevicePosition);
    dictionary[@"orientation"] = @(_orientation);
    
    return dictionary;
}


@end
