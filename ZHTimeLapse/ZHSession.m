//
//  ZHSession.m
//  ZHTimeLapse
//
//  Created by Zakk Hoyt on 12/21/15.
//  Copyright © 2015 Zakk Hoyt. All rights reserved.
//

#import "ZHSession.h"
#import "ZHDefines.h"
#import "ZHFileManager.h"
#import "NSDate+ZH.h"
#import "MBProgressHUD.h"
#import "ZHRenderer.h"
#import "UIViewController+AlertController.h"

@implementation ZHSession

+(ZHSession*)session{
    ZHSession *session = [[ZHSession alloc]initWithName:nil];
    return session;
}

+(ZHSession*)sessionFromSession:(ZHSession*)oldSession{
    ZHSession *session = [[ZHSession alloc]initWithName:nil];
    session.input = [oldSession.input copy];
    session.output = [oldSession.output copy];
    [session setProjectPath];
    return session;
}

+(ZHSession*)sessionWithName:(NSString*)name{
    ZHSession *session = [[ZHSession alloc]initWithName:name];
    return session;
}

- (instancetype)initWithName:(NSString*)name {
    self = [super init];
    if (self) {
        _name = name;
        _uuid = [[NSUUID UUID] UUIDString];
        _date = [NSDate date];
        
        _input = [ZHInputSession new];
        _output = [ZHOutputSession new];
    
        [self setProjectPath];
    }
    return self;
}


- (instancetype)initWithDictionary:(NSDictionary*)dictionary {
    self = [super init];
    if(self) {
        _name = dictionary[@"name"];
        _uuid = dictionary[@"uuid"];
        
        NSString *dateString = dictionary[@"date"];
        _date = [NSDate dateFromJSONString:dateString];
        
        NSDictionary *inputDictionary = dictionary[@"input"];
        _input = [[ZHInputSession alloc]initWithDictionary:inputDictionary];
        
        NSDictionary *outputDictionary = dictionary[@"output"];
        _output = [[ZHOutputSession alloc]initWithDictionary:outputDictionary];
        
        [self setProjectPath];
    }
    return self;
}

-(NSDictionary*)dictionaryRepresentation {
    NSMutableDictionary *dictionary = [@{}mutableCopy];
    
    if(_name){
        dictionary[@"name"] = _name;
    }
    
    if(_uuid){
        dictionary[@"uuid"] = _uuid;
    }

    if(_date){
        dictionary[@"date"] = [_date jsonStringForDate];
    }
    
    if(_input.dictionaryRepresentation) {
        dictionary[@"input"] = _input.dictionaryRepresentation;
    }

    if(_output.dictionaryRepresentation) {
        dictionary[@"output"] = _output.dictionaryRepresentation;
    }

    return dictionary;
}

-(void)setProjectPath {
    NSString *docsPath = [ZHFileManager pathForDocumentsDirectory];
    _projectPath = [docsPath stringByAppendingPathComponent:_uuid];
    [ZHFileManager ensureDirectoryExistsAtPath:_projectPath];
    
    NSString *videoPath = [_projectPath stringByAppendingPathComponent:@"output.mov"];
    _output.outputURL = [NSURL fileURLWithPath:videoPath];
    
    NSString *gifPath = [_projectPath stringByAppendingPathComponent:@"output.gif"];
    _output.outputGIF = [NSURL fileURLWithPath:gifPath];

}

-(NSString*)buildAndVersionString{
    NSBundle* bundle = [NSBundle mainBundle];
    NSString* appVersion = [bundle objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
    NSString* appBuild = [bundle objectForInfoDictionaryKey:(NSString *)kCFBundleVersionKey];
    return [NSString stringWithFormat:@"v%@ b%@", appVersion, appBuild];
}
-(NSString*)executableString{
    NSBundle* bundle = [NSBundle mainBundle];
//    NSString *executable = [bundle objectForInfoDictionaryKey:(NSString *)CFBundleName];
    NSString *executable = [bundle objectForInfoDictionaryKey:@"CFBundleName"];
    
    return executable;
}


-(NSString*)createdByString{
    switch (self.output.outputType) {
        case ZHOutputSessionOutputTypeVideo:
            return [NSString stringWithFormat:@"Video created by %@ %@", [self executableString], [self buildAndVersionString]];
        case ZHOutputSessionOutputTypeGIF:
            return [NSString stringWithFormat:@"GIF created by %@ %@", [self executableString], [self buildAndVersionString]];
        default:
            return [NSString stringWithFormat:@"Created by %@ %@", [self executableString], [self buildAndVersionString]];
            break;
    }
}

-(void)saveConfig{
    // Writes session.json
    NSDictionary *dict = [self dictionaryRepresentation];
    NSError *error = nil;
    NSData *data = [NSJSONSerialization dataWithJSONObject:dict options:NSJSONWritingPrettyPrinted error:&error];
    NSString *path = [_projectPath stringByAppendingPathComponent:@"session.json"];
    [data writeToFile:path atomically:NO];
}

-(void)cacheImage:(UIImage*)image index:(NSUInteger)index {
    NSData *data = UIImagePNGRepresentation(image);
    NSString *fileName = [NSString stringWithFormat:@"%05lu.png", (unsigned long)index];
    NSString *filePath = [_projectPath stringByAppendingPathComponent:@"frames"];
    filePath = [filePath stringByAppendingPathComponent:fileName];
//    NSLog(@"Writing frame to: %@", filePath);

    if([data writeToFile:filePath atomically:NO] == NO){
        NSLog(@"Error writing frame: %@", filePath);
    }

}


-(UIImage*)imageForIndex:(NSUInteger)index{
    NSString *fileName = [NSString stringWithFormat:@"%05lu.png", (unsigned long)index];
    NSString *filePath = [_projectPath stringByAppendingPathComponent:@"frames"];
    filePath = [filePath stringByAppendingPathComponent:fileName];
    UIImage *image = [UIImage imageWithContentsOfFile:filePath];
    return image;
}



-(void)listFrames{
    
}


-(BOOL)isEqual:(id)object {
    if([object isKindOfClass:[ZHSession class]] == NO) {
        return NO;
    }
    
    ZHSession *otherSession = object;
    return otherSession.hash == self.hash;
}

-(NSUInteger)hash {
    return _uuid.hash;
}

-(NSTimeInterval)timeLength{
    NSTimeInterval length = 1/(double)self.output.frameRate;
    length *= self.input.frameCount;
    return length;
}




-(void)renderVideoFromViewController:(UIViewController*)viewController completionBlock:(ZHSessionBoolBlock)completionBlock {
    // Show hud with progress ring
    MBProgressHUD *hud = [[MBProgressHUD alloc] initWithView:viewController.view];
    [viewController.view addSubview:hud];
    hud.mode = MBProgressHUDModeAnnularDeterminate;
    hud.labelText = @"Rendering video";
    [hud show:YES];
    
    // A counter to update our ring
    NSUInteger frameCount = self.input.frameCount;
    NSLog(@"%lu frames", (unsigned long) frameCount);
    
    ZHRenderer *renderer = [[ZHRenderer alloc]init];
    [renderer renderSessionToVideo:self progressBlock:^(NSUInteger framesRendered, NSUInteger totalFrames) {
        // Update the HUD ring
        NSLog(@"rendered video frame %lu/%lu", (unsigned long)framesRendered, (unsigned long)frameCount);
        hud.progress = framesRendered / (float)frameCount;
    } completionBlock:^(BOOL success, ZHSession *session) {
        NSLog(@"rendering finished");
        if(success == YES) {
            // Switch from progress ring to checkbox
            UIImage *image = [UIImage imageNamed:@"37x-Checkmark.png"];
            UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
            hud.customView = imageView;
            hud.mode = MBProgressHUDModeCustomView;
            hud.labelText = @"Exported to Camera Roll";
            
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [hud hide:YES];
                if(completionBlock) {
                    completionBlock(YES);
                }
            });
            NSLog(@"TODO: Cleanup");
        } else {
            [hud hide:YES];
            [viewController presentAlertDialogWithMessage:@"Failed"];
            if(completionBlock) {
                completionBlock(NO);
            }
        }
    }];
}

-(void)renderGIFFromViewController:(UIViewController*)viewController completionBlock:(ZHSessionBoolDataBlock)completionBlock{
    MBProgressHUD *hud = [[MBProgressHUD alloc] initWithView:viewController.view];
    [viewController.view addSubview:hud];
    hud.mode = MBProgressHUDModeAnnularDeterminate;
    hud.labelText = @"Rendering gif";
    [hud show:YES];
    
    NSUInteger frameCount = self.input.frameCount;
    NSLog(@"%lu frames", (unsigned long) frameCount);
    
    ZHRenderer *renderer = [[ZHRenderer alloc]init];
    [renderer renderSessionToGIF:self progressBlock:^(NSUInteger framesRendered, NSUInteger totalFrames) {
        NSLog(@"rendered gif frame %lu/%lu", (unsigned long)framesRendered, (unsigned long)frameCount);
        hud.progress = framesRendered / (float)frameCount;
    } completionBlock:^(BOOL success, ZHSession *session) {
        NSLog(@"completed");
        if(success == YES) {
            [hud hide:YES];
            NSData *data = [NSData dataWithContentsOfFile:self.output.outputGIF.path];
            if(completionBlock) {
                completionBlock(YES, data);
            }
        } else {
            [hud hide:YES];
            [viewController presentAlertDialogWithMessage:@"Failed"];
            if(completionBlock) {
                completionBlock(NO, nil);
            }
        }
    }];
}

-(void)deleteSessionCache {
    
}


@end
