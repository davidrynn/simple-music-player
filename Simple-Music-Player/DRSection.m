//
//  DRSection.m
//  Simple-Music-Player
//
//  Created by David Rynn on 9/10/15.
//  Copyright (c) 2015 David Rynn. All rights reserved.
//

#import "DRSection.h"

@implementation DRSection
-(instancetype)init
{
    return [self initWithRange:NSMakeRange(0, 0) andTitle:@""];
}

-(instancetype)initWithRange:(NSRange)range andTitle:(NSString *)title{
    
    self = [super init];
    if (self) {
        // Any custom setup work goes here
        _range = range;
        _title = title;
    }
    
    return self;
}
@end
