//
//  ZHNavigationController.m
//  ZHTimeLapse
//
//  Created by Zakk Hoyt on 12/24/15.
//  Copyright © 2015 Zakk Hoyt. All rights reserved.
//

#import "ZHNavigationController.h"

@interface ZHNavigationController ()

@end

@implementation ZHNavigationController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/



//-(BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
//
//    //The device has already rotated, that's why this method is being called.
//    UIDeviceOrientation orientation   = [[UIDevice currentDevice] orientation];
//
////    [UIView animateWithDuration:0.3 animations:^{
////        switch (orientation) {
////            case UIDeviceOrientationPortrait:
////                [self.rotatableViews enumerateObjectsUsingBlock:^(UIView *  _Nonnull view, NSUInteger idx, BOOL * _Nonnull stop) {
////                    view.transform = CGAffineTransformIdentity;
////                }];
////                break;
////            case UIDeviceOrientationPortraitUpsideDown:
////                [self.rotatableViews enumerateObjectsUsingBlock:^(UIView *  _Nonnull view, NSUInteger idx, BOOL * _Nonnull stop) {
////                    view.transform = CGAffineTransformMakeRotation(M_PI);
////                }];
////
////                break;
////            case UIDeviceOrientationLandscapeLeft:
////                [self.rotatableViews enumerateObjectsUsingBlock:^(UIView *  _Nonnull view, NSUInteger idx, BOOL * _Nonnull stop) {
////                    view.transform = CGAffineTransformMakeRotation(M_PI / 2.0);
////                }];
////                break;
////            case UIDeviceOrientationLandscapeRight:
////                [self.rotatableViews enumerateObjectsUsingBlock:^(UIView *  _Nonnull view, NSUInteger idx, BOOL * _Nonnull stop) {
////                    view.transform = CGAffineTransformMakeRotation(-M_PI / 2.0);
////                }];
////
////                break;
////            default:
////                break;
////        }
////
////    } completion:^(BOOL finished) {
////
////    }];
//
//    return NO;
//}

@end
