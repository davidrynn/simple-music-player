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

+(UIImage *)createImageBasedOnEnum: (NSInteger) enumNumber ofTypeString: (NSString *) type{

    NSString *name = [NSString stringWithFormat:@"%@%ld", type, (long)enumNumber];
    UIImage *buttonImage = [UIImage imageNamed:name];
    NSLog(@"Button produced: %@%ld", type, (long)enumNumber);
    return buttonImage;
}


//+(NSDictionary *)returnDictionaryFromCategory: (NSString *) category{
//        NSDictionary *mediaItemDictionary;
//    NSString *categoryLwrCase = [category lowercaseString];
//    NSString *queryString = [NSString stringWithFormat:@"%@query", categoryLwrCase];
//    MPMediaQuery *query = [MPMediaQuery queryString];
//
//    return mediaItemDictionary;
//}


+(NSDictionary *)returnDictionaryFromQuery: (MPMediaQuery *)query withCategory: (NSString *)category withGroupingType: (MPMediaGrouping) type isCollectionTypeItems:(BOOL) isItems{
    NSDictionary *mediaItemDictionary;
    
    //If there are songs:
    if (query.collections.count>0 || query.items.count > 0){
        
    [self filterOutCloudItemsFromQuery:query];
    query.groupingType = type;
        NSArray *mediaArray;
        if (isItems) {
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
