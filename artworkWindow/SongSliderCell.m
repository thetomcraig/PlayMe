#import "SongSliderCell.h"

@implementation SongSliderCell

@synthesize backgroundColor;
@synthesize progressColor;

//############################################################################
//This draws the knob.  We only want to draw the left half of the know because
//we want it to be to the left of the mouse.  This way it lines up better bec
//-ause the 
//############################################################################
-(void)drawKnob:(NSRect)knobRect
{
    NSRect leftHalf = knobRect;
    leftHalf.size.width /= 2;
    NSBezierPath* leftPath = [NSBezierPath bezierPathWithRect:leftHalf];
    
    [progressColor set];
    [leftPath fill];
}

//############################################################################
//This actually draws in the bar, and the color on the left of the knob comes
//from the algorithm.  We don't draw anything to the right of the knob.
//############################################################################
-(void)drawBarInside:(NSRect)aRect flipped:(BOOL)flipped
{
    [progressColor set];
    NSRect elapsedRect = aRect;
    elapsedRect.origin.y = [self knobRectFlipped:NO].origin.y;
    elapsedRect.size.height = [self knobRectFlipped:NO].size.height;
    elapsedRect.size.width = [self knobRectFlipped:NO].origin.x;
    NSBezierPath* elapsedPath = [NSBezierPath bezierPathWithRect:elapsedRect];
    [elapsedPath fill];
    
    [backgroundColor set];
    NSRect backgroundRect = aRect;
    backgroundRect.origin.x = [self knobRectFlipped:NO].origin.x;
    backgroundRect.origin.y = [self knobRectFlipped:NO].origin.y;
    backgroundRect.size.height = [self knobRectFlipped:NO].size.height;
    backgroundRect.size.width = aRect.size.width - elapsedRect.size.width;
    NSBezierPath* backgroundPath = [NSBezierPath bezierPathWithRect:backgroundRect];
    [backgroundPath fill];
}


@end