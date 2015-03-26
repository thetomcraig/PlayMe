#define EDGE_PADDING_WIDTH  6
#define INNER_PADDING_WIDTH  4
#define PADDING_HEIGHT 2

#import "StatusItemView.h"

@implementation StatusItemView

@synthesize statusItem;
@synthesize title;
@synthesize image;
@synthesize alternateImage;
@synthesize menu;
@synthesize preferences;
@synthesize openIniTunes;
@synthesize quitApp;
@synthesize statusRect;
@synthesize currentStatus;

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
        currentStatus = @"Stopped";
        isHighlighted = FALSE;
        
        menu = [[NSMenu alloc] initWithTitle:@"Menu"];
        [[menu addItemWithTitle:@"Go to song in iTunes"
                         action:@selector(openIniTunes:)
                  keyEquivalent:@""] setTarget:self];
        
        [[menu addItemWithTitle:@"Preferences..."
                         action:@selector(showPreferences:)
                  keyEquivalent:@""] setTarget:self];
        
        [[menu addItemWithTitle:@"Quit PlayMe"
                         action:@selector(quitPlayMe:)
                  keyEquivalent:@""] setTarget:self];
        
        
        [statusItem setMenu:menu];
        [menu setDelegate:self];
        
        [[NSDistributedNotificationCenter defaultCenter] addObserver:self
                                                            selector:@selector(darkModeChanged:) name:@"AppleInterfaceThemeChangedNotification"object:nil];
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
    if ([theEvent modifierFlags] & NSControlKeyMask)
    {
        [self rightMouseDown:nil];
    }
    else
    {
        [self sendMouseDownNotification];
    }
    
    [self setNeedsDisplay:YES];
}

//##############################################################################
//For rgith clicks, sends its own notification
//##############################################################################
- (void)rightMouseDown:(NSEvent *)theEvent
{
    [statusItem popUpStatusItemMenu:menu];
}

#
#pragma mark - menu related
#
//##############################################################################
//When the menu opens highliht it
//##############################################################################
- (void)menuWillOpen:(NSMenu *)menu
{
    isHighlighted = YES;
    [self setNeedsDisplay:YES];
}

//##############################################################################
//When the menu closes, unhighlight
//##############################################################################
- (void)menuDidClose:(NSMenu *)menu
{
    isHighlighted = NO;
    [self setNeedsDisplay:YES];
}

//##############################################################################
//Opens the preferences window
//##############################################################################
 - (void)showPreferences:(id)sender
{
    //--------------------------------------------------------------------------
    //Positioning the window
    //--------------------------------------------------------------------------
     NSDictionary *menubarInfo = @{};
     
     //Sending the notification
     [[NSNotificationCenter defaultCenter]
      postNotificationName:@"PreferencesSelectionNotification"
      object:self
      userInfo:menubarInfo];
}


//##############################################################################
//Closes PlayMe and goes to the song in iTunes
//It also closes the window that's open and it sends a notification
//so the delegate knows to update the menubar.
//##############################################################################
-(void)openIniTunes:(id)sender
{
    NSString *path = [[NSBundle mainBundle] pathForResource:@"revealTrack"
                                                     ofType:@"scpt"];
    NSAppleScript *script = [[NSAppleScript alloc]
                             initWithContentsOfURL:[NSURL fileURLWithPath:path]
                             error:nil];
    
    [script executeAndReturnError:nil];
}

//##############################################################################
//This quits the application.
//##############################################################################
-(void)quitPlayMe:(id)sender
{
    [NSApp terminate:self];
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
        int newWidth = image.size.width + (2*EDGE_PADDING_WIDTH);

        //If we are showing the song name, we need extra buffer space
        if([[NSUserDefaults standardUserDefaults] boolForKey:@"showSongName"])
        {
            if ([title isNotEqualTo:@" "])
            {
                newWidth = newWidth + titleBounds.size.width + INNER_PADDING_WIDTH;
            }
        }
        
        [statusItem setLength:newWidth];
        
        [self setNeedsDisplay:YES];
    }
}

//##############################################################################
//Uses the regualr methods to set the images.  Use this logic is in the view,
//because it needs to check if the OS is in dark mode.
//##############################################################################
- (void)setImagesForStatus:(NSString *)statusFromController
{
    NSLog(@"Images being set: %@", statusFromController);
    
    currentStatus = statusFromController;
    //Setting up the image
    NSImage *imageFromController = [NSImage imageNamed:currentStatus];
    NSImage *alternateImageFromController =
    [NSImage imageNamed:[currentStatus stringByAppendingString:@"White"]];

    if ([self isDarkModeOn])
    {
        imageFromController =
        [NSImage imageNamed:[currentStatus stringByAppendingString:@"White"]];

    }
    
    //Setting the images
    [self setImage:imageFromController];
    [self setAlternateImage:alternateImageFromController];
    [self setNeedsDisplay:YES];
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
    if (isHighlighted || [self isDarkModeOn])
    {
        return [NSColor whiteColor];
    }
    else
    {
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
//The text is drawn at the right and the icon at the left.  In this way, the
//icon is always at the right edge of the bounding rect, so it neever moves,
//and this is reflected in the statusRect that is the rect for the onscreen
//position of the icon (used to position window)
//##############################################################################
- (void)drawRect:(NSRect)rect
{
    //Draw status bar background, highlighted if menu is showing
    [statusItem drawStatusBarBackgroundInRect:[self bounds]
                                withHighlight:isHighlighted];
    
    //"origin" according to the padding
    NSPoint origin = NSMakePoint(EDGE_PADDING_WIDTH,
                                 PADDING_HEIGHT);
    
    
    [title drawAtPoint:origin
        withAttributes:[self titleAttributes]];
    
    
    NSPoint imageLocation = self.bounds.origin;
    imageLocation.x = self.bounds.size.width - image.size.width - EDGE_PADDING_WIDTH;
    
    imageLocation.y = 0;
    NSImage *imageToDraw = isHighlighted ? alternateImage : image;
    [imageToDraw drawAtPoint:imageLocation
                    fromRect:NSZeroRect
                   operation:NSCompositeSourceOver
                    fraction:1.0];
    
    //statusRect is position onscreen of the image
    //For the mouseDown notifications
    statusRect = [[self window] frame];
    statusRect.origin.x += imageLocation.x;
    statusRect.size.width = image.size.width;
}


#
#pragma mark - Sending notifications
#
//##############################################################################
//Notification for when the icon is clicked, sends the position of the icon
//for proper window placement.
//##############################################################################
- (void)sendMouseDownNotification
{
    NSDictionary *menubarInfo =
    @{
      @"ImagePoint": NSStringFromRect(statusRect)
      };
    
    //Sending the notification
    [[NSNotificationCenter defaultCenter]
     postNotificationName:@"MouseDownNotification"
     object:self
     userInfo:menubarInfo];

}

#
#pragma mark - Utilities
#

//##############################################################################
//Made this observer for when the user changes the mode so the images are up-
//datd manually.
//##############################################################################
- (void)darkModeChanged:(NSNotification *)notif
{
    [self setImagesForStatus:currentStatus];
}

- (BOOL)isDarkModeOn
{
    NSDictionary *dict = [[NSUserDefaults standardUserDefaults] persistentDomainForName:NSGlobalDomain];
    id style = [dict objectForKey:@"AppleInterfaceStyle"];
    BOOL darkModeOn = (style && [style isKindOfClass:[NSString class]] && NSOrderedSame == [style caseInsensitiveCompare:@"dark"] );
    return darkModeOn;
}

@end