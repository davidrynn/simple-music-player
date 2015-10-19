//
//  DRScrollDownButton.m
//  Simple-Music-Player
//
//  Created by David Rynn on 10/14/15.
//  Copyright © 2015 David Rynn. All rights reserved.
//

#import "DRScrollDownButton.h"

@implementation DRScrollDownButton
-(void)drawRect:(CGRect)rect{
    {
        CGFloat width = rect.size.width/2;
        CGFloat height = rect.size.height/2;
        CGFloat x = rect.size.width/4;
        CGFloat y = rect.size.height/4;
        CGRect small = CGRectMake(x, y, width, height);
        
        CGRect circleRect = CGRectMake(rect.size.width*0.05, rect.size.height*0.05, rect.size.width*0.9, rect.size.height*0.9);
        //circle
        UIBezierPath* circle = [UIBezierPath bezierPathWithOvalInRect:circleRect];
        [[UIColor whiteColor] setFill];
        circle.lineWidth = 1;
        [circle fill];
        
        
        //// Bezier Drawing
        UIBezierPath* bezierPath = [UIBezierPath bezierPath];
        [bezierPath moveToPoint: CGPointMake(CGRectGetMinX(small), CGRectGetMidY(small)-height/4)];
        [bezierPath addLineToPoint: CGPointMake(CGRectGetMidX(small), CGRectGetMaxY(small) -height/4)];
        [bezierPath addLineToPoint: CGPointMake(CGRectGetMaxX(small), CGRectGetMidY(small)-height/4)];
        [self.tintColor setStroke];
        bezierPath.lineWidth = 2;
        [bezierPath stroke];
        

        
    }
    
}
@end
