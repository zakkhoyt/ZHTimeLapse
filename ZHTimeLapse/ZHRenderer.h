//
//  ZHRenderer.h
//  ZHTimeLapse
//
//  Created by Zakk Hoyt on 12/24/15.
//  Copyright © 2015 Zakk Hoyt. All rights reserved.
//

#import <UIKit/UIKit.h>
@import Photos;

@class ZHSession;

typedef void (^ZHRendererCompletionBlock)(BOOL success, ZHSession* session);
typedef void (^ZHRendererProgressBlock)(NSUInteger framesRendered, NSUInteger totalFrames);

@interface ZHRenderer : NSObject


-(void)renderVideoAssetToVideo:(PHAsset*)asset progressBlock:(ZHRendererProgressBlock)progressBlock completionBlock:(ZHRendererCompletionBlock)completionBlock;

-(void)renderVideoAssetToGIF:(PHAsset*)asset progressBlock:(ZHRendererProgressBlock)progressBlock completionBlock:(ZHRendererCompletionBlock)completionBlock;

// Renders a the frames into a video inside the app's bundle at $/documents/{uuid}/output.mov then exports to the camera roll
-(void)renderSessionToVideo:(ZHSession*)session progressBlock:(ZHRendererProgressBlock)progressBlock completionBlock:(ZHRendererCompletionBlock)completionBlock;

// Renders a the frames into a gif inside the app's bundle at $/documents/{uuid}/output.gif
-(void)renderSessionToGIF:(ZHSession*)session progressBlock:(ZHRendererProgressBlock)progressBlock completionBlock:(ZHRendererCompletionBlock)completionBlock;
@end
