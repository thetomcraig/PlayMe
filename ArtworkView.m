#import "ArtworkView.h"

@implementation ArtworkView

@synthesize backgroundColor = _backgroundColor;
@synthesize topArrow = _topArrow;

//##############################################################################
//Overrode the shit out of this class.  It is made transparent, then the arrow
//is drawn at the top, and the background it drawn below it, behind the art
//##############################################################################
- (void)drawRect:(NSRect)dirtyRect
{
    _backgroundColor = [NSColor colorWithCalibratedRed:0.9
                                                 green:0.9
                                                  blue:0.9
                                                 alpha:1.0];
    _topArrow = [NSImage imageNamed:@"bgTopArrow"];
    
    //Clear everything
    [[NSColor clearColor] set];
    NSRectFill([self frame]);
    
    [self drawArrow:dirtyRect];
    [self drawBackground:dirtyRect];
}

//##############################################################################
//Drawing the top arrow, that points the menubar.  We find the point where
//it can be centered at the top of the window, then do fancy magic to make it
//into a mask, and colorize it, then draw it at the right location.
//
//topArrowLocation is set from the window controller, and it is where the top
//arrow is on the x axis
//##############################################################################
-(void)drawArrow:(NSRect)dirtyRect
{
    
    NSPoint arrowLocation =
        NSMakePoint(dirtyRect.size.width/2 - _topArrow.size.width/2,
                    dirtyRect.size.height - _topArrow.size.height);
    
    NSRect arrowRect = NSMakeRect(arrowLocation.x, arrowLocation.y,
                                  _topArrow.size.width, _topArrow.size.height);
    
    NSGraphicsContext *ctx = [NSGraphicsContext currentContext];
    CGContextRef contextRef = [ctx graphicsPort];
    
    NSData *data = [_topArrow TIFFRepresentation];
    CGImageSourceRef source =
                    CGImageSourceCreateWithData((__bridge CFDataRef)data, NULL);
    
    CGImageRef imageRef = CGImageSourceCreateImageAtIndex(source, 0, NULL);
    CFRelease(source);
    
    CGContextSaveGState(contextRef);
    {
        CGContextClipToMask(contextRef, NSRectToCGRect(arrowRect), imageRef);
        [_backgroundColor setFill];
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
-(void)drawBackground:(NSRect)dirtyRect
{
    double capHeight = 30.0;
    double roundingRadius = 6;
    NSImage *bgTopArrow = [NSImage imageNamed:@"bgTopArrow"];
    double arrowHeight = bgTopArrow.size.height;
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
    [_backgroundColor set];
    
    NSBezierPath* topCap =
                [NSBezierPath bezierPathWithRoundedRect
                :NSMakeRect(0.0, topSize.height - capHeight - roundingRadius,
                            topSize.width,
                            topSize.height + roundingRadius)
                xRadius:roundingRadius yRadius:roundingRadius];
    
    [topCap setWindingRule:NSEvenOddWindingRule];
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
    [_backgroundColor set];
    
    NSBezierPath* middle = [NSBezierPath bezierPathWithRect
                            :NSMakeRect(0.0, 0.0,
                                        middleSize.width,
                                        middleSize.height)];
    
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
    [_backgroundColor set];
    
    NSBezierPath* bottomCap = [NSBezierPath bezierPathWithRoundedRect
                               :NSMakeRect(0.0, 0.0,
                                           bottomSize.width,
                                           bottomSize.height + roundingRadius)
                               xRadius:roundingRadius yRadius:roundingRadius];
    
    [bottomCap setWindingRule:NSEvenOddWindingRule];
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
