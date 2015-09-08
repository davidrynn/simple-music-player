//
//  DRScrollingContainerController.m
//  Simple-Music-Player
//
//  Created by David Rynn on 9/8/15.
//  Copyright (c) 2015 David Rynn. All rights reserved.
//

#import "DRScrollingContainerController.h"


@interface DRScrollingContainerController()

@property (weak, nonatomic) IBOutlet UISlider *slider;


@end

@implementation DRScrollingContainerController

-(void)viewDidLoad{
    UIImage *image = [self drawThumbRect];
    [self.slider setThumbImage:image forState:UIControlStateNormal];
}
-(void)viewWillAppear:(BOOL)animated{


}

-(UIImage*) drawThumbRect {
    
    CGRect sliderRect = self.slider.bounds;
    CGRect rect = CGRectMake(sliderRect.origin.x, sliderRect.origin.y, sliderRect.size.height/2, sliderRect.size.height);

    
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    [[UIColor whiteColor] setFill];
    [self.view.tintColor setStroke];
    UIBezierPath *path = [UIBezierPath bezierPathWithRect:rect];
    [path fill];
    [path stroke];
    
    
    CGContextAddPath(context, path.CGPath);
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}
@end
