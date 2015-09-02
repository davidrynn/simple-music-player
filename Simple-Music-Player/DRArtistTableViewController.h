//
//  DRArtistTableViewController.h
//  Simple-Music-Player
//
//  Created by David Rynn on 8/31/15.
//  Copyright (c) 2015 David Rynn. All rights reserved.
//

#import <UIKit/UIKit.h>
@import MediaPlayer;

@interface DRArtistTableViewController : UITableViewController
@property (nonatomic, strong) MPMediaItemCollection *mediaCollection;
@end
