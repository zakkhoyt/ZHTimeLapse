//
//  ZHInAppPurchaseIdentifier.m
//  STKTest
//
//  Created by Zakk Hoyt on 10/22/13.
//  Copyright (c) 2013 Zakk Hoyt. All rights reserved.
//
//  A good tutorial on IAP here: http://www.raywenderlich.com/21081/introduction-to-in-app-purchases-in-ios-6-tutorial

#import "ZHInAppPurchaseIdentifier.h"


@implementation ZHInAppPurchaseIdentifier

+ (ZHInAppPurchaseIdentifier *)sharedInstance {
    static dispatch_once_t once;
    static ZHInAppPurchaseIdentifier * sharedInstance;
    dispatch_once(&once, ^{
        NSSet *productIdentifiers = [NSMutableSet setWithObjects:
                                     ZHInAppPurchaseRemoveWatermarkKey,
                                     nil];
        sharedInstance = [[self alloc] initWithProductIdentifiers:productIdentifiers];
    });
    return sharedInstance;
}
@end