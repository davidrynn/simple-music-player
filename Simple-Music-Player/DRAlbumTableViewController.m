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
    return 75.0;
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    MPMediaItem *song = self.mediaCollection.representativeItem;
    CGRect tableViewHeaderFrame = self.tableView.tableHeaderView.frame;
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(tableViewHeaderFrame.origin.x, tableViewHeaderFrame.origin.y, tableViewHeaderFrame.size.width, tableViewHeaderFrame.size.height)];
    CGRect imageRect = CGRectMake(0, 0, 75, 75);
    UIImageView *albumImageView = [[UIImageView alloc] initWithFrame:imageRect];
    albumImageView.image = [song.artwork imageWithSize:imageRect.size];
    [view addSubview:albumImageView];
    
    UILabel *albumTitle = [[UILabel alloc] initWithFrame:CGRectMake(albumImageView.frame.size.width +10.0, 0, self.tableView.frame.size.width - 60, 30)];
    albumTitle.text = song.albumTitle;
    albumTitle.font = [albumTitle.font fontWithSize:21.0];
    [view addSubview:albumTitle];
    
    UILabel *artist = [[UILabel alloc] initWithFrame:CGRectMake(albumImageView.frame.size.width +10.0, albumTitle.frame.size.height, self.tableView.frame.size.width - 60, 30)];
    artist.text = [NSString stringWithFormat:@"by %@", song.artist];
    artist.font = [artist.font fontWithSize:12.0];
    [view addSubview:artist];
    
    //Unfortunatly the only way to add a lower border
    UIView *border = [[UIView alloc] initWithFrame:CGRectMake(0, 74, self.tableView.frame.size.width, 1)];
    border.backgroundColor = [UIColor lightGrayColor];
    [view addSubview:border];
    
    view.backgroundColor = [UIColor whiteColor];

    return view;
    
}

@end
