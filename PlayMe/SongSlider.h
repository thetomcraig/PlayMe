#import <Cocoa/Cocoa.h>

@interface SongSlider : NSSlider

@property (readwrite, assign) int sliderPosition;
@property (strong, retain) NSColor *backgroundColor;

@end