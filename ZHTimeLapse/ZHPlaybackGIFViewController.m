//
//  ZHPlaybackGIFViewController.m
//  ZHTimeLapse
//
//  Created by Zakk Hoyt on 12/31/15.
//  Copyright © 2015 Zakk Hoyt. All rights reserved.
//

#import "ZHPlaybackGIFViewController.h"
#import "UIImage+animatedGIF.h"

@interface ZHPlaybackGIFViewController ()
@property (nonatomic, weak) IBOutlet UIImageView *gifImageView;
@end

@implementation ZHPlaybackGIFViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    UIImage *gifImage = [UIImage animatedImageWithAnimatedGIFURL:_session.output.outputGIF];
    self.gifImageView.image = gifImage;
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


-(void)shareItems:(NSArray*)items{
    NSMutableArray *activities = [@[]mutableCopy];
    UIActivityViewController *activityViewController = [[UIActivityViewController alloc]initWithActivityItems:items
                                                                                        applicationActivities:activities];
    
    [activityViewController setCompletionWithItemsHandler:^(NSString *activityType, BOOL completed, NSArray *returnedItems, NSError *activityError){
        if(completed){
        }
    }];
    
    //    activityViewController.excludedActivityTypes = @[UIActivityTypePostToTwitter];
    [self presentViewController:activityViewController animated:YES completion:nil];
}



-(IBAction)closeButtonTouchUpInside:(id)sender {
    [self dismissViewControllerAnimated:YES completion:NULL];
}

-(IBAction)shareButtonTouchUpInside:(id)sender {
    NSData *data = [NSData dataWithContentsOfFile:_session.output.outputGIF.path];
    [self shareItems:@[data]];
}

@end
