#import <Cocoa/Cocoa.h>

@interface SongSlider : NSSlider

@property (readwrite, assign) int sliderPosition;
@property (nonatomic, assign) NSColor *backgroundColor;

@end