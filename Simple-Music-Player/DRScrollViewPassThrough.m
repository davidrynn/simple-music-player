//
//  DRScrollViewPassThrough.m
//  Simple-Music-Player
//
//  Created by David Rynn on 9/2/15.
//  Copyright (c) 2015 David Rynn. All rights reserved.
//

#import "DRScrollViewPassThrough.h"

@implementation DRScrollViewPassThrough

- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event {
    
    for (UIView *subview in self.subviews) {
        CGPoint relativePoint = [subview convertPoint:point fromView:self];
        
        if ([subview pointInside:relativePoint withEvent:event]) {
            return YES;
        }
    }
    return NO;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
