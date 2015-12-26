//
//  ZHFiltersViewController.m
//  ZHTimeLapse
//
//  Created by Zakk Hoyt on 12/24/15.
//  Copyright © 2015 Zakk Hoyt. All rights reserved.
//

#import "ZHFiltersViewController.h"
#import "ZHFilterView.h"

@interface ZHFiltersViewController ()
@property (nonatomic, strong) NSArray <ZHFilterView*> *filterViews;
@property (nonatomic, strong) NSArray *filters;
@property (nonatomic, strong) GPUImageVideoCamera *videoCamera;
@property (nonatomic, strong) ZHFiltersViewControllerFilterBlock completionBlock;
@end

@implementation ZHFiltersViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupFilterViews];
}


-(void)setVideoCamera:(GPUImageVideoCamera *)videoCamera completionBlock:(ZHFiltersViewControllerFilterBlock)completionBlock {
    _videoCamera = videoCamera;
    _completionBlock = completionBlock;
}


-(void)setupFilterViews {
    
    CGFloat thirdWidth = self.view.bounds.size.width / 3.0;
    CGFloat thirdHeight = self.view.bounds.size.height / 3.0;
    
    {
        GPUImageOutput<GPUImageInput> *filter = [GPUImageCannyEdgeDetectionFilter new];
        ZHFilterView *filterView = [[[NSBundle mainBundle]loadNibNamed:@"ZHFilterView" owner:self options:nil] firstObject];
        filterView.frame = CGRectMake(0 * thirdWidth, 0 * thirdHeight, thirdWidth, thirdHeight);
        [filterView setFilter:filter filterName:@"Canny" videoCamera:self.videoCamera];
        [self.view addSubview:filterView];
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapGesture:)];
        [filterView addGestureRecognizer:tapGesture];
    }
    
    {
        GPUImageOutput<GPUImageInput> *filter = [GPUImagePrewittEdgeDetectionFilter new];
        ZHFilterView *filterView = [[[NSBundle mainBundle]loadNibNamed:@"ZHFilterView" owner:self options:nil] firstObject];
        filterView.frame = CGRectMake(1 * thirdWidth, 0 * thirdHeight, thirdWidth, thirdHeight);
        [filterView setFilter:filter filterName:@"Prewitt" videoCamera:self.videoCamera];
        [self.view addSubview:filterView];
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapGesture:)];
        [filterView addGestureRecognizer:tapGesture];
    }
    
    {
        GPUImageOutput<GPUImageInput> *filter = [GPUImageThresholdEdgeDetectionFilter new];
        ZHFilterView *filterView = [[[NSBundle mainBundle]loadNibNamed:@"ZHFilterView" owner:self options:nil] firstObject];
        filterView.frame = CGRectMake(2 * thirdWidth, 0 * thirdHeight, thirdWidth, thirdHeight);
        [filterView setFilter:filter filterName:@"Threshold" videoCamera:self.videoCamera];
        [self.view addSubview:filterView];
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapGesture:)];
        [filterView addGestureRecognizer:tapGesture];
    }
    
    {
        GPUImageOutput<GPUImageInput> *filter = [GPUImageSobelEdgeDetectionFilter new];
        ZHFilterView *filterView = [[[NSBundle mainBundle]loadNibNamed:@"ZHFilterView" owner:self options:nil] firstObject];
        filterView.frame = CGRectMake(0 * thirdWidth, 1 * thirdHeight, thirdWidth, thirdHeight);
        [filterView setFilter:filter filterName:@"Sobel" videoCamera:self.videoCamera];
        [self.view addSubview:filterView];
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapGesture:)];
        [filterView addGestureRecognizer:tapGesture];
    }
    
    {
        GPUImageOutput<GPUImageInput> *filter = [GPUImageFilter new];
        ZHFilterView *filterView = [[[NSBundle mainBundle]loadNibNamed:@"ZHFilterView" owner:self options:nil] firstObject];
        filterView.frame = CGRectMake(1 * thirdWidth, 1 * thirdHeight, thirdWidth, thirdHeight);
        [filterView setFilter:filter filterName:@"None" videoCamera:self.videoCamera];
        [self.view addSubview:filterView];
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapGesture:)];
        [filterView addGestureRecognizer:tapGesture];
    }
    
    {
        GPUImageOutput<GPUImageInput> *filter = [GPUImageSketchFilter new];
        ZHFilterView *filterView = [[[NSBundle mainBundle]loadNibNamed:@"ZHFilterView" owner:self options:nil] firstObject];
        filterView.frame = CGRectMake(2 * thirdWidth, 1 * thirdHeight, thirdWidth, thirdHeight);
        [filterView setFilter:filter filterName:@"Sketch" videoCamera:self.videoCamera];
        [self.view addSubview:filterView];
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapGesture:)];
        [filterView addGestureRecognizer:tapGesture];
    }
    
    {
        GPUImageOutput<GPUImageInput> *filter = [GPUImageSmoothToonFilter new];
        ZHFilterView *filterView = [[[NSBundle mainBundle]loadNibNamed:@"ZHFilterView" owner:self options:nil] firstObject];
        filterView.frame = CGRectMake(0 * thirdWidth, 2 * thirdHeight, thirdWidth, thirdHeight);
        [filterView setFilter:filter filterName:@"Toon" videoCamera:self.videoCamera];
        [self.view addSubview:filterView];
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapGesture:)];
        [filterView addGestureRecognizer:tapGesture];
    }
    
    {
        GPUImageOutput<GPUImageInput> *filter = [GPUImageAdaptiveThresholdFilter new];
        ZHFilterView *filterView = [[[NSBundle mainBundle]loadNibNamed:@"ZHFilterView" owner:self options:nil] firstObject];
        filterView.frame = CGRectMake(1 * thirdWidth, 2 * thirdHeight, thirdWidth, thirdHeight);
        [filterView setFilter:filter filterName:@"Adaptive" videoCamera:self.videoCamera];
        [self.view addSubview:filterView];
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapGesture:)];
        [filterView addGestureRecognizer:tapGesture];
    }
    
    {
        GPUImageOutput<GPUImageInput> *filter = [GPUImagePolkaDotFilter new];
        ZHFilterView *filterView = [[[NSBundle mainBundle]loadNibNamed:@"ZHFilterView" owner:self options:nil] firstObject];
        filterView.frame = CGRectMake(2 * thirdWidth, 2 * thirdHeight, thirdWidth, thirdHeight);
        [filterView setFilter:filter filterName:@"Polka Dot" videoCamera:self.videoCamera];
        [self.view addSubview:filterView];
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapGesture:)];
        [filterView addGestureRecognizer:tapGesture];
    }

}


-(void)tapGesture:(UITapGestureRecognizer*)sender {
    if([sender.view isKindOfClass:[ZHFilterView class]]) {
        ZHFilterView *filterView = (ZHFilterView*)sender.view;
        GPUImageOutput<GPUImageInput> *filter = filterView.filter;
        if(_completionBlock) {
            _completionBlock(filter);
        }
    } else {
        NSLog(@"Invalid class ");
    }
}
@end
