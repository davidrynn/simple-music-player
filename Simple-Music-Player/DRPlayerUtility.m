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

//for creating search results in sections
+(NSArray *)createArrayFromSearchString:(NSString *) searchString FromProperty:(NSString *) MPMediaItemProperty andQuery:(MPMediaQuery *)mediaQuery andGroupingType:(MPMediaGrouping) groupingType isCollectionTypeItems: (BOOL) isItems {

MPMediaPropertyPredicate *itemPredicate = [MPMediaPropertyPredicate predicateWithValue:searchString forProperty:MPMediaItemProperty comparisonType:MPMediaPredicateComparisonContains];
    
MPMediaQuery *searchQuery = mediaQuery;
[self filterOutCloudItemsFromQuery:searchQuery];
searchQuery.groupingType = groupingType;
[searchQuery addFilterPredicate:itemPredicate];

    if (isItems) {
        return [searchQuery items];
    }
    
    return [searchQuery collections];
}
@end
