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
    
    //setup song collection as initial controller
    [self.musicPlayerController setQueueWithItemCollection:self.mediaCollection];
    [self.musicPlayerController beginGeneratingPlaybackNotifications];

}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    NSSortDescriptor *albumSort = [[NSSortDescriptor alloc] initWithKey:MPMediaItemPropertyAlbumTitle ascending:YES];
    NSSortDescriptor *songSort = [[NSSortDescriptor alloc] initWithKey:MPMediaItemPropertyAlbumTrackNumber ascending:YES];
    self.songs = [[self.mediaCollection items] sortedArrayUsingDescriptors:@[albumSort, songSort]];
    MPMediaItem *firstSong = self.songs[0];
    self.navigationItem.title =[NSString stringWithFormat:@"%@", firstSong.artist];
    
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
    return 40;
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    
        NSRange sectionRange = [self.rangeArray[section] rangeValue];
        NSUInteger index = sectionRange.location;
        MPMediaItem *representativeItem = self.songs[index];

        MPMediaItemArtwork *artwork = representativeItem.artwork;
        UIImage *image = [artwork imageWithSize:CGSizeMake(40.0, 40.0)];
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 40, 40)];
    imageView.image = image;
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.tableView.frame.size.width, 40)];
    [view addSubview:imageView];
    
    UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake(50, 0, self.tableView.frame.size.width - 60, 30)];
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

    }
    
    
    [self.musicPlayerController play];
    
    TOCK;
    
}

-(void) pauseMusic {
    
    TICK
    
    [self.musicPlayerController pause];

    
    TOCK;
    
}

-(void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver: self
                                                    name: MPMusicPlayerControllerNowPlayingItemDidChangeNotification
                                                  object: self.musicPlayerController];
    
    [[NSNotificationCenter defaultCenter] removeObserver: self
                                                    name: MPMusicPlayerControllerPlaybackStateDidChangeNotification
                                                  object: self.musicPlayerController];
    
    [self.musicPlayerController endGeneratingPlaybackNotifications];
}

@end
