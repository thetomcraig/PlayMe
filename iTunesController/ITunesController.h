#import <Foundation/Foundation.h>
#import "iTunes.h"
#import "ImageController.h"


@interface ITunesController :NSObject

@property (nonatomic, strong) ImageController *imageController;
@property (nonatomic, strong) iTunesApplication *iTunes;
@property (nonatomic, strong) SBElementArray *artworks;
@property (nonatomic, retain) NSImage  *currentArtwork;
@property (nonatomic, retain) NSMutableDictionary* iTunesTags;
@property (nonatomic, retain) NSTimer *countDownTimer;
@property (nonatomic) NSNumber* currentProgress;
@property (nonatomic) double currentProgressDouble;
@property (nonatomic) NSNumber* currentLength;
@property (nonatomic) double currentLengthDouble;
@property (nonatomic, strong) NSString *currentTimeLeft;


- (void)updateTagsPoll;

@end