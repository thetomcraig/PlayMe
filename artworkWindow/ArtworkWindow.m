#import "ArtworkWindow.h"

@implementation ArtworkWindow

-(id)initWithContentRect:(NSRect)contentRect
               styleMask:(NSUInteger)aStyle
                 backing:(NSBackingStoreType)bufferingType
                   defer:(BOOL)flag
{
    //Reslts in a window with no titlebar
    self = [super initWithContentRect:contentRect
                            styleMask:NSBorderlessWindowMask
                              backing:NSBackingStoreBuffered defer:NO];
    if (self != nil)
    {
        [self setAlphaValue:1.0];
        [self setOpaque:NO];
    }
    return self;
}

-(BOOL)canBecomeKeyWindow
{
    return YES;
}
@end
