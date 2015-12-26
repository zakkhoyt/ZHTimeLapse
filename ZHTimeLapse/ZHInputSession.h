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
    ZHSessionInputFilterNone = 0,
    
    // Black and White
    ZHSessionInputFilterCannyEdgeDetection,
    ZHSessionInputFilterPrewittEdgeDetection,
    ZHSessionInputFilterThresholdEdgeDetection,
    ZHSessionInputFilterSobelEdgeDetection,
    ZHSessionInputFilterSketch,
    ZHSessionInputFilterAdaptiveThreshold,
    ZHSessionInputFilterThresholdSketch,
    ZHSessionInputFilterHalftone,
    ZHSessionInputFilterMosaic,
    
    // Color
    ZHSessionInputFilterSmoothToon,
    ZHSessionInputFilterPolkaDot,
    ZHSessionInputFilterMask = 255,
} ZHSessionInputFilter;

// **** B&W
// Threshold sketch
// Halftone
// Mosaic

// ** COLOR
// Polka Dot
// Erosion



@interface ZHInputSession : NSObject
@property (nonatomic) ZHSessionInputFilter filter;
@property (nonatomic) CGSize size;
@property (nonatomic) NSTimeInterval frameRate;
@property (nonatomic, strong) NSMutableArray *frames;
@property (nonatomic) AVCaptureDevicePosition captureDevicePosition;
@property (nonatomic) UIDeviceOrientation orientation;

- (instancetype)initWithDictionary:(NSDictionary*)dictionary;
-(NSDictionary*)dictionaryRepresentation;
@end
