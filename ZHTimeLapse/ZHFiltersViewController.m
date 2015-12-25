//
//  ZHFiltersViewController.m
//  ZHTimeLapse
//
//  Created by Zakk Hoyt on 12/24/15.
//  Copyright © 2015 Zakk Hoyt. All rights reserved.
//

#import "ZHFiltersViewController.h"

@interface ZHFiltersViewController ()
@property (strong, nonatomic) IBOutletCollection(UIView) NSArray *filterViews;

@end

@implementation ZHFiltersViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.filterViews enumerateObjectsUsingBlock:^(UIView *  _Nonnull view, NSUInteger idx, BOOL * _Nonnull stop) {
        view.layer.borderColor = [UIColor redColor].CGColor;
        view.layer.borderWidth = 1;
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
