//
//  DRRewindButton.m
//  Simple-Music-Player
//
//  Created by David Rynn on 9/3/15.
//  Copyright (c) 2015 David Rynn. All rights reserved.
//

#import "DRRewindButton.h"

@implementation DRRewindButton
-(void)drawRect:(CGRect)rect{
    
    CGFloat width = rect.size.width/4;
    CGFloat height = rect.size.height/4;
    CGFloat x = rect.size.width/2 - width/2;
    CGFloat y = rect.size.height/2 - height/2;
    CGRect small = CGRectMake(x, y, width, height);
    
    UIBezierPath* bezierPath = [UIBezierPath bezierPath];
    [bezierPath moveToPoint: CGPointMake(CGRectGetMaxX(small), CGRectGetMaxY(small))];
    [bezierPath addLineToPoint: CGPointMake(CGRectGetMaxX(small), CGRectGetMinY(small))];
    
    [bezierPath addLineToPoint: CGPointMake(CGRectGetMaxX(small)/2, CGRectGetMaxY(rect)/2)];
    [bezierPath addLineToPoint: CGPointMake(CGRectGetMaxX(small), CGRectGetMaxY(small))];
    [bezierPath closePath];
    [self.tintColor setFill];
    bezierPath.lineWidth = 1;
    [bezierPath fill];
    
    UIBezierPath* bezierPath2 = [UIBezierPath bezierPath];
    [bezierPath2 moveToPoint: CGPointMake(CGRectGetMaxX(small)/2, CGRectGetMaxY(small))];
    [bezierPath2 addLineToPoint: CGPointMake(CGRectGetMaxX(small)/2, CGRectGetMinY(small))];
    
    [bezierPath2 addLineToPoint: CGPointMake(CGRectGetMinX(small), CGRectGetMaxY(rect)/2)];
    [bezierPath2 addLineToPoint: CGPointMake(CGRectGetMaxX(small)/2, CGRectGetMaxY(small))];
    [bezierPath2 closePath];
    [self.tintColor setFill];
    bezierPath2.lineWidth = 1;
    [bezierPath2 fill];
    
    [self.layer setShadowColor:[[UIColor blackColor] CGColor]];
    self.layer.shadowOpacity = 0.8;
    self.layer.shadowRadius = 1;
    self.layer.shadowOffset = CGSizeMake(1.0f, 1.0f);

}
@end
