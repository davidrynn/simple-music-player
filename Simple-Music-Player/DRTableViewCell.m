//
//  DRTableViewCell.m
//  Simple-Music-Player
//
//  Created by David Rynn on 9/1/15.
//  Copyright (c) 2015 David Rynn. All rights reserved.
//

#import "DRTableViewCell.h"

@implementation DRTableViewCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    CGFloat multiplier = 0.85;
    self.imageView.frame = CGRectMake(self.imageView.frame.origin.x, (self.frame.size.height-self.frame.size.height*multiplier)/2, self.imageView.frame.size.width*multiplier, self.imageView.frame.size.height*multiplier);
}
@end
