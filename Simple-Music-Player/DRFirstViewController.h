//
//  DRFirstViewController.h
//  Simple-Music-Player
//
//  Created by David Rynn on 9/3/15.
//  Copyright (c) 2015 David Rynn. All rights reserved.
//

#import <UIKit/UIKit.h>
@import MediaPlayer;
@protocol DRPopSaysPlayMusicDelegate;//forward declaration


@interface DRFirstViewController : UIViewController
@property (nonatomic, weak) id<DRPopSaysPlayMusicDelegate> delegate;

@end
@protocol DRPopSaysPlayMusicDelegate <NSObject>

-(void)playOrPauseMusic;
-(void)performSegueForDadWithCollection:(MPMediaItemCollection *) collection andIdentifier:(NSString *) identifier;


@end
