//
//  ZHLibraryViewController.m
//  ZHTimeLapse
//
//  Created by Zakk Hoyt on 1/12/16.
//  Copyright © 2016 Zakk Hoyt. All rights reserved.
//

#import "ZHLibraryViewController.h"
#import "UIColor+ZH.h"
#import "ZHAssetManager.h"
#import "ZHDefines.h"
#import "ZHVideoAssetCollectionViewCell.h"
#import "ZHRenderer.h"
#import "MBProgressHUD.h"

@interface ZHLibraryViewController ()
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (nonatomic, strong) NSArray *videoAssets;
@end

@interface ZHLibraryViewController (UICollectionViewDataSource) <UICollectionViewDataSource>
@end

@interface ZHLibraryViewController (UICollectionViewDelegateFlowLayout) <UICollectionViewDelegateFlowLayout>
@end

@interface ZHLibraryViewController (UICollectionViewDelegate) <UICollectionViewDelegate>
@end


@implementation ZHLibraryViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [[ZHAssetManager sharedInstance]getVideoAssetsWithCompletionBlock:^(NSError *error) {
        if(error != nil) {
            ZH_LOG_ERROR(@"Error while getting video assets");
        } else {
            self.videoAssets = [ZHAssetManager sharedInstance].videoAssets;
            [self.collectionView reloadData];
        }
    }];
    
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

@end



@implementation ZHLibraryViewController (UICollectionViewDataSource)

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.videoAssets.count;
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    ZHVideoAssetCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"ZHVideoAssetCollectionViewCell" forIndexPath:indexPath];
    cell.backgroundColor = [UIColor randomColor];
    cell.videoAsset = self.videoAssets[indexPath.item];
    return cell;
}
@end

@implementation ZHLibraryViewController (UICollectionViewDelegateFlowLayout)

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    CGFloat w = self.view.bounds.size.width / 4.0;
    return CGSizeMake(w, w);
}

- (UIEdgeInsets)collectionView:(UICollectionView *)cv layout:(UICollectionViewLayout*)cvl insetForSectionAtIndex:(NSInteger)section {
    return UIEdgeInsetsZero;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section{
    return 0.0;
}
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section{
    return 0.0;
}
@end

@implementation ZHLibraryViewController (UICollectionViewDelegate)

#pragma mark UICollectionViewDelegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {

    
    PHAsset *videoAsset = self.videoAssets[indexPath.item];
    ZHRenderer *renderer = [ZHRenderer new];
    [renderer renderVideoAssetToGIF:videoAsset progressBlock:^(NSUInteger framesRendered, NSUInteger totalFrames) {
        NSLog(@"Progress: %.2f", framesRendered / (float)totalFrames);
    } completionBlock:^(BOOL success, ZHSession *session) {
        NSLog(@"Completed!");
    }];
}
@end