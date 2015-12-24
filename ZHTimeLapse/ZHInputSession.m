//
//  ZHInputModel.m
//  ZHTimeLapse
//
//  Created by Zakk Hoyt on 12/21/15.
//  Copyright © 2015 Zakk Hoyt. All rights reserved.
//

#import "ZHInputSession.h"

@implementation ZHInputSession

- (instancetype)initWithDictionary:(NSDictionary*)dictionary {
    self = [super init];
    if(self) {
        NSString *sizeString = dictionary[@"size"];
        if(sizeString) {
            _size = CGSizeFromString(sizeString);
        }
        
        NSNumber *frameRateNumber = dictionary[@"frameRate"];
        if(frameRateNumber) {
            _frameRate = frameRateNumber.doubleValue;
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
    dictionary[@"captureDevicePosition"] = @(_captureDevicePosition);
    dictionary[@"orientation"] = @(_orientation);
    return dictionary;
}


@end
