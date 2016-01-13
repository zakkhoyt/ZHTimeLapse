//
//  ZHVideoAssetCollectionViewCell.h
//  ZHTimeLapse
//
//  Created by Zakk Hoyt on 1/12/16.
//  Copyright © 2016 Zakk Hoyt. All rights reserved.
//

#import <UIKit/UIKit.h>
@import Photos;

@interface ZHVideoAssetCollectionViewCell : UICollectionViewCell
@property (nonatomic, strong) PHAsset *videoAsset;
@end
