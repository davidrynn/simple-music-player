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
#import "DRScrollingContainerController.h"
#import "DRSection.h"
#import "GVMusicPlayerController.h"
#import "DRPlayerUtility.h"
#import "DRAlbumTableViewController.h"


@interface DRMusicViewController () <UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate, DRPopSaysPlayMusicDelegate, GVMusicPlayerControllerDelegate, UISearchResultsUpdating>


@property (strong, nonatomic) IBOutlet UIView *topContainer;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (weak, nonatomic) IBOutlet UIBarButtonItem *sortButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *shuffleButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *loopButton;

@property (nonatomic, strong) NSDictionary *songsDictionary;
@property (nonatomic, strong) NSDictionary *albumsDictionary;
@property (nonatomic, strong) NSDictionary *artistsDictionary;
@property (nonatomic, strong) NSDictionary *genresDictionary;
@property (nonatomic, strong) NSDictionary *playlistsDictionary;
@property (nonatomic, strong) NSDictionary *mediaItemsDictionary;
@property (nonatomic, strong) NSDictionary *previousItemsDictionary;
@property (nonatomic, strong) GVMusicPlayerController *musicPlayer;
@property (nonatomic, strong) MPMediaItemCollection *musicCollection;
@property (nonatomic, strong) MPMediaItemCollection *dadCollection;
@property (nonatomic, strong) MPMediaItem *songToPlay;
@property (nonatomic, assign) NSUInteger adjustedIndex;
@property (nonatomic, assign) BOOL shuffleWasOn;
@property (nonatomic, strong) MPMusicPlayerController *mpMusicPlayer;

@property (strong, nonatomic) UISearchController *searchController;

@end
@implementation DRMusicViewController

- (void)viewDidLoad {
    
    TICK;
    [super viewDidLoad];
    [self setUpSearchBar];
    [self.tableView setSectionIndexColor:[UIColor redColor]];
    
    //setup topcontainer border
    [self.tableView.layer setBorderWidth:1.0f];
    UIColor *transBlack = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.1];
    [self.tableView.layer setBorderColor: [transBlack CGColor]];
    
    //starting music player
    self.musicPlayer = [GVMusicPlayerController sharedInstance];

    //for DRM
    self.mpMusicPlayer = [MPMusicPlayerController systemMusicPlayer];
    
    //setting up delegates
    [self setDelegates];
    
    [self.musicPlayer setupSortedLists];
  //  [self setupSortedLists];
    //TODO - EXCHANGE @"category" key for enums
    //setup song collection as initial collection
    self.mediaItemsDictionary = self.musicPlayer.songsDictionary;
    self.musicCollection =[[MPMediaItemCollection alloc] initWithItems:
                           self.mediaItemsDictionary[@"array"]];
    if (self.musicPlayer.nowPlayingItem == nil) {
        [self.musicPlayer loadSongFromUserDefaults];
        
    }
 
    TOCK;
    
}


-(void)setDelegates{
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    DRFirstViewController *dadController = (DRFirstViewController *)[self.navigationController parentViewController];
    dadController.delegate = self;

}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    //hide navbar
    self.navigationController.navigationBarHidden = YES;
    
    [[GVMusicPlayerController sharedInstance] addDelegate:self];
    
    NSArray *buttonArray = [DRPlayerUtility setupBarButtonImages];
    self.navigationItem.rightBarButtonItems = buttonArray;

}
-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    self.navigationController.navigationBarHidden= NO;
}

-(void)viewDidDisappear:(BOOL)animated{
    [[GVMusicPlayerController sharedInstance] removeDelegate:self];
    [super viewDidDisappear:animated];
    
}

//-(void) setupBarButtonImages{
//
//    //setup shuffle and loop buttons
//    UIImage *loopImage = [DRPlayerUtility createImageBasedOnEnum:self.musicPlayer.repeatMode ofTypeString: @"loop"];
//    UIBarButtonItem *loopButton = [[UIBarButtonItem alloc] initWithImage:loopImage style:UIBarButtonItemStylePlain target:self action:@selector(loopButtonTapped:)];
//    
//    UIImage *shuffleImage = [DRPlayerUtility createImageBasedOnEnum:self.musicPlayer.shuffleMode ofTypeString:@"shuffle"];
//    UIBarButtonItem *shuffleButton = [[UIBarButtonItem alloc] initWithImage:shuffleImage style:UIBarButtonItemStylePlain target:self action:@selector(shuffleButtonTapped:)];
//    UIBarButtonItem *sortButton = [[UIBarButtonItem alloc] initWithTitle:@"◦Songs" style:UIBarButtonItemStylePlain target:self action:@selector(sortTapped:)];
//    
//    UIBarButtonItem *flexibleSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:nil];
//    self.navigationItem.rightBarButtonItems = @[shuffleButton, flexibleSpace, sortButton, flexibleSpace, loopButton];
//}

//- (void) setupSortedLists {
//#if !(TARGET_IPHONE_SIMULATOR)
//    MPMediaQuery *songsQuery = [MPMediaQuery songsQuery];
//    if (songsQuery.items.count>0) {
//
//    NSDictionary *songDictionary = [DRPlayerUtility returnDictionaryFromQuery: songsQuery withCategory:@"Songs" withGroupingType: MPMediaGroupingTitle];
//    self.songsDictionary = songDictionary;
//    
//    MPMediaQuery *albumsQuery=[MPMediaQuery albumsQuery];
//    self.albumsDictionary = [DRPlayerUtility returnDictionaryFromQuery: albumsQuery withCategory:@"Albums" withGroupingType: MPMediaGroupingAlbum];
//    NSLog(@"number of albums: %ld", (unsigned long)albumsQuery.collections.count);
//    
//    MPMediaQuery *artistsQuery =[MPMediaQuery artistsQuery];
//    artistsQuery.groupingType = MPMediaGroupingArtist;
//    self.artistsDictionary = [DRPlayerUtility returnDictionaryFromQuery: artistsQuery withCategory:@"Artists" withGroupingType: MPMediaGroupingArtist];
//    NSLog(@"number of artists: %ld", (unsigned long)artistsQuery.collections.count);
//    
//    MPMediaQuery *genresQuery = [MPMediaQuery genresQuery];
//    self.genresDictionary = [DRPlayerUtility returnDictionaryFromQuery: genresQuery withCategory:@"Genres" withGroupingType: MPMediaGroupingGenre];
//    NSLog(@"number of genres: %ld", (unsigned long)genresQuery.collections.count);
//    
//    MPMediaQuery *playlistsQuery = [MPMediaQuery playlistsQuery];
//    self.playlistsDictionary = [DRPlayerUtility returnDictionaryFromQuery: playlistsQuery withCategory:@"Playlists" withGroupingType: MPMediaGroupingPlaylist];
//    NSLog(@"number of playlists: %ld", (unsigned long)playlistsQuery.collections.count);
//    
//    NSLog(@"number of songs: %ld", (unsigned long)songsQuery.collections.count);
//    }
//#endif
//    
//}

-(void)setUpSearchBar{
    self.searchController = [[UISearchController alloc] initWithSearchResultsController:nil];
    self.searchController.searchResultsUpdater = self;
    self.searchController.dimsBackgroundDuringPresentation = NO;
    self.searchController.searchBar.delegate = self;
    
    self.tableView.tableHeaderView = self.searchController.searchBar;
    self.searchController.searchBar.searchBarStyle = UISearchBarStyleDefault;
    self.searchController.searchBar.barTintColor= [UIColor colorWithRed:245.0/255.0 green:245.0/255.0 blue:245.0/255.0 alpha:1.0];
    self.searchController.searchBar.layer.borderWidth = 1;
    self.searchController.searchBar.layer.borderColor =[UIColor colorWithRed:230.0/255.0 green:230.0/255.0 blue:230.0/255.0 alpha:1.0].CGColor;
    
    self.definesPresentationContext = YES;
    
    [self.searchController.searchBar sizeToFit];
}

#pragma mark - button actions
- (IBAction)shuffleButtonTapped:(UIBarButtonItem *)sender {

    if( self.musicPlayer.shuffleMode == MPMusicShuffleModeSongs || self.musicPlayer.shuffleMode == MPMusicShuffleModeDefault){
        [self.musicPlayer setShuffleMode:MPMusicShuffleModeOff];
        self.shuffleWasOn = YES;

    } else{
        [self.musicPlayer setShuffleMode:MPMusicShuffleModeSongs]
        ;

        self.shuffleWasOn = NO;
        
    }
       sender.image = [DRPlayerUtility createImageBasedOnEnum:self.musicPlayer.shuffleMode ofTypeString:@"shuffle"];
    
}
- (IBAction)loopButtonTapped:(UIBarButtonItem *)sender {
    
        if( self.musicPlayer.repeatMode == MPMusicRepeatModeAll){
            [self.musicPlayer setRepeatMode:MPMusicRepeatModeOne];
        } else if( self.musicPlayer.repeatMode == MPMusicRepeatModeOne){
            [self.musicPlayer setRepeatMode:MPMusicRepeatModeNone];
        } else {
            [self.musicPlayer setRepeatMode:MPMusicRepeatModeAll];
        }
        sender.image = [DRPlayerUtility createImageBasedOnEnum:self.musicPlayer.repeatMode ofTypeString:@"loop"];

}

- (IBAction)sortTapped:(UIBarButtonItem *)sender {
#if !(TARGET_IPHONE_SIMULATOR)
    
    if([sender.title isEqualToString:@"◦Playlists"])
    {
        sender.title = @"◦Songs";
        self.mediaItemsDictionary = self.musicPlayer.songsDictionary;
        
    }
    else if ([sender.title isEqualToString:@"◦Songs"])
    {
        sender.title = @"◦Albums";
        self.mediaItemsDictionary = self.musicPlayer.albumsDictionary;
        
    }
    else if ([sender.title isEqualToString:@"◦Albums"])
    {
        sender.title = @"◦Artists";
        self.mediaItemsDictionary = self.musicPlayer.artistsDictionary;
        
    }
    else if ([sender.title isEqualToString:@"◦Artists"])
    {
        sender.title = @"◦Genres";
        self.mediaItemsDictionary = self.musicPlayer.genresDictionary;
        
    }
    else if ([sender.title isEqualToString:@"◦Genres"])
    {
        sender.title = @"◦Playlists";
        self.mediaItemsDictionary = self.musicPlayer.playlistsDictionary;
        
    }
    
    [self.tableView reloadData];
    
#endif
    
}

//End Button actions

#pragma mark - Content Filtering

//Search Functionality
-(void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{

    self.mediaItemsDictionary = self.previousItemsDictionary;
    [self.tableView reloadData];
    
}

-(BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar
{
    [searchBar setShowsCancelButton:YES animated:YES];
    if  (![self.previousItemsDictionary[@"category"]  isEqual: @"Search"]){
    self.previousItemsDictionary = self.mediaItemsDictionary;
    }
    return YES;
}
-(void)searchBarTextDidEndEditing:(UISearchBar *)searchBar{
    [searchBar resignFirstResponder];
}

-(void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    NSLog(@"textDidChange: '%@'", searchText);
    self.mediaItemsDictionary = [self performSearchWithString: searchText];
    [self.tableView reloadData];
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    [self.searchController.searchBar resignFirstResponder];
}


#pragma mark - Search Function

- (void)updateSearchResultsForSearchController:(UISearchController *)searchController
{
    NSString *searchString = searchController.searchBar.text;
    [self performSearchWithString:searchString];
    [self.tableView reloadData];
}

-(NSDictionary*) performSearchWithString: (NSString*) searchString
{
    
    //create arrays and sections for media dictionary
    
    NSArray *songsSearchArray = [DRPlayerUtility createArrayFromSearchString:searchString FromProperty:MPMediaItemPropertyTitle andQuery:[MPMediaQuery songsQuery] andGroupingType:MPMediaGroupingTitle];
    //use custom section so can set it.
    DRSection *songSection = [[DRSection alloc] initWithRange:NSMakeRange(0,  songsSearchArray.count) andTitle:@"Songs"];
    
    NSArray *artistsArray =[DRPlayerUtility createArrayFromSearchString:searchString FromProperty:MPMediaItemPropertyArtist andQuery:[MPMediaQuery artistsQuery] andGroupingType:MPMediaGroupingArtist];
    //use custom section so can set it.
    DRSection *artistsSection = [[DRSection alloc] initWithRange:NSMakeRange(songsSearchArray.count,  artistsArray.count) andTitle:@"Artists"];

    NSArray *albumsArray =[DRPlayerUtility createArrayFromSearchString:searchString FromProperty:MPMediaItemPropertyAlbumTitle andQuery:[MPMediaQuery albumsQuery] andGroupingType:MPMediaGroupingAlbum];
    DRSection *albumsSection = [[DRSection alloc] initWithRange:NSMakeRange(  (songsSearchArray.count+artistsArray.count), albumsArray.count) andTitle:@"Albums"];
    
    //make complete array from different sort types
    NSArray *searchArray = [songsSearchArray arrayByAddingObjectsFromArray:artistsArray];
    searchArray =[searchArray arrayByAddingObjectsFromArray:albumsArray];
    
    NSDictionary *searchDictionary = @{@"category":@"Search",
                                       @"array": searchArray,
                                       @"sections": @[songSection, artistsSection, albumsSection]
                                       };
    
    if (searchArray.count==0) {
        return @{};
    }
    return searchDictionary;
}

//End Search Function




#pragma mark - Tableview Setup

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
#if !(TARGET_IPHONE_SIMULATOR)
    NSArray *sectionsArray= self.mediaItemsDictionary[@"sections"];
    if (sectionsArray.count > 0){
    NSUInteger number = 0;
    if ([self.mediaItemsDictionary[@"category"] isEqualToString:@"Search"]) {
        
        DRSection *querySection = sectionsArray[section];
        number = querySection.range.length;
    } else{
        
        //get number after casting everything correctly to MPMedia -
        
        MPMediaQuerySection *querySection = sectionsArray[section];
        number = querySection.range.length;
        
    }
    
    return number;
    }

#endif
    return 1;

}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    NSArray *sectionsArray= self.mediaItemsDictionary[@"sections"];
    //want search sections to display regardless of count
    if ((sectionsArray.count > 4) || [self.mediaItemsDictionary[@"category"] isEqualToString:@"Search"]) {
        return sectionsArray.count;
    }
    return 1;
}

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView
{
    if ([self.mediaItemsDictionary[@"category"] isEqualToString:@"Search"]) {
        return @[];
    }
    NSArray *sectionsArray= self.mediaItemsDictionary[@"sections"];
    if (sectionsArray.count > 4) {
        
        NSMutableArray *sectionTitles= [[NSMutableArray alloc] init];
        for (MPMediaQuerySection *querySection in sectionsArray) {
            [sectionTitles addObject:querySection.title];
        }
        return [sectionTitles copy];
    }
    
    return nil;
    
}

- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString*)title atIndex:(NSInteger)index
{
    return index;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    NSArray *sections = self.mediaItemsDictionary[@"sections"];
    
    if ([self.mediaItemsDictionary[@"category"] isEqualToString:@"Search"]) {
        DRSection *querySection =self.mediaItemsDictionary[@"sections"][section];
        if (querySection.range.length >0) {
            return querySection.title;
        }
    }
    
    if (sections.count > 4) {
        MPMediaQuerySection *querySection = self.mediaItemsDictionary[@"sections"][section];
        return querySection.title;
    }
    
    return nil;
}


-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifer = @"cell";
    UITableViewCell *cell =[tableView dequeueReusableCellWithIdentifier:cellIdentifer forIndexPath:indexPath];
    
    NSString *mediaTypeString = self.mediaItemsDictionary[@"category"];
    MPMediaItem *item;
    //use custom section class for search
    if ([mediaTypeString isEqualToString:@"Search"]) {
        DRSection *querySection = self.mediaItemsDictionary[@"sections"][indexPath.section];
        self.adjustedIndex = querySection.range.location + indexPath.row;
    }
    else{
        MPMediaQuerySection *querySection = self.mediaItemsDictionary[@"sections"][indexPath.section];
        self.adjustedIndex = querySection.range.location + indexPath.row;
    }
    if (mediaTypeString) {
        
        //printout different for search cells depending on index 0 -> songs, 1 -> artists, etc
        
        if([mediaTypeString isEqualToString:@"Songs"] || ([mediaTypeString isEqualToString:@"Search"] && indexPath.section == 0)){
            item = (MPMediaItem *) self.mediaItemsDictionary[@"array"][self.adjustedIndex];
            cell.textLabel.text =[NSString stringWithFormat:@"%@", item.title];
            cell.detailTextLabel.text = [NSString stringWithFormat:@"%@ -- %@", item.artist, item.albumTitle];
        }
        else if ([mediaTypeString isEqualToString:@"Albums"] || ([mediaTypeString isEqualToString:@"Search"] && indexPath.section == 2)){
            MPMediaItemCollection *collection= self.mediaItemsDictionary[@"array"][self.adjustedIndex];
            item = collection.representativeItem;
            cell.textLabel.text =[NSString stringWithFormat:@"%@", item.albumTitle];
            cell.detailTextLabel.text = [NSString stringWithFormat:@"%@", item.artist];
            
        }
        else if ([mediaTypeString isEqualToString:@"Artists"] || ([mediaTypeString isEqualToString:@"Search"] && indexPath.section == 1)){
            MPMediaItemCollection *collection= self.mediaItemsDictionary[@"array"][self.adjustedIndex];
            item = collection.representativeItem;
            cell.textLabel.text =[NSString stringWithFormat:@"%@", item.artist];
            cell.detailTextLabel.text = @"";
            
        }
        else if ([mediaTypeString isEqualToString:@"Genres"]){
            MPMediaItemCollection *collection= self.mediaItemsDictionary[@"array"][self.adjustedIndex];
            item = collection.representativeItem;
            cell.textLabel.text =item.genre;
            cell.detailTextLabel.text = @"";
        }
        else if ([mediaTypeString isEqualToString:@"Playlists"]){
            MPMediaPlaylist *playlist= self.mediaItemsDictionary[@"array"][self.adjustedIndex];
            
            cell.textLabel.text =[NSString stringWithFormat:@"%@", [playlist valueForProperty:MPMediaPlaylistPropertyName]];
            cell.detailTextLabel.text = @"";
        }
        if(![mediaTypeString isEqualToString:@"Playlists"] && ![mediaTypeString isEqualToString:@"Genres"]) {
            if (!item.artwork) {
                cell.imageView.image = [UIImage imageNamed:@"noteSml"];
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

    [tableView deselectRowAtIndexPath:indexPath animated:YES];

    //set bool if shuffle was on to change back after
    //otherwise shufflemode invalidates music collection and song selection doesn't work
    if (self.musicPlayer.shuffleMode==MPMusicShuffleModeSongs) {

        [self.musicPlayer setShuffleMode: MPMusicShuffleModeOff];
        
        self.shuffleButton.image = [UIImage imageNamed:@"shuffle0"];
        
    }

    [self.musicPlayer setQueueWithItemCollection:self.musicCollection];
    
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
    
    //figure out correct index
    MPMediaQuerySection *querySection = self.mediaItemsDictionary[@"sections"][indexPath.section];
    self.adjustedIndex = querySection.range.location + indexPath.row;
  
    if ([self.mediaItemsDictionary[@"category"] isEqualToString:@"Songs"]||([self.mediaItemsDictionary[@"category"] isEqualToString:@"Search"]&&indexPath.section == 0)){
        //use index to find song
        MPMediaItem *song =(MPMediaItem *) self.mediaItemsDictionary[@"array"][self.adjustedIndex];
        
        if ( song != self.musicPlayer.nowPlayingItem) {
            self.musicCollection =[[MPMediaItemCollection alloc] initWithItems:
                                   self.mediaItemsDictionary[@"array"]];
            [self.musicPlayer setQueueWithItemCollection:self.musicCollection];
            
            [self.musicPlayer stop];
            
            NSLog(@"Mediaplayer item name: %@", song.title);
            
            self.songToPlay = song;
            [self.musicPlayer playItemAtIndex:self.adjustedIndex];
            
            [self playMusic];
        }
        TOCK;
    }
    
    //if not a song, segue
    else  {
        NSLog(@"I should be performing a segue");
        
        if ([self.mediaItemsDictionary[@"category"] isEqualToString:@"Search"]) {
            if (indexPath.section ==1) {
                [self performSegueWithIdentifier:@"Artists" sender:cell];
            }
            if (indexPath.section ==2) {
                [self performSegueWithIdentifier:@"Albums" sender:cell];
            }
        }
        else {
            [self performSegueWithIdentifier:self.mediaItemsDictionary[@"category"] sender:cell];
        }
    }
}


#pragma mark - Navigation
-(void)performSegueForDadWithCollection:(MPMediaItemCollection *)collection andIdentifier:(NSString *)identifier{
    BOOL isTappedFromArtistVC = [self.navigationController.viewControllers.lastObject isKindOfClass:[DRArtistTableViewController class]] && ([identifier  isEqualToString: @"Artists"]);
    BOOL isTappedFromAlbumVC = [self.navigationController.viewControllers.lastObject isKindOfClass:[DRAlbumTableViewController class]]  && [identifier isEqualToString:@"Albums"];
    
    
    if (!(isTappedFromArtistVC || isTappedFromAlbumVC)) {


        self.dadCollection = collection;
//TODO: Get VC to dismiss if it's not DRMusicVC so there isn't a huge stack each time you go to Artist/Album
        [self performSegueWithIdentifier:identifier sender:self];
        
 //   }
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    self.musicPlayer.shuffleMode = MPMusicShuffleModeDefault;
    if ([sender isKindOfClass:[UITableViewCell class]]) {
        
        UITableViewCell *cell = (UITableViewCell *)sender;
        NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
        MPMediaQuerySection *querySection = self.mediaItemsDictionary[@"sections"][indexPath.section];
        NSInteger adjustIndex = querySection.range.location + indexPath.row;
        
        if ([segue.identifier isEqualToString: @"Artists"]) {
            DRArtistTableViewController *destinationVC = [segue destinationViewController];
            destinationVC.mediaCollection = self.mediaItemsDictionary[@"array"][adjustIndex];
        } else if (segue.identifier){
            
            DRMediaTableViewController *destinationVC = [segue destinationViewController];
            destinationVC.mediaCollection = self.mediaItemsDictionary[@"array"][adjustIndex];
        }
    }
    //Distinguish between coming from cell or from other view
    else if([sender isKindOfClass:[self class]]&&self.dadCollection){
        
        DRMediaTableViewController *destinationVC = [segue destinationViewController];
        destinationVC.mediaCollection = self.dadCollection;
        self.dadCollection = nil;
        
    }
}

#pragma mark - Miscellaneous

-(void) playOrPauseMusic{
    if ((self.musicPlayer.playbackState == MPMusicPlaybackStatePaused)||self.musicPlayer.playbackState == MPMusicPlaybackStateStopped) {
        [self playMusic];
    }
    else if(self.musicPlayer.playbackState == MPMusicPlaybackStatePlaying){
        [self pauseMusic];
    }
}

-(void) playMusic{
    TICK;
    if (!self.songToPlay) {
        self.songToPlay = self.musicPlayer.nowPlayingItem ;
    }
    [self.musicPlayer play];
    TOCK;
}

-(void) pauseMusic {
    TICK
    if (![self.musicPlayer.nowPlayingItem valueForProperty:MPMediaItemPropertyAssetURL]) {
        [self.mpMusicPlayer pause];
    }
    [self.musicPlayer pause];
    TOCK;
}

@end
