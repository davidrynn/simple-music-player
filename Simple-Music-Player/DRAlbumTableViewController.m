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



    

}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    // Configure the cell...
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    MPMediaItem *item = self.songs[indexPath.row];
    cell.textLabel.text = [NSString stringWithFormat:@"%@",item.title];
  //  cell.imageView.image = [item.artwork imageWithSize:CGSizeMake(60.0f, 60.0f)];
    
    return cell;


}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 100.0;
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    MPMediaItem *song = self.mediaCollection.representativeItem;
    CGRect tableViewHeaderFrame = self.tableView.tableHeaderView.frame;
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(tableViewHeaderFrame.origin.x, tableViewHeaderFrame.origin.y, tableViewHeaderFrame.size.width, tableViewHeaderFrame.size.height)];
    UIImageView *albumImageView = [[UIImageView alloc] initWithImage:[song.artwork imageWithSize:CGSizeMake(tableViewHeaderFrame.size.height-10,tableViewHeaderFrame.size.height-10)]];
    [view addSubview:albumImageView];
    UILabel *albumTitle = [[UILabel alloc] initWithFrame:CGRectMake(albumImageView.frame.size.width +10.0, 0, self.tableView.frame.size.width - 60, 30)];
    albumTitle.text = song.albumTitle;
    albumTitle.font = [albumTitle.font fontWithSize:21.0];
    [view addSubview:albumTitle];
    UILabel *artist = [[UILabel alloc] initWithFrame:CGRectMake(albumImageView.frame.size.width +10.0, albumTitle.frame.size.height, self.tableView.frame.size.width - 60, 30)];
    artist.text = [NSString stringWithFormat:@"by %@", song.artist];
    artist.font = [artist.font fontWithSize:12.0];
    [view addSubview:artist];
    view.backgroundColor = [UIColor colorWithRed:245/255.0 green:245/255.0 blue:245/255.0 alpha:1];
    return view;
    
}

@end
