//
//  NSDate+ZH.h
//  ZH
//
//  Created by Zakk Hoyt on 4/20/15.
//  Copyright (c) 2015 Zakk Hoyt. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDate (ZH)
+(NSDate*)dateFromString:(NSString*)string;


-(NSString*)stringFromDateShort;
-(NSString*)stringRelativeTimeFromDate;

+(NSDate*)dateFromJSONString:(NSString*)jsonString;
-(NSString*)jsonStringForDate;

@end
