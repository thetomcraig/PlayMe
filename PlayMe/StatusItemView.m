#import "StatusItemView.h"

@implementation StatusItemView

@synthesize statusItem;
@synthesize title;
@synthesize image;
@synthesize alternateImage;
@synthesize isHighlighted;

//##############################################################################
//Initilaizing with an NSStatusItem
//##############################################################################
- (id)initWithStatusItem:(NSStatusItem *)statusItemInp
{
    CGFloat itemWidth = [statusItem length];
    CGFloat itemHeight = [[NSStatusBar systemStatusBar] thickness];
    NSRect itemRect = NSMakeRect(0.0, 0.0, itemWidth, itemHeight);
    self = [super initWithFrame:itemRect];
    
    if (self != nil) {
        statusItem = statusItemInp;
        statusItem.view = self;
    }
    return self;
}

//##############################################################################
//For updating the iTunes informatoin tahts displayed in the menubar
//Know that the name of the rsource image is going to be the same as
//the name of the iTunes status
//##############################################################################
- (void)update:(NSString *)songTitle :(NSString *)iTunesStatus
{
    /**
    if (![title isEqualToString:songTitle])
    {
        title = songTitle;
        image = [NSImage imageNamed:iTunesStatus];
        alternateImage =
            [NSImage imageNamed:[iTunesStatus stringByAppendingString:@"White"]];
        
        [self setNeedsDisplay:YES];
    }
     */
}

//##############################################################################
//Draws the resource image and the string of the iTunesStatus
//##############################################################################
/**
- (void)drawRect:(NSRect)dirtyRect
{

    
    ///The title is not working properly here
    
    ///NSLog(@"%@", title);
    //Draw the background

 

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
 */


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
    self.isHighlighted = TRUE;
    
    [self setNeedsDisplay:YES];
    
    if ([theEvent modifierFlags] & NSControlKeyMask)
    {
        [self rightMouseDown:nil];
    }
    else
    {
        //We need to pass the position of the rect in the menubar,
        //and we convert it to an NSValue
        NSString *globalRectString = NSStringFromRect([self globalRect]);
        
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
}

- (void)rightMouseDown:(NSEvent *)theEvent
{
    NSLog(@"RIGHT MOUSE DOWN");
    
    self.isHighlighted = TRUE;
    
    //Sending the notification
    [[NSNotificationCenter defaultCenter]
     postNotificationName:@"RightMouseDownNotification"
     object:self
     userInfo:nil];
}

- (void)mouseUp:(NSEvent *)theEvent
{
    ///self.isHighlighted = FALSE;
}

- (void)rightMouseUp:(NSEvent *)theEvent
{
    ///self.isHighlighted = FALSE;
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

#
#pragma mark - getters
#
//##############################################################################
//Used to get the dimenions of the reect in screen coords
//##############################################################################
- (NSRect)globalRect
{
    NSRect frame = [self frame];
    frame.origin = [self.window convertBaseToScreen:frame.origin];
    return frame;
}

@end
