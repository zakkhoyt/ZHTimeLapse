//
//  ZHOutputModel.m
//  ZHTimeLapse
//
//  Created by Zakk Hoyt on 12/21/15.
//  Copyright © 2015 Zakk Hoyt. All rights reserved.
//

#import "ZHOutputSession.h"
#import "ZHDefines.h"

@implementation ZHOutputSession

- (instancetype)init {
    self = [super init];
    if (self) {
        [self commonInit];
    }
    return self;
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
        
        NSNumber *outputTypeNumber = dictionary[@"outputType"];
        if(outputTypeNumber) {
            _outputType = (ZHOutputSessionOutputType)outputTypeNumber.unsignedIntegerValue;
        }

    }
    return self;
}

-(void)commonInit{
    _frameRate = 30;
    _size = CGSizeMake(480, 640);
    _outputType = ZHOutputSessionOutputTypeGIF;
}

-(NSDictionary*)dictionaryRepresentation {
    NSMutableDictionary *dictionary = [@{}mutableCopy];
    dictionary[@"size"] = NSStringFromCGSize(_size);
    dictionary[@"frameRate"] = @(_frameRate);
    dictionary[@"outputType"] = @(_outputType);
    return dictionary;

}


- (id)copyWithZone:(nullable NSZone *)zone{
    ZHOutputSession *output = [ZHOutputSession new];
    output.frameRate = _frameRate;
    output.size = _size;
    output.outputType = _outputType;
    return output;
}

@end
