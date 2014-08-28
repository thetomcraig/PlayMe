#import "ArtworkView.h"

@implementation ArtworkView

@synthesize backgroundColor;
@synthesize topArrow;
@synthesize arrowLocation;

//##############################################################################
//Overrode the shit out of this class.  It is made transparent, then the arrow
//is drawn at the top, and the background it drawn below it, behind the art.
//"dirtyRect" the bounds of whatever UI element most recently changed, as such,
//we use self.bounds to get the actual view dimensions for drawing the whole
//thing
//##############################################################################
- (void)drawRect:(NSRect)dirtyRect
{
    topArrow = [NSImage imageNamed:@"bgTopArrow"];
    
    //Clear everything
    [[NSColor clearColor] set];
    NSRectFill(self.bounds);
    
    [self drawBackground:self.bounds];
}

//##############################################################################
//Drawing the top arrow, that points the menubar.  We find the point where
//it can be centered at the top of the window, then do fancy magic to make it
//into a mask, and colorize it, then draw it at the right location.
//
//topArrowLocation is set from the window controller, and it is where the top
//arrow is on the x axis
//##############################################################################
- (void)drawArrow
{
    NSRect arrowRect = NSMakeRect(arrowLocation.x, arrowLocation.y,
                                  topArrow.size.width, topArrow.size.height);
    
    NSGraphicsContext *ctx = [NSGraphicsContext currentContext];
    CGContextRef contextRef = [ctx graphicsPort];
    
    NSData *data = [topArrow TIFFRepresentation];
    CGImageSourceRef source =
                    CGImageSourceCreateWithData((__bridge CFDataRef)data, NULL);
    
    CGImageRef imageRef = CGImageSourceCreateImageAtIndex(source, 0, NULL);
    CFRelease(source);
    
    CGContextSaveGState(contextRef);
    {
        CGContextClipToMask(contextRef, NSRectToCGRect(arrowRect), imageRef);
        [backgroundColor setFill];
        NSRectFill(arrowRect);
    }
    CGContextRestoreGState(contextRef);
    CFRelease(imageRef);
}

//##############################################################################
//Drawing the main background.  We create a rect that is the entire length of
//the view, minus th height of the top arrow.
//Then we create the top, middle, and bottom images for the background,
//colorizing each one.  At the end, we draw th background with these 3 images
//The roundingRadus is for th beveled edges, and the height is that of the
//Top and bottom caps, as the middle image is stretched to bridge the gap
//##############################################################################
- (void)drawBackground:(NSRect)dirtyRect
{
    double capHeight = 50.0;
    double roundingRadius = 6;
    double arrowHeight = topArrow.size.height;
    //Make a rect that's everything but the arrow
    NSRect mainBackgroundRect = NSMakeRect(dirtyRect.origin.x,
                                           dirtyRect.origin.y,
                                           dirtyRect.size.width,
                                           dirtyRect.size.height - arrowHeight);
    
    //--------------------------------------------------------------------------
    //Creating the topImage
    //--------------------------------------------------------------------------
    NSSize topSize = NSMakeSize(mainBackgroundRect.size.width, capHeight);
    NSImage *topImage = [[NSImage alloc] initWithSize:topSize];
    
    [topImage lockFocus];
    [[NSGraphicsContext currentContext]
                                setImageInterpolation:NSImageInterpolationHigh];

    NSBezierPath* topCap =
                [NSBezierPath bezierPathWithRoundedRect
                :NSMakeRect(0.0, topSize.height - capHeight - roundingRadius,
                            topSize.width,
                            topSize.height + roundingRadius)
                xRadius:roundingRadius yRadius:roundingRadius];
    
    [topCap setWindingRule:NSEvenOddWindingRule];
    [backgroundColor set];
    [topCap fill];
    
    [topImage unlockFocus];
    
    //--------------------------------------------------------------------------
    //Creating the middleImage
    //--------------------------------------------------------------------------
    NSSize middleSize = NSMakeSize(mainBackgroundRect.size.width, capHeight);
    NSImage *middleImage = [[NSImage alloc] initWithSize:topSize];
    
    [middleImage lockFocus];
    [[NSGraphicsContext currentContext]
                                setImageInterpolation:NSImageInterpolationHigh];

    NSBezierPath* middle = [NSBezierPath bezierPathWithRect
                            :NSMakeRect(0.0, 0.0,
                                        middleSize.width,
                                        middleSize.height)];
    [backgroundColor set];
    [middle fill];
    
    [middleImage unlockFocus];
    
    //--------------------------------------------------------------------------
    //Creating the bottomImage
    //--------------------------------------------------------------------------
    NSSize bottomSize = NSMakeSize(mainBackgroundRect.size.width, capHeight);
    NSImage *bottomImage = [[NSImage alloc] initWithSize:bottomSize];
    
    [bottomImage lockFocus];
    [[NSGraphicsContext currentContext]
                                setImageInterpolation:NSImageInterpolationHigh];
    
    NSBezierPath* bottomCap = [NSBezierPath bezierPathWithRoundedRect
                               :NSMakeRect(0.0, 0.0,
                                           bottomSize.width,
                                           bottomSize.height + roundingRadius)
                               xRadius:roundingRadius yRadius:roundingRadius];
    
    [bottomCap setWindingRule:NSEvenOddWindingRule];
    [backgroundColor set];
    [bottomCap fill];
    
    [bottomImage unlockFocus];
    
    //--------------------------------------------------------------------------
    //Combining and drawing
    //--------------------------------------------------------------------------
    NSDrawThreePartImage(mainBackgroundRect,
                         topImage, middleImage, bottomImage, YES,
                         NSCompositeSourceOver, 1.0, NO);
}

@end
