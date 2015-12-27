//
//  ZHUserDefaults.m
//  ZHTimeLapse
//
//  Created by Zakk Hoyt on 12/23/15.
//  Copyright © 2015 Zakk Hoyt. All rights reserved.
//

#import "ZHUserDefaults.h"
#import "ZHSession.h"

@implementation ZHUserDefaults

static NSString *ZHApplicationMode = @"ZHApplicationMode";

+(BOOL)modeContains:(NSString*)submode{
    NSString *modes = [[NSUserDefaults standardUserDefaults] objectForKey:ZHApplicationMode];
    NSLog(@"Application modes: %@", modes);
    return [modes rangeOfString:submode].location != NSNotFound;
}

@end
