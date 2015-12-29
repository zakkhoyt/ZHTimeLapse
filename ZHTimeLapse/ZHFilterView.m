//
//  ZHFilterView.m
//  ZHTimeLapse
//
//  Created by Zakk Hoyt on 12/25/15.
//  Copyright © 2015 Zakk Hoyt. All rights reserved.
//

#import "ZHFilterView.h"
#import "ZHDefines.h"

#import "GPUImage.h"

@interface ZHFilterView ()

@property (nonatomic, strong) ZHFilter *filter;
@property (nonatomic, strong) GPUImageVideoCamera* videoCamera;
@property (weak, nonatomic) IBOutlet GPUImageView *filterView;
@property (weak, nonatomic) IBOutlet UILabel *filterLabel;
@end

@implementation ZHFilterView

-(void)setFilter:(ZHFilter*)filter
     videoCamera:(GPUImageVideoCamera*)videoCamera {

    _filter = filter;
    _videoCamera = videoCamera;
    
    self.filterLabel.text = _filter.title;
    
    NSAssert(_filter.gpuFilter, @"No gpuFilter set");
    [videoCamera addTarget:_filter.gpuFilter];
    [_filter.gpuFilter addTarget:self.filterView];
}

-(void)dealloc {
    [_videoCamera removeTarget:_filter.gpuFilter];
    [_filter.gpuFilter removeAllTargets];
}

-(ZHFilter*)filter{
    return  _filter;
}
@end
