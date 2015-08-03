//
//  DRMusicViewController.m
//  Simple-Music-Player
//
//  Created by David Rynn on 8/1/15.
//  Copyright (c) 2015 David Rynn. All rights reserved.
//

#import "DRMusicViewController.h"
@import MediaPlayer;

@interface DRMusicViewController () <UITableViewDelegate, UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UIView *playerButtonContainer;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) NSDictionary *songsDictionary;
@property (nonatomic, strong) NSDictionary *albumsDictionary;
@property (nonatomic, strong) NSDictionary*artistsArray;
@property (nonatomic, strong) NSDictionary *genresArray;
@property (nonatomic, strong) NSDictionary *playlistsArray;
@property (nonatomic, strong) NSDictionary *mediaItemsDictionary;
@property (weak, nonatomic) IBOutlet UISegmentedControl *segmentedController;
@property (weak, nonatomic) IBOutlet UIImageView *cellImageView;

@property (nonatomic, strong) MPMusicPlayerController *musicPlayerController;
@property (nonatomic, strong) MPMediaItem *songToPlay;
//@property (nonatomic, strong) MPMediaLibrary *musicLibrary;
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;

@end

@implementation DRMusicViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
//    self.playerButtonContainer.layer.shadowColor =000;
//    self.playerButtonContainer.layer.shadowOffset = CGSizeMake(self.playerButtonContainer.frame.size.width, self.playerButtonContainer.frame.size.height +50);
//    self.playerButtonContainer.layer.shadowRadius = 5;
//
    
    self.playerButtonContainer.layer.shadowColor     = [[UIColor blackColor] CGColor];
    self.playerButtonContainer.layer.shadowOffset    = CGSizeMake (0, -1);
    self.playerButtonContainer.layer.shadowOpacity   = 0.47;
    self.playerButtonContainer.layer.shadowRadius    = 0.00;
    self.playerButtonContainer.layer.masksToBounds   = NO;
    self.musicPlayerController = [MPMusicPlayerController systemMusicPlayer];
    
    //setup five views
    MPMediaQuery *songsQuery =[MPMediaQuery songsQuery];
    NSArray *songSectionHeaders = @[@"A",@"B", @"C"];
    self.songsDictionary = @{@"category": @"Songs",
                             @"array": [songsQuery items],
                             @"sectionHeaderArray":songSectionHeaders};
    self.mediaItemsDictionary = self.songsDictionary;
    
    MPMediaQuery *albumsQuery=[MPMediaQuery albumsQuery];
    self.albumsDictionary = @{@"category": @"Albums",
                              @"array":[albumsQuery items]};
    
    MPMediaQuery *artistsQuery =[MPMediaQuery artistsQuery];
    self.artistsArray = @{@"category":@"Artists",
                          @"array":[artistsQuery items]};
    
    MPMediaQuery *genresQuery = [MPMediaQuery genresQuery];
    self.genresArray = @{@"category":@"Genres",
                         @"array":[genresQuery items]};
    
    MPMediaQuery *playlistsQuery = [MPMediaQuery playlistsQuery];
    self.playlistsArray = @{@"category":@"Playlists",
                            @"array": [playlistsQuery items]};
    
    


}
- (IBAction)playButtonTapped:(id)sender {

    UIButton *button = (UIButton *)sender;
    
    button.selected = !button.selected;
    
    if(button.selected)
    {
        // Play
        button.titleLabel.text = @"Pause";
        NSLog(@"Now PLaying? - %@", self.songToPlay.title);
        MPMediaItemCollection *collection = [[MPMediaItemCollection alloc] initWithItems:@[self.songToPlay]];
        [self.musicPlayerController setQueueWithItemCollection:collection];
        [self.musicPlayerController play];

    }
    else
    {
        // Pause
        button.titleLabel.text = @"Palay";
        [self.musicPlayerController pause];
    }
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)segmentedTapped:(UISegmentedControl *)sender {
    
    if(sender.selectedSegmentIndex == 0)
    {
        
        self.mediaItemsDictionary = self.songsDictionary;
    
    }
    else if (sender.selectedSegmentIndex == 1)
    {
        
        self.mediaItemsDictionary = self.albumsDictionary;
        
    }
    else if (sender.selectedSegmentIndex == 2)
    {
        
        self.mediaItemsDictionary = self.artistsArray;
        
    }
    else if (sender.selectedSegmentIndex == 3)
    {
        
        self.mediaItemsDictionary = self.genresArray;
        
    }
    else if (sender.selectedSegmentIndex == 4)
    {
        
        self.mediaItemsDictionary = self.playlistsArray;
        
    }
    
    [self.tableView reloadData];
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSArray *array = self.songsDictionary[@"array"];
    NSLog(@"count inside numberOfRows %ld", array.count);

    return array.count;
}
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if ([self.mediaItemsDictionary[@"category"] isEqualToString:@"Songs"]) {
        NSArray *arrayCast = self.mediaItemsDictionary[@"sectionHeaderArray"];
        return arrayCast.count;
    }
    
    return 1;
}

//-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
//{
//    //array of album names
//    return @"";
//}
//-(NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView
//{
//    return @[];
//}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifer = @"cell";
    UITableViewCell *cell =[tableView dequeueReusableCellWithIdentifier:cellIdentifer forIndexPath:indexPath];
    
    NSString *mediaType = self.mediaItemsDictionary[@"category"];

    NSLog(@"Media Type: %@", mediaType);


    
    if (mediaType) {
        
        MPMediaItem *item = (MPMediaItem *) self.mediaItemsDictionary[@"array"][indexPath.row];
        
        cell.textLabel.text =[NSString stringWithFormat:@"%@", item.title];
        cell.detailTextLabel.text = [NSString stringWithFormat:@"%@, %@", item.artist, item.albumTitle];
        UIImage *albumArtWork = [item.artwork imageWithSize:CGSizeMake(cell.frame.size.height, cell.frame.size.height)];
        cell.imageView.image =albumArtWork;
    }
//    if (![self.mediaItemsDictionary[@"category"][indexPath.row] isEqualToString:@"Songs"]) {
//        
//        MPMediaItemCollection *collection =
//        
//        cell.textLabel.text =[NSString stringWithFormat:@"%@", item.title];
//        cell.detailTextLabel.text = [NSString stringWithFormat:@"%@, %@", item.artist, item.albumTitle];
//    }
    
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    self.songToPlay = (MPMediaItem *) self.mediaItemsDictionary[@"array"][indexPath.row];
    
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
