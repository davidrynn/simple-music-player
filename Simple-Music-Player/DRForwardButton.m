//
//  DRForwardButton.m
//  Simple-Music-Player
//
//  Created by David Rynn on 9/3/15.
//  Copyright (c) 2015 David Rynn. All rights reserved.
//

#import "DRForwardButton.h"

@implementation DRForwardButton
-(void)drawRect:(CGRect)rect{
    
    CGFloat width = rect.size.width/4;
    CGFloat height = rect.size.height/4;
    CGFloat x = rect.size.width/2 - width/2;
    CGFloat y = rect.size.height/2 - height/2;
    CGRect small = CGRectMake(x, y, width, height);
    
    UIBezierPath* bezierPath = [UIBezierPath bezierPath];
    [bezierPath moveToPoint: CGPointMake(CGRectGetMinX(small), CGRectGetMinY(small))];
    [bezierPath addLineToPoint: CGPointMake(CGRectGetMinX(small), CGRectGetMaxY(small))];
    [bezierPath addLineToPoint: CGPointMake(CGRectGetMidX(small), CGRectGetMidY(small))];

    [bezierPath closePath];
    [self.tintColor setFill];
    bezierPath.lineWidth = 1;
    [bezierPath fill];
    
    UIBezierPath* bezierPath2 = [UIBezierPath bezierPath];
    [bezierPath2 moveToPoint: CGPointMake(CGRectGetMidX(small), CGRectGetMinY(small))];
    [bezierPath2 addLineToPoint: CGPointMake(CGRectGetMidX(small), CGRectGetMaxY(small))];
    [bezierPath2 addLineToPoint: CGPointMake(CGRectGetMaxX(small), CGRectGetMidY(small))];
    [bezierPath2 closePath];
    [self.tintColor setFill];
    bezierPath2.lineWidth = 1;
    [bezierPath2 fill];
    

}

@end
