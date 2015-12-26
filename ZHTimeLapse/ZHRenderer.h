//
//  ZHRenderer.h
//  ZHTimeLapse
//
//  Created by Zakk Hoyt on 12/24/15.
//  Copyright © 2015 Zakk Hoyt. All rights reserved.
//

#import <UIKit/UIKit.h>
@class ZHSession;

typedef void (^ZHRendererCompletionBlock)(BOOL success, ZHSession* session);
typedef void (^ZHRendererProgressBlock)(NSUInteger framesRendered, NSUInteger totalFrames);

@interface ZHRenderer : NSObject
-(void)renderSessionToVideo:(ZHSession*)session progressBlock:(ZHRendererProgressBlock)progressBlock completionBlock:(ZHRendererCompletionBlock)completionBlock;
-(void)renderSessionToGIF:(ZHSession*)session progressBlock:(ZHRendererProgressBlock)progressBlock completionBlock:(ZHRendererCompletionBlock)completionBlock;
@end
