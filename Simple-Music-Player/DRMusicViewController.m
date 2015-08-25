//
//  DRMusicViewController.m
//  Simple-Music-Player
//
//  Created by David Rynn on 8/1/15.
//  Copyright (c) 2015 David Rynn. All rights reserved.
//

#define TICK CFTimeInterval startTime = CACurrentMediaTime();
#define WILLDEFINE NSString *willDefine
#define TOCK   NSLog(@"Time for %@: %f", willDefine, (CACurrentMediaTime()-startTime));

#import "DRMusicViewController.h"

@import MediaPlayer;

@interface DRMusicViewController () <UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate>

@property (weak, nonatomic) IBOutlet UIView *playerButtonContainer;
@property (strong, nonatomic) IBOutlet UIView *topContainer;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIButton *playButton;
@property (weak, nonatomic) IBOutlet UIButton *backButton;
@property (weak, nonatomic) IBOutlet UIButton *forwardButton;
@property (weak, nonatomic) IBOutlet UISegmentedControl *segmentedController;


@property (weak, nonatomic) IBOutlet UIImageView *nowPlayingImage;
@property (weak, nonatomic) IBOutlet UILabel *nowPlayingLabel;

@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property (weak, nonatomic) IBOutlet UIView *searchBarView;
@property (nonatomic, strong) NSDictionary *searchResults;


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
    
    //hooking up tableView
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    
    //starting music player
    self.musicPlayerController = [MPMusicPlayerController systemMusicPlayer];
    
    //searchbar setup
    self.searchBar.delegate = self;
    
    [self setUpSegmentSortedLists];
    
    
    
    //setup song collection as initial controller
    self.musicCollection =[[MPMediaItemCollection alloc] initWithItems:
                           self.mediaItemsDictionary[@"array"]];
    [self.musicPlayerController setQueueWithItemCollection:self.musicCollection];
    [self registerMediaPlayerNotifications];
    
    NSString *willDefine = @"viewDidLoad";
    TOCK;
    
    
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
    NSLog(@"number of albums: %ld", albumsQuery.collections.count);
    
    MPMediaQuery *artistsQuery =[MPMediaQuery artistsQuery];
    artistsQuery.groupingType = MPMediaGroupingArtist;
    self.artistsArray = @{@"category":@"Artists",
                          @"array":artistsQuery.collections,
                          @"sections": artistsQuery.collectionSections
                          };
    NSLog(@"number of artists: %ld", artistsQuery.collections.count);
    
    MPMediaQuery *genresQuery = [MPMediaQuery genresQuery];
    genresQuery.groupingType = MPMediaGroupingGenre;
    self.genresArray = @{@"category":@"Genres",
                         @"array":[genresQuery collections],
                         @"sections": genresQuery.collectionSections
                         };
     NSLog(@"number of genres: %ld", genresQuery.collections.count);
    
    MPMediaQuery *playlistsQuery = [MPMediaQuery playlistsQuery];
    playlistsQuery.groupingType = MPMediaGroupingPlaylist;
    self.playlistsArray = @{@"category":@"Playlists",
                            @"array": [playlistsQuery collections],
                            @"sections": playlistsQuery.collectionSections
                            };
        NSLog(@"number of playlists: %ld", playlistsQuery.collections.count);
    
    
    NSLog(@"number of songs: %ld", songsQuery.collections.count);
    self.mediaItemsDictionary = self.songsDictionary;
    
    
}

#pragma mark - Notifications

- (void) registerMediaPlayerNotifications
{
    NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
    
    [notificationCenter addObserver: self
                           selector: @selector (handle_NowPlayingItemChanged:)
                               name: MPMusicPlayerControllerNowPlayingItemDidChangeNotification
                             object: self.musicPlayerController];
    
    [notificationCenter addObserver: self
                           selector: @selector (handle_PlaybackStateChanged:)
                               name: MPMusicPlayerControllerPlaybackStateDidChangeNotification
                             object: self.musicPlayerController];
    
    //    [notificationCenter addObserver: self
    //                           selector: @selector (handle_VolumeChanged:)
    //                               name: MPMusicPlayerControllerVolumeDidChangeNotification
    //                             object: self.musicPlayerController];
    
    [self.musicPlayerController beginGeneratingPlaybackNotifications];
}


#pragma mark Music notification handlers__________________

// When the now-playing item changes, update the media item artwork and the now-playing label.
- (void) handle_NowPlayingItemChanged: (id) notification {
    
    MPMediaItem *currentItem = [self.musicPlayerController nowPlayingItem];
    
    // Assume that there is no artwork for the media item.
    UIImage *artworkImage = nil;
    
    // Get the artwork from the current media item, if it has artwork.
    MPMediaItemArtwork *artwork = [currentItem valueForProperty: MPMediaItemPropertyArtwork];
    
    // Obtain a UIImage object from the MPMediaItemArtwork object
    if (artwork) {
        artworkImage = [artwork imageWithSize: CGSizeMake (30, 30)];
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
    
    self.nowPlayingImage.image = artworkImage;
    // Display the artist and song name for the now-playing media item
    [self.nowPlayingLabel setText: [
                                    NSString stringWithFormat: @"%@ %@ %@ %@",
                                    NSLocalizedString (@"Now Playing:", @"Label for introducing the now-playing song title and artist"),
                                    [currentItem valueForProperty: MPMediaItemPropertyTitle],
                                    NSLocalizedString (@"by", @"Article between song name and artist name"),
                                    [currentItem valueForProperty: MPMediaItemPropertyArtist]]];
    
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
}

// When the playback state changes, set the play/pause button in the Navigation bar
//		appropriately.
- (void) handle_PlaybackStateChanged: (id) notification {
    
    
    
    //    MPMusicPlaybackState playbackState = [musicPlayer playbackState];
    //
    //    if (playbackState == MPMusicPlaybackStatePaused) {
    //
    //        navigationBar.topItem.leftBarButtonItem = playBarButton;
    //
    //    } else if (playbackState == MPMusicPlaybackStatePlaying) {
    //
    //        navigationBar.topItem.leftBarButtonItem = pauseBarButton;
    //
    //    } else if (playbackState == MPMusicPlaybackStateStopped) {
    //
    //        navigationBar.topItem.leftBarButtonItem = playBarButton;
    //
    //        // Even though stopped, invoking 'stop' ensures that the music player will play
    //        //		its queue from the start.
    //        [musicPlayer stop];
    //
    //    }
}

- (void) handle_iPodLibraryChanged: (id) notification {
    
    // Implement this method to update cached collections of media items when the
    // user performs a sync while your application is running. This sample performs
    // no explicit media queries, so there is nothing to update.
}



#pragma mark - button actions
- (IBAction)playButtonTapped:(id)sender {
    TICK;
    UIButton *button = (UIButton *)sender;
    
    
    if ([self.musicPlayerController playbackState] == MPMusicPlaybackStatePlaying) {
        button.titleLabel.text = @"Pause";
        [self.musicPlayerController pause];
        
    } else if(self.songToPlay){
        
        [self.musicPlayerController play];
        
    }
    else {
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"No music selected"
                                                        message:@"You must be select music in order to play it."
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
        
    }
    WILLDEFINE =@"playbutton";
    TOCK;
    
    
    
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
    [searchBar setShowsCancelButton:NO animated:YES];
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
    self.searchResults = [self performSearchWithString: searchText];
    self.mediaItemsDictionary = self.searchResults;
    [self.tableView reloadData];
}

#pragma mark - Search Function

-(NSDictionary*) performSearchWithString: (NSString*) searchString
{
    
    MPMediaPropertyPredicate *songsPredicate = [MPMediaPropertyPredicate predicateWithValue:searchString forProperty:MPMediaItemPropertyTitle comparisonType:MPMediaPredicateComparisonContains];
    
    MPMediaQuery *songsSearchQuery = [[MPMediaQuery alloc] init];
    songsSearchQuery.groupingType = MPMediaGroupingTitle;

    [songsSearchQuery addFilterPredicate:songsPredicate];
     NSDictionary *searchDictionary = @{@"category":@"Search",
                            @"array": [songsSearchQuery items],
                            @"sections": songsSearchQuery.collectionSections
                            };
    
//TODO: add search results by artist, albums and playlists
    return searchDictionary;
}


//- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar{
//
//
//}
//- (void)filterContentForSearchText:(NSString*)searchText scope:(NSString*)scope
//{
//    NSPredicate *resultPredicate = [NSPredicate predicateWithFormat:@"name contains[c] %@", searchText];
//    self.searchResults = [self.songsDictionary[@"array"] filteredArrayUsingPredicate:resultPredicate];
//}
//


//End Search Function


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma tableview setup

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
    
    if ([self.mediaItemsDictionary[@"category"] isEqualToString:@"Songs"]||[self.mediaItemsDictionary[@"category"] isEqualToString:@"Search"]) {
  
    
    [self.musicPlayerController stop];
    
    WILLDEFINE = @"stop";
    MPMediaQuerySection *querySection = self.mediaItemsDictionary[@"sections"][indexPath.section];
    NSInteger adjustIndex = querySection.range.location + indexPath.row;
    
    MPMediaItem *song =(MPMediaItem *) self.mediaItemsDictionary[@"array"][adjustIndex];
    
    [self.musicPlayerController setNowPlayingItem:song];
    
    
    NSLog(@"Mediaplayer item name: %@", song.title);
    
    self.songToPlay = song;
    TICK;
    [self.musicPlayerController play];
    willDefine = @"to setup did selectROw";
    TOCK;
    }
    
    
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
