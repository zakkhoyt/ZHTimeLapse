//
//  UIColor+ZH.m
//  ZH
//
//  Created by Zakk Hoyt on 4/21/15.
//  Copyright (c) 2015 Zakk Hoyt. All rights reserved.
//

#import "UIColor+ZH.h"


@implementation UIColor (ZH)

+(UIColor*)randomColor{
    return [UIColor randomColorWithAlpha:1.0];
}

+(UIColor*)randomColorWithAlpha:(float)alpha{
    CGFloat red = (arc4random() % 0xFF) / (float)0xFF;
    CGFloat blue = (arc4random() % 0xFF) / (float)0xFF;
    CGFloat green = (arc4random() % 0xFF) / (float)0xFF;
    return [UIColor colorWithRed:red green:green blue:blue alpha:alpha];
}

+(UIColor*)randomSoftColor{
    return [UIColor randomSoftColorWithAlpha:1.0];
}

+(UIColor*)randomSoftColorWithAlpha:(float)alpha{
    CGFloat hue = ( arc4random() % 256 / 256.0 ); // 0.0 to 1.0
    CGFloat saturation = ( arc4random() % 128 / 256.0 ) + 0.5; // 0.5 to 1.0, away from white
    CGFloat brightness = ( arc4random() % 128 / 256.0 ) + 0.5; // 0.5 to 1.0, away from black
    return [UIColor colorWithHue:hue saturation:saturation brightness:brightness alpha:alpha];
}

+(UIColor*)zhBackgroundColor{
    return [UIColor darkGrayColor];
}

+(UIColor*)zhTintColor{
    return [UIColor yellowColor];
}

+(UIColor*)zhAlternateTintColor{
    return [UIColor cyanColor];
}




@end
