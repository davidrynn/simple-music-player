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
