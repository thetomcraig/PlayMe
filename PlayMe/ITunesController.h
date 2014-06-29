#import <Foundation/Foundation.h>
#import "iTunes.h"
#import "ImageController.h"
#import "NCController.h"


@interface ITunesController :NSObject
{
    iTunesApplication *_iTunes;
    ImageController *_imageController;
    NCController *_ncController;
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
@property (nonatomic, strong) ImageController *imageController;
@property (nonatomic, strong) NCController *ncController;
@property (nonatomic, strong) NSString *currentStatus;
@property (nonatomic, strong) NSString *currentSong;
@property (nonatomic, strong) NSString *currentArtist;
@property (nonatomic, strong) NSString *currentAlbum;
@property (nonatomic, strong) NSString *currentLyrics;
@property (nonatomic, retain) NSImage  *currentArtwork;
@property (nonatomic) double currentProgress;
@property (nonatomic) double currentLength;
@property (nonatomic) bool iTunesRunning;

- (void)updateTags;

@end