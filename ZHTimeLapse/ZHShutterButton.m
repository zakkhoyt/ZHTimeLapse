//
//  ZHShutterButton.m
//  ZHTimeLapse
//
//  Created by Zakk Hoyt on 12/26/15.
//  Copyright © 2015 Zakk Hoyt. All rights reserved.
//

#import "ZHShutterButton.h"
#import "ZHDefines.h"
#import "NSTimer+Blocks.h"
@import CoreMotion;

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
@property (nonatomic) NSUInteger tickCounter;

@property (nonatomic) BOOL isRecording;

@property (nonatomic, strong) UIDynamicAnimator *animator;
@property (nonatomic, strong) UIGravityBehavior *gravity;
//@property (nonatomic, strong) UIPushBehavior *push;

@property (nonatomic, strong) CMMotionManager *motion;
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
    
    // A view to rotate around the button
    self.orbitView = [[UIView alloc]initWithFrame:self.bounds];
    self.orbitView.userInteractionEnabled = NO;
    self.orbitView.layer.masksToBounds = NO;

    // A tick line on the rotating view
    const CGFloat w = 2;
    const CGFloat h = 8;
    CGRect f = CGRectMake((self.bounds.size.width - w) / 2.0, 0, w, h);
    UIView *b = [[UIView alloc]initWithFrame:f];
    b.layer.cornerRadius = w/2.0;
    b.layer.masksToBounds = YES;
    b.backgroundColor = [UIColor whiteColor];
    [self.orbitView addSubview:b];
    [self.shutterButton addSubview:self.orbitView];

    CABasicAnimation *rotateAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
    rotateAnimation.toValue = @(2*M_PI); // The angle we are rotating to
    rotateAnimation.duration = 1.0;
    rotateAnimation.repeatCount = 10000;
    // Add small delay to try to sync the followin animation
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1/_session.input.frameRate * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self.orbitView.layer addAnimation:rotateAnimation forKey:@"rotate"];
    });
    


    _tickCounter = 0;
    [self tick];
    _tickTimer = [NSTimer scheduledTimerWithTimeInterval:1/_session.input.frameRate block:^{
        [self tick];
    } repeats:YES];
}



-(void)tick {
    
//    // A view to rotate around the button
//    UIView *bgView = [[UIView alloc]initWithFrame:self.bounds];
//    bgView.userInteractionEnabled = NO;
//    bgView.layer.masksToBounds = YES;
//    bgView.layer.cornerRadius = bgView.bounds.size.width / 2.0;
//    CALayer *orbitLayer = self.orbitView.layer.presentationLayer;
//    bgView.layer.transform = orbitLayer.transform;
//    
//    // A tick line on the rotating view
//    const CGFloat w = 8;
//    const CGFloat h = 8;
//    CGRect f = CGRectMake((self.bounds.size.width - w) / 2.0, -h / 2.0, w, h);
//    UIView *b = [[UIView alloc]initWithFrame:f];
//    b.layer.cornerRadius = w/2.0;
//    b.layer.masksToBounds = YES;
//    b.backgroundColor = [UIColor whiteColor];
//    [bgView addSubview:b];
//    [self.shutterButton addSubview:bgView];
//    
//    [UIView animateWithDuration:0.5 animations:^{
//        bgView.alpha = 0;
//    } completion:^(BOOL finished) {
//        [bgView removeFromSuperview];
//    }];
    
    
    
    // A view to rotate around the button
    UIView *bgView = [[UIView alloc]initWithFrame:self.bounds];
    bgView.userInteractionEnabled = NO;
    bgView.layer.masksToBounds = YES;
    bgView.layer.cornerRadius = bgView.bounds.size.width / 2.0;
    // Calculate rotation angle
    CGFloat angle = _tickCounter * 2*M_PI/_session.input.frameRate;
    bgView.transform = CGAffineTransformMakeRotation(angle);
    
    // A tick line on the rotating view
    const CGFloat w = 8;
    const CGFloat h = 8;
    CGRect f = CGRectMake((self.bounds.size.width - w) / 2.0, -h / 2.0, w, h);
    UIView *b = [[UIView alloc]initWithFrame:f];
    b.layer.cornerRadius = w/2.0;
    b.layer.masksToBounds = YES;
    b.backgroundColor = [UIColor whiteColor];
    [bgView addSubview:b];
    [self.shutterButton addSubview:bgView];
    _tickCounter++;
    
    
    [UIView animateWithDuration:1.0 delay:0 options:UIViewAnimationOptionCurveEaseIn animations:^{
        bgView.alpha = 0;
        b.transform = CGAffineTransformMakeTranslation(0, (_shutterButton.bounds.size.height) / 2.0);
        b.transform = CGAffineTransformScale(b.transform, 0.2, 0.2);
    } completion:^(BOOL finished) {
        [bgView removeFromSuperview];
    }];


}

-(void)stopAnimation{
  
//    // Spit out a dot for each frame in a random direction and vector
//    // Turn on gravity
//    _animator = [[UIDynamicAnimator alloc] initWithReferenceView:self];
//    _gravity = [[UIGravityBehavior alloc] init];
//    [_animator addBehavior:_gravity];
//    
//    // Use real gravity
//    _motion = [[CMMotionManager alloc]init];
//    [_motion startDeviceMotionUpdatesToQueue:[NSOperationQueue mainQueue]  withHandler:^(CMDeviceMotion * _Nullable motion, NSError * _Nullable error) {
//        double x = motion.gravity.x;
//        double y = motion.gravity.y;
//        _gravity.gravityDirection = CGVectorMake(x, -y);
//    }];
//
//    NSUInteger count = MIN(_session.input.frameCount, 30);
//    NSTimeInterval delay = 1 / (NSTimeInterval)count;
//    
//    for(NSUInteger index = 0; index < count; index++) {
//        // A tick line on the rotating view
//        const CGFloat w = 8;
//        const CGFloat h = 8;
//        CGRect f = CGRectMake((self.bounds.size.width - w) / 2.0,
//                              (self.bounds.size.height - h) / 2.0,
//                              w,
//                              h);
//        __block UIView *b = [[UIView alloc]initWithFrame:f];
//        b.layer.cornerRadius = w/2.0;
//        b.layer.masksToBounds = YES;
//        b.backgroundColor = [UIColor whiteColor];
//        
//        CGFloat angleRatio = arc4random() % 360 / 360.0;
//        CGFloat angle = 2*M_PI * angleRatio;
//        angle += M_PI;
//        CGFloat magnitudeRatio = arc4random() % 360 / 360.0;
//        CGFloat magnitude = 0.05 * magnitudeRatio;
//        
//        
//        
//        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delay * index * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//            [self addSubview:b];
//            
//            // Apply an impulse
//            UIPushBehavior *push = [[UIPushBehavior alloc]initWithItems:@[b] mode:UIPushBehaviorModeInstantaneous];
//            [push setAngle:angle magnitude:magnitude];
//            [_animator addBehavior:push];
//            [_gravity addItem:b];
//        });
//        
//        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//            [UIView animateWithDuration:0.2 animations:^{
//                b.alpha = 0;
//            } completion:^(BOOL finished) {
//                [b removeFromSuperview];
//                b = nil;
//            }];
//        });
//    }
    
    [_orbitTimer invalidate];
    [_tickTimer invalidate];
    [self.orbitView.layer removeAnimationForKey:@"rotate"];
    [self.orbitView removeFromSuperview];
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
