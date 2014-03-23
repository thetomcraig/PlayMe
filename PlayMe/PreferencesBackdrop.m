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
    
    [[NSColor colorWithCalibratedRed:.02734375 green:.5234375 blue:0 alpha:1.0] setFill];
    NSRectFill(dirtyRect);

    NSRect creditsArea = NSMakeRect(dirtyRect.origin.x, dirtyRect.origin.y, dirtyRect.size.width, 35);
    [[NSColor grayColor] setFill];
    NSRectFill(creditsArea);
}

@end
