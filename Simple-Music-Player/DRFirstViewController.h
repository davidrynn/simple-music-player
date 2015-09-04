//
//  DRFirstViewController.h
//  Simple-Music-Player
//
//  Created by David Rynn on 9/3/15.
//  Copyright (c) 2015 David Rynn. All rights reserved.
//

#import <UIKit/UIKit.h>
@import MediaPlayer;

@protocol RootViewDelegate <NSObject>

-(MPMediaItem *)sendRVCNowPlayingSong: (MPMediaItem *)song;

@end
@interface DRFirstViewController : UIViewController

@end
