//
//  DRArtistTableViewController.m
//  Simple-Music-Player
//
//  Created by David Rynn on 8/31/15.
//  Copyright (c) 2015 David Rynn. All rights reserved.
//

#define TICK CFTimeInterval startTime = CACurrentMediaTime();
#define TOCK   NSLog(@"Time for %@: %f", NSStringFromSelector(_cmd), (CACurrentMediaTime()-startTime));

#import "DRArtistTableViewController.h"


@interface DRArtistTableViewController ()
@property (nonatomic, strong) NSArray *songs;
@property (nonatomic, strong) NSArray *albumsArray;
@property (nonatomic, strong) NSMutableDictionary *albumsDictionary;
@property (nonatomic, strong) NSArray *rangeArray;
@property (nonatomic, strong) MPMediaItem *songToPlay;
@property (nonatomic, strong) MPMusicPlayerController *musicPlayerController;
@property (nonatomic, strong) UIImageView *nowPlayingImage;
@property (nonatomic, strong) UILabel *nowPlayingLabel;
@end

@implementation DRArtistTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    //starting music player
    self.musicPlayerController = [MPMusicPlayerController systemMusicPlayer];
    [self.musicPlayerController setShuffleMode:MPMusicShuffleModeOff];

    
    //setup song collection as initial controller
    [self.musicPlayerController setQueueWithItemCollection:self.mediaCollection];
    [self registerMediaPlayerNotifications];
    
    
}
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    NSSortDescriptor *albumSort = [[NSSortDescriptor alloc] initWithKey:MPMediaItemPropertyAlbumTitle ascending:YES];
    NSSortDescriptor *songSort = [[NSSortDescriptor alloc] initWithKey:MPMediaItemPropertyTitle ascending:YES];
    self.songs = [[self.mediaCollection items] sortedArrayUsingDescriptors:@[albumSort, songSort]];
    MPMediaItem *firstSong = self.songs[0];
    self.navigationItem.title =[NSString stringWithFormat:@"%@", firstSong.artist];
    
    NSMutableSet *albumSet = [[NSMutableSet alloc] init];
    
    for (MPMediaItem *song in self.songs) {
        [albumSet addObject:song.albumTitle];
    }
    NSSortDescriptor *albumTitleSort = [[NSSortDescriptor alloc] initWithKey:@"" ascending:YES];
    self.albumsArray = [albumSet sortedArrayUsingDescriptors:@[albumTitleSort]];
    NSMutableArray *rangeArray = [NSMutableArray arrayWithCapacity:self.albumsArray.count];
    //for creating range
    NSUInteger arrayPlacement=0;
    
    
    for (NSUInteger i=0; i<self.albumsArray.count; i++) {
        //sets up the songs in each section
        NSMutableArray *albumSectionSongs= [[NSMutableArray alloc] init];
        for (MPMediaItem *song in self.songs) {
            if ([song.albumTitle isEqualToString:self.albumsArray[i]] ) {
                [albumSectionSongs addObject:song];
            }
        }
        
        NSRange sectionRange = NSMakeRange(arrayPlacement, albumSectionSongs.count);
        [rangeArray insertObject:[NSValue valueWithRange:sectionRange] atIndex:i];
        arrayPlacement +=albumSectionSongs.count;
    }
    self.rangeArray = [rangeArray copy];


}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {

    // Return the number of sections.
    return self.albumsArray.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    NSInteger count = 0;
    
    for (MPMediaItem *song in self.songs) {
        if ([song.albumTitle isEqualToString:self.albumsArray[section]]) {
            count++;
        }
    }
    
    return count;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{

    return self.albumsArray[section];
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    NSRange sectionRange = [self.rangeArray[indexPath.section] rangeValue];
    
 NSInteger adjustIndex = sectionRange.location + indexPath.row;
    MPMediaItem * item = self.songs[adjustIndex];
    cell.textLabel.text =[NSString stringWithFormat:@"%@", item.title];
    cell.imageView.image = [item.artwork  imageWithSize:CGSizeMake(60.0, 60.0)];
 
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    TICK

    

        
        [self.musicPlayerController stop];
        
        
        //figure out correct index
        NSRange sectionRange = [self.rangeArray[indexPath.section] rangeValue];
        NSInteger adjustIndex = sectionRange.location + indexPath.row;
        //use index to find song
        MPMediaItem *song =(MPMediaItem *) self.songs[adjustIndex];
        
        [self.musicPlayerController setNowPlayingItem:song];
        
        
        NSLog(@"Mediaplayer item name: %@", song.title);
        
        self.songToPlay = song;
        
        [self playMusic];
        
        TOCK;
    
    
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
    
    TOCK
}

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

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
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

    
    
    
    
    
    
    
    TOCK;
    
}

-(void) pauseMusic {
    
    TICK
    
    [self.musicPlayerController pause];

    
    TOCK;
    
}



@end
