//
//  DRPlayerUtility.m
//  Simple-Music-Player
//
//  Created by David Rynn on 9/7/15.
//  Copyright (c) 2015 David Rynn. All rights reserved.
//

#import "DRPlayerUtility.h"

@implementation DRPlayerUtility
+(void)filterOutCloudItemsFromQuery: (MPMediaQuery *) query{
    
    [query addFilterPredicate:[MPMediaPropertyPredicate predicateWithValue:[NSNumber numberWithBool:NO] forProperty:MPMediaItemPropertyIsCloudItem]];
}
@end
