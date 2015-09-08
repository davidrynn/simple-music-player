//
//  DRSlider.m
//  Simple-Music-Player
//
//  Created by David Rynn on 9/8/15.
//  Copyright (c) 2015 David Rynn. All rights reserved.
//

#import "DRSlider.h"

@implementation DRSlider
-(CGRect)trackRectForBounds:(CGRect)bounds{
    CGRect rect = CGRectMake(0, 0, bounds.size.width, bounds.size.height/3);
    
    return rect;
}


@end
