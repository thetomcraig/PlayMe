#import <Cocoa/Cocoa.h>

@interface ArtworkView : NSView
{
    NSColor *_backgroundColor;
    NSImage *_topArrow;
}

@property (nonatomic, strong) NSImage *topArrow;
@property (nonatomic, strong) NSColor *backgroundColor;

@end
