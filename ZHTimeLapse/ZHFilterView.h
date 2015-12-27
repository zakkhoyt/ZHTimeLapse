//
//  ZHFilterView.h
//  ZHTimeLapse
//
//  Created by Zakk Hoyt on 12/25/15.
//  Copyright © 2015 Zakk Hoyt. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ZHSession.h"

@interface ZHFilterView : UIView

-(void)setFilter:(ZHFilter*)filter
     videoCamera:(GPUImageVideoCamera*)videoCamera;

-(ZHFilter*)filter;

@end
