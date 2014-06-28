#import <Foundation/Foundation.h>
#import "iTunes.h"

@class ITunesController;
@protocol ITunesControllerDelegate <NSObject>
@end

@interface ITunesController :NSObject
{
    __unsafe_unretained id<ITunesControllerDelegate> _delegate;
    iTunesApplication *_iTunes;
    NSString *_currentStatus;
    NSString *_currentSong;
    NSString *_currentArtist;
    NSString *_currentAlbum;
    NSString *_currentLyrics;
    NSImage *_currentArtwork;
    double _currentProgress;
    double _currentLength;
    bool _iTunesRunning;
}

@property (nonatomic, strong) iTunesApplication *iTunes;
@property (nonatomic, strong) NSString *currentStatus;
@property (nonatomic, strong) NSString *currentSong;
@property (nonatomic, strong) NSString *currentArtist;
@property (nonatomic, strong) NSString *currentAlbum;
@property (nonatomic, strong) NSString *currentLyrics;
@property (nonatomic, retain) NSImage  *currentArtwork;
@property (nonatomic) double currentProgress;
@property (nonatomic) double currentLength;
@property (nonatomic) bool iTunesRunning;


///
- (void)iTunesControllerDelegateTest;
///

- (id)initWithDelegate:(id<ITunesControllerDelegate>)delegate;
- (void)update;
- (void)updateWithNill;
- (void)updateArtwork;
- (void)updateProgress;
- (void)updateLyrics;
- (bool)createiTunesObjectIfNeeded;
- (bool)destroyiTunes;
- (void)setPlayerPosition:(double)newPosition;
- (void)playpause;
- (void)nextSong;
- (void)previousSong;

@end
