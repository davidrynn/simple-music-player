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
#import "DRPlayerUtility.h"

@import MediaPlayer;

@interface DRFirstViewController () <UIScrollViewDelegate, GVMusicPlayerControllerDelegate>

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UILabel *nowPlayingLabel;

@property (weak, nonatomic) IBOutlet UILabel *nowPlayingArtist;
@property (weak, nonatomic) IBOutlet UIImageView *nowPlayingImage;
@property (weak, nonatomic) IBOutlet UIView *buttonContainer;

@property (weak, nonatomic) IBOutlet UIButton *scrollUpButton;

@property (strong, nonatomic) IBOutlet UIButton *playerButton;
@property (weak, nonatomic) IBOutlet UIButton *previousButton;
@property (weak, nonatomic) IBOutlet UIButton *forwardButton;
@property (weak, nonatomic) IBOutlet DRPauseButton *pauseButton;

@property (weak, nonatomic) IBOutlet UISlider *slider;
@property (weak, nonatomic) IBOutlet UILabel *currentTrackTime;
@property (weak, nonatomic) IBOutlet UILabel *currentTrackLengthLabel;
@property (nonatomic) NSTimeInterval currentTrackLength;
@property (weak, nonatomic) IBOutlet UIButton *artistButton;
@property (weak, nonatomic) IBOutlet UIButton *albumButton;

@property (nonatomic, strong) GVMusicPlayerController *musicPlayer;
@property (nonatomic, strong) MPMusicPlayerController *mpMusicPlayer;
@property BOOL panningProgress;
@property (nonatomic, strong) NSTimer *timer;
@property (nonatomic) CGFloat proportionalHeight;

@end

@implementation DRFirstViewController
//const int kCellTitleKey = self.view.layer.size.height*0.2;

-(void)viewDidLoad{
    TICK
    [super viewDidLoad];
    
    self.mpMusicPlayer = [MPMusicPlayerController systemMusicPlayer];
    
        //setup topcontainer border
    [self.buttonContainer.layer setBorderWidth:1.0f];
    UIColor *transBlack = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.1];
    [self.buttonContainer.layer setBorderColor: [transBlack CGColor]];
    
    [self.scrollView.layer setBorderWidth:1.0f];
    [self.scrollView.layer setBorderColor: [transBlack CGColor]];
    
    //set slider button to square
    self.slider.continuous = YES;
    UIImage *image = [self drawThumbRect];
    [self.slider setThumbImage:image forState:UIControlStateNormal];
    [self.slider addTarget:self action:@selector(sliderChanged:) forControlEvents:UIControlEventValueChanged];
    
    self.timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(timedJob) userInfo:nil repeats:YES];
    [self.timer fire];
    [self setUpScrollView];

    TOCK
    
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    [[GVMusicPlayerController sharedInstance] addDelegate:self];
}


-(void)timedJob {
    if (!self.panningProgress){
        self.slider.value = [GVMusicPlayerController sharedInstance].currentPlaybackTime;
        self.currentTrackTime.text = [self stringFromTime:[GVMusicPlayerController sharedInstance].currentPlaybackTime];
    }
    //trying to deal with DRM here
    if (self.mpMusicPlayer.playbackState == MPMusicPlaybackStatePlaying &&  [GVMusicPlayerController sharedInstance].currentPlaybackTime > self.currentTrackLength -1) {
        [self.mpMusicPlayer stop];
        [self forwardButtonTapped:self];
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
    //set height of scrollview
    if (self.view.bounds.size.width == 414) {
        self.proportionalHeight = self.view.bounds.size.height*0.77;
    }
    else if (self.view.bounds.size.width == 375) {
        self.proportionalHeight = self.view.bounds.size.height*0.76;
        
    }
    else if (self.view.frame.size.width > 414){
        self.proportionalHeight = self.view.frame.size.height*1.5;
    }
    
    else {
        self.proportionalHeight = self.view.frame.size.height*0.75;
    }

    
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
//    DOESN'T Like code below
//    screws up all buttons on scrollview
    self.scrollView.contentInset = UIEdgeInsetsMake(self.proportionalHeight, 0, 0, 0); 
    
    
//    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0), dispatch_get_main_queue(), ^{
//        [UIView animateWithDuration:.1 animations:^{
//            
//            [self.scrollView setContentOffset:CGPointMake(0, -self.proportionalHeight) animated:NO];
//            [self.scrollUpButton setImage:[UIImage imageNamed:@"scrollUp"] forState:UIControlStateNormal];
//            
//        }];
//    });
//
    
}
-(void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset{
    
    if (scrollView == self.scrollView) {
        
        if (velocity.y >= 0) {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0), dispatch_get_main_queue(), ^{
                [UIView animateWithDuration:.1 animations:^{
                    
                    [scrollView setContentOffset:CGPointMake(0, 0) animated:NO];
                    [self.scrollUpButton setImage: [UIImage imageNamed:@"scrollDown"]forState:UIControlStateNormal];
                    
                }];
            });
            
        } else {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0), dispatch_get_main_queue(), ^{
                [UIView animateWithDuration:.1 animations:^{
                    
                    [scrollView setContentOffset:CGPointMake(0, -self.proportionalHeight) animated:NO];
                    [self.scrollUpButton setImage:[UIImage imageNamed:@"scrollUp"] forState:UIControlStateNormal];
                    
                }];
            });
        }
    }
}

#pragma mark - Button Actions
//TODO: Add ratings for paid version for sorting and editing
/*
 -(void)editRating{
 
 [mediaItem setValue:[NSNumber numberWithInteger:rating] forKey:@"rating"];
 }
 */
- (IBAction)scrollUpButtonTapped:(id)sender {
    
    if (self.scrollView.contentOffset.y == 0) {
        
        [UIView animateWithDuration:.1 animations:^{
            
            [self.scrollView setContentOffset:CGPointMake(0, -self.proportionalHeight) animated:NO];
            [self.scrollUpButton setImage:[UIImage imageNamed:@"scrollUp"] forState:UIControlStateNormal];
            
        }];
        
    }
    else {
        
        [UIView animateWithDuration:.1 animations:^{
            
            [self.scrollView setContentOffset:CGPointMake(0, 0) animated:NO];
            [self.scrollUpButton setImage: [UIImage imageNamed:@"scrollDown"]forState:UIControlStateNormal];
            
        }];
        
    }
}

- (IBAction)artistButtonTapped:(id)sender {
#if !(TARGET_IPHONE_SIMULATOR)
    //search library and send to controller --feels wrong from here.

    MPMediaPropertyPredicate *artistPredicate = [MPMediaPropertyPredicate predicateWithValue:[GVMusicPlayerController sharedInstance].nowPlayingItem.artist forProperty:MPMediaItemPropertyArtist comparisonType:MPMediaPredicateComparisonContains];
    MPMediaPropertyPredicate *mediaTypePredicate = [MPMediaPropertyPredicate predicateWithValue:@(MPMediaTypeMusic) forProperty:MPMediaItemPropertyMediaType comparisonType:MPMediaPredicateComparisonEqualTo];
    NSSet *predicateSet = [NSSet setWithObjects:artistPredicate, mediaTypePredicate, nil];
    
    MPMediaQuery *artistQuery = [MPMediaQuery artistsQuery];
    MPMediaQuery *fullArtistQuery =[[MPMediaQuery alloc] initWithFilterPredicates:predicateSet];
    
        [DRPlayerUtility filterOutCloudItemsFromQuery:artistQuery];
    fullArtistQuery.groupingType = MPMediaGroupingAlbum;
    [artistQuery addFilterPredicate:artistPredicate];
    NSArray *mediaArray = [fullArtistQuery items];
    MPMediaItemCollection *collection = [[MPMediaItemCollection alloc] initWithItems:mediaArray];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0), dispatch_get_main_queue(), ^{
        [UIView animateWithDuration:.1 animations:^{
            
            [self.scrollView setContentOffset:CGPointMake(0, -self.proportionalHeight) animated:YES];
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
    [DRPlayerUtility filterOutCloudItemsFromQuery:albumQuery];
    albumQuery.groupingType = MPMediaGroupingAlbum;
    [albumQuery addFilterPredicate:albumPredicate];
    NSArray *mediaArray = [albumQuery items];
    MPMediaItemCollection *collection = [[MPMediaItemCollection alloc] initWithItems:mediaArray];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0), dispatch_get_main_queue(), ^{
        [UIView animateWithDuration:.1 animations:^{
            
            [self.scrollView setContentOffset:CGPointMake(0, -self.proportionalHeight) animated:YES];
        }];
    });
    [self.delegate performSegueForDadWithCollection:collection andIdentifier:@"Albums"];
#endif
}

- (IBAction) playOrPauseMusic: (id)sender {
    
    [self.delegate playOrPauseMusic];

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
    //logic to update track time
    
    self.currentTrackTime.text = [self stringFromTime:self.slider.value];
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
    //disable force touch
    // Time labels
#if (TARGET_IPHONE_SIMULATOR)
    NSTimeInterval trackLength = 500.00;
    self.currentTrackLength = trackLength;
    self.currentTrackLengthLabel.text = [self stringFromTime:trackLength];
    self.slider.value = 0;
    self.slider.maximumValue = trackLength;
    
    // Labels
    self.nowPlayingLabel.text = @"TestNowPlaying";
    self.nowPlayingArtist.text = @"TestArtist";
#else
    NSTimeInterval trackLength = [[nowPlayingItem valueForProperty:MPMediaItemPropertyPlaybackDuration] doubleValue];
    self.currentTrackLength = trackLength;
    self.currentTrackLengthLabel.text = [self stringFromTime:trackLength];
    self.slider.value = 0;
    self.slider.maximumValue = trackLength;
    
    // Labels
    self.nowPlayingLabel.text = [nowPlayingItem valueForProperty:MPMediaItemPropertyTitle];
    self.nowPlayingArtist.text = [nowPlayingItem valueForProperty:MPMediaItemPropertyArtist];
#endif
    // Artwork
    MPMediaItemArtwork *artwork = [nowPlayingItem valueForProperty:MPMediaItemPropertyArtwork];
    if (artwork) {
        self.nowPlayingImage.image = [artwork imageWithSize: CGSizeMake(self.scrollView.frame.size.width/4, self.scrollView.frame.size.height/4) ];
    }
    if (!artwork) {
        self.nowPlayingImage.image = [UIImage imageNamed:@"noteMd"];
    }
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


-(void)drawUpArrowForScrollUpView{
    
    CGFloat width = self.scrollUpButton.bounds.size.width/2;
    CGFloat height = self.scrollUpButton.bounds.size.height/2;
    CGFloat x = self.scrollUpButton.bounds.size.width/4;
    CGFloat y = self.scrollUpButton.bounds.size.height/4;
    CGRect small = CGRectMake(x, y, width, height);
    //// Bezier Drawing
    UIBezierPath* bezierPath = [UIBezierPath bezierPath];
    [bezierPath moveToPoint: CGPointMake(CGRectGetMinX(small), CGRectGetMaxY(small)-height/4)];
    [bezierPath addLineToPoint: CGPointMake(CGRectGetMidX(small), CGRectGetMinY(small) +height/4)];
    [bezierPath addLineToPoint: CGPointMake(CGRectGetMaxX(small), CGRectGetMaxY(small)-height/4)];
    [self.view.tintColor setStroke];
    bezierPath.lineWidth = 2;
    [bezierPath stroke];
    
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
