//
//  ZHOutputModel.m
//  ZHTimeLapse
//
//  Created by Zakk Hoyt on 12/21/15.
//  Copyright © 2015 Zakk Hoyt. All rights reserved.
//

#import "ZHOutputSession.h"

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
    }
    return self;
}

-(void)commonInit{
    _frameRate = 30;
    _size = CGSizeMake(720, 1280);
}

-(NSDictionary*)dictionaryRepresentation {
    NSMutableDictionary *dictionary = [@{}mutableCopy];
    dictionary[@"size"] = NSStringFromCGSize(_size);
    dictionary[@"frameRate"] = @(_frameRate);
    return dictionary;

}
@end
