#define StatusItemViewPaddingWidth  6
#define StatusItemViewPaddingHeight 3

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
        isHighlighted = NO;
    }
    return self;
}

#
#pragma mark - updating
#
//##############################################################################
//For updating the iTunes informatoin tahts displayed in the menubar
//Know that the name of the rsource image is going to be the same as
//the name of the iTunes status
//##############################################################################
- (void)update:(NSString *)songTitle :(NSString *)iTunesStatus
{
    if (![title isEqualToString:songTitle])
    {
        title = songTitle;
        image = [NSImage imageNamed:iTunesStatus];
        alternateImage =
        [NSImage imageNamed:[iTunesStatus stringByAppendingString:@"White"]];
        
        [self setNeedsDisplay:YES];
    }
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
    ///[[self menu] setDelegate:self];
    ///[statusItem popUpStatusItemMenu:[self menu]];
    
    
    
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

- (void)rightMouseDown:(NSEvent *)theEvent
{
    isHighlighted = !isHighlighted;
    
    //Sending the notification
    [[NSNotificationCenter defaultCenter]
     postNotificationName:@"RightMouseDownNotification"
     object:self
     userInfo:nil];
}

- (void)menuWillOpen:(NSMenu *)menu {
    isHighlighted = YES;
    [self setNeedsDisplay:YES];
}

- (void)menuDidClose:(NSMenu *)menu {
    isHighlighted = NO;
    [menu setDelegate:nil];
    [self setNeedsDisplay:YES];
}

- (NSColor *)titleForegroundColor {
    if (isHighlighted) {
        return [NSColor whiteColor];
    }
    else {
        return [NSColor blackColor];
    }
}

- (NSDictionary *)titleAttributes {
    // Use default menu bar font size
    NSFont *font = [NSFont menuBarFontOfSize:0];
    
    NSColor *foregroundColor = [self titleForegroundColor];
    
    return [NSDictionary dictionaryWithObjectsAndKeys:
            font,            NSFontAttributeName,
            foregroundColor, NSForegroundColorAttributeName,
            nil];
}

- (NSRect)titleBoundingRect {
    return [title boundingRectWithSize:NSMakeSize(1e100, 1e100)
                               options:0
                            attributes:[self titleAttributes]];
}

- (void)setTitle:(NSString *)newTitle {
    if (![title isEqual:newTitle]) {

        title = newTitle;
        
        // Update status item size (which will also update this view's bounds)
        NSRect titleBounds = [self titleBoundingRect];
        int newWidth = titleBounds.size.width + (2 * StatusItemViewPaddingWidth);
        [statusItem setLength:newWidth];
        
        [self setNeedsDisplay:YES];
    }
}

- (NSString *)title {
    return title;
}

- (void)drawRect:(NSRect)rect {
    // Draw status bar background, highlighted if menu is showing
    [statusItem drawStatusBarBackgroundInRect:[self bounds]
                                withHighlight:isHighlighted];
    
    // Draw title string
    NSPoint origin = NSMakePoint(StatusItemViewPaddingWidth,
                                 StatusItemViewPaddingHeight);
    [title drawAtPoint:origin
        withAttributes:[self titleAttributes]];
}




/**
//##############################################################################
//Draws the resource image and the string of the iTunesStatus
//##############################################################################
- (void)drawRect:(NSRect)dirtyRect
{


    [self.statusItem drawStatusBarBackgroundInRect:statusItem.view.frame
                                     withHighlight:self.isHighlighted];

    //What color icons and text?
    NSImage *icon = self.isHighlighted ? self.alternateImage : self.image;
    NSColor *textColor = self.isHighlighted ? [NSColor whiteColor] : [NSColor blackColor];

    //Setting up the text attributes, 0 means default size
    NSFont *menuBarFont = [NSFont menuBarFontOfSize: 0];
    
    NSMutableParagraphStyle *menuBarparagraphStyle =
    [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
    [menuBarparagraphStyle setAlignment:NSCenterTextAlignment];
    
    NSDictionary *attributes =
    @{
      NSFontAttributeName: menuBarFont,
      NSParagraphStyleAttributeName: menuBarparagraphStyle,
      NSForegroundColorAttributeName:textColor
      };
    
    //Setting up the icon information
    NSSize iconSize = [icon size];
    NSRect bounds = self.bounds;
    CGFloat iconX = 0;
    CGFloat iconY = roundf((NSHeight(bounds) - iconSize.height) / 2);
    NSPoint iconPoint = NSMakePoint(iconX, iconY);

    //Do the icon and text
    [icon drawAtPoint:iconPoint
             fromRect:NSZeroRect
            operation:NSCompositeSourceOver
             fraction:1.0];
    
    [title drawInRect:self.bounds withAttributes:attributes];
    
    
    //This is finding what size the actual menubar item should take up
    //because it's dependent upon how much text we have
    NSRect newBounds = self.bounds;
    CGSize titleSize = [title sizeWithAttributes:attributes];
    
    newBounds.size.width = titleSize.width;
    ///[statusItem setLength:newBounds.size.width];
    ///[self setBounds:newBounds];
    ///[statusItem setTitle:title];
}





#
#pragma mark - setters
#

- (void)setImage:(NSImage *)newImage
{
    image = newImage;
}

- (void)setAlternateImage:(NSImage *)newImage
{
    alternateImage = newImage;
}

- (void)setTitle:(NSString *)newTitle
{
    title = newTitle;
}
*/
@end