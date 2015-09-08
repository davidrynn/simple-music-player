//
//  DRMusicViewController.m
//  Simple-Music-Player
//
//  Created by David Rynn on 8/1/15.
//  Copyright (c) 2015 David Rynn. All rights reserved.
//

#define TICK CFTimeInterval startTime = CACurrentMediaTime();
#define TOCK   NSLog(@"Time for %@: %f", NSStringFromSelector(_cmd), (CACurrentMediaTime()-startTime));

#import "DRMusicViewController.h"
#import "DRArtistTableViewController.h"
#import "DRMediaTableViewController.h"
#import "DRFirstViewController.h"



@interface DRMusicViewController () <UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate, UIScrollViewDelegate, DRPopSaysPlayMusicDelegate>


@property (strong, nonatomic) IBOutlet UIView *topContainer;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property (weak, nonatomic) IBOutlet UIView *searchBarView;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *sortButton;

@property (nonatomic, strong) NSDictionary *songsDictionary;
@property (nonatomic, strong) NSDictionary *albumsDictionary;
@property (nonatomic, strong) NSDictionary*artistsArray;
@property (nonatomic, strong) NSDictionary *genresArray;
@property (nonatomic, strong) NSDictionary *playlistsArray;
@property (nonatomic, strong) NSDictionary *mediaItemsDictionary;
@property (nonatomic, strong) MPMusicPlayerController *musicPlayerController;
@property (nonatomic, strong) MPMediaItemCollection *musicCollection;
@property (nonatomic, strong) MPMediaItem *songToPlay;


@end
@implementation DRMusicViewController

- (void)viewDidLoad {
    
    
    TICK;
    [super viewDidLoad];
    [self.tableView setSectionIndexColor:[UIColor redColor]];
    
    
    //setup topcontainer border
    [self.tableView.layer setBorderWidth:1.0f];
    UIColor *transBlack = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.1];
    [self.tableView.layer setBorderColor: [transBlack CGColor]];
    
    //starting music player
    self.musicPlayerController = [MPMusicPlayerController systemMusicPlayer];
    [self.musicPlayerController beginGeneratingPlaybackNotifications];
    
    
    //setting up delegates
    [self setDelegates];
    
    [self setUpSegmentSortedLists];
    

        
        //setup song collection as initial collection
        self.mediaItemsDictionary = self.songsDictionary;
        self.musicCollection =
        self.mediaItemsDictionary[@"array"];
    
    if (!self.musicPlayerController.nowPlayingItem) {

        
        [self.musicPlayerController setQueueWithItemCollection:self.musicCollection];
    }


    TOCK;

}

-(void)setDelegates{

    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    DRFirstViewController *dadController = (DRFirstViewController *)[self.navigationController parentViewController];
    dadController.delegate = self;
    
    self.searchBar.delegate = self;
    
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    //hide navbar
    self.navigationController.navigationBarHidden = YES;
}
-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    self.navigationController.navigationBarHidden= NO;
}

- (void) setUpSegmentSortedLists {
    
    MPMediaQuery *songsQuery = [MPMediaQuery songsQuery];

    self.songsDictionary = @{@"category": @"Songs",
                             @"array": [songsQuery items],
                             @"sections": songsQuery.collectionSections
                             };
    
    
    MPMediaQuery *albumsQuery=[MPMediaQuery albumsQuery];
    albumsQuery.groupingType = MPMediaGroupingAlbum;
    self.albumsDictionary = @{@"category": @"Albums",
                              @"array":albumsQuery.collections,
                              @"sections": albumsQuery.collectionSections
                              };
    NSLog(@"number of albums: %ld", (unsigned long)albumsQuery.collections.count);
    
    MPMediaQuery *artistsQuery =[MPMediaQuery artistsQuery];
    artistsQuery.groupingType = MPMediaGroupingArtist;
    self.artistsArray = @{@"category":@"Artists",
                          @"array":artistsQuery.collections,
                          @"sections": artistsQuery.collectionSections
                          };
    NSLog(@"number of artists: %ld", (unsigned long)artistsQuery.collections.count);
    
    MPMediaQuery *genresQuery = [MPMediaQuery genresQuery];
    genresQuery.groupingType = MPMediaGroupingGenre;
    self.genresArray = @{@"category":@"Genres",
                         @"array":[genresQuery collections],
                         @"sections": genresQuery.collectionSections
                         };
    NSLog(@"number of genres: %ld", (unsigned long)genresQuery.collections.count);
    
    MPMediaQuery *playlistsQuery = [MPMediaQuery playlistsQuery];
    playlistsQuery.groupingType = MPMediaGroupingPlaylist;
    self.playlistsArray = @{@"category":@"Playlists",
                            @"array": [playlistsQuery collections],
                            @"sections": playlistsQuery.collectionSections
                            };
    NSLog(@"number of playlists: %ld", (unsigned long)playlistsQuery.collections.count);
    
    
    NSLog(@"number of songs: %ld", (unsigned long)songsQuery.collections.count);
    
}


#pragma mark - button actions
- (IBAction)shuffleButtonTapped:(UIBarButtonItem *)sender {
    
    if( self.musicPlayerController.shuffleMode == MPMusicShuffleModeSongs){
        [self.musicPlayerController setShuffleMode:MPMusicShuffleModeOff];
        [sender setTintColor: [UIColor redColor]];
        sender.title = @"Shuffle";
    } else{
        [self.musicPlayerController setShuffleMode:MPMusicShuffleModeSongs]
        ;
        sender.title = @"Shuffle On";
        
    }
    
}
- (IBAction)sortTapped:(UIBarButtonItem *)sender {

    
    if([sender.title isEqualToString:@"Playlists"])
    {
        sender.title = @"Songs";
        self.mediaItemsDictionary = self.songsDictionary;
        
    }
    else if ([sender.title isEqualToString:@"Songs"])
    {
        sender.title = @"Albums";
        self.mediaItemsDictionary = self.albumsDictionary;
        
    }
    else if ([sender.title isEqualToString:@"Albums"])
    {
        sender.title = @"Artists";
        self.mediaItemsDictionary = self.artistsArray;
        
    }
    else if ([sender.title isEqualToString:@"Artists"])
    {
        sender.title = @"Genres";
        self.mediaItemsDictionary = self.genresArray;
        
    }
    else if ([sender.title isEqualToString:@"Genres"])
    {
        sender.title = @"Playlists";
        self.mediaItemsDictionary = self.playlistsArray;
        
    }
    
    [self.tableView reloadData];
    
}

//End Button actions

#pragma mark - Content Filtering
//Search Functionality
-(void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
    self.searchBar.hidden = YES;
    [searchBar resignFirstResponder];
    [searchBar setText:@""];
    self.mediaItemsDictionary = self.songsDictionary;
    [self.tableView reloadData];
    
}

-(BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar
{
    [searchBar setShowsCancelButton:YES animated:YES];
    return YES;
}

-(void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    NSLog(@"textDidChange: '%@'", searchText);
    self.mediaItemsDictionary = [self performSearchWithString: searchText];
    [self.tableView reloadData];
}

#pragma mark - Search Function
- (IBAction)searchButtonTapped:(id)sender {
    
    self.searchBar.hidden = NO;
    [self.searchBar becomeFirstResponder];
    
}

-(NSDictionary*) performSearchWithString: (NSString*) searchString
{
    
    MPMediaPropertyPredicate *songsPredicate = [MPMediaPropertyPredicate predicateWithValue:searchString forProperty:MPMediaItemPropertyTitle comparisonType:MPMediaPredicateComparisonContains];
    
    MPMediaQuery *songsSearchQuery = [[MPMediaQuery alloc] init];
    songsSearchQuery.groupingType = MPMediaGroupingTitle;
    [songsSearchQuery addFilterPredicate:songsPredicate];
    NSArray *searchArray = [songsSearchQuery items];
    
    //catch no return results
    if (searchArray.count==0) {
        return @{};
    }
    
    NSDictionary *searchDictionary = @{@"category":@"Search",
                                       @"array": searchArray,
                                       @"sections": songsSearchQuery.collectionSections,
                                       };
    
    //TODO: add search results by artist, albums and playlists
    return searchDictionary;
}

//End Search Function


#pragma mark - Tableview Setup

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    
    //get number after casting everything correctly to MPMedia -
    NSArray *sectionsArray= self.mediaItemsDictionary[@"sections"];
    MPMediaQuerySection *querySection = sectionsArray[section];
    NSUInteger number = querySection.range.length;
    return number;
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    NSArray *sectionsArray= self.mediaItemsDictionary[@"sections"];
    return sectionsArray.count;
}

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView
{
    NSArray *sectionsArray= self.mediaItemsDictionary[@"sections"];
    NSMutableArray *sectionTitles= [[NSMutableArray alloc] init];
    for (MPMediaQuerySection *querySection in sectionsArray) {
        [sectionTitles addObject:querySection.title];
    }
    
    return [sectionTitles copy];
}

- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString*)title atIndex:(NSInteger)index
{
    return index;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    MPMediaQuerySection *querySection = self.mediaItemsDictionary[@"sections"][section];
    
    return querySection.title;
}


-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifer = @"cell";
    UITableViewCell *cell =[tableView dequeueReusableCellWithIdentifier:cellIdentifer forIndexPath:indexPath];
    
    NSString *mediaTypeString = self.mediaItemsDictionary[@"category"];
    MPMediaItem *item;
    MPMediaQuerySection *querySection = self.mediaItemsDictionary[@"sections"][indexPath.section];
    NSInteger adjustIndex = querySection.range.location + indexPath.row;
    
    if (mediaTypeString) {
        
        if([mediaTypeString isEqualToString:@"Songs"] || [mediaTypeString isEqualToString:@"Search"]){
            item = (MPMediaItem *) self.mediaItemsDictionary[@"array"][adjustIndex];
            cell.textLabel.text =[NSString stringWithFormat:@"%@", item.title];
            cell.detailTextLabel.text = [NSString stringWithFormat:@"%@ -- %@", item.artist, item.albumTitle];
        }
        else if ([mediaTypeString isEqualToString:@"Albums"]){
            MPMediaItemCollection *collection= self.mediaItemsDictionary[@"array"][adjustIndex];
            item = collection.representativeItem;
            cell.textLabel.text =[NSString stringWithFormat:@"%@", item.albumTitle];
            cell.detailTextLabel.text = [NSString stringWithFormat:@"%@", item.artist];
            
        }
        else if ([mediaTypeString isEqualToString:@"Artists"]){
            MPMediaItemCollection *collection= self.mediaItemsDictionary[@"array"][adjustIndex];
            item = collection.representativeItem;
            cell.textLabel.text =[NSString stringWithFormat:@"%@", item.artist];
            cell.detailTextLabel.text = @"";
            
        }
        else if ([mediaTypeString isEqualToString:@"Genres"]){
            MPMediaItemCollection *collection= self.mediaItemsDictionary[@"array"][adjustIndex];
            item = collection.representativeItem;
            cell.textLabel.text =item.genre;
            cell.detailTextLabel.text = @"";
        }
        else if ([mediaTypeString isEqualToString:@"Playlists"]){
            MPMediaPlaylist *playlist= self.mediaItemsDictionary[@"array"][adjustIndex];
            
            cell.textLabel.text =[NSString stringWithFormat:@"%@", [playlist valueForProperty:MPMediaPlaylistPropertyName]];
            cell.detailTextLabel.text = @"";
        }
        if(![mediaTypeString isEqualToString:@"Playlists"] && ![mediaTypeString isEqualToString:@"Genres"]) {
            if (!item.artwork) {
                cell.imageView.image = [UIImage imageNamed:@"noteBW"];
            }
            else
            {
                
                cell.imageView.image = [item.artwork  imageWithSize:CGSizeMake(60.0, 60.0)];
            }
        }
        else {
            cell.imageView.image = nil;
            cell.textLabel.textAlignment = NSTextAlignmentCenter;
        }
    }
    
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    TICK
    
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
    
    //figure out correct index
    MPMediaQuerySection *querySection = self.mediaItemsDictionary[@"sections"][indexPath.section];
    NSInteger adjustIndex = querySection.range.location + indexPath.row;
    //use index to find song
    MPMediaItem *song =(MPMediaItem *) self.mediaItemsDictionary[@"array"][adjustIndex];
    
    if (([self.mediaItemsDictionary[@"category"] isEqualToString:@"Songs"]||[self.mediaItemsDictionary[@"category"] isEqualToString:@"Search"] ) && (song != self.musicPlayerController.nowPlayingItem)) {
        
        [self.musicPlayerController stop];
       
        
        self.musicPlayerController.nowPlayingItem = song;
        
        
        NSLog(@"Mediaplayer item name: %@", song.title);
        
        self.songToPlay = song;
        
        [self playMusic];
        
        
        TOCK;
    }
    
    else if (song != self.musicPlayerController.nowPlayingItem) {
        NSLog(@"I should be performing a segue");
        [self performSegueWithIdentifier:self.mediaItemsDictionary[@"category"] sender:cell];
    }
    
    
}


#pragma mark - Navigation


- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    UITableViewCell *cell = (UITableViewCell *)sender;
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    MPMediaQuerySection *querySection = self.mediaItemsDictionary[@"sections"][indexPath.section];
    NSInteger adjustIndex = querySection.range.location + indexPath.row;
    
    if ([segue.identifier isEqualToString: @"artistViewSegue"]) {
        DRArtistTableViewController *destinationVC = [segue destinationViewController];
        destinationVC.mediaCollection = self.mediaItemsDictionary[@"array"][adjustIndex];
    } else if (segue.identifier){
        
        DRMediaTableViewController *destinationVC = [segue destinationViewController];
        destinationVC.mediaCollection = self.mediaItemsDictionary[@"array"][adjustIndex];
    }
    
    
}


#pragma mark - Miscellaneous

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
    [[NSNotificationCenter defaultCenter] removeObserver: self
                                                    name: MPMusicPlayerControllerPlaybackStateDidChangeNotification
                                                  object: self.musicPlayerController];
    
    [self.musicPlayerController endGeneratingPlaybackNotifications];
    // Dispose of any resources that can be recreated.
}

-(void) playOrPauseMusic{
    if ((self.musicPlayerController.playbackState == MPMusicPlaybackStatePaused)||self.musicPlayerController.playbackState == MPMusicPlaybackStateStopped) {
        [self playMusic];
    }
    else if(self.musicPlayerController.playbackState == MPMusicPlaybackStatePlaying){
        [self pauseMusic];
        
    }
}

-(void) playMusic{
    TICK;
    if (!self.songToPlay) {
        self.songToPlay = self.musicPlayerController.nowPlayingItem ;

    }
    
    
    [self.musicPlayerController play];

    
    TOCK;
    
}

-(void) pauseMusic {
    
    TICK
    
    [self.musicPlayerController pause];

    
    TOCK;
    
}

@end
