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
    float red = 81.0/256.0;
    float green = 136.0/256.0;
    float blue = 57.0/256.0;
    
    [[NSColor colorWithCalibratedRed:red green:green blue:blue alpha:1.0] setFill];
    NSRectFill(dirtyRect);

    
     NSRect creditsArea = NSMakeRect(dirtyRect.origin.x, dirtyRect.origin.y, dirtyRect.size.width, 35);
    [[NSColor grayColor] setFill];
    NSRectFill(creditsArea);

     
}

@end
