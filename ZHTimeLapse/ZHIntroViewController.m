//
//  ZHIntroViewController.m
//  ZHTimeLapse
//
//  Created by Zakk Hoyt on 12/27/15.
//  Copyright © 2015 Zakk Hoyt. All rights reserved.
//

#import "ZHIntroViewController.h"
#import "VWWPermissionKit.h"
#import "ZHDefines.h"

static NSString *SegueIntroToCapture = @"SegueIntroToCapture";

@interface ZHIntroViewController ()
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;

@end

@implementation ZHIntroViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleLightContent;
    
    _titleLabel.text = ZH_BUNDLE_NAME;
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    
    VWWCameraPermission *camera = [VWWCameraPermission permissionWithLabelText:@"We need to access your camera so you can record videos."];
    VWWPhotosPermission *photos = [VWWPhotosPermission permissionWithLabelText:@"Timelapse videos are saved to your Camera Roll."];

    NSArray *permissions = @[camera, photos];
    
    [VWWPermissionsManager requirePermissions:permissions
                                       title:@"Welcome to the ZHTimeLapse, a timelapse camera with adjustable parameters and filters. In order for this app to work, it is essential that you allow access to the following."
                          fromViewController:self
                                resultsBlock:^(NSArray *permissions) {
                                    [permissions enumerateObjectsUsingBlock:^(VWWPermission *permission, NSUInteger idx, BOOL *stop) {

                                    }];
                                    [self performSegueWithIdentifier:SegueIntroToCapture sender:nil];
                                }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(BOOL)prefersStatusBarHidden {
    return YES;
}

//-(UIStatusBarStyle)preferredStatusBarStyle {
//    return UIStatusBarStyleLightContent;
//}

-(IBAction)okayButtonTouchUpInside:(UIButton*)sender {
    [self performSegueWithIdentifier:SegueIntroToCapture sender:nil];
}

@end
