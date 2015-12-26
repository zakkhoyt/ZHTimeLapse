//
//  ZHInputModel.h
//  ZHTimeLapse
//
//  Created by Zakk Hoyt on 12/21/15.
//  Copyright © 2015 Zakk Hoyt. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GPUImage.h"

typedef enum {
    ZHSessionFilterNone = 0,
    ZHSessionFilterCannyEdgeDetection,
    ZHSessionFilterPrewittEdgeDetection,
    ZHSessionFilterThresholdEdgeDetection,
    ZHSessionFilterSobelEdgeDetection,
    ZHSessionFilterSketch,
    ZHSessionFilterSmoothToon,
    ZHSessionFilterAdaptiveThreshold,
    ZHSessionFilterPolkaDot,
    ZHSessionFilterMask = 255,
} ZHSessionFilter;

// **** B&W
// Threshold sketch

// ** COLOR
// Erosion


@interface ZHInputSession : NSObject
@property (nonatomic) ZHSessionFilter filter;
@property (nonatomic) CGSize size;
@property (nonatomic) NSTimeInterval frameRate;
@property (nonatomic, strong) NSMutableArray *frames;
@property (nonatomic) AVCaptureDevicePosition captureDevicePosition;
@property (nonatomic) UIDeviceOrientation orientation;

- (instancetype)initWithDictionary:(NSDictionary*)dictionary;
-(NSDictionary*)dictionaryRepresentation;
@end
