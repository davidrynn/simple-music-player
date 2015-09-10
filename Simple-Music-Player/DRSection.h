//
//  DRSection.h
//  Simple-Music-Player
//
//  Created by David Rynn on 9/10/15.
//  Copyright (c) 2015 David Rynn. All rights reserved.
//
// custom class emulating MPMediaQuerySection
// allows setting
#import <Foundation/Foundation.h>

@interface DRSection : NSObject
@property (nonatomic, assign) NSRange range;
@property (nonatomic, strong) NSString *title;

-(instancetype)init;
-(instancetype)initWithRange: (NSRange) range andTitle: (NSString *) title;
@end
