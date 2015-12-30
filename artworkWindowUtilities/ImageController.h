#import <Foundation/Foundation.h>
#import "AlbumColorPicker.h"

@interface ImageController : NSObject
{
    int threshold;
}

@property (nonatomic, retain) NSImage *bgBlack;
@property (nonatomic, retain) AlbumColorPicker *albumColorPicker;
@property (nonatomic, retain) NSDictionary *albumColors;
@property (nonatomic, retain) NSString *lastArtCalculated;
@property (nonatomic, retain) NSImage *nothingPlaying;

-(BOOL)findColorsOpSeperateThread :(NSImage *)albumArt forSong:(NSString *)songTitle;
-(NSImage *)prepareNewArt :(NSImage *)resourceImage :(NSString *)status;
-(NSImage *)clipArtToSquare :(NSImage *)nonSquareArt;
-(NSImage *)resizeArt :(NSImage *)bigArt;
-(NSImage *)resizeNothingPlaying;
-(NSImage *)resizeResource :(NSImage *) origImage :(NSSize)targetSize;
-(void)putOnPausedMask :(NSImage *)unmaskedArt;
-(NSImage*)roundCorners: (NSImage *)squareArt;

@end
