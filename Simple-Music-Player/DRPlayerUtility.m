//
//  DRPlayerUtility.m
//  Simple-Music-Player
//
//  Created by David Rynn on 9/7/15.
//  Copyright (c) 2015 David Rynn. All rights reserved.
//

#import "DRPlayerUtility.h"
#import "GVMusicPlayerController.h"

@implementation DRPlayerUtility
+(void)filterOutCloudItemsFromQuery: (MPMediaQuery *) query{
    //is this necessary?
    [query addFilterPredicate:[MPMediaPropertyPredicate predicateWithValue:[NSNumber numberWithBool:NO] forProperty:MPMediaItemPropertyIsCloudItem]];
}

//for creating search results in sections
+(NSArray *)createArrayFromSearchString:(NSString *) searchString FromProperty:(NSString *) MPMediaItemProperty andQuery:(MPMediaQuery *)mediaQuery andGroupingType:(MPMediaGrouping) groupingType {
    
    MPMediaPropertyPredicate *itemPredicate = [MPMediaPropertyPredicate predicateWithValue:searchString forProperty:MPMediaItemProperty comparisonType:MPMediaPredicateComparisonContains];
    
    MPMediaQuery *searchQuery = mediaQuery;
    [self filterOutCloudItemsFromQuery:searchQuery];
    searchQuery.groupingType = groupingType;
    [searchQuery addFilterPredicate:itemPredicate];
    
    if (groupingType == MPMediaGroupingTitle) {
        return [searchQuery items];
    }
    
    return [searchQuery collections];
}

+(UIImage *)createImageBasedOnEnum: (NSInteger) enumNumber ofTypeString: (NSString *) type{
//    if (enumNumber || type == nil) {
//        return [UIImage imageNamed:@"shuffle0"];
//    }
    NSString *name = [NSString stringWithFormat:@"%@%ld", type, (long)enumNumber];
    UIImage *buttonImage = [UIImage imageNamed:name];
    return buttonImage;
}

+(NSArray *) setupBarButtonImages{
    GVMusicPlayerController *musicPlayer = [GVMusicPlayerController sharedInstance];
    //setup shuffle and loop buttons
    UIImage *loopImage = [self createImageBasedOnEnum: musicPlayer.repeatMode ofTypeString: @"loop"];
    
    UIBarButtonItem *loopButton = [[UIBarButtonItem alloc] initWithImage:loopImage style:UIBarButtonItemStylePlain target:self action:@selector(loopButtonTapped:)];
    
    UIImage *shuffleImage = [self createImageBasedOnEnum: musicPlayer.shuffleMode ofTypeString:@"shuffle"];

    UIBarButtonItem *shuffleButton = nil;
//    if ([self respondsToSelector:@selector(shuffleButtonTapped:)]) {
        shuffleButton = [[UIBarButtonItem alloc] initWithImage:shuffleImage style:UIBarButtonItemStylePlain target:self action:@selector(shuffleButtonTapped:)];
//    }

    UIBarButtonItem *sortButton = [[UIBarButtonItem alloc] initWithTitle:@"◦Songs" style:UIBarButtonItemStylePlain target:self action:@selector(sortTapped:)];
    
    UIBarButtonItem *flexibleSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:nil];
    NSArray *buttonArray = @[shuffleButton, flexibleSpace, sortButton, flexibleSpace, loopButton];
    
    return buttonArray;
}



+(NSDictionary *)returnDictionaryFromQuery: (MPMediaQuery *)query withCategory: (NSString *)category withGroupingType: (MPMediaGrouping) type {
    NSDictionary *mediaItemDictionary;
    
    //If there are songs:
    if (query.collections.count>0 || query.items.count > 0){
        
        [self filterOutCloudItemsFromQuery:query];
        query.groupingType = type;
        NSArray *mediaArray;
        if (query.groupingType == MPMediaGroupingTitle) {
            mediaArray = query.items;
        }
        else {
            mediaArray = query.collections;
        }
        mediaItemDictionary = @{@"category":category,
                                @"array":mediaArray,
                                @"sections": query.collectionSections
                                };
    }
    //if no songs
    else {
        
        mediaItemDictionary = @{@"category":category,
                                @"array":@[],
                                @"sections":@[],
                                };
    }
    
    return mediaItemDictionary;
}
@end
