//
//  DRMediaTableViewController.h
//  Simple-Music-Player
//
//  Created by David Rynn on 9/1/15.
//  Copyright (c) 2015 David Rynn. All rights reserved.
//

#import <UIKit/UIKit.h>

@import MediaPlayer;
@interface DRMediaTableViewController : UITableViewController
@property (nonatomic, strong) MPMediaItemCollection *mediaCollection;
@property (nonatomic, strong) NSArray *songs;


@end
