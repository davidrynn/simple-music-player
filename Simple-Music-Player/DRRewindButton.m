//
//  DRRewindButton.m
//  Simple-Music-Player
//
//  Created by David Rynn on 9/3/15.
//  Copyright (c) 2015 David Rynn. All rights reserved.
//

#import "DRRewindButton.h"
IB_DESIGNABLE
@implementation DRRewindButton
-(void)drawRect:(CGRect)rect{
    
    UIBezierPath* bezierPath = [UIBezierPath bezierPath];
    [bezierPath moveToPoint: CGPointMake(CGRectGetMaxX(rect), CGRectGetMaxY(rect))];
    [bezierPath addLineToPoint: CGPointMake(CGRectGetMaxX(rect), CGRectGetMinY(rect))];
    
    [bezierPath addLineToPoint: CGPointMake(CGRectGetMaxX(rect)/2, CGRectGetMaxY(rect)/2)];
    [bezierPath addLineToPoint: CGPointMake(CGRectGetMaxX(rect), CGRectGetMaxY(rect))];
    [bezierPath closePath];
    [[UIColor colorWithRed:0.988 green:0.373 blue:0.361 alpha:1.0] setFill];
    bezierPath.lineWidth = 1;
    [bezierPath fill];
    
    UIBezierPath* bezierPath2 = [UIBezierPath bezierPath];
    [bezierPath2 moveToPoint: CGPointMake(CGRectGetMaxX(rect)/2, CGRectGetMaxY(rect))];
    [bezierPath2 addLineToPoint: CGPointMake(CGRectGetMaxX(rect)/2, CGRectGetMinY(rect))];
    
    [bezierPath2 addLineToPoint: CGPointMake(CGRectGetMinX(rect), CGRectGetMaxY(rect)/2)];
    [bezierPath2 addLineToPoint: CGPointMake(CGRectGetMaxX(rect)/2, CGRectGetMaxY(rect))];
    [bezierPath2 closePath];
    [[UIColor colorWithRed:0.988 green:0.373 blue:0.361 alpha:1.0] setFill];
    bezierPath2.lineWidth = 1;
    [bezierPath2 fill];
    
    [self.layer setShadowColor:[[UIColor blackColor] CGColor]];
    self.layer.shadowOpacity = 0.8;
    self.layer.shadowRadius = 1;
    self.layer.shadowOffset = CGSizeMake(1.0f, 1.0f);

}
@end
