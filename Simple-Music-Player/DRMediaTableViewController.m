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
@property (nonatomic, strong) GVMusicPlayerController *musicPlayerController;
@end

@implementation DRMediaTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    //starting music player
    self.musicPlayerController = [GVMusicPlayerController sharedInstance];
    
    //setup song collection as initial controller
    [self.musicPlayerController setQueueWithItemCollection:self.mediaCollection];
    self.songs = [self.mediaCollection items];


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
    [self.musicPlayerController stop];
   
    [self.musicPlayerController playItemAtIndex:indexPath.row];

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
    
    [self.musicPlayerController play];
    
    TOCK;
    
}

-(void) pauseMusic {
    
    TICK
    
    [self.musicPlayerController pause];

    TOCK;
    
}



@end
