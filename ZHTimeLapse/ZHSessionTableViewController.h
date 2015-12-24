//
//  ZHSessionTableViewController.h
//  ZHTimeLapse
//
//  Created by Zakk Hoyt on 12/23/15.
//  Copyright © 2015 Zakk Hoyt. All rights reserved.
//

#import <UIKit/UIKit.h>
@class ZHSession;

@interface ZHSessionTableViewController : UITableViewController
@property (nonatomic, strong) ZHSession *session;
@end
