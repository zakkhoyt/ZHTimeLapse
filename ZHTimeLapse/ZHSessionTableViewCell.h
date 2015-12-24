//
//  ZHSessionTableViewCell.h
//  ZHTimeLapse
//
//  Created by Zakk Hoyt on 12/24/15.
//  Copyright © 2015 Zakk Hoyt. All rights reserved.
//

#import <UIKit/UIKit.h>
@class ZHSession;

@interface ZHSessionTableViewCell : UITableViewCell
@property (nonatomic, strong) ZHSession *session;
@end
