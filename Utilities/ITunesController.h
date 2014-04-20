#import <Foundation/Foundation.h>
#import "iTunes.h"

@interface ITunesController : NSObject
{
    iTunesApplication *iTunes;
}

//@property (nonatomic, assign) iTunesApplication *iTunes;
@property (nonatomic, assign) bool iTunesRunning;
@property (nonatomic, assign) NSString *currentStatus;
@property (nonatomic, assign) NSString *currentSong;
@property (nonatomic, assign) NSString *currentArtist;
@property (nonatomic, assign) NSString *currentAlbum;
@property (nonatomic, assign) NSString *currentLyrics;
@property (nonatomic, assign) double currentProgress;
@property (nonatomic, assign) double currentLength;
@property (nonatomic, retain) NSImage  *currentArtwork;

-(id)init;
-(void)update;
-(void)updateWithNill;
-(void)updateArtwork;
-(void)updateProgress;
-(void)updateLyrics;
-(bool)createiTunesObjectIfNeeded;
-(bool)destroyiTunes;
-(void)setPlayerPosition:(double)newPosition;
-(void)playpause;
-(void)nextSong;
-(void)previousSong;

@end
