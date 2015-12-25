//
//  ZHSessionTableViewCell.m
//  ZHTimeLapse
//
//  Created by Zakk Hoyt on 12/24/15.
//  Copyright © 2015 Zakk Hoyt. All rights reserved.
//

#import "ZHSessionTableViewCell.h"
#import "ZHSession.h"
#import "NSDate+ZH.h"

@interface ZHSessionTableViewCell ()
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *uuidLabel;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@property (weak, nonatomic) IBOutlet UILabel *frameCountLabel;
@end

@implementation ZHSessionTableViewCell

-(void)setSession:(ZHSession *)session {
    _session = session;
    if(session.name) {
        _nameLabel.text = session.name;
    } else {
        _nameLabel.text = @"(no name)";
    }
    _uuidLabel.text = session.uuid;
    _dateLabel.text = [session.date stringFromDate];
    _frameCountLabel.text = [NSString stringWithFormat:@"%lu frames | %.2f sec",
                             (unsigned long)[session frameCount],
                             [session timeLength]];
    
    
}
@end
