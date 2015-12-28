//
//  ZHSession.h
//  ZHTimeLapse
//
//  Created by Zakk Hoyt on 12/21/15.
//  Copyright © 2015 Zakk Hoyt. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "ZHInputSession.h"
#import "ZHOutputSession.h"

typedef void (^ZHSessionBoolBlock)(BOOL success);

@interface ZHSession : NSObject

@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *uuid;
@property (nonatomic, strong) NSDate *date;
@property (nonatomic, strong) NSString *projectPath;


@property (nonatomic, strong) ZHInputSession *input;
@property (nonatomic, strong) ZHOutputSession *output;

+(ZHSession*)session;
+(ZHSession*)sessionFromSession:(ZHSession*)oldSession;
+(ZHSession*)sessionWithName:(NSString*)name;
- (instancetype)initWithDictionary:(NSDictionary*)dictionary;

-(void)saveConfig;
-(void)cacheImage:(UIImage*)image index:(NSUInteger)index;

-(UIImage*)imageForIndex:(NSUInteger)index;

-(void)listFrames;

-(NSTimeInterval)timeLength;

-(void)renderVideoFromViewController:(UIViewController*)viewController completionBlock:(ZHSessionBoolBlock)completionBlock;
-(void)renderGIFFromViewController:(UIViewController*)viewController completionBlock:(ZHSessionBoolBlock)completionBlock;
-(void)deleteSessionCache;
@end
