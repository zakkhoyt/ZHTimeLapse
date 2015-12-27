//
//  ZHFilter.h
//  ZHTimeLapse
//
//  Created by Zakk Hoyt on 12/26/15.
//  Copyright © 2015 Zakk Hoyt. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GPUImage.h"


typedef enum {
    // Default 
    ZHFilterTypeNone = 0,
    
    // Black and White
    ZHFilterTypeCannyEdgeDetection,
    ZHFilterTypePrewittEdgeDetection,
    ZHFilterTypeThresholdEdgeDetection,
    ZHFilterTypeSobelEdgeDetection,
    ZHFilterTypeSketch,
    ZHFilterTypeAdaptiveThreshold,
    ZHFilterTypeThresholdSketch,
    ZHFilterTypeHalftone,
    ZHFilterTypeMosaic,
    ZHFilterTypeInvertedCannyEdgeDetection,
    
    // Color
    ZHFilterTypeSmoothToon,
    ZHFilterTypePolkaDot,
    ZHFilterTypeErosion,
    
    ZHFilterTypeCustom,
    ZHFilterTypeMask = 255,
} ZHFilterType;


@interface ZHFilter : NSObject

- (instancetype)initWithFilterType:(ZHFilterType)filterType;
-(void)updateParamValue:(CGFloat)value;

@property (nonatomic, readonly) ZHFilterType filterType;
@property (nonatomic, strong, readonly) GPUImageOutput<GPUImageInput> *gpuFilter;
@property (nonatomic, strong, readonly) NSString *title;

@property (nonatomic, readonly) CGFloat paramMin;
@property (nonatomic, readonly) CGFloat paramMax;
@property (nonatomic, readonly) CGFloat paramValue;

@end
