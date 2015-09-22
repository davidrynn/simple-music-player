//
//  DRPlayerUtility.h
//  Simple-Music-Player
//
//  Created by David Rynn on 9/7/15.
//  Copyright (c) 2015 David Rynn. All rights reserved.
//

#import <Foundation/Foundation.h>
@import MediaPlayer;

@interface DRPlayerUtility : NSObject
+(void)filterOutCloudItemsFromQuery: (MPMediaQuery *) query;
@end
