//
//  ZHFileManager.h
//  ZHTimeLapse
//
//  Created by Zakk Hoyt on 12/21/15.
//  Copyright © 2015 Zakk Hoyt. All rights reserved.
//

#import <Foundation/Foundation.h>
@class ZHSession;

@interface ZHFileManager : NSObject

+(NSString*)pathForDocumentsDirectory;
+(void)ensureDirectoryExistsAtPath:(NSString*)path;
+(BOOL)projectFolderExists:(NSString*)path;

+(void)deleteFileAtURL:(NSURL*)url;
+(NSArray <ZHSession*> *)sessions;
+(BOOL)deleteSession:(ZHSession*)session;
+(NSUInteger)frameCountForSession:(ZHSession*)session;


@end
