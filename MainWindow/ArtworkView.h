#import <Cocoa/Cocoa.h>

@interface ArtworkView : NSView

@property (nonatomic, assign) double tagsBottom;
@property (nonatomic, assign) double topArrowLocation;
@property (nonatomic, assign) NSColor *arrowColor;
@property (nonatomic, assign) NSColor *backgroundColor;

-(void)drawArrow:(NSRect)dirtyRect;
-(void)drawBackground:(NSRect)dirtyRect;

@end