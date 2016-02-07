//
//  GVMusicPlayer.h
//  Example
//
//  Created by Kevin Renskers on 03-10-12.
//  Copyright (c) 2012 Gangverk. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MediaPlayer/MediaPlayer.h>

@class GVMusicPlayerController;

@protocol GVMusicPlayerControllerDelegate <NSObject>
@optional
- (void)musicPlayer:(GVMusicPlayerController *)musicPlayer trackDidChange:(MPMediaItem *)nowPlayingItem previousTrack:(MPMediaItem *)previousTrack;
- (void)musicPlayer:(GVMusicPlayerController *)musicPlayer endOfQueueReached:(MPMediaItem *)lastTrack;
- (void)musicPlayer:(GVMusicPlayerController *)musicPlayer playbackStateChanged:(MPMusicPlaybackState)playbackState previousPlaybackState:(MPMusicPlaybackState)previousPlaybackState;
- (void)musicPlayer:(GVMusicPlayerController *)musicPlayer volumeChanged:(float)volume;
@end


@interface GVMusicPlayerController : NSObject <MPMediaPlayback>

@property (strong, nonatomic, readonly) MPMediaItem *nowPlayingItem;
@property (nonatomic) MPMusicPlaybackState playbackState;
@property (nonatomic) MPMusicRepeatMode repeatMode; // note: MPMusicRepeatModeDefault is not supported
@property (nonatomic) MPMusicShuffleMode shuffleMode; // note: only MPMusicShuffleModeOff and MPMusicShuffleModeSongs are supported
@property (nonatomic) float volume; // 0.0 to 1.0
@property (nonatomic, readonly) NSUInteger indexOfNowPlayingItem; // NSNotFound if no queue
@property (nonatomic) BOOL updateNowPlayingCenter; // default YES
@property (nonatomic, readonly) NSArray *queue;
@property (strong, nonatomic, readonly) NSArray *originalQueue;
@property (nonatomic) BOOL shouldReturnToBeginningWhenSkippingToPreviousItem; // default YES
@property (nonatomic) BOOL isDRM;

@property (nonatomic) BOOL shuffleOn;
@property (nonatomic, strong) NSDictionary *songsDictionary;
@property (nonatomic, strong) NSDictionary *albumsDictionary;
@property (nonatomic, strong) NSDictionary *artistsDictionary;
@property (nonatomic, strong) NSDictionary *genresDictionary;
@property (nonatomic, strong) NSDictionary *playlistsDictionary;
@property (nonatomic, strong) NSDictionary *mediaItemsDictionary;
@property (nonatomic, strong) NSDictionary *previousItemsDictionary;
@property (nonatomic, strong) GVMusicPlayerController *musicPlayer;
@property (nonatomic, strong) MPMediaItemCollection *musicCollection;
@property (nonatomic, strong) MPMediaItemCollection *dadCollection;
@property (nonatomic, strong) MPMediaItem *songToPlay;

+ (GVMusicPlayerController *)sharedInstance;

- (void)addDelegate:(id<GVMusicPlayerControllerDelegate>)delegate;
- (void)removeDelegate:(id<GVMusicPlayerControllerDelegate>)delegate;
- (void)remoteControlReceivedWithEvent:(UIEvent *)receivedEvent;
- (void)setQueueWithItemCollection:(MPMediaItemCollection *)itemCollection;
- (void)setQueueWithQuery:(MPMediaQuery *)query;

//DR stuff added
- (void) setupSortedLists;
- (void)skipToNextItem;
- (void)skipToBeginning;
- (void)skipToPreviousItem;
- (void)storePersistentIdSong :(MPMediaItem *) song;
- (void)loadSongFromUserDefaults;

- (void)playItemAtIndex:(NSUInteger)index;
- (void)playItem:(MPMediaItem *)item;

// Check MPMediaPlayback for other playback related methods
// and properties like play, plause, currentPlaybackTime
// and more.

@end
