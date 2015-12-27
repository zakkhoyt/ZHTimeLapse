//
//  ZHShutterButton.h
//  ZHTimeLapse
//
//  Created by Zakk Hoyt on 12/26/15.
//  Copyright © 2015 Zakk Hoyt. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void (^ZHShutterButtonEmptyBlock)();

@interface ZHShutterButton : UIButton

-(void)setStartBlock:(ZHShutterButtonEmptyBlock)startBlock;
-(void)setStopBlock:(ZHShutterButtonEmptyBlock)stopBlock;

@end
