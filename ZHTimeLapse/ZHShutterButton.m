//
//  ZHShutterButton.m
//  ZHTimeLapse
//
//  Created by Zakk Hoyt on 12/26/15.
//  Copyright © 2015 Zakk Hoyt. All rights reserved.
//

#import "ZHShutterButton.h"

@interface ZHShutterButton ()
@property (nonatomic, strong) ZHShutterButtonEmptyBlock startBlock;
@property (nonatomic, strong) ZHShutterButtonEmptyBlock stopBlock;
@property (nonatomic, strong) ZHShutterButton *shutterButton;
@property (nonatomic, strong) UIView *rotatingView;
//@property (nonatomic, strong) CABasicAnimation *rotateAnimation;
@end

@implementation ZHShutterButton


- (id)initWithCoder:(NSCoder *)aDecoder {
    if ((self = [super initWithCoder:aDecoder])) {
        // Make self invisible
        [self setTitle:@"" forState:UIControlStateNormal];
        
        // Add subview from nib file
        _shutterButton = [[[NSBundle mainBundle] loadNibNamed:@"ZHShutterButton" owner:self options:nil] firstObject];
        _shutterButton.frame = self.bounds;
        [self addSubview:_shutterButton];
        [_shutterButton addTarget:self action:@selector(touchUpInside:) forControlEvents:UIControlEventTouchUpInside];

        // Setup colors and looks
        _shutterButton.titleLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleCaption2];
        _shutterButton.tintColor = [UIColor redColor];
        [_shutterButton setBackgroundColor:[_shutterButton.tintColor colorWithAlphaComponent:0.1]];
        _shutterButton.layer.cornerRadius = _shutterButton.frame.size.width / 2.0;
        _shutterButton.layer.borderWidth = 1;
        _shutterButton.layer.borderColor = _shutterButton.tintColor.CGColor;
        
        [_shutterButton setTitle:@"Start" forState:UIControlStateNormal];
    }
    return self;
}

-(void)layoutSubviews {
    
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

-(void)touchUpInside:(UIButton*)sender {

    NSLog(@"%s", __FUNCTION__);
    
    if([_shutterButton.titleLabel.text isEqualToString:@"Start"]) {
        [self startAnimation];
        [_shutterButton setTitle:@"Stop" forState:UIControlStateNormal];
        if(_startBlock)  {
            _startBlock();
        }
    } else {
        [_shutterButton setTitle:@"Start" forState:UIControlStateNormal];
        [self stopAnimation];
        if(_stopBlock) {
            _stopBlock();
        }
    }
}

-(void)startAnimation{
    
    // A view to rotate around the button
    self.rotatingView = [[UIView alloc]initWithFrame:self.bounds];
    self.rotatingView.userInteractionEnabled = NO;
//    self.rotatingView.backgroundColor = [[UIColor greenColor] colorWithAlphaComponent:0.2];
    self.rotatingView.layer.masksToBounds = NO;
    
    // A dot on the rotating view
    const CGFloat w = 8;
    CGRect f = CGRectMake((self.bounds.size.width - w) / 2.0, 0, w, w);
    UIView *b = [[UIView alloc]initWithFrame:f];
    b.layer.cornerRadius = w/2.0;
    b.layer.masksToBounds = YES;
    b.backgroundColor = _shutterButton.tintColor;
    [self.rotatingView addSubview:b];
    
    [self.shutterButton addSubview:self.rotatingView];
    
    
    CABasicAnimation *rotateAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
    rotateAnimation.toValue = @(2*M_PI); // The angle we are rotating to
    rotateAnimation.duration = 1.0;
    rotateAnimation.repeatCount = 10000;
    [self.rotatingView.layer addAnimation:rotateAnimation forKey:@"rotate"];
}
-(void)stopAnimation{
    [self.rotatingView.layer removeAnimationForKey:@"rotate"];
    [self.rotatingView removeFromSuperview];
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



-(void)setStartBlock:(ZHShutterButtonEmptyBlock)startBlock {
    _startBlock = startBlock;
}

-(void)setStopBlock:(ZHShutterButtonEmptyBlock)stopBlock {
    _stopBlock = stopBlock;
}


@end
