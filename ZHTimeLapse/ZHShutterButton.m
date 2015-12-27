//
//  ZHShutterButton.m
//  ZHTimeLapse
//
//  Created by Zakk Hoyt on 12/26/15.
//  Copyright © 2015 Zakk Hoyt. All rights reserved.
//

#import "ZHShutterButton.h"
#import "NSTimer+Blocks.h"

static NSString *ZHShutterButtonStoppedString = @"Capture";
static NSString *ZHShutterButtonStartedString = @"";

@interface ZHShutterButton ()
@property (nonatomic, strong) ZHShutterButtonEmptyBlock startBlock;
@property (nonatomic, strong) ZHShutterButtonEmptyBlock stopBlock;
@property (nonatomic, strong) ZHShutterButton *shutterButton;
@property (nonatomic, strong) NSDate *lastOrbitStartDate;
@property (nonatomic, strong) UIView *orbitView;
@property (nonatomic, strong) NSTimer *orbitTimer;
//@property (nonatomic, strong) UIView *orbitView;
@property (nonatomic, strong) NSTimer *tickTimer;

@property (nonatomic) BOOL isRecording;
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
        
        [_shutterButton setTitle:ZHShutterButtonStoppedString forState:UIControlStateNormal];
    }
    return self;
}

#pragma mark Private methods

-(void)touchUpInside:(UIButton*)sender {
    if(_isRecording == NO) {
        _isRecording = YES;
        [self startAnimation];
        [_shutterButton setTitle:ZHShutterButtonStartedString forState:UIControlStateNormal];
        if(_startBlock)  {
            _startBlock();
        }
    } else {
        _isRecording = NO;
        [_shutterButton setTitle:ZHShutterButtonStoppedString forState:UIControlStateNormal];
        [self stopAnimation];
        if(_stopBlock) {
            _stopBlock();
        }
    }
}

-(void)startAnimation{
    NSAssert(_session, @"No session set for shutter button");
    
//    // A view to rotate around the button
//    self.orbitView = [[UIView alloc]initWithFrame:self.bounds];
//    self.orbitView.userInteractionEnabled = NO;
//    self.orbitView.layer.masksToBounds = NO;
//
//    // A tick line on the rotating view
//    const CGFloat w = 2;
//    const CGFloat h = 8;
//    CGRect f = CGRectMake((self.bounds.size.width - w) / 2.0, 0, w, h);
//    UIView *b = [[UIView alloc]initWithFrame:f];
//    b.layer.cornerRadius = w/2.0;
//    b.layer.masksToBounds = YES;
//    b.backgroundColor = [UIColor whiteColor];
//    [self.orbitView addSubview:b];
//    [self.shutterButton addSubview:self.orbitView];
//    
//    {
//        CABasicAnimation *rotateAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
//        rotateAnimation.toValue = @(2*M_PI); // The angle we are rotating to
//        rotateAnimation.duration = 1.0;
//        rotateAnimation.repeatCount = 10000;
//        [self.orbitView.layer addAnimation:rotateAnimation forKey:@"rotate"];
//    }
    
    
    __block NSUInteger counter = 0;
    
    void (^tick)() = ^(){
        // A view to rotate around the button
        UIView *bgView = [[UIView alloc]initWithFrame:self.bounds];
        bgView.userInteractionEnabled = NO;
        bgView.layer.masksToBounds = NO;
        // Calculate rotation angle
        CGFloat angle = counter * 2*M_PI/_session.input.frameRate;
        bgView.transform = CGAffineTransformMakeRotation(angle);
        
        // A tick line on the rotating view
        const CGFloat w = 8;
        const CGFloat h = 8;
        CGRect f = CGRectMake((self.bounds.size.width - w) / 2.0, 0, w, h);
        UIView *b = [[UIView alloc]initWithFrame:f];
        b.layer.cornerRadius = w/2.0;
        b.layer.masksToBounds = YES;
        b.backgroundColor = [UIColor whiteColor];
        [bgView addSubview:b];
        [self.shutterButton addSubview:bgView];
        counter++;
        
        [UIView animateWithDuration:1.0 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
            bgView.alpha = 0;
            b.transform = CGAffineTransformMakeTranslation(0, _shutterButton.bounds.size.height / 2.0 - h);
            b.transform = CGAffineTransformScale(b.transform, 0.2, 0.2);
        } completion:^(BOOL finished) {
            [bgView removeFromSuperview];
        }];
    };

    tick();
    _tickTimer = [NSTimer scheduledTimerWithTimeInterval:1/_session.input.frameRate block:^{
        tick();
    } repeats:YES];
}

-(void)stopAnimation{
    [_orbitTimer invalidate];
    [_tickTimer invalidate];
    [self.orbitView.layer removeAnimationForKey:@"rotate"];
    [self.orbitView removeFromSuperview];
}

-(void)addTick{
    
    

}

#pragma mark Public methods

-(void)setStartBlock:(ZHShutterButtonEmptyBlock)startBlock {
    _startBlock = startBlock;
}

-(void)setStopBlock:(ZHShutterButtonEmptyBlock)stopBlock {
    _stopBlock = stopBlock;
}


//- (void)animationDidStart:(CAAnimation *)theAnimation {
//    NSLog(@"%s", __FUNCTION__);
////    [self addTick];
//}
//- (void)animationDidStop:(CAAnimation *)theAnimation finished:(BOOL)flag {
//    NSLog(@"%s", __FUNCTION__);
//}

@end
