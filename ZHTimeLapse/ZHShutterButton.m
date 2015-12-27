//
//  ZHShutterButton.m
//  ZHTimeLapse
//
//  Created by Zakk Hoyt on 12/26/15.
//  Copyright © 2015 Zakk Hoyt. All rights reserved.
//

#import "ZHShutterButton.h"

@implementation ZHShutterButton


-(void)layoutSubviews {
    
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

-(void)startAnimation{
    
}
-(void)stopAnimation{
    
}

- (BOOL)beginTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event {
    NSLog(@"");
    return YES;
}

- (BOOL)continueTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event {
    return YES;
}

- (void)endTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event {

}

- (void)cancelTrackingWithEvent:(UIEvent *)event {

}

@end
