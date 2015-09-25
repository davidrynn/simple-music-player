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
#import "GVMusicPlayerController.h"


@interface DRArtistTableViewController ()
@property (nonatomic, strong) NSArray *songs;
@property (nonatomic, strong) NSArray *albumsArray;
@property (nonatomic, strong) NSMutableDictionary *albumsDictionary;
@property (nonatomic, strong) NSArray *rangeArray;
@property (nonatomic, strong) MPMediaItem *songToPlay;
@property (nonatomic, strong) GVMusicPlayerController *musicPlayer;
@property (nonatomic, strong) UIImageView *nowPlayingImage;
@property (nonatomic, strong) UILabel *nowPlayingLabel;
@property   (nonatomic, assign) BOOL mediaCollected;
@property (nonatomic) BOOL shuffleWasOn;
@end

@implementation DRArtistTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    //starting music player
    self.musicPlayer = [GVMusicPlayerController sharedInstance];
    
    //set header to display artist's name
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.tableView.frame.size.width, 50.0)];
    UILabel *artistLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 10, self.tableView.frame.size.width, 20)];
    artistLabel.text = self.mediaCollection.representativeItem.artist;
    artistLabel.textColor = self.view.tintColor;
    artistLabel.textAlignment = NSTextAlignmentCenter;
    artistLabel.font = [UIFont boldSystemFontOfSize:21.0];
    [headerView addSubview:artistLabel];
    headerView.backgroundColor = [UIColor whiteColor];
    self.tableView.tableHeaderView = headerView;
    
    //setup loop and shuffle buttons
    UIBarButtonItem *loopButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"loop"] style:UIBarButtonItemStylePlain target:self action:@selector(loopButtonTapped:)];
    UIBarButtonItem *shuffleButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"shuffle"] style:UIBarButtonItemStylePlain target:self action:@selector(shuffleButtonTapped:)];
    self.navigationItem.rightBarButtonItems = @[shuffleButton, loopButton];

    
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    NSSortDescriptor *albumSort = [[NSSortDescriptor alloc] initWithKey:MPMediaItemPropertyAlbumTitle ascending:YES];
    NSSortDescriptor *songSort = [[NSSortDescriptor alloc] initWithKey:MPMediaItemPropertyAlbumTrackNumber ascending:YES];
    self.songs = [[self.mediaCollection items] sortedArrayUsingDescriptors:@[albumSort, songSort]];

    
    //using NSSet cannot repeat album title
    //so using it to get array of album titles
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

#pragma mark - TableView dataSource

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 50;
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    
    NSRange sectionRange = [self.rangeArray[section] rangeValue];
    NSUInteger index = sectionRange.location;
    MPMediaItem *representativeItem = self.songs[index];
    
    MPMediaItemArtwork *artwork = representativeItem.artwork;
    UIImage *image = [artwork imageWithSize:CGSizeMake(40.0, 40.0)];
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(10, 5, 40, 40)];
    imageView.image = image;
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.tableView.frame.size.width, 40)];
    [view addSubview:imageView];
    
    UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake(imageView.frame.size.width + 20, 5, self.tableView.frame.size.width - 60, 30)];
    title.text = self.albumsArray[section];
    [view addSubview:title];
    view.backgroundColor = [UIColor colorWithRed:245/255.0 green:245/255.0 blue:245/255.0 alpha:1];
    
    return view;
    
    
}


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
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    TICK
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (self.musicPlayer.shuffleMode==MPMusicShuffleModeSongs) {
        
        [self.musicPlayer setShuffleMode: MPMusicShuffleModeOff];
   //     self.shuffleButton.image = [UIImage imageNamed:@"shuffle"];
    }
    if (!self.mediaCollected) {
        //setup song collection as initial controller
        MPMediaItemCollection *collection = [MPMediaItemCollection collectionWithItems:self.songs];
        [self.musicPlayer setQueueWithItemCollection:collection];
        self.mediaCollected = YES;
    }
    [self.musicPlayer stop];
    
    
    //figure out correct index
    NSRange sectionRange = [self.rangeArray[indexPath.section] rangeValue];
    NSInteger adjustIndex = sectionRange.location + indexPath.row;
    //use index to find song
    MPMediaItem *song =(MPMediaItem *) self.songs[adjustIndex];
    
    [self.musicPlayer playItemAtIndex:adjustIndex];
    
    NSLog(@"Mediaplayer item name: %@,%@", song.title, [self.musicPlayer nowPlayingItem].title);
    
    self.songToPlay = song;

    [self playMusic];
    
    TOCK;
    
}

#pragma mark - button actions
- (void)shuffleButtonTapped:(UIBarButtonItem *)sender {
    
    if( self.musicPlayer.shuffleMode == MPMusicShuffleModeSongs){
        [self.musicPlayer setShuffleMode:MPMusicShuffleModeOff];
        sender.image = [UIImage imageNamed:@"shuffle"];
        self.shuffleWasOn = YES;
        
    } else{
        [self.musicPlayer setShuffleMode:MPMusicShuffleModeSongs]
        ;
        sender.image = [UIImage imageNamed:@"shuffleSelected"];
        self.shuffleWasOn = NO;
        
    }
    
}
- (void)loopButtonTapped:(UIBarButtonItem *)sender {
    
    if( self.musicPlayer.repeatMode == MPMusicRepeatModeAll){
        [self.musicPlayer setRepeatMode:MPMusicRepeatModeOne];
        sender.image = [UIImage imageNamed:@"loop1Selected"];
        
    } else if( self.musicPlayer.repeatMode == MPMusicRepeatModeOne){
        [self.musicPlayer setRepeatMode:MPMusicRepeatModeNone];
        sender.image = [UIImage imageNamed:@"loop"];
        
    } else {
        [self.musicPlayer setRepeatMode:MPMusicRepeatModeAll];
        sender.image = [UIImage imageNamed:@"loopSelected"];
        
    }
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
    
    [self.musicPlayer pause];
    
    
    TOCK;
    
}


@end
