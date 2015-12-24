//
//  ZHOutputModel.h
//  ZHTimeLapse
//
//  Created by Zakk Hoyt on 12/21/15.
//  Copyright © 2015 Zakk Hoyt. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ZHOutputSession : NSObject
@property (nonatomic) CGSize size;
@property (nonatomic) NSTimeInterval frameRate;
@property (nonatomic, strong) NSURL *outputURL;

- (instancetype)initWithDictionary:(NSDictionary*)dictionary;
-(NSDictionary*)dictionaryRepresentation;
@end
