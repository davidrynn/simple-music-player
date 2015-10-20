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
+(NSArray *)createArrayFromSearchString:(NSString *) searchString FromProperty:(NSString *) MPMediaItemProperty andQuery:(MPMediaQuery *)mediaQuery andGroupingType:(MPMediaGrouping) groupingType;
+(UIImage *)createImageBasedOnEnum: (NSInteger) enumNumber ofTypeString: (NSString *) type;
+(NSDictionary *)returnDictionaryFromQuery: (MPMediaQuery *)query withCategory: (NSString *)category withGroupingType: (MPMediaGrouping) type;
@end
