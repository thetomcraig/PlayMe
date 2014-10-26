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

-(BOOL)findColorsOpSeperateThread :(NSImage *)albumArt forSong:(NSString *)songTitle;
-(NSImage *)resizeArt :(NSImage *) bigArt forSize:(NSSize)targetSize;
-(NSImage *)resizeNothingPlaying:(NSSize)targetSize;
-(NSImage *)resizeResource :(NSImage *) origImage :(NSSize)targetSize;
-(NSImage *)putOnPausedMask :(NSImage *)unmaskedArt;
-(NSImage *)roundCorners: (NSImage *)squareArt;

@end