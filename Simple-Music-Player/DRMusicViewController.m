//
//  DRMusicViewController.m
//  Simple-Music-Player
//
//  Created by David Rynn on 8/1/15.
//  Copyright (c) 2015 David Rynn. All rights reserved.
//

#define TICK   NSDate *startTime = [NSDate date]
#define WILLDEFINE NSString *willDefine
#define TOCK   NSLog(@"Time for %@: %f", willDefine, -[startTime timeIntervalSinceNow])

#import "DRMusicViewController.h"
@import MediaPlayer;

@interface DRMusicViewController () <UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate, UISearchControllerDelegate>
@property (weak, nonatomic) IBOutlet UIView *playerButtonContainer;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIButton *playButton;
@property (weak, nonatomic) IBOutlet UIButton *backButton;
@property (weak, nonatomic) IBOutlet UIButton *forwardButton;
@property (weak, nonatomic) IBOutlet UISegmentedControl *segmentedController;
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property (weak, nonatomic) IBOutlet UIImageView *nowPlayingImage;
@property (weak, nonatomic) IBOutlet UILabel *nowPlayingLabel;

@property (nonatomic, strong) NSDictionary *songsDictionary;
@property (nonatomic, strong) NSDictionary *albumsDictionary;
@property (nonatomic, strong) NSDictionary*artistsArray;
@property (nonatomic, strong) NSDictionary *genresArray;
@property (nonatomic, strong) NSDictionary *playlistsArray;
@property (nonatomic, strong) NSDictionary *mediaItemsDictionary;
@property (nonatomic, strong) MPMusicPlayerController *musicPlayerController;
@property (nonatomic, strong) MPMediaItemCollection *musicCollection;
@property (nonatomic, strong) MPMediaItem *songToPlay;
@property (nonatomic, strong) NSArray *searchResults;

@end



@implementation DRMusicViewController

- (void)viewDidLoad {
    TICK;
    [super viewDidLoad];
    
    //hooking up tableView
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    
    //trying to make a shadow
    self.playerButtonContainer.layer.shadowColor     = [[UIColor blackColor] CGColor];
    self.playerButtonContainer.layer.shadowOffset    = CGSizeMake (0, -1);
    self.playerButtonContainer.layer.shadowOpacity   = 1.0f;
    
    //starting music player
    
    self.musicPlayerController = [MPMusicPlayerController systemMusicPlayer];
    
    
    //setup five views
    MPMediaQuery *songsQuery = [MPMediaQuery songsQuery];
    songsQuery.groupingType = MPMediaGroupingTitle;
    //TODO: setting up sections..
    NSArray *songSectionHeaders = @[@"A",@"B", @"C"];
    
    
    self.songsDictionary = @{@"category": @"Songs",
                             @"array": [songsQuery items],
                             @"sectionHeaderArray":songSectionHeaders};
    self.mediaItemsDictionary = self.songsDictionary;
    //   [self.musicPlayerController setQueueWithItemCollection:self.mediaItemsDictionary[@"array"]] ;
    
    MPMediaQuery *albumsQuery=[MPMediaQuery albumsQuery];
    albumsQuery.groupingType = MPMediaGroupingAlbum;
    self.albumsDictionary = @{@"category": @"Albums",
                              @"array":[albumsQuery items]};
    
    MPMediaQuery *artistsQuery =[MPMediaQuery artistsQuery];
    artistsQuery.groupingType = MPMediaGroupingArtist;
    self.artistsArray = @{@"category":@"Artists",
                          @"array":[artistsQuery items]};
    
    MPMediaQuery *genresQuery = [MPMediaQuery genresQuery];
    genresQuery.groupingType = MPMediaGroupingGenre;
    self.genresArray = @{@"category":@"Genres",
                         @"array":[genresQuery items]};
    
    MPMediaQuery *playlistsQuery = [MPMediaQuery playlistsQuery];
    playlistsQuery.groupingType = MPMediaGroupingPlaylist;
    self.playlistsArray = @{@"category":@"Playlists",
                            @"array": [playlistsQuery items]};
    
    //setup song collection
    self.musicCollection =[[MPMediaItemCollection alloc] initWithItems:self.mediaItemsDictionary[@"array"]];
    [self.musicPlayerController setQueueWithItemCollection:self.musicCollection];
    [self registerMediaPlayerNotifications];
    
    NSString *willDefine = @"viewDidLoad";
    TOCK;
    
    
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
//- (IBAction)backButtontapRepeated:(id)sender {
//
//    [self.musicPlayerController skipToPreviousItem];
//    NSLog(@"previous");
//
//    [self.musicPlayerController play];
//}

- (IBAction)forwardButtonTapped:(id)sender {
    [self.musicPlayerController skipToNextItem];
    NSLog(@"skip");
    
    [self.musicPlayerController play];
}

- (IBAction)segmentedTapped:(UISegmentedControl *)sender {
    
    //    TODO change if statements to switch
    
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
//#pragma mark - UISearchDisplayController Delegate Methods
//-(BOOL)searchController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString {
//    // Tells the table data source to reload when text changes
//    [self filterContentForSearchText:searchString scope:
//     [[self.searchDisplayController.searchBar scopeButtonTitles] objectAtIndex:[self.searchDisplayController.searchBar selectedScopeButtonIndex]]];
//    // Return YES to cause the search result table view to be reloaded.
//    return YES;
//}
//
//-(BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchScope:(NSInteger)searchOption {
//    // Tells the table data source to reload when scope bar selection changes
//    [self filterContentForSearchText:self.searchDisplayController.searchBar.text scope:
//     [[self.searchDisplayController.searchBar scopeButtonTitles] objectAtIndex:searchOption]];
//    // Return YES to cause the search result table view to be reloaded.
//    return YES;
//}
//


//End Search Function


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSArray *array = self.songsDictionary[@"array"];
    return array.count;
}
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    //    if ([self.mediaItemsDictionary[@"category"] isEqualToString:@"Songs"]) {
    //        NSArray *arrayCast = self.mediaItemsDictionary[@"sectionHeaderArray"];
    //        return arrayCast.count;
    //    }
    
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
    
    NSString *mediaTypeString = self.mediaItemsDictionary[@"category"];
    
    if (mediaTypeString) {
        
        MPMediaItem *item = (MPMediaItem *) self.mediaItemsDictionary[@"array"][indexPath.row];
        
        cell.textLabel.text =[NSString stringWithFormat:@"%@", item.title];
        cell.detailTextLabel.text = [NSString stringWithFormat:@"%@ -- %@", item.artist, item.albumTitle];
        
        if (!item.artwork) {
            cell.imageView.image = [UIImage imageNamed:@"noteBW"];
        }
        else
        {
            //        UIImage *albumArtWork = [item.artwork imageWithSize:CGSizeMake(cell.frame.size.height, cell.frame.size.height)];
            
            cell.imageView.image = [item.artwork  imageWithSize:CGSizeMake(60.0, 60.0)];
        }
        
    }
    
    
    return cell;
}


////Trying to test tableview load
//-(void) tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
//{   TICK;
//    if([indexPath row] == ((NSIndexPath*)[[tableView indexPathsForVisibleRows] lastObject]).row){
//        //end of loading
//        //for example [activityIndicator stopAnimating];
//    }
//    WILLDEFINE = @"tableview load";
//    TOCK;
//}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    
    [self.musicPlayerController stop];
    
    WILLDEFINE = @"stop";
    
    MPMediaItem *song =(MPMediaItem *) self.mediaItemsDictionary[@"array"][indexPath.row];
    
    [self.musicPlayerController setNowPlayingItem:song];
    
    
    NSLog(@"Mediaplayer item name: %@", song.title);
    
    self.songToPlay = song;
    TICK;
    [self.musicPlayerController play];
    willDefine = @"to setup did selectROw";
    TOCK;
 
    
}







//
//-(void)timeMethodTesterWithBlock:(void(^)(parameterTypes))blockName
//{
//
//
//
//NSDate *beforePlayerStop = [NSDate date];
//
//// code to test
//
//    blockName();
//
//NSDate *afterPlayerStop = [NSDate date];
//NSTimeInterval timeTaken = [afterPlayerStop timeIntervalSinceDate:beforePlayerStop];
//NSLog(@"Time for playerstop = %f", timeTaken);
//
//}



/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

@end
