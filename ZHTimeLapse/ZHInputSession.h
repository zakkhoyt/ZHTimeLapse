//
//  ZHInputModel.h
//  ZHTimeLapse
//
//  Created by Zakk Hoyt on 12/21/15.
//  Copyright © 2015 Zakk Hoyt. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GPUImage.h"

@interface ZHInputSession : NSObject
@property (nonatomic, strong) GPUImageFilter *filter;
@property (nonatomic) CGSize size;
@property (nonatomic) NSTimeInterval frameRate;
@property (nonatomic, strong) NSMutableArray *frames;

- (instancetype)initWithDictionary:(NSDictionary*)dictionary;
-(NSDictionary*)dictionaryRepresentation;
@end
