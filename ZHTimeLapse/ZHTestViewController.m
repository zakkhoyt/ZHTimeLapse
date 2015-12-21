//
//  ZHTestViewController.m
//  ZHTimeLapse
//
//  Created by Zakk Hoyt on 12/21/15.
//  Copyright © 2015 Zakk Hoyt. All rights reserved.
//

#import "ZHTestViewController.h"
#import "GPUImage.h"
#import "PHAsset+Utility.h"
#import "MBProgressHUD.h"

@interface ZHTestViewController () <UINavigationControllerDelegate, UIImagePickerControllerDelegate, UIActionSheetDelegate, GPUImageVideoCameraDelegate>
@property (weak, nonatomic) IBOutlet UIToolbar *toolbar;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *albumButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *cameraButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *filterButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *saveButton;
@property (weak, nonatomic) IBOutlet UIImageView *selectedImageView;
@property (nonatomic, strong) UIImage *originalImage;
@end

@implementation ZHTestViewController


#pragma mark UIViewController
- (void)viewDidLoad {
    [super viewDidLoad];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

-(BOOL)prefersStatusBarHidden{
    return  YES;
}

#pragma mark Private methods

- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo {
    NSString *alertTitle = error ? @"Error" : @"Image Saved";
    NSString *alertMessage = error ? @"Unable to save to photo album." : @"Image saved to photo album successfully.";
    
    UIAlertController *ac = [UIAlertController alertControllerWithTitle:alertTitle message:alertMessage preferredStyle:UIAlertControllerStyleAlert];
    
    [ac addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
    }]];
    
    [self presentViewController:ac animated:YES completion:NULL];
    
}

#pragma mark IBActions
- (IBAction)albumButtonTouchUpInside:(id)sender {
    UIImagePickerController *photoPicker = [[UIImagePickerController alloc] init];
    photoPicker.delegate = self;
    photoPicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    
    [self presentViewController:photoPicker animated:YES completion:NULL];
    
}
- (IBAction)cameraButtonTouchUpInside:(id)sender {
    UIImagePickerController *photoPicker = [[UIImagePickerController alloc] init];
    
    photoPicker.delegate = self;
    photoPicker.sourceType = UIImagePickerControllerSourceTypeCamera;
    
    [self presentViewController:photoPicker animated:YES completion:NULL];
    
}

- (IBAction)filterButtonTouchUpInside:(UIBarButtonItem*)sender {

    
    
    
    void (^applyFilter)(GPUImageFilter *filter) = ^(GPUImageFilter *filter){
        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        UIImage *filteredImage = [filter imageByFilteringImage:self.originalImage];
        [self.selectedImageView setImage:filteredImage];
        [MBProgressHUD hideHUDForView:self.view animated:YES];
    };
    
    
    UIAlertController *ac = [UIAlertController alertControllerWithTitle:@"Select Filter" message:nil preferredStyle:UIAlertControllerStyleAlert];
    ac.popoverPresentationController.barButtonItem = sender;
    
    [ac addAction:[UIAlertAction actionWithTitle:@"Grayscale" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        GPUImageFilter *filter = [[GPUImageGrayscaleFilter alloc] init];
        applyFilter(filter);
    }]];
    
    [ac addAction:[UIAlertAction actionWithTitle:@"Sepia" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        GPUImageFilter *filter = [[GPUImageSepiaFilter alloc] init];
        applyFilter(filter);
    }]];

    [ac addAction:[UIAlertAction actionWithTitle:@"Sketch" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        GPUImageFilter *filter = [[GPUImageSketchFilter alloc] init];
        applyFilter(filter);
    }]];

    [ac addAction:[UIAlertAction actionWithTitle:@"Pixellate" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        GPUImageFilter *filter = [[GPUImagePixellateFilter alloc] init];
        applyFilter(filter);
    }]];

    [ac addAction:[UIAlertAction actionWithTitle:@"Color Invert" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        GPUImageFilter *filter = [[GPUImageColorInvertFilter alloc] init];
        applyFilter(filter);
    }]];

    [ac addAction:[UIAlertAction actionWithTitle:@"Toon" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        GPUImageFilter *filter = [[GPUImageToonFilter alloc] init];
        applyFilter(filter);
    }]];

    [ac addAction:[UIAlertAction actionWithTitle:@"Pinch Distort" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        GPUImageFilter *filter = [[GPUImagePinchDistortionFilter alloc] init];
        applyFilter(filter);
    }]];

    [ac addAction:[UIAlertAction actionWithTitle:@"Blur" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        GPUImageiOSBlurFilter *blurFilter = [[GPUImageiOSBlurFilter alloc]init];
        GPUImageFilter *filter = (GPUImageFilter*)blurFilter;
        applyFilter(filter);
    }]];
    
    [ac addAction:[UIAlertAction actionWithTitle:@"None" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        GPUImageFilter *filter = [[GPUImageFilter alloc] init];
        applyFilter(filter);
    }]];


    
    [self presentViewController:ac animated:YES completion:NULL];

}

- (IBAction)saveButtonTouchUpInside:(id)sender {
    [PHAsset saveImageToCameraRoll:self.selectedImageView.image location:nil completionBlock:^(PHAsset *asset, BOOL success) {
        if(success) {
            NSLog(@"Saved");
        } else {
            NSLog(@"Error: Could not save asset to camera roll");
        }
    }];
}


#pragma mark UIImagePickerDelegate
- (void)imagePickerController:(UIImagePickerController *)photoPicker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    self.saveButton.enabled = YES;
    self.filterButton.enabled = YES;
    
    self.originalImage = [info valueForKey:UIImagePickerControllerOriginalImage];
    
    [self.selectedImageView setImage:self.originalImage];
    
    [photoPicker dismissViewControllerAnimated:YES completion:^{
        
    }];
}


#pragma mark GPUImageVideoCameraDelegate

- (void)willOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer{
    [self.selectedImageView setNeedsDisplay];
}



@end
