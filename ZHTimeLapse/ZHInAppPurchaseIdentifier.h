//
//  ZHInAppPurchaseIdentifier.h
//  STKTest
//
//  Created by Zakk Hoyt on 10/22/13.
//  Copyright (c) 2013 Zakk Hoyt. All rights reserved.
//
#import "ZHInAppPurchase.h"
#import <StoreKit/StoreKit.h>


static NSString *ZHInAppPurchaseRemoveWatermarkKey = @"com.vaporwarewolf.ZHTimeLapse.removeWatermark";

@interface ZHInAppPurchaseIdentifier : ZHInAppPurchase
+ (ZHInAppPurchaseIdentifier *)sharedInstance;
@end