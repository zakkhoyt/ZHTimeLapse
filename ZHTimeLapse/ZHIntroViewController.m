//
//  ZHIntroViewController.m
//  ZHTimeLapse
//
//  Created by Zakk Hoyt on 12/27/15.
//  Copyright © 2015 Zakk Hoyt. All rights reserved.
//

#import "ZHIntroViewController.h"
#import "VWWPermissionKit.h"

static NSString *SegueIntroToCapture = @"SegueIntroToCapture";

@interface ZHIntroViewController ()

@end

@implementation ZHIntroViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    
    VWWCameraPermission *camera = [VWWCameraPermission permissionWithLabelText:@"We need to access your camera so you can record videos."];
    VWWPhotosPermission *photos = [VWWPhotosPermission permissionWithLabelText:@"Videos are saved to the Photos app."];

    NSArray *permissions = @[camera, photos];
    
    [VWWPermissionsManager requirePermissions:permissions
                                       title:@"Welcome to the ZHTimeLapse app. This app is a timelapse camera with variable parameters and filters. We'll need you permission to access your device before we get started."
                          fromViewController:self
                                resultsBlock:^(NSArray *permissions) {
                                    [permissions enumerateObjectsUsingBlock:^(VWWPermission *permission, NSUInteger idx, BOOL *stop) {
                                        [self performSegueWithIdentifier:SegueIntroToCapture sender:nil];
                                    }];
                                }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(IBAction)okayButtonTouchUpInside:(UIButton*)sender {
    [self performSegueWithIdentifier:SegueIntroToCapture sender:nil];
}

@end
