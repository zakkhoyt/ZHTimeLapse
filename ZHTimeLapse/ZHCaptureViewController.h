//
//  ZHCaptureViewController.h
//  ZHTimeLapse
//
//  Created by Zakk Hoyt on 12/21/15.
//  Copyright © 2015 Zakk Hoyt. All rights reserved.
//

#import <UIKit/UIKit.h>
@class ZHSession;

@interface ZHCaptureViewController : UIViewController
@property (nonatomic, strong) ZHSession *session;
@end
