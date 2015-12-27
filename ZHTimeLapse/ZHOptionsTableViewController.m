//
//  ZHSessionTableViewController.m
//  ZHTimeLapse
//
//  Created by Zakk Hoyt on 12/23/15.
//  Copyright © 2015 Zakk Hoyt. All rights reserved.
//

#import "ZHOptionsTableViewController.h"
#import "ZHSession.h"
#import "ZHCaptureViewController.h"
#import "ZHFileManager.h"
#import "ZHRenderer.h"
#import "UIViewController+AlertController.h"
#import "MBProgressHUD.h"
#import "UIImage+animatedGIF.h"


static NSString *SegueOptionsToCapture = @"SegueOptionsToCapture";
static NSString *SegueOptionsToRender = @"SegueOptionsToRender";

typedef enum {
    ZHSessionTableViewControllerSectionName = 0,
    ZHSessionTableViewControllerSectionInput = 1,
    ZHSessionTableViewControllerSectionOutput = 2,
    ZHSessionTableViewControllerSectionFilter = 3,
} ZHSessionTableViewControllerSection;


@interface ZHOptionsTableViewController (UITextFieldDelegate) <UITextFieldDelegate>
@end

@interface ZHOptionsTableViewController () <UITextFieldDelegate>

@property (nonatomic, strong) NSNumber *selectedInputIndex;
@property (nonatomic, strong) NSNumber *selectedOutputIndex;
@property (nonatomic, strong) NSNumber *selectedFilterIndex;
@property (weak, nonatomic) IBOutlet UITextField *nameTextField;
@property (weak, nonatomic) IBOutlet UIButton *captureButton;
@property (weak, nonatomic) IBOutlet UIButton *renderButton;

@property (weak, nonatomic) IBOutlet UIStepper *inputFrameRateStepper;
@property (weak, nonatomic) IBOutlet UIStepper *outputFrameRateStepper;

@property (weak, nonatomic) IBOutlet UILabel *inputFrameRateLabel;
@property (weak, nonatomic) IBOutlet UILabel *outputFrameRateLabel;
@property (weak, nonatomic) IBOutlet UILabel *resolutionLabel;
@property (weak, nonatomic) IBOutlet UILabel *filterLabel;

@end

@implementation ZHOptionsTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if(_session == nil) {
        _session = [ZHSession session];
    } else {
        _nameTextField.text = _session.name;
    }
    
//    self.renderButton.enabled = NO;
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = NO;
    [UIApplication sharedApplication].statusBarHidden = NO;
    
    [self updateUI];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];

}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if([segue.identifier isEqualToString:SegueOptionsToCapture]) {
        ZHCaptureViewController *vc = segue.destinationViewController;
        vc.session = _session;
    }
}

-(void)updateUI{
    self.inputFrameRateStepper.value = _session.input.frameRate;
    self.inputFrameRateLabel.text = [NSString stringWithFormat:@"%lu fps", (unsigned long)_session.input.frameRate];
    self.outputFrameRateStepper.value = _session.output.frameRate;
    self.outputFrameRateLabel.text = [NSString stringWithFormat:@"%lu fps", (unsigned long)_session.output.frameRate];
    
    self.resolutionLabel.text = [NSString stringWithFormat:@"%lux%lu",
                                 (unsigned long)_session.input.size.width,
                                 (unsigned long)_session.input.size.height];

    switch (self.session.input.filter) {
            
        case ZHSessionInputFilterCannyEdgeDetection:{
            self.filterLabel.text = @"Canny Edge Detection";
        }
            break;
        case ZHSessionInputFilterPrewittEdgeDetection:{
            self.filterLabel.text = @"Prewitt Edge Detection";
        }
            break;
        case ZHSessionInputFilterThresholdEdgeDetection:{
            self.filterLabel.text = @"Threshold Edge Detection";
        }
            break;
        case ZHSessionInputFilterSobelEdgeDetection:{
            self.filterLabel.text = @"Sobel Edge Detection";
        }
            break;
        case ZHSessionInputFilterSketch:{
            self.filterLabel.text = @"Sketch";
        }
            break;
        case ZHSessionInputFilterAdaptiveThreshold:{
            self.filterLabel.text = @"Adaptive Threshold";
        }
            break;
        case ZHSessionInputFilterThresholdSketch:{
            self.filterLabel.text = @"Threshold Sketch";
        }
            break;
        case ZHSessionInputFilterHalftone:{
            self.filterLabel.text = @"Halftone";
        }
            break;
        case ZHSessionInputFilterMosaic:{
            self.filterLabel.text = @"Mosaic";
        }
            break;
            
            
        case ZHSessionInputFilterSmoothToon:{
            self.filterLabel.text = @"Smooth Toon";
        }
            break;
        case ZHSessionInputFilterPolkaDot:{
            self.filterLabel.text = @"Polka Dot";
        }
            break;
        case ZHSessionInputFilterNone:{
            self.filterLabel.text = @"None";
        }
            break;
        default:{
            self.filterLabel.text = @"?";
        }
            break;
    }
}

- (IBAction)closeBarButtonAction:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)nextBarButtonAction:(id)sender {
    
    [self performSegueWithIdentifier:SegueOptionsToCapture sender:nil];
}


-(void)shareItems:(NSArray*)items{
    NSMutableArray *activities = [@[]mutableCopy];
    UIActivityViewController *activityViewController = [[UIActivityViewController alloc]initWithActivityItems:items
                                                                                        applicationActivities:activities];
    
    [activityViewController setCompletionWithItemsHandler:^(NSString *activityType, BOOL completed, NSArray *returnedItems, NSError *activityError){
        if(completed){
            [self dismissViewControllerAnimated:YES completion:NULL];
        }
    }];
    
    
//    activityViewController.excludedActivityTypes = @[UIActivityTypePostToTwitter,
//                                                     UIActivityTypePostToFacebook,
//                                                     UIActivityTypePostToWeibo,
//                                                     UIActivityTypePrint,
//                                                     UIActivityTypeAssignToContact,
//                                                     UIActivityTypeSaveToCameraRoll,
//                                                     UIActivityTypeAddToReadingList,
//                                                     UIActivityTypePostToFlickr,
//                                                     UIActivityTypePostToVimeo,
//                                                     UIActivityTypePostToTencentWeibo];
    [self presentViewController:activityViewController animated:YES completion:nil];
    
}


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if(indexPath.section == 1) {
        
        [tableView reloadSections:[NSIndexSet indexSetWithIndex:indexPath.section] withRowAnimation:UITableViewRowAnimationAutomatic];
    }
    
}

-(void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath {
}

- (IBAction)nameTextFieldEditingChanged:(UITextField*)sender {
    
    _session.name = sender.text;
    
    if(_session.name == nil || [_session.name isEqualToString:@""]) {
        self.captureButton.enabled = NO;
    } else {
        self.captureButton.enabled = YES;
    }
}

- (IBAction)changeResolutionButtonTouchUpInside:(id)sender {
    UIAlertController *ac = [UIAlertController alertControllerWithTitle:@"Resolution" message:nil preferredStyle:UIAlertControllerStyleAlert];
    
    [ac addAction:[UIAlertAction actionWithTitle:@"288x352" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        _session.input.size = CGSizeMake(288, 352);
        _session.output.size = _session.input.size;
        [self updateUI];
    }]];

    [ac addAction:[UIAlertAction actionWithTitle:@"480x640" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        _session.input.size = CGSizeMake(480, 640);
        _session.output.size = _session.input.size;
        [self updateUI];
    }]];

    [ac addAction:[UIAlertAction actionWithTitle:@"540x960" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        _session.input.size = CGSizeMake(540, 960);
        _session.output.size = _session.input.size;
        [self updateUI];
    }]];

    [ac addAction:[UIAlertAction actionWithTitle:@"720x1280" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        _session.input.size = CGSizeMake(720, 1280);
        _session.output.size = _session.input.size;
        [self updateUI];
    }]];

    [ac addAction:[UIAlertAction actionWithTitle:@"1080x1920" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        _session.input.size = CGSizeMake(1080, 1920);
        _session.output.size = _session.input.size;
        [self updateUI];
    }]];

    [ac addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
    }]];

    [self presentViewController:ac animated:YES completion:nil];
}



- (IBAction)captureFramesButtonTouchUpInside:(UIButton*)sender {
    sender.enabled = NO;
    

    
    [_session saveConfig];
    
    [self performSegueWithIdentifier:SegueOptionsToCapture sender:nil];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        sender.enabled = YES;
    });
}

- (IBAction)renderButtonTouchUpInside:(UIButton*)sender {
    
    sender.enabled = NO;
    
    MBProgressHUD *hud = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
    [self.navigationController.view addSubview:hud];
    hud.mode = MBProgressHUDModeAnnularDeterminate;
    hud.labelText = @"Rendering video";
    [hud show:YES];
    
    NSUInteger frameCount = [ZHFileManager frameCountForSession:_session];
    NSLog(@"%lu frames", (unsigned long) frameCount);
    
    ZHRenderer *renderer = [[ZHRenderer alloc]init];
    [renderer renderSessionToVideo:_session progressBlock:^(NSUInteger framesRendered, NSUInteger totalFrames) {
        NSLog(@"rendered video frame %lu/%lu", (unsigned long)framesRendered, (unsigned long)frameCount);
        hud.progress = framesRendered / (float)frameCount;
    } completionBlock:^(BOOL success, ZHSession *session) {
        NSLog(@"completed");
        if(success == YES) {
            UIImage *image = [UIImage imageNamed:@"37x-Checkmark.png"];
            UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
            hud.customView = imageView;
            hud.mode = MBProgressHUDModeCustomView;
            hud.labelText = @"Exported to Camera Roll";
            
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [hud hide:YES];
            });

            NSLog(@"TODO: Cleanup");
        } else {
            [hud hide:YES];
            [self presentAlertDialogWithMessage:@"Failed"];
        }
        
        sender.enabled = YES;
    }];
    
//    [self performSegueWithIdentifier:SegueOptionsToRender sender:nil];
}

- (IBAction)renderGifButtonTouchUpInside:(UIButton*)sender {
    sender.enabled = NO;
    
    MBProgressHUD *hud = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
    [self.navigationController.view addSubview:hud];
    hud.mode = MBProgressHUDModeAnnularDeterminate;
    hud.labelText = @"Rendering gif";
    [hud show:YES];
    
    NSUInteger frameCount = [ZHFileManager frameCountForSession:_session];
    NSLog(@"%lu frames", (unsigned long) frameCount);
    
    ZHRenderer *renderer = [[ZHRenderer alloc]init];
    [renderer renderSessionToGIF:_session progressBlock:^(NSUInteger framesRendered, NSUInteger totalFrames) {
        NSLog(@"rendered gif frame %lu/%lu", (unsigned long)framesRendered, (unsigned long)frameCount);
        hud.progress = framesRendered / (float)frameCount;
    } completionBlock:^(BOOL success, ZHSession *session) {
        NSLog(@"completed");
        if(success == YES) {
            UIImage *image = [UIImage imageNamed:@"37x-Checkmark.png"];
            UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
            hud.customView = imageView;
            hud.mode = MBProgressHUDModeCustomView;
            hud.labelText = @"Gif in bundle";
            
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [hud hide:YES];
            });
            
            NSLog(@"TODO: Cleanup");
        } else {
            [hud hide:YES];
            [self presentAlertDialogWithMessage:@"Failed"];
        }
        
        sender.enabled = YES;
        
    }];
    
}

- (IBAction)shareVideoButtonTouchUpInside:(id)sender {
    [self shareItems:@[self.session.output.outputURL]];
}

- (IBAction)shareGIFButtonTouchUpInside:(id)sender {
    NSData *data = [NSData dataWithContentsOfFile:_session.output.outputGIF.path];
    [self shareItems:@[data]];
}


@end


@implementation ZHOptionsTableViewController (UITextFieldDelegate)
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    if( [string rangeOfCharacterFromSet:[NSCharacterSet newlineCharacterSet]].location == NSNotFound ) {
        return YES;
    } else {
        [textField resignFirstResponder];
        return NO;
    }
}

@end


