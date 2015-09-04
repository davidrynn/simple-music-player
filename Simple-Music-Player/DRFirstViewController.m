//
//  DRFirstViewController.m
//  Simple-Music-Player
//
//  Created by David Rynn on 9/3/15.
//  Copyright (c) 2015 David Rynn. All rights reserved.
//

#define TICK CFTimeInterval startTime = CACurrentMediaTime();
#define TOCK   NSLog(@"Time for %@: %f", NSStringFromSelector(_cmd), (CACurrentMediaTime()-startTime));

#import "DRFirstViewController.h"
@import MediaPlayer;

@interface DRFirstViewController () <UIScrollViewDelegate>
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UILabel *nowPlayingLabel;
@property (weak, nonatomic) IBOutlet UIImageView *nowPlayingImage;
@property (weak, nonatomic) IBOutlet UIView *buttonContainer;
@property (weak, nonatomic) IBOutlet UIButton *playerButton;
@property (weak, nonatomic) IBOutlet UIButton *previousButton;
@property (weak, nonatomic) IBOutlet UIButton *forwardButton;

@property (nonatomic, strong) id<RootViewDelegate> delegate;
@property (nonatomic, strong) MPMusicPlayerController *musicPlayer;


@end

@implementation DRFirstViewController


-(void)viewDidLoad{
    [super viewDidLoad];
    //setup scrollview
    [self setUpScrollView];
    
    self.musicPlayer = [MPMusicPlayerController systemMusicPlayer];
    [self.musicPlayer prepareToPlay];
    [self.playerButton.layer setShadowColor:[[UIColor blackColor] CGColor]];
    self.playerButton.layer.shadowOpacity = 0.8
    ;
    self.playerButton.layer.shadowRadius = 1;
    self.playerButton.layer.shadowOffset = CGSizeMake(2.0f, 2.0f);
    
}


-(void)nowPlayingStateChange{
    
    
    TICK
    MPMediaItem *currentItem = [self.musicPlayer nowPlayingItem];
    
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
    
    
    if (self.musicPlayer.playbackState == MPMusicPlaybackStateStopped) {
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

#pragma mark Scroll View

-(void)setUpScrollView{
    // In the next section we will implement a delegate method to show and hide the contained view controller in the scrollview.
    self.scrollView.delegate = self;
    // We disable paging to allow the scrollview to move freely and not "stick" to the next page.
    self.scrollView.pagingEnabled = NO;
    // We hide the vertical scroll indicator because we do not want our end user to realize we are using a scroll view.
    self.scrollView.showsVerticalScrollIndicator = NO;
    // This property allows the scroll view to "spring" up and down when we reach the end of the content.
    self.scrollView.alwaysBounceVertical = NO;
    // This prevents the scroll view from moving horizontally
    self.scrollView.alwaysBounceHorizontal = NO;
    // This creates a buffer area on top of the scroll view's contents (our contained view controller) and expands the content area without changing the size of the subview
    self.scrollView.contentInset = UIEdgeInsetsMake(460,0,0,0);
    
    
}
-(void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset{
    
    if (scrollView == self.scrollView) {
        
        if (velocity.y >= 0) {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0), dispatch_get_main_queue(), ^{
                [UIView animateWithDuration:.1 animations:^{
                    
                    [scrollView setContentOffset:CGPointMake(0, 0) animated:NO];
                }];
            });
            
        } else {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0), dispatch_get_main_queue(), ^{
                [UIView animateWithDuration:.1 animations:^{
                    
                    [scrollView setContentOffset:CGPointMake(0, -460) animated:NO];
                }];
            });
        }
    }
}

#pragma mark - Miscellaneous

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
    [[NSNotificationCenter defaultCenter] removeObserver: self
                                                    name: MPMusicPlayerControllerPlaybackStateDidChangeNotification
                                                  object: self.musicPlayer];
    
    [self.musicPlayer endGeneratingPlaybackNotifications];
    // Dispose of any resources that can be recreated.
}

- (IBAction) playOrPauseMusic: (id)sender {
    
    MPMusicPlaybackState playbackState = [self.musicPlayer playbackState];
    
    if (playbackState == MPMusicPlaybackStateStopped || playbackState == MPMusicPlaybackStatePaused) {
        [self.musicPlayer play];
    } else if (playbackState == MPMusicPlaybackStatePlaying) {
        [self.musicPlayer pause];
    }
}

//-(void) playMusic{
//    TICK;
//    if (!self.songToPlay) {
//        self.songToPlay = self.musicPlayerController.nowPlayingItem ;
//        //        mediaItemsDictionary[@"array"][0];
//    }
//    
//    
//    [self.musicPlayerController play];
//    [self changePlayOrPauseButtonToType:UIBarButtonSystemItemPause];
//    
//    
//
//    
//    
//    
//    
//    TOCK;
//    
//}

//-(void) pauseMusic {
//    
//    TICK
//    
//    [self.musicPlayerController pause];
//    [self changePlayOrPauseButtonToType: UIBarButtonSystemItemPlay];
//    
//    TOCK;
//    
//}

-(void) changePlayOrPauseButtonToType: (UIBarButtonSystemItem) buttonType {
    
    TICK
    NSMutableArray *items = [self.navigationController.toolbar.items mutableCopy];
    
    UIBarButtonItem *item = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:buttonType target:self action:@selector(playButtonTapped:)];
    
    [items replaceObjectAtIndex:3 withObject:item];
    self.navigationController.toolbar.items = items;
    
    TOCK
    
}
@end
