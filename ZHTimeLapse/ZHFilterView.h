//
//  ZHFilterView.h
//  ZHTimeLapse
//
//  Created by Zakk Hoyt on 12/25/15.
//  Copyright © 2015 Zakk Hoyt. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GPUImage.h"

@interface ZHFilterView : UIView
//@property (nonatomic, strong) GPUImageOutput<GPUImageInput> *filter;
-(void)setFilter:(GPUImageOutput<GPUImageInput>*)filter
      filterName:(NSString*)filterName
     videoCamera:(GPUImageVideoCamera*)videoCamera;

-(GPUImageOutput<GPUImageInput>*)filter;
@end
