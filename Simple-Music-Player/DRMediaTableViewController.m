//
//  DRMediaTableViewController.m
//  Simple-Music-Player
//
//  Created by David Rynn on 9/1/15.
//  Copyright (c) 2015 David Rynn. All rights reserved.
//

#define TICK CFTimeInterval startTime = CACurrentMediaTime();
#define TOCK   NSLog(@"Time for %@: %f", NSStringFromSelector(_cmd), (CACurrentMediaTime()-startTime));

#import "DRMediaTableViewController.h"
#import "GVMusicPlayerController.h"

@interface DRMediaTableViewController ()
@property (nonatomic, strong) MPMediaItem *songToPlay;
@property (nonatomic, strong) GVMusicPlayerController *musicPlayer;
@property (nonatomic) BOOL shuffleWasOn;
@end

@implementation DRMediaTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    //starting music player
    self.musicPlayer = [GVMusicPlayerController sharedInstance];
    
    //setup song collection as initial controller
    [self.musicPlayer setQueueWithItemCollection:self.mediaCollection];
    self.songs = [self.mediaCollection items];
    
    //setup loop and shuffle buttons
    UIBarButtonItem *loopButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"loop"] style:UIBarButtonItemStylePlain target:self action:@selector(loopButtonTapped:)];
    UIBarButtonItem *shuffleButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"shuffle"] style:UIBarButtonItemStylePlain target:self action:@selector(shuffleButtonTapped:)];
    self.navigationItem.rightBarButtonItems = @[shuffleButton, loopButton];
    
    
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    // Return the number of rows in the section.
    return self.songs.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    
    // Configure the cell...
    MPMediaItem *item = self.songs[indexPath.row];
    cell.textLabel.text = [NSString stringWithFormat:@"%@ -- %@",item.title, item.artist];
    cell.imageView.image = [item.artwork imageWithSize:CGSizeMake(60.0f, 60.0f)];

    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    TICK
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    [self.musicPlayer stop];
    if (self.musicPlayer.shuffleMode==MPMusicShuffleModeSongs) {
        
        [self.musicPlayer setShuffleMode: MPMusicShuffleModeOff];
        //    self.shuffleButton.image = [UIImage imageNamed:@"shuffle"];
    }
    
    [self.musicPlayer playItemAtIndex:indexPath.row];
    
    [self playMusic];
    
    TOCK;
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
    
    [self.musicPlayer play];
    
    TOCK;
    
}

-(void) pauseMusic {
    
    TICK
    
    [self.musicPlayer pause];
    
    TOCK;
    
}



@end
