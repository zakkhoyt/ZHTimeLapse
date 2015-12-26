//
//  ZHFilterView.m
//  ZHTimeLapse
//
//  Created by Zakk Hoyt on 12/25/15.
//  Copyright © 2015 Zakk Hoyt. All rights reserved.
//

#import "ZHFilterView.h"


@interface ZHFilterView ()
@property (nonatomic, strong) GPUImageOutput<GPUImageInput>* filter;
@property (nonatomic, strong) GPUImageVideoCamera* videoCamera;
@property (weak, nonatomic) IBOutlet GPUImageView *filterView;
@property (weak, nonatomic) IBOutlet UILabel *filterLabel;
@end

@implementation ZHFilterView

-(void)setFilter:(GPUImageOutput<GPUImageInput>*)filter
      filterName:(NSString*)filterName
     videoCamera:(GPUImageVideoCamera*)videoCamera {

    _filter = filter;
    _videoCamera = videoCamera;
    
    [videoCamera addTarget:filter];
    [filter addTarget:self.filterView];
    _filterLabel.text = filterName;
    
}

-(void)dealloc {
    [_videoCamera removeTarget:_filter];
    [_filter removeAllTargets];
}

-(GPUImageOutput<GPUImageInput>*)filter {
    return _filter;
}
@end
