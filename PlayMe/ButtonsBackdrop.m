#import "ButtonsBackdrop.h"

@implementation ButtonsBackdrop

@synthesize backgroundColor;

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code here.
    }
    return self;
}

//############################################################################
//Overriding this so it makes a solid color semi-transparent backdrop for the
//control buttons.
//############################################################################
- (void)drawRect:(NSRect)dirtyRect
{
    [[NSColor colorWithCalibratedRed:backgroundColor.redComponent
                               green:backgroundColor.greenComponent
                                blue:backgroundColor.blueComponent
                               alpha:0.80] set];
    NSRect backgroundRect = NSMakeRect(0.0, 0.0,
                                       self.bounds.size.width,
                                       self.bounds.size.height);
    NSBezierPath* backgroundPath = [NSBezierPath bezierPathWithRect:backgroundRect];
    [backgroundPath fill];
}

@end
