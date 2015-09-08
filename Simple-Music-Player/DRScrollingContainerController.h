//
//  DRScrollingContainerController.h
//  Simple-Music-Player
//
//  Created by David Rynn on 9/8/15.
//  Copyright (c) 2015 David Rynn. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol DRSliderDelegate; //forward declaration

@interface DRScrollingContainerController : UIViewController
@property (nonatomic, weak) id<DRSliderDelegate> delegate;
@end
@protocol DRSliderDelegate <NSObject>

-(void)changeTrackTime;

@end