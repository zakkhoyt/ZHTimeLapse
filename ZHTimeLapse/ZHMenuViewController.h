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

@interface ZHMenuViewController : UIViewController
@property (nonatomic) ZHMenuViewControllerType type;
@property (nonatomic, strong) ZHMenuViewControllerResolutionBlock resolutionBlock;
@property (nonatomic, strong) ZHMenuViewControllerFrameRateBlock frameRateBlock;
@end
