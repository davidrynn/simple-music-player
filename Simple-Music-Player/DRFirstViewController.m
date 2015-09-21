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
#import "DRArtistTableViewController.h"
#import "DRMediaTableViewController.h"

@import MediaPlayer;

@interface DRFirstViewController () <UIScrollViewDelegate, GVMusicPlayerControllerDelegate>
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UILabel *nowPlayingLabel;
@property (weak, nonatomic) IBOutlet UILabel *upDownLabel;
@property (weak, nonatomic) IBOutlet UILabel *nowPlayingArtist;
@property (weak, nonatomic) IBOutlet UIImageView *nowPlayingImage;
@property (weak, nonatomic) IBOutlet UIView *buttonContainer;
@property (strong, nonatomic) IBOutlet UIButton *playerButton;
@property (weak, nonatomic) IBOutlet UIButton *previousButton;
@property (weak, nonatomic) IBOutlet UIButton *forwardButton;
@property (weak, nonatomic) IBOutlet DRPauseButton *pauseButton;

@property (weak, nonatomic) IBOutlet UISlider *slider;
@property (weak, nonatomic) IBOutlet UILabel *currentTrackTime;
@property (weak, nonatomic) IBOutlet UILabel *currentTrackLength;
@property (weak, nonatomic) IBOutlet UIButton *artistButton;
@property (weak, nonatomic) IBOutlet UIButton *albumButton;

@property (nonatomic, strong) GVMusicPlayerController *musicPlayer;
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
    
    

    
    

    
    TOCK
    
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    [self setUpScrollView];
    //if music is playing
//    if (self.musicPlayer.nowPlayingItem) {
//        self.playerButton.enabled = NO;
//        self.playerButton.hidden = YES;
//        self.pauseButton.enabled = YES;
//        self.pauseButton.hidden = NO;
//    }
//    else {
//        self.playerButton.enabled = YES;
//        self.playerButton.hidden = NO;
//        self.pauseButton.enabled = NO;
//        self.pauseButton.hidden = YES;
//        
//        
//    }
        [[GVMusicPlayerController sharedInstance] addDelegate:self];
}


-(void)timedJob {
    if (!self.panningProgress){
        self.slider.value = [GVMusicPlayerController sharedInstance].currentPlaybackTime;
        self.currentTrackTime.text = [self stringFromTime:[GVMusicPlayerController sharedInstance].currentPlaybackTime];
    }
    
}

#pragma mark - Catch remote control events, forward to the music player

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [[UIApplication sharedApplication] beginReceivingRemoteControlEvents];
    [self becomeFirstResponder];
}

- (void)viewWillDisappear:(BOOL)animated {
    [[UIApplication sharedApplication] endReceivingRemoteControlEvents];
    [self resignFirstResponder];
    [super viewWillDisappear:animated];
}

- (BOOL)canBecomeFirstResponder {
    return YES;
}

- (void)remoteControlReceivedWithEvent:(UIEvent *)receivedEvent {
    [[GVMusicPlayerController sharedInstance] remoteControlReceivedWithEvent:receivedEvent];
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
    self.scrollView.contentInset = UIEdgeInsetsMake(440,0,0,0);
    
    
}
-(void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset{
    
    if (scrollView == self.scrollView) {
        
        if (velocity.y >= 0) {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0), dispatch_get_main_queue(), ^{
                [UIView animateWithDuration:.1 animations:^{
                    
                    [scrollView setContentOffset:CGPointMake(0, 0) animated:NO];
                    self.upDownLabel.text = @"╲╱";
                }];
            });
            
        } else {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0), dispatch_get_main_queue(), ^{
                [UIView animateWithDuration:.1 animations:^{
                    
                    [scrollView setContentOffset:CGPointMake(0, -440) animated:NO];
                    self.upDownLabel.text = @"╱╲";
                }];
            });
        }
    }
}

#pragma mark - Button Actions
- (IBAction)artistButtonTapped:(id)sender {
#if !(TARGET_IPHONE_SIMULATOR)
    //search library and send to controller --feels wrong from here.
    MPMediaPropertyPredicate *artistPredicate = [MPMediaPropertyPredicate predicateWithValue:[GVMusicPlayerController sharedInstance].nowPlayingItem.artist forProperty:MPMediaItemPropertyArtist comparisonType:MPMediaPredicateComparisonContains];
    MPMediaQuery *artistQuery = [MPMediaQuery artistsQuery];
    artistQuery.groupingType = MPMediaGroupingAlbum;
    [artistQuery addFilterPredicate:artistPredicate];
    NSArray *mediaArray = [artistQuery items];
    MPMediaItemCollection *collection = [[MPMediaItemCollection alloc] initWithItems:mediaArray];
    
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0), dispatch_get_main_queue(), ^{
        [UIView animateWithDuration:.1 animations:^{
            
            [self.scrollView setContentOffset:CGPointMake(0, -430) animated:YES];
        }];
    });
    [self.delegate performSegueForDadWithCollection:collection andIdentifier:@"Artists"];
#endif
}
- (IBAction)albumButtonTapped:(id)sender {
#if !(TARGET_IPHONE_SIMULATOR)
    //search library and send to controller --feels wrong from here.
    MPMediaPropertyPredicate *albumPredicate = [MPMediaPropertyPredicate predicateWithValue:[GVMusicPlayerController sharedInstance].nowPlayingItem.albumTitle forProperty:MPMediaItemPropertyAlbumTitle comparisonType:MPMediaPredicateComparisonContains];
    MPMediaQuery *albumQuery = [MPMediaQuery albumsQuery];
    albumQuery.groupingType = MPMediaGroupingAlbum;
    [albumQuery addFilterPredicate:albumPredicate];
    NSArray *mediaArray = [albumQuery items];
    MPMediaItemCollection *collection = [[MPMediaItemCollection alloc] initWithItems:mediaArray];
    
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0), dispatch_get_main_queue(), ^{
        [UIView animateWithDuration:.1 animations:^{
            
            [self.scrollView setContentOffset:CGPointMake(0, -430) animated:YES];
        }];
    });
    [self.delegate performSegueForDadWithCollection:collection andIdentifier:@"Albums"];
#endif
}

- (IBAction) playOrPauseMusic: (id)sender {
    
    [self.delegate playOrPauseMusic];
    NSLog(@"Tapping button in RVC");
}
- (IBAction)backButtonTapped:(id)sender {
    //basically go to previous item if already at beginning
    if ([GVMusicPlayerController sharedInstance].currentPlaybackTime<1.0) {
            [[GVMusicPlayerController sharedInstance] skipToPreviousItem];
    }
    else {
        [[GVMusicPlayerController sharedInstance] skipToBeginning];
        NSLog(@"to Beginning");
    }
    [[GVMusicPlayerController sharedInstance] play];
}

- (IBAction)forwardButtonTapped:(id)sender {
    [[GVMusicPlayerController sharedInstance] skipToNextItem];
    NSLog(@"skip");
    
    [[GVMusicPlayerController sharedInstance] play];
}
- (IBAction)sliderChanged:(id)sender {
    
    self.panningProgress = YES;
}
- (IBAction)finishedSliding {
    
    [GVMusicPlayerController sharedInstance].currentPlaybackTime = self.slider.value;
    self.panningProgress = NO;
}

#pragma mark - GVMusicPlayerControllerDelegate

- (void)musicPlayer:(GVMusicPlayerController *)musicPlayer playbackStateChanged:(MPMusicPlaybackState)playbackState previousPlaybackState:(MPMusicPlaybackState)previousPlaybackState {
    

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

- (void)musicPlayer:(GVMusicPlayerController *)musicPlayer trackDidChange:(MPMediaItem *)nowPlayingItem previousTrack:(MPMediaItem *)previousTrack {
    
    // Time labels
    NSTimeInterval trackLength = [[nowPlayingItem valueForProperty:MPMediaItemPropertyPlaybackDuration] doubleValue];
    self.currentTrackLength.text = [self stringFromTime:trackLength];
    self.slider.value = 0;
    self.slider.maximumValue = trackLength;
    
    // Labels
    self.nowPlayingLabel.text = [nowPlayingItem valueForProperty:MPMediaItemPropertyTitle];
    self.nowPlayingArtist.text = [nowPlayingItem valueForProperty:MPMediaItemPropertyArtist];
    
    // Artwork
    MPMediaItemArtwork *artwork = [nowPlayingItem valueForProperty:MPMediaItemPropertyArtwork];
    if (artwork) {
        self.nowPlayingImage.image = [artwork imageWithSize: CGSizeMake(self.scrollView.frame.size.width/4, self.scrollView.frame.size.height/4) ];
    }
    if (!artwork) {
        self.nowPlayingImage.image = [UIImage imageNamed:@"noteMd"];
    }
    
    NSLog(@"Proof that this code is being called, even in the background!");
}

- (void)musicPlayer:(GVMusicPlayerController *)musicPlayer endOfQueueReached:(MPMediaItem *)lastTrack {
    NSLog(@"End of queue, but last track was %@", [lastTrack valueForProperty:MPMediaItemPropertyTitle]);
}

//- (void)musicPlayer:(GVMusicPlayerController *)currenlayer volumeChanged:(float)volume {
//    if (!self.panningVolume) {
//        self.volumeSlider.value = volume;
//    }
//}


#pragma mark - Miscellaneous


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

-(NSString *)stringFromTime:(NSTimeInterval)seconds {
    NSString *timeString = nil;
    const int secsPerMin = 60;
    const int minsPerHour = 60;
    const char *timeSep = ":";
    seconds = floor(seconds);
    
    if (seconds < 60.0) {
        timeString = [NSString stringWithFormat:@"0:%02.0f", seconds];
    } else {
        int mins = seconds/secsPerMin;
        int secs = seconds - mins*secsPerMin;
        
        if (mins < 60.0) {
            timeString = [NSString stringWithFormat:@"%d%s%02d", mins, timeSep, secs];
        } else {
            int hours = mins/minsPerHour;
            mins -= hours * minsPerHour;
            timeString = [NSString stringWithFormat:@"%d%s%02d%s%02d", hours, timeSep, mins, timeSep, secs];
        }
    }
    
    return timeString;
}
@end
