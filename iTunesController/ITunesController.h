#import <Foundation/Foundation.h>
#import "iTunes.h"
#import "ImageController.h"


@interface ITunesController :NSObject

@property (nonatomic) NSMutableDictionary* iTunesTags;
@property (nonatomic, retain) NSImage *nothingPlaying;
@property (nonatomic, retain) NSTimer *countDownTimer;
@property (nonatomic) NSNumber* currentProgress;
@property (nonatomic) double currentProgressDouble;
@property (nonatomic) NSNumber* currentLength;
@property (nonatomic) double currentLengthDouble;
@property (nonatomic, strong) NSString *currentTimeLeft;


- (void)updateTagsPoll:(iTunesApplication *)iTunes;
- (void)updateArtwork:(BOOL)getNewArt;
- (void)updateWithNill;
- (void)receivedStatusNotification:(NSNotification *)note;
- (void)receivedCommandNotification:(NSNotification *)note;
- (void)sendTagsNotification;
- (void)playingUpdate:(NSDictionary *)dict;
- (void)pausedUpdate;
- (void)stoppedUpdate;

@end