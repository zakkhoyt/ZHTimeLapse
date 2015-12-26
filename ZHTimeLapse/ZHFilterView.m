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
@property (nonatomic) ZHSessionInputFilter filter;
@property (nonatomic, strong) GPUImageVideoCamera* videoCamera;
@property (weak, nonatomic) IBOutlet GPUImageView *filterView;
@property (weak, nonatomic) IBOutlet UILabel *filterLabel;
@end

@implementation ZHFilterView

-(void)setFilter:(ZHSessionInputFilter)filter
     videoCamera:(GPUImageVideoCamera*)videoCamera {

    _filter = filter;
    _videoCamera = videoCamera;
    
    
    switch (_filter) {
            
        case ZHSessionInputFilterCannyEdgeDetection:{
            self.filterLabel.text = @"Canny";
            _gpuFilter = [GPUImageCannyEdgeDetectionFilter new];
        }
            break;
        case ZHSessionInputFilterPrewittEdgeDetection:{
            
            self.filterLabel.text = @"Prewitt";
            _gpuFilter = [GPUImagePrewittEdgeDetectionFilter new];
        }
            break;
        case ZHSessionInputFilterThresholdEdgeDetection:{
            self.filterLabel.text = @"Threshold";
            _gpuFilter = [GPUImageThresholdEdgeDetectionFilter new];
        }
            break;
        case ZHSessionInputFilterSobelEdgeDetection:{
            self.filterLabel.text = @"Sobel";
            _gpuFilter = [GPUImageSobelEdgeDetectionFilter new];
        }
            break;
        case ZHSessionInputFilterSketch:{
            self.filterLabel.text = @"Sketch";
            _gpuFilter = [GPUImageSketchFilter new];
        }
            break;
        case ZHSessionInputFilterSmoothToon:{
            self.filterLabel.text = @"Toon";
            _gpuFilter = [GPUImageSmoothToonFilter new];
        }
            break;
        case ZHSessionInputFilterAdaptiveThreshold:{
            self.filterLabel.text = @"Adaptive";
            _gpuFilter = [GPUImageAdaptiveThresholdFilter new];
        }
            break;
        case ZHSessionInputFilterPolkaDot:{
            self.filterLabel.text = @"Polka Dot";
            _gpuFilter = [GPUImagePolkaDotFilter new];
        }
            break;
        case ZHSessionInputFilterNone:{
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

-(ZHSessionInputFilter)filter{
    return  _filter;
}
@end
