//
//  ZHFiltersViewController.m
//  ZHTimeLapse
//
//  Created by Zakk Hoyt on 12/24/15.
//  Copyright © 2015 Zakk Hoyt. All rights reserved.
//
//
//

#import "ZHFiltersViewController.h"
#import "ZHDefines.h"
#import "ZHFilterView.h"
#import "ZHFilter.h"

@interface ZHFiltersViewController ()
@property (nonatomic, strong) NSMutableArray <ZHFilterView*> *filterViews;
@property (nonatomic, strong) NSArray *filters;
@property (nonatomic, strong) GPUImageVideoCamera *videoCamera;
@property (nonatomic, strong) ZHFiltersViewControllerFilterBlock completionBlock;
@end

@implementation ZHFiltersViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}


-(void)setVideoCamera:(GPUImageVideoCamera *)videoCamera completionBlock:(ZHFiltersViewControllerFilterBlock)completionBlock {
    _videoCamera = videoCamera;
    _completionBlock = completionBlock;
    [self setupFilterViews];
}

// Create a 3x3 grid of filter previews.
-(void)setupFilterViews {
    
    CGFloat thirdWidth = self.view.bounds.size.width / 3.0;
    CGFloat thirdHeight = self.view.bounds.size.height / 3.0;
    self.filterViews = [[NSMutableArray alloc]initWithCapacity:9];
    
    for(NSUInteger y = 0; y < 3; y++) {
        for(NSUInteger x = 0; x < 3; x++) {
            ZHFilterView *filterView = [[[NSBundle mainBundle]loadNibNamed:@"ZHFilterView" owner:self options:nil] firstObject];
            filterView.frame = CGRectMake(x * thirdWidth, y * thirdHeight, thirdWidth, thirdHeight);
            
            // Assign our filter
            switch (y * 3 + x) {
                case 0:
                    [filterView setFilter:[[ZHFilter alloc]initWithFilterType:ZHFilterTypeCannyEdgeDetection] videoCamera:_videoCamera];
                    break;
                case 1:
                    [filterView setFilter:[[ZHFilter alloc]initWithFilterType:ZHFilterTypeInvertedCannyEdgeDetection] videoCamera:_videoCamera];
                    break;
                case 2:
                    [filterView setFilter:[[ZHFilter alloc]initWithFilterType:ZHFilterTypePrewittEdgeDetection] videoCamera:_videoCamera];
                    break;
                case 3:
                    [filterView setFilter:[[ZHFilter alloc]initWithFilterType:ZHFilterTypeThresholdEdgeDetection] videoCamera:_videoCamera];
                    break;
                case 4:
                    [filterView setFilter:[[ZHFilter alloc]initWithFilterType:ZHFilterTypeNone] videoCamera:_videoCamera];
                    break;
                case 5:
                    [filterView setFilter:[[ZHFilter alloc]initWithFilterType:ZHFilterTypeSobelEdgeDetection] videoCamera:_videoCamera];
                    break;
                case 6:
                    [filterView setFilter:[[ZHFilter alloc]initWithFilterType:ZHFilterTypeSketch] videoCamera:_videoCamera];
                    break;
                case 7:
                    [filterView setFilter:[[ZHFilter alloc]initWithFilterType:ZHFilterTypeThresholdSketch] videoCamera:_videoCamera];
                    break;
                case 8:
                    [filterView setFilter:[[ZHFilter alloc]initWithFilterType:ZHFilterTypeErosion] videoCamera:_videoCamera];
                    break;
                default:
                    NSLog(@"invalid x/y index");
                    break;
            }
            
            // Store so we can dealloc manually
            [self.filterViews addObject:filterView];
            
            [self.view addSubview:filterView];
            UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapGesture:)];
            [filterView addGestureRecognizer:tapGesture];
        }
    }
}

// Fire our completion block with a ZHSessionInputFilter
-(void)tapGesture:(UITapGestureRecognizer*)sender {
    if([sender.view isKindOfClass:[ZHFilterView class]]) {
        ZHFilterView *filterView = (ZHFilterView*)sender.view;
        ZHFilter *filter = filterView.filter;
        
        // Remove these forcing dealloc and GPUImage clean up before we fire our completion block.
        [self.filterViews enumerateObjectsUsingBlock:^(ZHFilterView * _Nonnull filterView, NSUInteger idx, BOOL * _Nonnull stop) {
            [filterView removeFromSuperview];
            filterView = nil;
        }];
        [self.filterViews removeAllObjects];
        
        if(_completionBlock) {
            _completionBlock(filter);
        }
    } else {
        NSLog(@"Invalid class ");
    }
}
@end
