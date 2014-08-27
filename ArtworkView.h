#import <Cocoa/Cocoa.h>

@interface ArtworkView : NSView

@property (nonatomic, strong) NSImage *topArrow;
@property (strong, retain) NSColor *backgroundColor;
@property (nonatomic) NSPoint arrowLocation;

@end
