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

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];

}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if([segue.identifier isEqualToString:SegueOptionsToCapture]) {
        ZHCaptureViewController *vc = segue.destinationViewController;
        vc.session = _session;
    }
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

- (IBAction)captureFramesButtonTouchUpInside:(id)sender {

    _session.input.size = CGSizeMake(480, 640);
    _session.input.frameRate = 5;
    
    _session.output.size = _session.input.size;
    _session.output.frameRate = 30;

    
    [_session saveConfig];
    
    [self performSegueWithIdentifier:SegueOptionsToCapture sender:nil];
}

- (IBAction)renderButtonTouchUpInside:(id)sender {
    
    NSUInteger frameCount = [ZHFileManager frameCountForSession:_session];
    NSLog(@"%lu frames", (unsigned long) frameCount);
    
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


