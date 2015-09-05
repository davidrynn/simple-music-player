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
    //// Bezier Drawing
    UIBezierPath* bezierPath = [UIBezierPath bezierPath];
    [bezierPath moveToPoint: CGPointMake(CGRectGetMinX(small), CGRectGetMinY(small))];
    [bezierPath addLineToPoint: CGPointMake(CGRectGetMinX(small), CGRectGetMaxY(small))];
    [bezierPath addLineToPoint: CGPointMake(CGRectGetMaxX(small), CGRectGetMaxY(rect)/2)];
    [bezierPath addLineToPoint: CGPointMake(CGRectGetMinX(small), CGRectGetMinY(small))];
    [bezierPath closePath];
    [self.tintColor setFill];
    bezierPath.lineWidth = 1;
    [bezierPath fill];
    
    [self.layer setShadowColor:[[UIColor blackColor] CGColor]];
    self.layer.shadowOpacity = 0.8;
    self.layer.shadowRadius = 1;
    self.layer.shadowOffset = CGSizeMake(1.0f, 1.0f);
    
}
@end
