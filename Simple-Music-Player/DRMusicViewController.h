//
//  DRMusicViewController.h
//  Simple-Music-Player
//
//  Created by David Rynn on 8/1/15.
//  Copyright (c) 2015 David Rynn. All rights reserved.
//



#import <UIKit/UIKit.h>
@import MediaPlayer;


typedef NS_OPTIONS(NSUInteger, MediaType) {
    MediaTypeSong       = 0,
    MediaTypeArtist     = 1 << 0,
    MediaTypeAlbum      = 1 << 1,
    MediaTypeGenres     = 1 << 2,
    MediaTypePlaylists  = 1 << 3,
    MediaTypeSearch     = 1 << 4
};
@interface DRMusicViewController : UIViewController



@end

