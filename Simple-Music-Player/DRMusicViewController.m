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



@interface DRMusicViewController () <UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate, UIScrollViewDelegate>

@property (weak, nonatomic) IBOutlet UIView *playerButtonContainer;
@property (strong, nonatomic) IBOutlet UIView *topContainer;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *playButton;

@property (weak, nonatomic) IBOutlet UIButton *backButton;
@property (weak, nonatomic) IBOutlet UIButton *forwardButton;
@property (weak, nonatomic) IBOutlet UISegmentedControl *segmentedController;


@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIImageView *nowPlayingImage;
@property (weak, nonatomic) IBOutlet UILabel *nowPlayingLabel;

@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property (weak, nonatomic) IBOutlet UIView *searchBarView;

@property (nonatomic, strong) NSDictionary *songsDictionary;
@property (nonatomic, strong) NSDictionary *albumsDictionary;
@property (nonatomic, strong) NSDictionary*artistsArray;
@property (nonatomic, strong) NSDictionary *genresArray;
@property (nonatomic, strong) NSDictionary *playlistsArray;
@property (nonatomic, strong) NSDictionary *mediaItemsDictionary;
@property (nonatomic, strong) MPMusicPlayerController *musicPlayerController;
@property (nonatomic, strong) MPMediaItemCollection *musicCollection;
@property (nonatomic, strong) MPMediaItem *songToPlay;
@property (nonatomic, strong) NSArray *sections;

@end
@implementation DRMusicViewController

- (void)viewDidLoad {
    
    
    TICK;
    [super viewDidLoad];
    [self.tableView setSectionIndexColor:[UIColor blackColor]];

    
    //setup topcontainer border
    [self.tableView.layer setBorderWidth:1.0f];
    UIColor *transBlack = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.1];
    [self.tableView.layer setBorderColor: [transBlack CGColor]];
    
    
    //hooking up tableView
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    //searchbar setup
    self.searchBar.delegate = self;
    
    [self setUpSegmentSortedLists];

    TOCK;
    
    [self registerMediaPlayerNotifications];
    
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    //hide navbar
    self.navigationController.navigationBarHidden = YES;
    
    //starting music player
    self.musicPlayerController = [MPMusicPlayerController systemMusicPlayer];
    [self.musicPlayerController setShuffleMode:MPMusicShuffleModeOff];
    [self.musicPlayerController prepareToPlay];
    
    //setup song collection as initial controller
    self.musicCollection =[[MPMediaItemCollection alloc] initWithItems:
                           self.mediaItemsDictionary[@"array"]];
    [self.musicPlayerController setQueueWithItemCollection:self.musicCollection];
    
}

//show navbar for other views
-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    self.navigationController.navigationBarHidden = NO;
    
}
- (void) setUpSegmentSortedLists {
    
    MPMediaQuery *songsQuery = [MPMediaQuery songsQuery];
    self.sections = songsQuery.collectionSections;
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
    self.mediaItemsDictionary = self.songsDictionary;
    
    }


#pragma mark - Notifications

- (void) registerMediaPlayerNotifications
{
    TICK
    NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
    
    [notificationCenter addObserver: self
                           selector: @selector (handle_NowPlayingItemChanged:)
                               name: MPMusicPlayerControllerNowPlayingItemDidChangeNotification
                             object: self.musicPlayerController];
    
//    [notificationCenter addObserver: self
//                           selector: @selector (playMusic)
//                               name: MPMusicPlayerControllerPlaybackStateDidChangeNotification
//                             object: self.musicPlayerController];
    
//    [notificationCenter addObserver: self
//                           selector: @selector (pauseMusic)
//                               name: MPMusicPlayerControllerPlaybackStateDidChangeNotification
//                             object: self.musicPlayerController];
    
    //    [notificationCenter addObserver: self
    //                           selector: @selector (handle_VolumeChanged:)
    //                               name: MPMusicPlayerControllerVolumeDidChangeNotification
    //                             object: self.musicPlayerController];
    
    [self.musicPlayerController beginGeneratingPlaybackNotifications];

    TOCK
}


#pragma mark Music notification handlers__________________

// When the now-playing item changes, update the media item artwork and the now-playing label.
- (void) handle_NowPlayingItemChanged: (id) notification {
    
    TICK
        MPMediaItem *currentItem = [self.musicPlayerController nowPlayingItem];
 
       // Assume that there is no artwork for the media item.
    __block UIImage *artworkImage = nil;
    
    // Get the artwork from the current media item, if it has artwork.
    MPMediaItemArtwork *artwork = [currentItem valueForProperty: MPMediaItemPropertyArtwork];
    
    // Obtain a UIImage object from the MPMediaItemArtwork object
    NSOperationQueue *mainQueue = [NSOperationQueue mainQueue];
    NSOperationQueue *photoQueue = [[NSOperationQueue alloc] init];
    NSOperationQueue *processingQueue = [[NSOperationQueue alloc] init];

        if (artwork) {
            
            [photoQueue addOperationWithBlock:^{
                
                artworkImage = [artwork imageWithSize: CGSizeMake(self.scrollView.frame.size.width/4, self.scrollView.frame.size.height/4) ];
                
                [mainQueue addOperationWithBlock:^{
                    self.nowPlayingImage.image = artworkImage;
                }];
            }];
            
        }
  
    // Obtain a UIButton object and set its background to the UIImage object
    //    UIButton *artworkView = [[UIButton alloc] initWithFrame: CGRectMake (0, 0, 30, 30)];
    //    [artworkView setBackgroundImage: artworkImage forState: UIControlStateNormal];
    
    // Obtain a UIBarButtonItem object and initialize it with the UIButton object
    //    UIBarButtonItem *newArtworkItem = [[UIBarButtonItem alloc] initWithCustomView: artworkView];
    //    [self setArtworkItem: newArtworkItem];
    //    [newArtworkItem release];
    
    //    [artworkItem setEnabled: NO];
    
    // Display the new media item artwork
    //    [navigationBar.topItem setRightBarButtonItem: artworkItem animated: YES];
    
    [processingQueue addOperationWithBlock:^{
        self.nowPlayingImage.image = artworkImage;    // Display the artist and song name for the now-playing media item
        [self.nowPlayingLabel setText: [
                                        NSString stringWithFormat: @"%@ %@ %@ %@",
                                        NSLocalizedString (@"Now Playing:", @"Label for introducing the now-playing song title and artist"),
                                        [currentItem valueForProperty: MPMediaItemPropertyTitle],
                                        NSLocalizedString (@"by", @"Article between song name and artist name"),
                                        [currentItem valueForProperty: MPMediaItemPropertyArtist]]];
    }];
    
    
    if (self.musicPlayerController.playbackState == MPMusicPlaybackStateStopped) {
        // Provide a suitable prompt to the user now that their chosen music has
        //		finished playing.
        [self.nowPlayingLabel setText:@""
         //         [
         //                                   NSString stringWithFormat: @"%@",
         //                                   NSLocalizedString (@"Music-ended Instructions", @"Label for prompting user to play music again after it has stopped")
         //                                        ]
         ];
        
    }

    TOCK}

- (void) handle_iPodLibraryChanged: (id) notification {
    
    // Implement this method to update cached collections of media items when the
    // user performs a sync while your application is running. This sample performs
    // no explicit media queries, so there is nothing to update.
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


- (IBAction)playButtonTapped:(id)sender {
    if ([self.musicPlayerController playbackState] == MPMusicPlaybackStatePlaying) {
        
        [self pauseMusic];
        
    }
    else {
        [self playMusic];
    }
}


- (IBAction)backButtonTapped:(id)sender {
    
    [self.musicPlayerController skipToBeginning];
    NSLog(@"to Beginning");
    
    [self.musicPlayerController play];
}

- (IBAction)forwardButtonTapped:(id)sender {
    [self.musicPlayerController skipToNextItem];
    NSLog(@"skip");
    
    [self.musicPlayerController play];
}

- (IBAction)segmentedTapped:(UISegmentedControl *)sender {
    
    //TODO:  change if statements to switch
    
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
    
    if ([self.mediaItemsDictionary[@"category"] isEqualToString:@"Songs"]||[self.mediaItemsDictionary[@"category"] isEqualToString:@"Search"]) {
        
        [self.musicPlayerController stop];
        
        
        //figure out correct index
        MPMediaQuerySection *querySection = self.mediaItemsDictionary[@"sections"][indexPath.section];
        NSInteger adjustIndex = querySection.range.location + indexPath.row;
        //use index to find song
        MPMediaItem *song =(MPMediaItem *) self.mediaItemsDictionary[@"array"][adjustIndex];
        
        [self.musicPlayerController setNowPlayingItem:song];
        
        
        NSLog(@"Mediaplayer item name: %@", song.title);
        
        self.songToPlay = song;
        
        [self playMusic];

        TOCK;
    }
    
    else {
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

-(void) playMusic{
    TICK;
    if (!self.songToPlay) {
        self.songToPlay = self.musicPlayerController.nowPlayingItem ;
        //        mediaItemsDictionary[@"array"][0];
    }
    
    
    [self.musicPlayerController play];
    [self changePlayOrPauseButtonToType:UIBarButtonSystemItemPause];
    
    
    
    
    
    

    TOCK;
    
}

-(void) pauseMusic {
    
    TICK
    
    [self.musicPlayerController pause];
    [self changePlayOrPauseButtonToType: UIBarButtonSystemItemPlay];

    TOCK;
    
}

-(void) changePlayOrPauseButtonToType: (UIBarButtonSystemItem) buttonType {
    
    TICK
    NSMutableArray *items = [self.navigationController.toolbar.items mutableCopy];
    
    UIBarButtonItem *item = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:buttonType target:self action:@selector(playButtonTapped:)];
    
    [items replaceObjectAtIndex:3 withObject:item];
    self.navigationController.toolbar.items = items;

    TOCK
    
}

@end
