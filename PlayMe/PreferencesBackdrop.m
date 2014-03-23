#import "PreferencesBackdrop.h"

@implementation PreferencesBackdrop

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        // Initialization code here.
    }
    return self;
}

- (void)drawRect:(NSRect)dirtyRect
{
	[super drawRect:dirtyRect];
    
	
    //[[NSColor colorWithCalibratedRed:.443137255 green:.749019608 blue:.309803922 alpha:1.0] setFill];
    //NSRectFill(dirtyRect);
    
    NSRect creditsArea = NSMakeRect(dirtyRect.origin.x, dirtyRect.origin.y, dirtyRect.size.width, 35);
    [[NSColor grayColor] setFill];
    NSRectFill(creditsArea);
    
    [super drawRect:dirtyRect];
}

@end
