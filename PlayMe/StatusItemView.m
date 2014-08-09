#define EDGE_PADDING_WIDTH  6
#define INNER_PADDING_WIDTH  3
#define PADDING_HEIGHT 3

#import "StatusItemView.h"

@implementation StatusItemView

@synthesize statusItem;
@synthesize title;
@synthesize image;
@synthesize alternateImage;

//##############################################################################
//Init
//##############################################################################
- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        statusItem = nil;
        title = @"";
        image = [NSImage imageNamed:@"Stopped"];
        isHighlighted = NO;
    }
    return self;
}

#
#pragma mark - mouse events
#
//##############################################################################
//When he user clicks.  If they are holding the control key, this counts as a
//right click, so we call right mouseDown.  RightMouseDown is similar, but sends
//a different notification.
//##############################################################################
- (void)mouseDown:(NSEvent *)theEvent
{
    isHighlighted = !isHighlighted;
    
    if ([theEvent modifierFlags] & NSControlKeyMask)
    {
        [self rightMouseDown:nil];
    }
    else
    {
        //We need to pass the position of the rect in the menubar,
        //and we convert it to an NSValue
        NSString *globalRectString =
        NSStringFromRect([[[NSApp currentEvent] window] frame]);
        
        NSDictionary *menubarInfo =
        @{
          @"GlobalRect": globalRectString
          };
        
        //Sending the notification
        [[NSNotificationCenter defaultCenter]
         postNotificationName:@"MouseDownNotification"
         object:self
         userInfo:menubarInfo];
    }
    
    [self setNeedsDisplay:YES];
}

//##############################################################################
//For rgith clicks, sends its own notification
//##############################################################################
- (void)rightMouseDown:(NSEvent *)theEvent
{
    isHighlighted = !isHighlighted;
    
    //Sending the notification
    [[NSNotificationCenter defaultCenter]
     postNotificationName:@"RightMouseDownNotification"
     object:self
     userInfo:nil];
}


#
#pragma mark - setters
#
//##############################################################################
//Setting the instacne property, and setting the length of the statusItem to
//match the length of the text
//##############################################################################
- (void)setTitle:(NSString *)newTitle
{
    if (![title isEqual:newTitle])
    {

        title = newTitle;
        
        // Update status item size (which will also update this view's bounds)
        NSRect titleBounds = [self titleBoundingRect];
        int newWidth = titleBounds.size.width + image.size.width + (2*EDGE_PADDING_WIDTH) + INNER_PADDING_WIDTH;
        [statusItem setLength:newWidth];
        
        [self setNeedsDisplay:YES];
    }
}

- (void)setImage:(NSImage *)newImage
{
    image = newImage;
}

- (void)setAlternateImage:(NSImage *)newImage
{
    alternateImage = newImage;
}

#
#pragma mark - getters
#
- (NSString *)title
{
    return title;
}

- (NSColor *)titleForegroundColor
{
    if (isHighlighted) {
        return [NSColor whiteColor];
    }
    else {
        return [NSColor blackColor];
    }
}

- (NSDictionary *)titleAttributes
{
    // Use default menu bar font size
    NSFont *font = [NSFont menuBarFontOfSize:0];
    
    NSColor *foregroundColor = [self titleForegroundColor];
    
    return [NSDictionary dictionaryWithObjectsAndKeys:
            font,            NSFontAttributeName,
            foregroundColor, NSForegroundColorAttributeName,
            nil];
}

- (NSRect)titleBoundingRect
{
    return [title boundingRectWithSize:NSMakeSize(1e100, 1e100)
                               options:0
                            attributes:[self titleAttributes]];
}

#
#pragma mark - drawing
#
//##############################################################################
//Drawing the statusbar in the view, and drawing the text at the origin
//##############################################################################
- (void)drawRect:(NSRect)rect
{
    //Draw status bar background, highlighted if menu is showing
    [statusItem drawStatusBarBackgroundInRect:[self bounds]
                                withHighlight:isHighlighted];
    
    //"origin" according to the padding
    NSPoint origin = NSMakePoint(EDGE_PADDING_WIDTH,
                                 PADDING_HEIGHT);
    
    double widthOfImage = image.size.width;
    NSPoint titlePoint = origin;
    titlePoint.x += widthOfImage + INNER_PADDING_WIDTH;
    
    [title drawAtPoint:titlePoint
        withAttributes:[self titleAttributes]];

    NSPoint imagePoint = origin;
    imagePoint.y = 0;
    NSImage *imageToDraw = isHighlighted ? alternateImage : image;
    [imageToDraw drawAtPoint:imagePoint
                    fromRect:NSZeroRect
                   operation:NSCompositeSourceOver
                    fraction:1.0];
    
}













@end