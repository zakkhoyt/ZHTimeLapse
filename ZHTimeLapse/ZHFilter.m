//
//  ZHFilter.m
//  ZHTimeLapse
//
//  Created by Zakk Hoyt on 12/26/15.
//  Copyright © 2015 Zakk Hoyt. All rights reserved.
//

#import "ZHFilter.h"
#import "ZHDefines.h"

@interface ZHFilter ()
@property (nonatomic, readwrite) ZHFilterType filterType;
@property (nonatomic, strong, readwrite) GPUImageOutput<GPUImageInput> *gpuFilter;
@property (nonatomic, strong, readwrite) NSString *title;
@property (nonatomic, readwrite) CGFloat paramMin;
@property (nonatomic, readwrite) CGFloat paramMax;
@property (nonatomic, readwrite) CGFloat paramValue;
@property (nonatomic, readwrite) BOOL paramAvailable;

@property (nonatomic, strong) GPUImageUIElement *uiElementInput;
@property (nonatomic, strong) GPUImageSepiaFilter *sepiaFilter;
//@property (nonatomic, strong) GPUImageOutput<GPUImageInput> *filter;

//@property (strong, nonatomic) GPUImagePicture *sourcePicture;
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
            self.paramAvailable = YES;
            _gpuFilter = [GPUImageCannyEdgeDetectionFilter new];
        }
            break;
        case ZHFilterTypeInvertedCannyEdgeDetection: {
            self.title = @"I-Canny";
            
            self.paramMin = 0.0;
            self.paramMax = 1.0;
            self.paramValue = 1.0;
            self.paramAvailable = YES;
            
            _gpuFilter = [[GPUImageFilterGroup alloc] init];
            
            GPUImageColorInvertFilter *sepiaFilter = [[GPUImageColorInvertFilter alloc] init];
            [(GPUImageFilterGroup *)_gpuFilter addFilter:sepiaFilter];
            
            GPUImageCannyEdgeDetectionFilter *cannyFilter = [GPUImageCannyEdgeDetectionFilter new];
            [(GPUImageFilterGroup *)_gpuFilter addFilter:cannyFilter];
            
            [cannyFilter addTarget:sepiaFilter];
            [(GPUImageFilterGroup *)_gpuFilter setInitialFilters:[NSArray arrayWithObject:cannyFilter]];
            [(GPUImageFilterGroup *)_gpuFilter setTerminalFilter:sepiaFilter];
            
        }
            break;

        case ZHFilterTypePrewittEdgeDetection:{
            self.title = @"Prewitt";
            self.paramMin = 0.0;
            self.paramMax = 1.0;
            self.paramValue = 1.0;
            self.paramAvailable = YES;
            _gpuFilter = [GPUImagePrewittEdgeDetectionFilter new];
        }
            break;
        case ZHFilterTypeThresholdEdgeDetection:{
            self.title = @"Threshold";
            self.paramMin = 0.0;
            self.paramMax = 1.0;
            self.paramValue = 0.25;
            self.paramAvailable = YES;
            _gpuFilter = [GPUImageThresholdEdgeDetectionFilter new];
        }
            break;
        case ZHFilterTypeSobelEdgeDetection:{
            self.title = @"Sobel";
            self.paramMin = 0.0;
            self.paramMax = 1.0;
            self.paramValue = 0.25;
            self.paramAvailable = YES;
            _gpuFilter = [GPUImageSobelEdgeDetectionFilter new];
        }
            break;
        case ZHFilterTypeSketch:{
            self.title = @"Sketch";
            self.paramMin = 0.0;
            self.paramMax = 1.0;
            self.paramValue = 0.25;
            self.paramAvailable = YES;
            _gpuFilter = [GPUImageSketchFilter new];
        }
            break;
        case ZHFilterTypeAdaptiveThreshold:{
            self.title = @"A-Threshold";
            self.paramMin = 1.0;
            self.paramMax = 20.0;
            self.paramValue = 1.0;
            self.paramAvailable = YES;
            _gpuFilter = [GPUImageAdaptiveThresholdFilter new];
        }
            break;
        case ZHFilterTypeThresholdSketch:{
            self.title = @"T-Sketch";
            self.paramMin = 0.0;
            self.paramMax = 1.0;
            self.paramValue = 0.25;
            self.paramAvailable = YES;
            _gpuFilter = [[GPUImageThresholdSketchFilter alloc] init];
        }
            break;
        case ZHFilterTypeHalftone:{
            self.title = @"Halftone";
            self.paramMin = 0.0;
            self.paramMax = 0.05;
            self.paramValue = 0.01;
            self.paramAvailable = YES;
            _gpuFilter = [[GPUImageHalftoneFilter alloc] init];
        }
            break;
            
        case ZHFilterTypeMosaic:{
            self.title = @"Mosaic";
            self.paramMin = 0.002;
            self.paramMax = 0.05;
            self.paramValue = 0.025;
            self.paramAvailable = YES;
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
            self.paramAvailable = YES;
            _gpuFilter = [GPUImageSmoothToonFilter new];
        }
            break;
            
        case ZHFilterTypePolkaDot:{
            self.title = @"Polka Dot";
            self.paramMin = 0.05;
            self.paramMax = 0.0;
            self.paramValue = 0.3;
            self.paramAvailable = YES;
            _gpuFilter = [GPUImagePolkaDotFilter new];
        }
            break;
            
        case ZHFilterTypeErosion: {
            self.title = @"Erosion";
            self.paramAvailable = NO;

            _gpuFilter = [[GPUImageRGBErosionFilter alloc] initWithRadius:4];
        }
            break;
            
        case ZHFilterTypeUIElement: {
            
            self.title = @"UIElement";
            self.paramAvailable = NO;
            
            _sepiaFilter = [GPUImageSepiaFilter new];

            GPUImageAlphaBlendFilter *blendFilter = [[GPUImageAlphaBlendFilter alloc] init];
            blendFilter.mix = 1.0;
            
            
            NSDate *startTime = [NSDate date];
            
            UILabel *timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0, 0.0, 100, 100)];
            timeLabel.font = [UIFont systemFontOfSize:17.0f];
            timeLabel.text = @"Time: 0.0 s";
            timeLabel.textAlignment = NSTextAlignmentCenter;
            timeLabel.backgroundColor = [UIColor clearColor];
            timeLabel.textColor = [UIColor whiteColor];
            timeLabel.backgroundColor = [UIColor blueColor];
            
            _uiElementInput = [[GPUImageUIElement alloc] initWithView:timeLabel];
            
            [_sepiaFilter addTarget:blendFilter];
            [_uiElementInput addTarget:blendFilter];
            
//            [blendFilter addTarget:filterView];
            
            __unsafe_unretained GPUImageUIElement *weakUIElementInput = _uiElementInput;
            
            [_sepiaFilter setFrameProcessingCompletionBlock:^(GPUImageOutput * filter, CMTime frameTime){
                timeLabel.text = [NSString stringWithFormat:@"Time: %f s", -[startTime timeIntervalSinceNow]];
                [weakUIElementInput update];
            }];
            
            _gpuFilter = blendFilter;
            
        }
            break;
        case ZHFilterTypeCustom: {
            self.title = @"Custom";
            self.paramAvailable = NO;

            
            _gpuFilter = [[GPUImageFilterGroup alloc] init];
            
            GPUImageSepiaFilter *sepiaFilter = [[GPUImageSepiaFilter alloc] init];
            [(GPUImageFilterGroup *)_gpuFilter addFilter:sepiaFilter];
            
            GPUImageCannyEdgeDetectionFilter *cannyFilter = [GPUImageCannyEdgeDetectionFilter new];
            [(GPUImageFilterGroup *)_gpuFilter addFilter:cannyFilter];
            
            [cannyFilter addTarget:sepiaFilter];
            [(GPUImageFilterGroup *)_gpuFilter setInitialFilters:[NSArray arrayWithObject:cannyFilter]];
            [(GPUImageFilterGroup *)_gpuFilter setTerminalFilter:sepiaFilter];
        }
            break;
            
            // ********************** Default filters
        case ZHFilterTypeNone:
        default:{
            self.title = @"None";
            self.paramAvailable = NO;
            _gpuFilter = [GPUImageFilter new];
        }
            break;
    }
    
    [self updateParamValue:self.paramValue];
}

-(void)updateParamValue:(CGFloat)value {
    _paramValue = value;
    switch (_filterType) {
            // ** B&W filters
        case ZHFilterTypeCannyEdgeDetection:{
            [(GPUImageCannyEdgeDetectionFilter*)_gpuFilter setBlurTexelSpacingMultiplier:_paramValue];
        }
            break;
        case ZHFilterTypeInvertedCannyEdgeDetection: {
            GPUImageFilterGroup *group = (GPUImageFilterGroup*)_gpuFilter;
             GPUImageCannyEdgeDetectionFilter *cannyFilter = [group.initialFilters firstObject];
            [cannyFilter setBlurTexelSpacingMultiplier:_paramValue];
        }
            break;
        case ZHFilterTypePrewittEdgeDetection:{
            [(GPUImagePrewittEdgeDetectionFilter*)_gpuFilter setEdgeStrength:_paramValue];
        }
            break;
        case ZHFilterTypeThresholdEdgeDetection:{
            [(GPUImageLuminanceThresholdFilter*)_gpuFilter setThreshold:_paramValue];
        }
            break;
        case ZHFilterTypeSobelEdgeDetection:{
            [(GPUImageSobelEdgeDetectionFilter*)_gpuFilter setEdgeStrength:_paramValue];
        }
            break;
        case ZHFilterTypeSketch:{
            [(GPUImageSketchFilter*)_gpuFilter setEdgeStrength:_paramValue];
        }
            break;
        case ZHFilterTypeAdaptiveThreshold:{
            [(GPUImageAdaptiveThresholdFilter*)_gpuFilter setBlurRadiusInPixels:_paramValue];
        }
            break;
            
        case ZHFilterTypeThresholdSketch:{
            [(GPUImageThresholdSketchFilter*)_gpuFilter setThreshold:_paramValue];
        }
            break;
            
        case ZHFilterTypeHalftone:{
            [(GPUImageHalftoneFilter *)_gpuFilter setFractionalWidthOfAPixel:_paramValue];
        }
            break;
            
        case ZHFilterTypeMosaic:{
            [(GPUImageMosaicFilter *)_gpuFilter setDisplayTileSize:CGSizeMake(_paramValue, _paramValue)];
        }
            break;
            
            
            
        // ** Color filters
        case ZHFilterTypeSmoothToon:{
            [(GPUImageSmoothToonFilter*)_gpuFilter setBlurRadiusInPixels:_paramValue];
        }
            break;
        case ZHFilterTypePolkaDot:{
            [(GPUImagePolkaDotFilter*)_gpuFilter setFractionalWidthOfAPixel:_paramValue];
        }
            break;
            
        // ** Default Filters
        case ZHFilterTypeNone:
        default:{
        }
            break;
    }
}


- (id)copyWithZone:(nullable NSZone *)zone{
    ZHFilter *filter = [[ZHFilter alloc]initWithFilterType:self.filterType];
    filter.paramMax = _paramMax;
    filter.paramMin = _paramMin;
    filter.paramValue = _paramValue;
    return filter;
}

@end
