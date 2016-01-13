//
//  ZHVideoAssetCollectionViewCell.m
//  ZHTimeLapse
//
//  Created by Zakk Hoyt on 1/12/16.
//  Copyright © 2016 Zakk Hoyt. All rights reserved.
//

#import "ZHVideoAssetCollectionViewCell.h"
#import "ZHAssetManager.h"

@interface ZHVideoAssetCollectionViewCell ()
@property (weak, nonatomic) IBOutlet UIImageView *imageView;

@end

@implementation ZHVideoAssetCollectionViewCell

-(void)setVideoAsset:(PHAsset *)videoAsset {
    _videoAsset = videoAsset;
    
    _imageView.layer.borderColor = [UIColor redColor].CGColor;
    _imageView.layer.borderWidth = 1.0;
    
    [[ZHAssetManager sharedInstance]requestResizedImageForAsset:_videoAsset imageView:_imageView progressBlock:^(float progress) {
        
    } completionBlock:^(NSError *error) {
        
    }];
}
@end
