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

#pragma mark Private methods

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
    const CGFloat w = 4;
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
    rotateAnimation.delegate = self;
    [self.rotatingView.layer addAnimation:rotateAnimation forKey:@"rotate"];
}

-(void)stopAnimation{
    [self.rotatingView.layer removeAnimationForKey:@"rotate"];
    [self.rotatingView removeFromSuperview];
}

-(void)addTick{
    UIView *tickView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.height)];
    tickView.userInteractionEnabled = NO;
    tickView.backgroundColor = _shutterButton.tintColor;
    tickView.layer.masksToBounds = YES;
    tickView.layer.cornerRadius = self.bounds.size.width / 2.0;
    tickView.center = CGPointMake(self.bounds.size.width / 2.0, self.bounds.size.height / 2.0);
//    tickView.alpha = 1.0;
    
    [_shutterButton addSubview:tickView];
    
    [self bringSubviewToFront:self.rotatingView];
    
    [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        tickView.transform = CGAffineTransformMakeScale(0.01, 0.01);
//        tickView.alpha = 0.0;
    } completion:^(BOOL finished) {
        [tickView removeFromSuperview];
    }];
}

#pragma mark Public methods

-(void)setStartBlock:(ZHShutterButtonEmptyBlock)startBlock {
    _startBlock = startBlock;
}

-(void)setStopBlock:(ZHShutterButtonEmptyBlock)stopBlock {
    _stopBlock = stopBlock;
}


- (void)animationDidStart:(CAAnimation *)theAnimation {
    NSLog(@"%s", __FUNCTION__);
    [self addTick];
}
- (void)animationDidStop:(CAAnimation *)theAnimation finished:(BOOL)flag {
    NSLog(@"%s", __FUNCTION__);
}

@end
