//
//  DRFirstViewController.h
//  Simple-Music-Player
//
//  Created by David Rynn on 9/3/15.
//  Copyright (c) 2015 David Rynn. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GVMusicPlayerController.h"
@protocol DRPopSaysPlayMusicDelegate;//forward declaration
@protocol DRPushUpScrollViewDelegate;//forward declaration

@interface DRFirstViewController : UIViewController
@property (nonatomic, weak) id<DRPopSaysPlayMusicDelegate> delegate;
@property (nonatomic, weak) id<DRPushUpScrollViewDelegate> delegate2;
@property (weak, nonatomic) IBOutlet UIView *viewContainer;

@end
@protocol DRPopSaysPlayMusicDelegate <NSObject>

-(void)playOrPauseMusic;
-(void)performSegueForDadWithCollection:(MPMediaItemCollection *) collection andIdentifier:(NSString *) identifier;
@end

@protocol DRPushUpScrollViewDelegate <NSObject>
-(void)pushUpScrollViewOnPlay;
@end
