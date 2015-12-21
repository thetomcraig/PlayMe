#import <Foundation/Foundation.h>
#import "iTunes.h"
#import "ImageController.h"


@interface ITunesController :NSObject

@property (nonatomic, strong) ImageController *imageController;
@property (nonatomic, strong) iTunesApplication *iTunes;
@property (nonatomic) NSMutableDictionary* iTunesTags;
@property (nonatomic) NSSize artworkSize;
@property (nonatomic, retain) NSImage *blankArtwork;
@property (nonatomic, retain) NSTimer *countDownTimer;
@property (nonatomic) NSNumber* currentProgress;
@property (nonatomic) double currentProgressDouble;
@property (nonatomic) NSNumber* currentLength;
@property (nonatomic) double currentLengthDouble;
@property (nonatomic, strong) NSString *currentTimeLeft;


- (void)updateTagsPoll;

@end