#import "SongSlider.h"

@implementation SongSlider

@synthesize sliderPosition;
@synthesize backgroundColor;

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {

    }
    return self;
}

-(void)drawRect:(NSRect)dirtyRect
{
	[super drawRect:dirtyRect];
}

//############################################################################
//This was added to make sure that the entire slider is redrawn when needed,
//aka when the user moves it.
//############################################################################
-(void)setNeedsDisplayInRect:(NSRect)invalidRect
{
    [super setNeedsDisplayInRect:[self bounds]];
}

@end