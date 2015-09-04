//
//  DRPausePlayButton.m
//  Simple-Music-Player
//
//  Created by David Rynn on 9/3/15.
//  Copyright (c) 2015 David Rynn. All rights reserved.
//

#import "DRPlayButton.h"

@implementation DRPlayButton
-(void)drawRect:(CGRect)rect
{
    
    //// Bezier Drawing
    UIBezierPath* bezierPath = [UIBezierPath bezierPath];
    [bezierPath moveToPoint: CGPointMake(CGRectGetMinX(rect), CGRectGetMinY(rect))];
    [bezierPath addLineToPoint: CGPointMake(CGRectGetMinX(rect), CGRectGetMaxY(rect))];
    [bezierPath addLineToPoint: CGPointMake(CGRectGetMaxX(rect), CGRectGetMaxY(rect)/2)];
    [bezierPath addLineToPoint: CGPointMake(CGRectGetMinX(rect), CGRectGetMinY(rect))];
    [bezierPath closePath];
    [[UIColor colorWithRed:0.988 green:0.373 blue:0.361 alpha:1.0] setFill];
    bezierPath.lineWidth = 1;
    [bezierPath fill];
    
    [self.layer setShadowColor:[[UIColor blackColor] CGColor]];
    self.layer.shadowOpacity = 0.8;
    self.layer.shadowRadius = 1;
    self.layer.shadowOffset = CGSizeMake(1.0f, 1.0f);
    
}
@end
