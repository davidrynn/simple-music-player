//
//  GVMusicPlayer.m
//
//  Created by Kevin Renskers on 03-10-12.
//  Copyright (c) 2012 Gangverk. All rights reserved.
//  Updated by David Rynn 2015
//

#import "GVMusicPlayerController.h"
#import <AVFoundation/AVFoundation.h>
#import "DRFirstViewController.h"
#import "DRPlayerUtility.h"


@interface NSArray (GVShuffledArray) 
@property (NS_NONATOMIC_IOSONLY, readonly, copy) NSArray *shuffled;
@end


@implementation NSArray (GVShuffledArray)

- (NSArray *)shuffled {
//altered from original
    NSMutableArray *mutableArray = [NSMutableArray arrayWithArray:self];
    NSUInteger count = [mutableArray count];
    // See http://en.wikipedia.org/wiki/Fisher–Yates_shuffle
    if (count > 1) {
        for (NSUInteger i = count - 1; i > 0; --i) {
            [mutableArray exchangeObjectAtIndex:i withObjectAtIndex:arc4random_uniform((int32_t)(i + 1))];
        }
    }
    
    NSArray *randomArray = [NSArray arrayWithArray:mutableArray];
    
    return randomArray;
}

@end


@interface GVMusicPlayerController () <AVAudioSessionDelegate>
@property (copy, nonatomic) NSArray *delegates;
@property (strong, nonatomic) AVPlayer *player;
@property (strong, nonatomic) MPMusicPlayerController *mpPlayer;
@property (strong, nonatomic, readwrite) NSArray *originalQueue;
@property (strong, nonatomic, readwrite) NSArray *queue;
@property (strong, nonatomic) MPMediaItem *nowPlayingItem;
@property (nonatomic, readwrite) NSUInteger indexOfNowPlayingItem;
@property (nonatomic) BOOL interrupted;
@property (nonatomic) BOOL isLoadingAsset;
@end


@implementation GVMusicPlayerController

+ (GVMusicPlayerController *)sharedInstance {
    static dispatch_once_t onceQueue;
    static GVMusicPlayerController *instance = nil;
    dispatch_once(&onceQueue, ^{
        instance = [[self alloc] init];
    });
    return instance;
}

void audioRouteChangeListenerCallback (void *inUserData, AudioSessionPropertyID inPropertyID, UInt32 inPropertyValueSize, const void *inPropertyValue) {
    if (inPropertyID != kAudioSessionProperty_AudioRouteChange) return;

    GVMusicPlayerController *controller = (__bridge GVMusicPlayerController *)inUserData;

    CFDictionaryRef routeChangeDictionary = inPropertyValue;

    CFNumberRef routeChangeReasonRef = CFDictionaryGetValue(routeChangeDictionary, CFSTR (kAudioSession_AudioRouteChangeKey_Reason));
    SInt32 routeChangeReason;
    CFNumberGetValue (routeChangeReasonRef, kCFNumberSInt32Type, &routeChangeReason);

    CFStringRef oldRouteRef = CFDictionaryGetValue(routeChangeDictionary, CFSTR (kAudioSession_AudioRouteChangeKey_OldRoute));
    NSString *oldRouteString = (__bridge NSString *)oldRouteRef;

    if (routeChangeReason == kAudioSessionRouteChangeReason_OldDeviceUnavailable) {
        if ((controller.playbackState == MPMusicPlaybackStatePlaying) &&
            (([oldRouteString isEqualToString:@"Headphone"]) ||
             ([oldRouteString isEqualToString:@"LineOut"])))
        {
            // Janking out the headphone will stop the audio.
            [controller pause];
        }
    }
}

- (instancetype)init {
    self = [super init];
    if (self) {
        self.indexOfNowPlayingItem = NSNotFound;
        self.delegates = @[];

        // Set defaults
        self.updateNowPlayingCenter = YES;
        self.repeatMode = MPMusicRepeatModeNone;
        self.shuffleMode = MPMusicShuffleModeOff;
        self.shouldReturnToBeginningWhenSkippingToPreviousItem = YES;

        // Make sure the system follows our playback status
        AVAudioSession *audioSession = [AVAudioSession sharedInstance];
        [audioSession setActive:YES error:nil];

        NSError *sessionError = nil;
        BOOL success = [audioSession setCategory:AVAudioSessionCategoryPlayback error:&sessionError];
        if (!success){
            NSLog(@"setCategory error %@", sessionError);
        }
        success = [audioSession setActive:YES error:&sessionError];
        if (!success){
            NSLog(@"setActive error %@", sessionError);
        }
        //  replace [audioSession setDelegate:self] with notifications;
        
        self.mpPlayer = [MPMusicPlayerController systemMusicPlayer];
        [self registerNotifications];
    }

    return self;
}
-(void)registerNotifications{

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(interruption:) name:AVAudioSessionInterruptionNotification object:nil];

 
    // Handle unplugging of headphones
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(audioHardwareRouteChanged:) name:AVAudioSessionRouteChangeNotification object:nil];
}

//TODO: put in init
- (void) setupSortedLists {
#if !(TARGET_IPHONE_SIMULATOR)
    MPMediaQuery *songsQuery = [MPMediaQuery songsQuery];
    if (songsQuery.items.count>0) {
        
        NSDictionary *songDictionary = [DRPlayerUtility returnDictionaryFromQuery: songsQuery withCategory:@"Songs" withGroupingType: MPMediaGroupingTitle];
        self.songsDictionary = songDictionary;
        
        MPMediaQuery *albumsQuery=[MPMediaQuery albumsQuery];
        self.albumsDictionary = [DRPlayerUtility returnDictionaryFromQuery: albumsQuery withCategory:@"Albums" withGroupingType: MPMediaGroupingAlbum];
        NSLog(@"number of albums: %ld", (unsigned long)albumsQuery.collections.count);
        
        MPMediaQuery *artistsQuery =[MPMediaQuery artistsQuery];
        artistsQuery.groupingType = MPMediaGroupingArtist;
        self.artistsDictionary = [DRPlayerUtility returnDictionaryFromQuery: artistsQuery withCategory:@"Artists" withGroupingType: MPMediaGroupingArtist];
        NSLog(@"number of artists: %ld", (unsigned long)artistsQuery.collections.count);
        
        MPMediaQuery *genresQuery = [MPMediaQuery genresQuery];
        self.genresDictionary = [DRPlayerUtility returnDictionaryFromQuery: genresQuery withCategory:@"Genres" withGroupingType: MPMediaGroupingGenre];
        NSLog(@"number of genres: %ld", (unsigned long)genresQuery.collections.count);
        
        MPMediaQuery *playlistsQuery = [MPMediaQuery playlistsQuery];
        self.playlistsDictionary = [DRPlayerUtility returnDictionaryFromQuery: playlistsQuery withCategory:@"Playlists" withGroupingType: MPMediaGroupingPlaylist];
        NSLog(@"number of playlists: %ld", (unsigned long)playlistsQuery.collections.count);
        
        NSLog(@"number of songs: %ld", (unsigned long)songsQuery.collections.count);
    }
#endif
    
}

//know persistentId of the song then can save it in userDefaults.
//TODO: put in init
- (void)storePersistentIdSong :(MPMediaItem *) song {
    NSNumber *songId = [song valueForProperty:MPMediaItemPropertyPersistentID];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:songId forKey:@"persistentID"];
}

//when your application will be launched next time get required song:
//TODO: put in init
- (void)loadSongFromUserDefaults{
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSNumber *songID = [defaults objectForKey:@"persistentID"];
    if (songID) {
        
        MPMediaQuery *query = [MPMediaQuery songsQuery];
        MPMediaPropertyPredicate *predicate = [MPMediaPropertyPredicate predicateWithValue:songID forProperty:MPMediaItemPropertyPersistentID];
        [query addFilterPredicate:predicate];
        
        MPMediaItem *item = [query items][0];
        
        [self.musicPlayer setQueueWithItemCollection:self.musicCollection];
        [self.musicPlayer playItem:item];
        
    }
    else{
        [self.musicPlayer setQueueWithItemCollection:
         self.musicCollection];
        [self.musicPlayer playItemAtIndex:0];
    }
    
}

- (void) interruption:(NSNotification*)notification
{
    NSDictionary *interuptionDict = notification.userInfo;
    
    NSUInteger interuptionType = (NSUInteger)[interuptionDict valueForKey:AVAudioSessionInterruptionTypeKey];
    
    if (interuptionType == AVAudioSessionInterruptionTypeBegan)
        [self beginInterruption];
    
    else if (interuptionType == AVAudioSessionInterruptionTypeEnded)
        [self endInterruption];
}
- (void)audioHardwareRouteChanged:(NSNotification *)notification {
    //handles deprecated methods from older gvmplayer
    [self pause];
}
- (void)dealloc {
    [[MPMusicPlayerController systemMusicPlayer] endGeneratingPlaybackNotifications];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                  name:MPMusicPlayerControllerVolumeDidChangeNotification
                                object:[MPMusicPlayerController systemMusicPlayer]];
}

- (void)addDelegate:(id<GVMusicPlayerControllerDelegate>)delegate {
    NSMutableArray *delegates = [self.delegates mutableCopy];
    [delegates addObject:delegate];
    self.delegates = delegates;

    // Call the delegate's xChanged methods, so it can initialize its UI

    if ([delegate respondsToSelector:@selector(musicPlayer:trackDidChange:previousTrack:)]) {
        [delegate musicPlayer:self trackDidChange:self.nowPlayingItem previousTrack:nil];
    }

    if ([delegate respondsToSelector:@selector(musicPlayer:playbackStateChanged:previousPlaybackState:)]) {
        [delegate musicPlayer:self playbackStateChanged:self.playbackState previousPlaybackState:MPMusicPlaybackStateStopped];
    }

    if ([delegate respondsToSelector:@selector(musicPlayer:volumeChanged:)]) {
        [delegate musicPlayer:self volumeChanged:self.volume];
    }
}

- (void)removeDelegate:(id<GVMusicPlayerControllerDelegate>)delegate {
    NSMutableArray *delegates = [self.delegates mutableCopy];
    [delegates removeObject:delegate];
    self.delegates = delegates;
}

#pragma mark - Emulate MPMusicPlayerController

- (void)setQueueWithItemCollection:(MPMediaItemCollection *)itemCollection {
    self.originalQueue = [itemCollection items];
}

- (void)setQueueWithQuery:(MPMediaQuery *)query {
    self.originalQueue = [query items];
}

- (void)skipToNextItem {
    if (self.indexOfNowPlayingItem+1 < [self.queue count]) {
        // Play next track
        self.indexOfNowPlayingItem++;
    } else {
        if (self.repeatMode == MPMusicRepeatModeAll) {
            // Wrap around back to the first track
            self.indexOfNowPlayingItem = 0;
        } else {
            if (self.playbackState == MPMusicPlaybackStatePlaying) {
                if (_nowPlayingItem != nil) {
                    for (id <GVMusicPlayerControllerDelegate> delegate in self.delegates) {
                        if ([delegate respondsToSelector:@selector(musicPlayer:endOfQueueReached:)]) {
                            [delegate musicPlayer:self endOfQueueReached:_nowPlayingItem];
                        }
                    }
                }
            }
            NSLog(@"GVMusicPlayerController: end of queue reached");
            [self stop];
        }
    }
}

- (void)skipToBeginning {
    self.currentPlaybackTime = 0.0;
}

- (void)skipToPreviousItem {
    if (self.indexOfNowPlayingItem > 0) {
        self.indexOfNowPlayingItem--;
    } else if (self.shouldReturnToBeginningWhenSkippingToPreviousItem) {
        [self skipToBeginning];
    }
}

#pragma mark - MPMediaPlayback

- (void)play {
    if (![self.nowPlayingItem valueForProperty:MPMediaItemPropertyAssetURL]) {
        [self playDRMMusic];
    }
    else {
    [self.mpPlayer stop];
    [self.player play];
    }
    [self storePersistentIdSong:self.nowPlayingItem];
    self.playbackState = MPMusicPlaybackStatePlaying;
}
-(void) playDRMMusic {
    [self stop];
    MPMediaItem *song = self.nowPlayingItem;
    MPMediaItemCollection *collection = [MPMediaItemCollection collectionWithItems:@[song]];
    [self.mpPlayer setQueueWithItemCollection:collection];
    [self.mpPlayer setNowPlayingItem:self.nowPlayingItem];
    NSLog(@"DRM url:%@, DRM title, %@", [self.nowPlayingItem valueForProperty:MPMediaItemPropertyAssetURL], self.mpPlayer.nowPlayingItem.title);
    
    //set completion block that resets index to next song after nowplaying item in AVplayer.
    [self.mpPlayer play];
}
-(void) pauseDRMMusic {
    [self.mpPlayer pause];
}
- (void)pause {
    if (![self.nowPlayingItem valueForProperty:MPMediaItemPropertyAssetURL]) {
        [self pauseDRMMusic];
    }
    else {
    [self.player pause];
    }
    self.playbackState = MPMusicPlaybackStatePaused;
}

- (void)stop {
    [self.player pause];
    self.playbackState = MPMusicPlaybackStateStopped;
}

- (void)prepareToPlay {
    NSLog(@"Not supported");
}

- (void)beginSeekingBackward {
    NSLog(@"Not supported");
}

- (void)beginSeekingForward {
    NSLog(@"Not supported");
}

- (void)endSeeking {
    NSLog(@"Not supported");
}

- (BOOL)isPreparedToPlay {
    return YES;
}

- (NSTimeInterval)currentPlaybackTime {
#if !(TARGET_IPHONE_SIMULATOR)
    if (self.mpPlayer.playbackState == MPMusicPlaybackStatePlaying) {
        return self.mpPlayer.currentPlaybackTime;
    } else {
    return self.player.currentTime.value / self.player.currentTime.timescale;
    }
#else
    return 0;
#endif
}

- (void)setCurrentPlaybackTime:(NSTimeInterval)currentPlaybackTime {
    CMTime t = CMTimeMake(currentPlaybackTime, 1);
    if (self.mpPlayer.playbackState == MPMusicPlaybackStatePlaying) {
        [self.mpPlayer setCurrentPlaybackTime:currentPlaybackTime];
    } else {
    [self.player seekToTime:t];
     }
}

- (float)currentPlaybackRate {
    return self.player.rate;
}

- (void)setCurrentPlaybackRate:(float)currentPlaybackRate {
    self.player.rate = currentPlaybackRate;
}

#pragma mark - Setters and getters

- (void)setShuffleMode:(MPMusicShuffleMode)shuffleMode {
    _shuffleMode = shuffleMode;
    self.queue = self.originalQueue;
}

- (void)setOriginalQueue:(NSArray *)originalQueue {
    // The original queue never changes, while queue is shuffled
    _originalQueue = originalQueue;
    self.queue = originalQueue;
}

- (void)setQueue:(NSArray *)queue {
    switch (self.shuffleMode) {
        case MPMusicShuffleModeOff:
            _queue = queue;
            break;

        case MPMusicShuffleModeSongs:
            _queue = [queue shuffled];
            break;

        default:
            NSLog(@"Only MPMusicShuffleModeOff and MPMusicShuffleModeSongs are supported");
            _queue = [queue shuffled];
            break;
    }

    if ([_queue count]) {
        self.indexOfNowPlayingItem = 0;
    } else {
        self.indexOfNowPlayingItem = NSNotFound;
    }
}

- (void)setIndexOfNowPlayingItem:(NSUInteger)indexOfNowPlayingItem {
    if (indexOfNowPlayingItem == NSNotFound) {
        return;
    }

    _indexOfNowPlayingItem = indexOfNowPlayingItem;
    self.nowPlayingItem = (self.queue)[indexOfNowPlayingItem];
}

- (void)setNowPlayingItem:(MPMediaItem *)nowPlayingItem {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:AVPlayerItemDidPlayToEndTimeNotification object:nil];
//    [[NSNotificationCenter defaultCenter] removeObserver:self name:AVPlayerItemDidPlayToEndTimeNotification object:nil];

    MPMediaItem *previousTrack = _nowPlayingItem;
    _nowPlayingItem = nowPlayingItem;

    // Used to prevent duplicate notifications
    self.isLoadingAsset = YES;

    // Create a new player item
    NSURL *assetUrl = [nowPlayingItem valueForProperty:MPMediaItemPropertyAssetURL];
    AVPlayerItem *playerItem = [AVPlayerItem playerItemWithURL:assetUrl];

    // Either create a player or replace it
    if (self.player) {
        [self.player replaceCurrentItemWithPlayerItem:playerItem];
    } else {
        self.player = [AVPlayer playerWithPlayerItem:playerItem];
    }

    // Subscribe to the AVPlayerItem's DidPlayToEndTime notification.
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleAVPlayerItemDidPlayToEndTimeNotification) name:AVPlayerItemDidPlayToEndTimeNotification object:nil];
    
////TODO: add MPMedia equivalent to player did play to end notification.
//    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(handleAVPlayerItemDidPlayToEndTimeNotification) name:MPMusicPlayerControllerNowPlayingItemDidChangeNotification object:nil];

    // Inform delegates
    for (id <GVMusicPlayerControllerDelegate> delegate in self.delegates) {
        if ([delegate respondsToSelector:@selector(musicPlayer:trackDidChange:previousTrack:)]) {
            [delegate musicPlayer:self trackDidChange:nowPlayingItem previousTrack:previousTrack];
        }
    }

    // Inform iOS now playing center
    [self doUpdateNowPlayingCenter];

    self.isLoadingAsset = NO;
}

- (void)playItemAtIndex:(NSUInteger)index {
    [self setIndexOfNowPlayingItem:index];
}

- (void)playItem:(MPMediaItem *)item {
    NSUInteger indexOfItem = [self.queue indexOfObject:item];
    [self playItemAtIndex:indexOfItem];
}

- (void)handleAVPlayerItemDidPlayToEndTimeNotification {
    if (!self.isLoadingAsset) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (self.repeatMode == MPMusicRepeatModeOne) {
                // Play the same track again
                self.indexOfNowPlayingItem = self.indexOfNowPlayingItem;
                if (self.playbackState == MPMusicPlaybackStatePlaying) {
                    [self.player play];
                }
            } else {
                // Go to next track
                [self skipToNextItem];
                if (self.playbackState == MPMusicPlaybackStatePlaying) {
                    [self.player play];
                }
            }
        });
    }
}

- (void)doUpdateNowPlayingCenter {
    if (!self.updateNowPlayingCenter || !self.nowPlayingItem) {
        return;
    }

    MPNowPlayingInfoCenter *center = [MPNowPlayingInfoCenter defaultCenter];
    NSMutableDictionary *songInfo = [NSMutableDictionary dictionaryWithDictionary:@{
        MPMediaItemPropertyArtist: [self.nowPlayingItem valueForProperty:MPMediaItemPropertyArtist] ?: @"",
        MPMediaItemPropertyTitle: [self.nowPlayingItem valueForProperty:MPMediaItemPropertyTitle] ?: @"",
        MPMediaItemPropertyAlbumTitle: [self.nowPlayingItem valueForProperty:MPMediaItemPropertyAlbumTitle] ?: @"",
        MPMediaItemPropertyPlaybackDuration: [self.nowPlayingItem valueForProperty:MPMediaItemPropertyPlaybackDuration] ?: @0
    }];

    // Add the artwork if it exists
    MPMediaItemArtwork *artwork = [self.nowPlayingItem valueForProperty:MPMediaItemPropertyArtwork];
    if (artwork) {
        songInfo[MPMediaItemPropertyArtwork] = artwork;
    }

    center.nowPlayingInfo = songInfo;
}

- (void)setPlaybackState:(MPMusicPlaybackState)playbackState {
    if (playbackState == _playbackState) {
        return;
    }

    MPMusicPlaybackState oldState = _playbackState;
    _playbackState = playbackState;

    for (id <GVMusicPlayerControllerDelegate> delegate in self.delegates) {
        if ([delegate respondsToSelector:@selector(musicPlayer:playbackStateChanged:previousPlaybackState:)]) {
            [delegate musicPlayer:self playbackStateChanged:_playbackState previousPlaybackState:oldState];
        }
    }
}


#pragma mark - AVAudioSessionDelegate

- (void)beginInterruption {

    if (self.playbackState == MPMusicPlaybackStatePlaying) {
        self.interrupted = YES;
    }
    [self pause];
}

- (void)endInterruptionWithFlags:(NSUInteger)flags {
    if (self.interrupted && (flags & AVAudioSessionInterruptionOptionShouldResume)) {
        [self play];
    }
    self.interrupted = NO;
}

#pragma mark - Other public methods

- (void)remoteControlReceivedWithEvent:(UIEvent *)receivedEvent {
    if (receivedEvent.type != UIEventTypeRemoteControl) {
        return;
    }

    switch (receivedEvent.subtype) {
        case UIEventSubtypeRemoteControlTogglePlayPause: {
            if (self.playbackState == MPMusicPlaybackStatePlaying) {
                [self pause];
            } else {
                [self play];
            }
            break;
        }

        case UIEventSubtypeRemoteControlNextTrack:
            [self skipToNextItem];
            break;

        case UIEventSubtypeRemoteControlPreviousTrack:
            [self skipToPreviousItem];
            break;

        case UIEventSubtypeRemoteControlPlay:
            [self play];
            break;

        case UIEventSubtypeRemoteControlPause:
            [self pause];
            break;

        case UIEventSubtypeRemoteControlStop:
            [self stop];
            break;

        case UIEventSubtypeRemoteControlBeginSeekingBackward:
            [self beginSeekingBackward];
            break;

        case UIEventSubtypeRemoteControlBeginSeekingForward:
            [self beginSeekingForward];
            break;

        case UIEventSubtypeRemoteControlEndSeekingBackward:
        case UIEventSubtypeRemoteControlEndSeekingForward:
            [self endSeeking];
            break;

        default:
            break;
    }
}

@end
