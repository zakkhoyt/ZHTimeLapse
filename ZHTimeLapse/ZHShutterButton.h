//
//  ZHShutterButton.h
//  ZHTimeLapse
//
//  Created by Zakk Hoyt on 12/26/15.
//  Copyright © 2015 Zakk Hoyt. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ZHSession.h"
typedef void (^ZHShutterButtonEmptyBlock)();

@interface ZHShutterButton : UIButton
@property (nonatomic, strong) ZHSession *session;
-(void)setStartBlock:(ZHShutterButtonEmptyBlock)startBlock;
-(void)setStopBlock:(ZHShutterButtonEmptyBlock)stopBlock;
//-(void)tick;
@end
