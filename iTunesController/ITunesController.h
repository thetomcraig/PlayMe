#import <Foundation/Foundation.h>
#import "iTunes.h"
#import "ImageController.h"


@interface ITunesController :NSObject


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

- (void)updateTags;

@end