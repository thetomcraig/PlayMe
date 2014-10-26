#import <Foundation/Foundation.h>
#import "iTunes.h"
#import "ImageController.h"


@interface ITunesController :NSObject
{
    iTunesApplication *_iTunes;
    ImageController *_imageController;
    NSString *_currentStatus;
    NSString *_currentSong;
    NSString *_currentArtist;
    NSString *_currentAlbum;
    NSString *_currentLyrics;
    NSImage *_currentArtwork;
    NSTimer *_countDownTimer;
    double _currentProgress;
    double _currentLength;
    NSString *_currentTimeLeft;
    bool _iTunesRunning;
    
}

@property (nonatomic, strong) iTunesApplication *iTunes;
@property (nonatomic, strong) ImageController *imageController;
@property (nonatomic, strong) NSString *currentStatus;
@property (nonatomic, strong) NSString *currentSong;
@property (nonatomic, strong) NSString *currentArtist;
@property (nonatomic, strong) NSString *currentAlbum;
@property (nonatomic, strong) NSString *currentLyrics;
@property (nonatomic, retain) NSImage  *currentArtwork;
@property (nonatomic, retain) NSTimer *countDownTimer;
@property (nonatomic) double currentProgress;
@property (nonatomic) double currentLength;
@property (nonatomic, strong) NSString *currentTimeLeft;
@property (nonatomic) bool iTunesRunning;

- (void)updateTags;

@end