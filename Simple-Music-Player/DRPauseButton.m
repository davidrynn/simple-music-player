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
    
    CGFloat width = rect.size.width/4;
    CGFloat height = rect.size.height/4;
    CGFloat x = rect.size.width/2 - width/2;
    CGFloat y = rect.size.height/2 - height/2;
    CGRect small = CGRectMake(x, y, width, height);
    
    //// Rectangle Drawing
    UIBezierPath* rectanglePath = [UIBezierPath bezierPathWithRect: CGRectMake(CGRectGetMidX(small) - (small.size.width/4), CGRectGetMinY(small), small.size.width/4, small.size.height)];
        [self.tintColor setFill];
    [rectanglePath fill];
    
    
    //// Rectangle 2 Drawing
    UIBezierPath* rectangle2Path = [UIBezierPath bezierPathWithRect: CGRectMake(CGRectGetMidX(small) + (small.size.width/4), CGRectGetMinY(small), small.size.width/4, small.size.height)];
        [self.tintColor setFill];
    [rectangle2Path fill];
    
    CGRect circleRect = CGRectMake(rect.size.width*0.05, rect.size.height*0.05, rect.size.width*0.9, rect.size.height*0.9);

    
    // draw circle
    UIBezierPath* circle = [UIBezierPath bezierPathWithOvalInRect:circleRect];
    [self.tintColor setStroke];
    circle.lineWidth = 1;
    [circle stroke];
    
    [self.layer setShadowColor:[[UIColor blackColor] CGColor]];
    self.layer.shadowOpacity = 0.8;
    self.layer.shadowRadius = 1;
    self.layer.shadowOffset = CGSizeMake(1.0f, 1.0f);
    
}
@end
