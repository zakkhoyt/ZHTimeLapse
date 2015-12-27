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
        case ZHSessionInputFilterAdaptiveThreshold:{
            self.filterLabel.text = @"Adaptive";
            _gpuFilter = [GPUImageAdaptiveThresholdFilter new];
        }
            break;
        case ZHSessionInputFilterThresholdSketch:{
            self.filterLabel.text = @"T-Sketch";
            _gpuFilter = [GPUImageThresholdSketchFilter new];
        }
            break;
        case ZHSessionInputFilterHalftone:{
            self.filterLabel.text = @"Halftone";
            _gpuFilter = [GPUImageHalftoneFilter new];
        }
            break;
        case ZHSessionInputFilterMosaic:{
            self.filterLabel.text = @"Mosaic";
            _gpuFilter = [GPUImageMosaicFilter new];
            [((GPUImageMosaicFilter*)_gpuFilter) setTileSet:@"squares.png"];
            [((GPUImageMosaicFilter*)_gpuFilter) setColorOn:NO];
            [(GPUImageMosaicFilter *)_gpuFilter setDisplayTileSize:CGSizeMake(0.025, 0.025)];
        }
            break;
            
            
            
            
        case ZHSessionInputFilterSmoothToon:{
            self.filterLabel.text = @"Toon";
            _gpuFilter = [GPUImageSmoothToonFilter new];
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
    
    NSAssert(_gpuFilter, @"No gpuFilter set");
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
