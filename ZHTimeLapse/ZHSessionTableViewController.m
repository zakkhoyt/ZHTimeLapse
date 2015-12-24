//
//  ZHSessionTableViewController.m
//  ZHTimeLapse
//
//  Created by Zakk Hoyt on 12/23/15.
//  Copyright © 2015 Zakk Hoyt. All rights reserved.
//

#import "ZHSessionTableViewController.h"
#import "ZHSession.h"
#import "ZHCaptureViewController.h"
#import "ZHFileManager.h"
#import "ZHRenderer.h"
#import "UIViewController+AlertController.h"
#import "MBProgressHUD.h"

static NSString *SegueOptionsToCapture = @"SegueOptionsToCapture";
static NSString *SegueOptionsToRender = @"SegueOptionsToRender";

typedef enum {
    ZHSessionTableViewControllerSectionName = 0,
    ZHSessionTableViewControllerSectionInput = 1,
    ZHSessionTableViewControllerSectionOutput = 2,
    ZHSessionTableViewControllerSectionFilter = 3,
} ZHSessionTableViewControllerSection;


@interface ZHSessionTableViewController (UITextFieldDelegate) <UITextFieldDelegate>
@end

@interface ZHSessionTableViewController () <UITextFieldDelegate>

@property (nonatomic, strong) NSNumber *selectedInputIndex;
@property (nonatomic, strong) NSNumber *selectedOutputIndex;
@property (nonatomic, strong) NSNumber *selectedFilterIndex;
@property (weak, nonatomic) IBOutlet UITextField *nameTextField;
@property (weak, nonatomic) IBOutlet UIButton *captureButton;
@property (weak, nonatomic) IBOutlet UIButton *renderButton;
@end

@implementation ZHSessionTableViewController

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

- (IBAction)closeBarButtonAction:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)nextBarButtonAction:(id)sender {
    
    [self performSegueWithIdentifier:SegueOptionsToCapture sender:nil];
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
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

- (IBAction)captureFramesButtonTouchUpInside:(UIButton*)sender {
    sender.enabled = NO;
    
    _session.input.size = CGSizeMake(720, 1280);
    _session.input.frameRate = 5;
    
    _session.output.size = _session.input.size;
    _session.output.frameRate = 30;

    
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
    hud.labelText = @"Loading";
    [hud show:YES];
    
    NSUInteger frameCount = [ZHFileManager frameCountForSession:_session];
    NSLog(@"%lu frames", (unsigned long) frameCount);
    
    ZHRenderer *renderer = [[ZHRenderer alloc]init];
    [renderer renderSession:_session progressBlock:^(NSUInteger framesRendered, NSUInteger totalFrames) {
        NSLog(@"rendered %lu/%lu", (unsigned long)framesRendered, (unsigned long)frameCount);
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

@end


@implementation ZHSessionTableViewController (UITextFieldDelegate)
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    if( [string rangeOfCharacterFromSet:[NSCharacterSet newlineCharacterSet]].location == NSNotFound ) {
        return YES;
    } else {
        [textField resignFirstResponder];
        return NO;
    }
}

@end


