#import <Foundation/Foundation.h>
#import "iTunes.h"
#import "ImageController.h"


@interface ITunesController :NSObject

@property (nonatomic, strong) ImageController *imageController;
@property (nonatomic, strong) iTunesApplication *iTunes;
@property (nonatomic, strong) SBElementArray *artworks;
@property (nonatomic, strong) NSString *currentStatus;
@property (nonatomic, strong) NSString *currentSong;
@property (nonatomic, strong) NSString *currentArtist;
@property (nonatomic, strong) NSString *currentAlbum;
@property (nonatomic, retain) NSImage  *currentArtwork;
@property (nonatomic, retain) NSDictionary* iTunesTags;
@property (nonatomic, retain) NSTimer *countDownTimer;
@property (nonatomic) NSNumber* currentProgress;
@property (nonatomic) double currentProgressDouble;
@property (nonatomic) NSNumber* currentLength;
@property (nonatomic) double currentLengthDouble;
@property (nonatomic, strong) NSString *currentTimeLeft;


- (void)updateTagsPoll;

@end