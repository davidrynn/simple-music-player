//
//  DRAlbumTableViewController.m
//  Simple-Music-Player
//
//  Created by David Rynn on 9/9/15.
//  Copyright (c) 2015 David Rynn. All rights reserved.
//

#import "DRAlbumTableViewController.h"

@implementation DRAlbumTableViewController
-(void)viewDidLoad{
    [super viewDidLoad];
    MPMediaItem *representativeItem = self.mediaCollection.representativeItem;
    self.title = [NSString stringWithFormat:@"%@ - %@", representativeItem.albumTitle, representativeItem.artist];

}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    // Configure the cell...
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    MPMediaItem *item = self.songs[indexPath.row];
    cell.textLabel.text = [NSString stringWithFormat:@"%@",item.title];
    cell.imageView.image = [item.artwork imageWithSize:CGSizeMake(60.0f, 60.0f)];
    
    return cell;


}
@end
