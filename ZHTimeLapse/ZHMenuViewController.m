//
//  ZHMenuViewController.m
//  ZHTimeLapse
//
//  Created by Zakk Hoyt on 12/30/15.
//  Copyright © 2015 Zakk Hoyt. All rights reserved.
//

#import "ZHMenuViewController.h"
#import "ZHDefines.h"
#import "UIColor+ZH.h"

typedef enum {
    ZHMenuViewControllerMenuItemTypeLabel = 0,
    ZHMenuViewControllerMenuItemTypeStepper,
    ZHMenuViewControllerMenuItemTypeCancel,
} ZHMenuViewControllerMenuItemType;

typedef void (^ZHMenuViewControllerEmptyBlock)();

@interface ZHMenuViewController ()
@property (nonatomic, weak) IBOutlet UICollectionView *collectionView;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *centerYConstraint;
@property (nonatomic, strong) NSArray *menuItems;
@end

@interface ZHMenuViewController (UICollectionViewDataSource) <UICollectionViewDataSource>
@end

@interface ZHMenuViewController (UICollectionViewDelegateFlowLayout) <UICollectionViewDelegateFlowLayout>
@end

@interface ZHMenuViewController (UICollectionViewDelegate) <UICollectionViewDelegate>
@end

@implementation ZHMenuViewController

-(void)viewDidLoad {
    [super viewDidLoad];
    
    _collectionView.layer.masksToBounds = YES;
    _collectionView.layer.cornerRadius = 10;
    
    
    // Set the CV just off the bottom of the screen
    [self animateOutWithDuration:0 completionBlock:NULL];
    
    
    NSMutableArray *menuItems = [[NSMutableArray alloc]init];

    for(NSUInteger i = 0; i < 18; i++) {
        NSDictionary *entry = @{@"title": @"The Title",
                                @"type": @(ZHMenuViewControllerMenuItemTypeLabel)};
        [menuItems addObject:entry];
    }
    
    {
        NSDictionary *entry = @{@"title": @"Cance",
                                @"type": @(ZHMenuViewControllerMenuItemTypeCancel)};
        [menuItems addObject:entry];
    }
    _menuItems = [NSArray arrayWithArray:menuItems];
    [self.collectionView reloadData];
    
}


-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [self animateInWithDuration:0.3];
}

-(void)animateInWithDuration:(NSTimeInterval)duration{
    _centerYConstraint.constant = 0;
    if(duration > 0) {
        [UIView animateWithDuration:0.3 animations:^{
            [self.view layoutIfNeeded];
        }];
    } else {
        [self.view layoutIfNeeded];
    }
}

-(void)animateOutWithDuration:(NSTimeInterval)duration completionBlock:(ZHMenuViewControllerEmptyBlock)completionBlock{
    _centerYConstraint.constant = self.view.bounds.size.height;
    
    if(duration > 0) {
        [UIView animateWithDuration:0.3 animations:^{
            [self.view layoutIfNeeded];
        } completion:^(BOOL finished) {
            if(completionBlock){
                completionBlock();
            }
        }];
    } else {
        [self.view layoutIfNeeded];
    }
    
    if(completionBlock){
        completionBlock();
    }
}


-(ZHMenuViewControllerMenuItemType)menuTypeForItemAtIndexPath:(NSIndexPath*)indexPath{
    NSDictionary *dictionary = self.menuItems[indexPath.item];
    NSNumber *typeNumber = (NSNumber*)dictionary[@"type"];
    if(typeNumber == nil) {
        ZH_LOG_CRITICAL(@"No type found for menu cell");
    }
    ZHMenuViewControllerMenuItemType type = (ZHMenuViewControllerMenuItemType)typeNumber.unsignedIntegerValue;
    return type;
}

@end


@implementation ZHMenuViewController (UICollectionViewDataSource)

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.menuItems.count;
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"Cell" forIndexPath:indexPath];
    cell.backgroundColor = [UIColor randomColor];
    return cell;
}
@end

@implementation ZHMenuViewController (UICollectionViewDelegateFlowLayout)

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    switch ([self menuTypeForItemAtIndexPath:indexPath]) {
        case ZHMenuViewControllerMenuItemTypeLabel:{
            CGFloat w = collectionView.bounds.size.width / 3.0 - 1;
            return CGSizeMake(w, w);
        }
        case ZHMenuViewControllerMenuItemTypeStepper:
        case ZHMenuViewControllerMenuItemTypeCancel:
        default:{
            return CGSizeMake(collectionView.bounds.size.width, 44);
        }
    }
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

@implementation ZHMenuViewController (UICollectionViewDelegate)

#pragma mark UICollectionViewDelegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    switch ([self menuTypeForItemAtIndexPath:indexPath]) {
        case ZHMenuViewControllerMenuItemTypeLabel:{
            [self animateOutWithDuration:0.3 completionBlock:^{
                switch (self.type) {
                    case ZHMenuViewControllerTypeFrameRate:{
                        if(_frameRateBlock){
                            _frameRateBlock(1, 2);
                        }
                    }
                        break;
                    case ZHMenuViewControllerTypeResolution:{
                        if(_resolutionBlock) {
                            _resolutionBlock(CGSizeMake(288, 352));
                        }
                    }
                        break;
                    default:
                        break;
                }
                [self dismissViewControllerAnimated:YES completion:NULL];
            }];
        }
            break;
        case ZHMenuViewControllerMenuItemTypeStepper:{
            [self animateOutWithDuration:0.3 completionBlock:^{
                [self dismissViewControllerAnimated:YES completion:NULL];
            }];
        }
            break;
        case ZHMenuViewControllerMenuItemTypeCancel:{
            [self animateOutWithDuration:0.3 completionBlock:^{
                [self dismissViewControllerAnimated:YES completion:NULL];
            }];
        }
            break;
        default:{
            ZH_LOG_CRITICAL(@"Bad selection");
        }
    }
}

@end
