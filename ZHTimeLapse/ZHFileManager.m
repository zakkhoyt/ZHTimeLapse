//
//  ZHFileManager.m
//  ZHTimeLapse
//
//  Created by Zakk Hoyt on 12/21/15.
//  Copyright © 2015 Zakk Hoyt. All rights reserved.
//

#import "ZHFileManager.h"
#import "ZHSession.h"

@implementation ZHFileManager

+(NSString*)pathForDocumentsDirectory{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    return documentsDirectory;
}

+(void)ensureDirectoryExistsAtPath:(NSString*)path {
    if ([[NSFileManager defaultManager] fileExistsAtPath:path] == NO){
        NSError* error;
        if([[NSFileManager defaultManager]createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:&error]){
            NSLog(@"Created project dir at %@", path);
        } else {
            NSLog(@"Failed to create project dir :%@ with error: %@", path, error.description);
        }
        
        NSString *framesPath = [path stringByAppendingPathComponent:@"frames"];
        if([[NSFileManager defaultManager]createDirectoryAtPath:framesPath withIntermediateDirectories:YES attributes:nil error:&error]){
            NSLog(@"Created frames dir at %@", path);
        } else {
            NSLog(@"Failed to create frames dir :%@ with error: %@", path, error.description);
        }
    }
}

+(BOOL)projectFolderExists:(NSString*)path {
    return [[NSFileManager defaultManager] fileExistsAtPath:path];
}


+(NSArray <ZHSession*> *)sessions{
    NSString *docsDir = [ZHFileManager pathForDocumentsDirectory];
    NSError *error = nil;
    NSArray *contents = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:docsDir error:&error];
    if(error != nil) {
        NSLog(@"Handle error");
        return nil;
    }
    
    NSMutableArray *sessions = [[NSMutableArray alloc]initWithCapacity:contents.count];
    [contents enumerateObjectsUsingBlock:^(id  _Nonnull file, NSUInteger idx, BOOL * _Nonnull stop) {
        NSString *path = [docsDir stringByAppendingPathComponent:file];
        BOOL isDir = NO;
        [[NSFileManager defaultManager] fileExistsAtPath:path isDirectory:&isDir];
        if(isDir == YES) {
            NSString *sessionPath = [path stringByAppendingPathComponent:@"session.json"];
            if([[NSFileManager defaultManager] fileExistsAtPath:sessionPath] == NO) {
                NSLog(@"TODO: no session.json file");
                return;
            }
            
            NSError *jsonError = nil;
            NSData *data = [NSData dataWithContentsOfFile:sessionPath];
            NSDictionary *dictionary = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&jsonError];
            if(jsonError != nil) {
                NSLog(@"TODO: Handle json conversion error");
            }
            
            NSLog(@"session: %@", dictionary.description);
            ZHSession *session = [[ZHSession alloc]initWithDictionary:dictionary];
            [sessions addObject:session];
        }
    }];
    
    return sessions;
}

+(BOOL)deleteSession:(ZHSession*)session {
    NSError *error = nil;
    [[NSFileManager defaultManager] removeItemAtPath:session.projectPath error:&error];
    if(error != nil) {
        NSLog(@"Error deleting session: %@", error.localizedDescription);
        return NO;
    }
    return YES;
}


+(NSUInteger)frameCountForSession:(ZHSession*)session {
    NSString *framesDir = [session.projectPath stringByAppendingPathComponent:@"frames"];
    NSError *error = nil;
    NSArray *contents = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:framesDir error:&error];
    if(error != nil) {
        NSLog(@"Handle error while finding frame");
        return 0;
    }

    [contents enumerateObjectsUsingBlock:^(NSString * _Nonnull path, NSUInteger idx, BOOL * _Nonnull stop) {
        NSLog(@"path: %@", path);
    }];
    
    return contents.count;
}
@end
