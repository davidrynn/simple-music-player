//
//  DRPauseButton.m
//  Simple-Music-Player
//
//  Created by David Rynn on 9/3/15.
//  Copyright (c) 2015 David Rynn. All rights reserved.
//

#import "DRPauseButton.h"


@implementation DRPauseButton

-(void)drawRect:(CGRect)rect{
    
    //// Rectangle Drawing
    UIBezierPath* rectanglePath = [UIBezierPath bezierPathWithRect: CGRectMake(CGRectGetMaxX(rect)/3 -rect.size.width/5, CGRectGetMinY(rect), rect.size.width/5, rect.size.height)];
        [[UIColor colorWithRed:0.988 green:0.373 blue:0.361 alpha:1.0] setFill];
    [rectanglePath fill];
    
    
    //// Rectangle 2 Drawing
    UIBezierPath* rectangle2Path = [UIBezierPath bezierPathWithRect: CGRectMake(CGRectGetMaxX(rect)/3 + rect.size.width/5, CGRectGetMinY(rect), rect.size.width/5, rect.size.height)];
        [[UIColor colorWithRed:0.988 green:0.373 blue:0.361 alpha:1.0] setFill];
    [rectangle2Path fill];
    
    [self.layer setShadowColor:[[UIColor blackColor] CGColor]];
    self.layer.shadowOpacity = 0.8;
    self.layer.shadowRadius = 1;
    self.layer.shadowOffset = CGSizeMake(1.0f, 1.0f);
    
}
@end
