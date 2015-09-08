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
#import "DRPauseButton.h"
#import "DRPlayButton.h"
#import "DRMusicViewController.h"

@import MediaPlayer;

@interface DRFirstViewController () <UIScrollViewDelegate>
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UILabel *nowPlayingLabel;
@property (weak, nonatomic) IBOutlet UIImageView *nowPlayingImage;
@property (weak, nonatomic) IBOutlet UIView *buttonContainer;
@property (strong, nonatomic) IBOutlet UIButton *playerButton;
@property (weak, nonatomic) IBOutlet UIButton *previousButton;
@property (weak, nonatomic) IBOutlet UIButton *forwardButton;
@property (weak, nonatomic) IBOutlet DRPauseButton *pauseButton;

@property (weak, nonatomic) IBOutlet UISlider *slider;

@property (nonatomic, strong) MPMusicPlayerController *musicPlayer;
@property BOOL panningProgress;
@property (nonatomic, strong) NSTimer *timer;


@end

@implementation DRFirstViewController


-(void)viewDidLoad{
    TICK
    [super viewDidLoad];

    //setup topcontainer border
    [self.buttonContainer.layer setBorderWidth:1.0f];
    UIColor *transBlack = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.1];
    [self.buttonContainer.layer setBorderColor: [transBlack CGColor]];
    
    [self.scrollView.layer setBorderWidth:1.0f];
    [self.scrollView.layer setBorderColor: [transBlack CGColor]];
    
    
    
    UIImage *image = [self drawThumbRect];
    [self.slider setThumbImage:image forState:UIControlStateNormal];
    self.timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(timedJob) userInfo:nil repeats:YES];
    [self.timer fire];
    

    self.musicPlayer = [MPMusicPlayerController systemMusicPlayer];
    
    
    [[NSNotificationCenter defaultCenter] postNotificationName:MPMusicPlayerControllerPlaybackStateDidChangeNotification object:self.musicPlayer];
    [[NSNotificationCenter defaultCenter] postNotificationName:MPMusicPlayerControllerNowPlayingItemDidChangeNotification object:self.musicPlayer];


[self registerForMediaPlayerNotifications];
    
    TOCK
    
}

-(void)viewWillAppear:(BOOL)animated{
    
    [self setUpScrollView];
    //if music is playing
    if (self.musicPlayer.nowPlayingItem) {
        self.playerButton.enabled = NO;
        self.playerButton.hidden = YES;
        self.pauseButton.enabled = YES;
        self.pauseButton.hidden = NO;
    }
    else {
        self.playerButton.enabled = YES;
        self.playerButton.hidden = NO;
        self.pauseButton.enabled = NO;
        self.pauseButton.hidden = YES;
    
    
    }
}


-(void)timedJob {
    if (!self.panningProgress){
        self.slider.value = self.musicPlayer.currentPlaybackTime;
    }

}
#pragma mark Music notification handlers__________________

// When the now-playing item changes, update the media item artwork and the now-playing label.
- (void) handle_NowPlayingItemChanged: (id) notification {
    
    MPMediaItem *currentItem = [self.musicPlayer nowPlayingItem];
    
    // Assume that there is no artwork for the media item.
    __block UIImage *artworkImage = [UIImage imageNamed:@"noteBW"];
    
    // Get the artwork from the current media item, if it has artwork.
    MPMediaItemArtwork *artwork = [currentItem valueForProperty: MPMediaItemPropertyArtwork];
    
    // Obtain a UIImage object from the MPMediaItemArtwork object
    NSOperationQueue *mainQueue = [NSOperationQueue mainQueue];
    NSOperationQueue *photoQueue = [[NSOperationQueue alloc] init];

    if (artwork) {
        
        [photoQueue addOperationWithBlock:^{
            
            artworkImage = [artwork imageWithSize: CGSizeMake(self.scrollView.frame.size.width/4, self.scrollView.frame.size.height/4) ];
            
            [mainQueue addOperationWithBlock:^{
                self.nowPlayingImage.image = artworkImage;
            }];
        }];
        
    }

    // Display the artist and song name for the now-playing media item
    [self.nowPlayingLabel setText: [
                               NSString stringWithFormat: @"%@ %@ %@ %@",
                               NSLocalizedString (@"", @"Label for introducing the now-playing song title and artist"),
                               [currentItem valueForProperty: MPMediaItemPropertyTitle],
                               NSLocalizedString (@"by", @"Article between song name and artist name"),
                               [currentItem valueForProperty: MPMediaItemPropertyArtist]]];
    
    if (self.musicPlayer.playbackState == MPMusicPlaybackStateStopped) {
        // Provide a suitable prompt to the user now that their chosen music has
        //		finished playing.
        [self.nowPlayingLabel setText: [
                                   NSString stringWithFormat: @"%@",
                                   NSLocalizedString (@"Music-ended Instructions", @"Label for prompting user to play music again after it has stopped")]];
 

        
    }
    [self.slider setMaximumValue:self.musicPlayer.nowPlayingItem.playbackDuration];
    self.slider.value = 0;
 
}

// When the playback state changes, set the play/pause button in the button container
//		appropriately.
- (void) handle_PlaybackStateChanged: (id) notification {
    
    MPMusicPlaybackState playbackState = [self.musicPlayer playbackState];
    
    if (playbackState == MPMusicPlaybackStatePaused|| playbackState == MPMusicPlaybackStateStopped) {
        
        self.playerButton.enabled = YES;
        self.playerButton.hidden = NO;
        self.pauseButton.enabled = NO;
        self.pauseButton.hidden = YES;
        
    } else if (playbackState == MPMusicPlaybackStatePlaying) {
        
        self.playerButton.enabled = NO;
        self.playerButton.hidden = YES;
        self.pauseButton.enabled = YES;
        self.pauseButton.hidden = NO;
        
    }
}
- (void) registerForMediaPlayerNotifications {
    
    NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
    
    [notificationCenter addObserver: self
                           selector: @selector (handle_NowPlayingItemChanged:)
                               name: MPMusicPlayerControllerNowPlayingItemDidChangeNotification
                             object: self.musicPlayer];
    
    [notificationCenter addObserver: self
                           selector: @selector (handle_PlaybackStateChanged:)
                               name: MPMusicPlayerControllerPlaybackStateDidChangeNotification
                             object: self.musicPlayer];
    

    

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
    self.scrollView.alwaysBounceVertical = YES;
    // This prevents the scroll view from moving horizontally
    self.scrollView.alwaysBounceHorizontal = NO;
    // This creates a buffer area on top of the scroll view's contents (our contained view controller) and expands the content area without changing the size of the subview
    self.scrollView.contentInset = UIEdgeInsetsMake(430,0,0,0);
    
    
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
                    
                    [scrollView setContentOffset:CGPointMake(0, -430) animated:NO];
                }];
            });
        }
    }
}
#pragma mark - Navigation
//-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
//    
//    DRNavigationController *destinationVC= [segue destinationViewController];
//    self.delegate = destinationVC;
//
//}

#pragma mark - Button Actions

- (IBAction) playOrPauseMusic: (id)sender {
    
    [self.delegate playOrPauseMusic];
    NSLog(@"Tapping button in RVC");
}
- (IBAction)backButtonTapped:(id)sender {
    
    [self.musicPlayer skipToBeginning];
    NSLog(@"to Beginning");
    
    [self.musicPlayer play];
}

- (IBAction)forwardButtonTapped:(id)sender {
    [self.musicPlayer skipToNextItem];
    NSLog(@"skip");
    
    [self.musicPlayer play];
}
- (IBAction)sliderChanged:(id)sender {

    self.panningProgress = YES;
}
- (IBAction)finishedSliding {
    
    self.musicPlayer.currentPlaybackTime = self.slider.value;
    self.panningProgress = NO;
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

- (void)dealloc {
    NSLog(@"Deallocating");

    [[NSNotificationCenter defaultCenter] removeObserver: self
                                                    name: MPMusicPlayerControllerNowPlayingItemDidChangeNotification
                                                  object: self.musicPlayer];
    
    [[NSNotificationCenter defaultCenter] removeObserver: self
                                                    name: MPMusicPlayerControllerPlaybackStateDidChangeNotification
                                                  object: self.musicPlayer];
    
    [self.musicPlayer endGeneratingPlaybackNotifications];

    

}

-(UIImage*) drawThumbRect {
    
    CGRect sliderRect = self.slider.bounds;
    CGRect rect = CGRectMake(sliderRect.origin.x, sliderRect.origin.y, sliderRect.size.height/2, sliderRect.size.height);
    
    
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    [[UIColor whiteColor] setFill];
    [self.view.tintColor setStroke];
    UIBezierPath *path = [UIBezierPath bezierPathWithRect:rect];
    [path fill];
    [path stroke];
    
    
    CGContextAddPath(context, path.CGPath);
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}
@end
