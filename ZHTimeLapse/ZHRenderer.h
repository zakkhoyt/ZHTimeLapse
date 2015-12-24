//
//  ZHRenderer.h
//  ZHTimeLapse
//
//  Created by Zakk Hoyt on 12/24/15.
//  Copyright © 2015 Zakk Hoyt. All rights reserved.
//

#import <UIKit/UIKit.h>
@class ZHSession;

typedef void (^ZHRendererCompletionBlock)(ZHSession* session);
typedef void (^ZHRendererProgressBlock)(NSUInteger framesRendered, NSUInteger totalFrames);

@interface ZHRenderer : NSObject
-(void)renderSession:(ZHSession*)session progressBlock:(ZHRendererProgressBlock)progressBlock completionBlock:(ZHRendererCompletionBlock)completionBlock;
@end
