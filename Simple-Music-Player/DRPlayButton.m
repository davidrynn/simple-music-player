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
    CGFloat width = rect.size.width/4;
    CGFloat height = rect.size.height/4;
    CGFloat x = rect.size.width/2 - width/2;
    CGFloat y = rect.size.height/2 - height/2;
    CGRect small = CGRectMake(x, y, width, height);
    
    CGRect circleRect = CGRectMake(rect.size.width*0.05, rect.size.height*0.05, rect.size.width*0.9, rect.size.height*0.9);
    //circle
    UIBezierPath* circle = [UIBezierPath bezierPathWithOvalInRect:circleRect];
    [self.tintColor setStroke];
    circle.lineWidth = 1;
    [circle stroke];

    
    //// Bezier Drawing
    UIBezierPath* bezierPath = [UIBezierPath bezierPath];
    [bezierPath moveToPoint: CGPointMake(CGRectGetMinX(small) + small.size.width/4, CGRectGetMinY(small))];
    [bezierPath addLineToPoint: CGPointMake(CGRectGetMinX(small) + small.size.width/4, CGRectGetMaxY(small))];
    [bezierPath addLineToPoint: CGPointMake(CGRectGetMaxX(small), CGRectGetMidY(rect))];
    [bezierPath closePath];
    [self.tintColor setFill];
    bezierPath.lineWidth = 1;
    [bezierPath fill];
    
}
@end
