//
//  ZHUserDefaults.h
//  ZHTimeLapse
//
//  Created by Zakk Hoyt on 12/23/15.
//  Copyright © 2015 Zakk Hoyt. All rights reserved.
//

#import <Foundation/Foundation.h>
@class ZHSession;

static NSString *ZHUserDefaultsModeAdvanced = @"full";

@interface ZHUserDefaults : NSObject


+(BOOL)modeContains:(NSString*)submode;
+(BOOL)simpleMode;
+(BOOL)renderAsGIF;
@end
