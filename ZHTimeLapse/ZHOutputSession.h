//
//  ZHOutputModel.h
//  ZHTimeLapse
//
//  Created by Zakk Hoyt on 12/21/15.
//  Copyright © 2015 Zakk Hoyt. All rights reserved.
//

#import <UIKit/UIKit.h>


typedef enum {
    ZHOutputSessionOutputTypeVideo = 0,
    ZHOutputSessionOutputTypeGIF = 1,
} ZHOutputSessionOutputType;

@interface ZHOutputSession : NSObject <NSCopying>
@property (nonatomic) CGSize size;
@property (nonatomic) NSTimeInterval frameRate;
@property (nonatomic, strong) NSURL *outputURL;
@property (nonatomic, strong) NSURL *outputGIF;
@property (nonatomic) ZHOutputSessionOutputType outputType;

- (instancetype)initWithDictionary:(NSDictionary*)dictionary;
-(NSDictionary*)dictionaryRepresentation;
@end
