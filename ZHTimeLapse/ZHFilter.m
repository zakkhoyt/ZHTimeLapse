//
//  ZHFilter.m
//  ZHTimeLapse
//
//  Created by Zakk Hoyt on 12/26/15.
//  Copyright © 2015 Zakk Hoyt. All rights reserved.
//

#import "ZHFilter.h"

@interface ZHFilter ()
@property (nonatomic, readwrite) ZHFilterType filterType;
@property (nonatomic, strong, readwrite) GPUImageOutput<GPUImageInput> *gpuFilter;
@property (nonatomic, strong, readwrite) NSString *title;
@property (nonatomic, readwrite) CGFloat paramMin;
@property (nonatomic, readwrite) CGFloat paramMax;
@property (nonatomic, readwrite) CGFloat paramValue;

@end

@implementation ZHFilter

- (instancetype)initWithFilterType:(ZHFilterType)filterType {
    self = [super init];
    if (self) {
        _filterType = filterType;
        [self setupGPUFilter];
    }
    return self;
}


#pragma mark Private methods

-(void)setupGPUFilter{
    switch (_filterType) {
          
            // ********************** B&W filters
        case ZHFilterTypeCannyEdgeDetection:{
            self.title = @"Canny";
            self.paramMin = 0.0;
            self.paramMax = 1.0;
            self.paramValue = 1.0;
            _gpuFilter = [GPUImageCannyEdgeDetectionFilter new];
        }
            break;
        case ZHFilterTypePrewittEdgeDetection:{
            self.title = @"Prewitt";
            self.paramMin = 0.0;
            self.paramMax = 1.0;
            self.paramValue = 1.0;
            _gpuFilter = [GPUImagePrewittEdgeDetectionFilter new];
        }
            break;
        case ZHFilterTypeThresholdEdgeDetection:{
            self.title = @"Threshold";
            self.paramMin = 0.0;
            self.paramMax = 1.0;
            self.paramValue = 0.25;
            _gpuFilter = [GPUImageThresholdEdgeDetectionFilter new];
        }
            break;
        case ZHFilterTypeSobelEdgeDetection:{
            self.title = @"Sobel";
            self.paramMin = 0.0;
            self.paramMax = 1.0;
            self.paramValue = 0.25;
            _gpuFilter = [GPUImageSobelEdgeDetectionFilter new];
        }
            break;
        case ZHFilterTypeSketch:{
            self.title = @"Sketch";
            self.paramMin = 0.0;
            self.paramMax = 1.0;
            self.paramValue = 0.25;
            _gpuFilter = [GPUImageSketchFilter new];
        }
            break;
        case ZHFilterTypeAdaptiveThreshold:{
            self.title = @"A-Threshold";
            self.paramMin = 1.0;
            self.paramMax = 20.0;
            self.paramValue = 1.0;
            _gpuFilter = [GPUImageAdaptiveThresholdFilter new];
        }
            break;
        case ZHFilterTypeThresholdSketch:{
            self.title = @"T-Sketch";
            self.paramMin = 0.0;
            self.paramMax = 1.0;
            self.paramValue = 0.25;
            _gpuFilter = [[GPUImageThresholdSketchFilter alloc] init];
        }
            break;
        case ZHFilterTypeHalftone:{
            self.title = @"Halftone";
            self.paramMin = 0.0;
            self.paramMax = 0.05;
            self.paramValue = 0.01;
            _gpuFilter = [[GPUImageHalftoneFilter alloc] init];
        }
            break;
            
        case ZHFilterTypeMosaic:{
            self.title = @"Mosaic";
            self.paramMin = 0.002;
            self.paramMax = 0.05;
            self.paramValue = 0.025;
            _gpuFilter = [[GPUImageMosaicFilter alloc] init];
            [(GPUImageMosaicFilter*)_gpuFilter setTileSet:@"squares.png"];
            [(GPUImageMosaicFilter*)_gpuFilter setColorOn:NO];
        }
            break;

            // ********************** Color filters
        case ZHFilterTypeSmoothToon:{
            self.title = @"Toon";
            self.paramMin = 1.0;
            self.paramMax = 6.0;
            self.paramValue = 1.0;
            _gpuFilter = [GPUImageSmoothToonFilter new];
        }
            break;
            
        case ZHFilterTypePolkaDot:{
            self.title = @"Polka Dot";
            self.paramMin = 0.05;
            self.paramMax = 0.0;
            self.paramValue = 0.3;
            _gpuFilter = [GPUImagePolkaDotFilter new];
        }
            break;
            
        case ZHFilterTypeErosion: {
            self.title = @"Erosion";
            _gpuFilter = [[GPUImageRGBErosionFilter alloc] initWithRadius:4];
        }
            break;
            
            // ********************** Default filters
        case ZHFilterTypeNone:
        default:{
            self.title = @"None";
            _gpuFilter = [GPUImageFilter new];
        }
            break;
    }
    
    [self updateParamValue:self.paramValue];
}

-(void)updateParamValue:(CGFloat)value {
    switch (_filterType) {
            // ** B&W filters
        case ZHFilterTypeCannyEdgeDetection:{
            [(GPUImageCannyEdgeDetectionFilter*)_gpuFilter setBlurTexelSpacingMultiplier:value];
        }
            break;
        case ZHFilterTypePrewittEdgeDetection:{
            [(GPUImagePrewittEdgeDetectionFilter*)_gpuFilter setEdgeStrength:value];
        }
            break;
        case ZHFilterTypeThresholdEdgeDetection:{
            [(GPUImageLuminanceThresholdFilter*)_gpuFilter setThreshold:value];
        }
            break;
        case ZHFilterTypeSobelEdgeDetection:{
            [(GPUImageSobelEdgeDetectionFilter*)_gpuFilter setEdgeStrength:value];
        }
            break;
        case ZHFilterTypeSketch:{
            [(GPUImageSketchFilter*)_gpuFilter setEdgeStrength:value];
        }
            break;
        case ZHFilterTypeAdaptiveThreshold:{
            [(GPUImageAdaptiveThresholdFilter*)_gpuFilter setBlurRadiusInPixels:value];
        }
            break;
            
        case ZHFilterTypeThresholdSketch:{
            [(GPUImageThresholdSketchFilter*)_gpuFilter setThreshold:value];
        }
            break;
            
        case ZHFilterTypeHalftone:{
            [(GPUImageHalftoneFilter *)_gpuFilter setFractionalWidthOfAPixel:value];
        }
            break;
            
        case ZHFilterTypeMosaic:{
            [(GPUImageMosaicFilter *)_gpuFilter setDisplayTileSize:CGSizeMake(value, value)];
        }
            break;
            
            
            
        // ** Color filters
        case ZHFilterTypeSmoothToon:{
            [(GPUImageSmoothToonFilter*)_gpuFilter setBlurRadiusInPixels:value];
        }
            break;
        case ZHFilterTypePolkaDot:{
            [(GPUImagePolkaDotFilter*)_gpuFilter setFractionalWidthOfAPixel:value];
        }
            break;
            
        // ** Default Filters
        case ZHFilterTypeNone:
        default:{
        }
            break;
    }
}

@end
