//
//  ZHMenuViewController.h
//  ZHTimeLapse
//
//  Created by Zakk Hoyt on 12/30/15.
//  Copyright © 2015 Zakk Hoyt. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum {
    ZHMenuViewControllerTypeFrameRate = 0,
    ZHMenuViewControllerTypeResolution = 1,
} ZHMenuViewControllerType;


typedef void (^ZHMenuViewControllerResolutionBlock)(CGSize resolution);
typedef void (^ZHMenuViewControllerFrameRateBlock)(NSUInteger seconds, NSUInteger frames);
typedef void (^ZHMenuViewControllerEmptyBlock)();

@interface ZHMenuViewController : UIViewController

-(void)setTitle:(NSString*)title type:(ZHMenuViewControllerType)type frameRateBlock:(ZHMenuViewControllerFrameRateBlock)frameRateBlock cancelBlock:(ZHMenuViewControllerEmptyBlock)cancelBlock;
-(void)setTitle:(NSString*)title type:(ZHMenuViewControllerType)type resolutionBlock:(ZHMenuViewControllerResolutionBlock)resolutionBlock cancelBlock:(ZHMenuViewControllerEmptyBlock)cancelBlock;
@end
