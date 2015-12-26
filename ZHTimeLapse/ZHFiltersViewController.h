//
//  ZHFiltersViewController.h
//  ZHTimeLapse
//
//  Created by Zakk Hoyt on 12/24/15.
//  Copyright © 2015 Zakk Hoyt. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GPUImage.h"
#import "ZHSession.h"


typedef void (^ZHFiltersViewControllerFilterBlock)(ZHSessionFilter filter);

@interface ZHFiltersViewController : UIViewController
-(void)setVideoCamera:(GPUImageVideoCamera *)videoCamera completionBlock:(ZHFiltersViewControllerFilterBlock)completionBlock;
@end
