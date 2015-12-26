//
//  ZHFilterView.m
//  ZHTimeLapse
//
//  Created by Zakk Hoyt on 12/25/15.
//  Copyright © 2015 Zakk Hoyt. All rights reserved.
//

#import "ZHFilterView.h"

#import "GPUImage.h"

@interface ZHFilterView ()

@property (nonatomic, strong) GPUImageOutput<GPUImageInput>* gpuFilter;
@property (nonatomic) ZHSessionFilter filter;
@property (nonatomic, strong) GPUImageVideoCamera* videoCamera;
@property (weak, nonatomic) IBOutlet GPUImageView *filterView;
@property (weak, nonatomic) IBOutlet UILabel *filterLabel;
@end

@implementation ZHFilterView

-(void)setFilter:(ZHSessionFilter)filter
     videoCamera:(GPUImageVideoCamera*)videoCamera {

    _filter = filter;
    _videoCamera = videoCamera;
    
    
    switch (_filter) {
            
        case ZHSessionFilterCannyEdgeDetection:{
            self.filterLabel.text = @"Canny";
            _gpuFilter = [GPUImageCannyEdgeDetectionFilter new];
        }
            break;
        case ZHSessionFilterPrewittEdgeDetection:{
            
            self.filterLabel.text = @"Prewitt";
            _gpuFilter = [GPUImagePrewittEdgeDetectionFilter new];
        }
            break;
        case ZHSessionFilterThresholdEdgeDetection:{
            self.filterLabel.text = @"Threshold";
            _gpuFilter = [GPUImageThresholdEdgeDetectionFilter new];
        }
            break;
        case ZHSessionFilterSobelEdgeDetection:{
            self.filterLabel.text = @"Sobel";
            _gpuFilter = [GPUImageSobelEdgeDetectionFilter new];
        }
            break;
        case ZHSessionFilterSketch:{
            self.filterLabel.text = @"Sketch";
            _gpuFilter = [GPUImageSketchFilter new];
        }
            break;
        case ZHSessionFilterSmoothToon:{
            self.filterLabel.text = @"Toon";
            _gpuFilter = [GPUImageSmoothToonFilter new];
        }
            break;
        case ZHSessionFilterAdaptiveThreshold:{
            self.filterLabel.text = @"Adaptive";
            _gpuFilter = [GPUImageAdaptiveThresholdFilter new];
        }
            break;
        case ZHSessionFilterPolkaDot:{
            self.filterLabel.text = @"Polka Dot";
            _gpuFilter = [GPUImagePolkaDotFilter new];
        }
            break;
        case ZHSessionFilterNone:{
            self.filterLabel.text = @"None";
            _gpuFilter = [GPUImageFilter new];
        }
            break;
        default:{
            self.filterLabel.text = @"?";
        }
            break;
    }
    
    [videoCamera addTarget:_gpuFilter];
    [_gpuFilter addTarget:self.filterView];
}

-(void)dealloc {
    [_videoCamera removeTarget:_gpuFilter];
    [_gpuFilter removeAllTargets];
}

-(ZHSessionFilter)filter{
    return  _filter;
}
@end
