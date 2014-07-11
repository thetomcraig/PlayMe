#import "ArtworkWindowController.h"

@implementation ArtworkWindowController

- (id)initWithWindowNibName:(NSString *)windowNibName
{
    self = [super initWithWindowNibName:windowNibName];
    if (self)
    {
        [[NSNotificationCenter defaultCenter]
                             addObserver:self
                             selector:@selector(receivedMouseDownNotification:)
                             name:@"MouseDownNotification"
                             object:nil];
    }
    return self;
}

//##############################################################################
//Opening and closing the window with the menubar icon is clicked.
//##############################################################################
-(void)receivedMouseDownNotification:(NSNotification *)note
{
    NSLog(@"ALPHA");
    //If the window is open, close it
    if ([[self window] isVisible])
    {
        [[self window] close];
    }
    
    //Otherwise its closed, so open it
    else
    {
        //Clear notifications from the screen,
        [[NSUserNotificationCenter defaultUserNotificationCenter]
         removeAllDeliveredNotifications];

        struct DangerZone
        {
            double lowerBound;
            double upperBound;
        };
        
        //Get the position of the menubar item
        CGRect statusRect =
                NSRectFromString([note.userInfo objectForKey:@"GlobalRect"]);
        statusRect.origin.y = NSMinY(statusRect) - NSHeight(statusRect);
        //Move the window to under here
        NSRect windowRect = [[self window] frame];
        windowRect.origin.x = roundf(NSMidX(statusRect) - NSWidth(windowRect)/2);
        windowRect.origin.y = NSMaxY(statusRect) - NSHeight(windowRect);
        [[self window] setFrame:windowRect display:YES];
        //Display the window
        [[self window] makeKeyAndOrderFront:self];
        [[self window] setLevel:kCGFloatingWindowLevel];
        [NSApp activateIgnoringOtherApps:YES];
    }//End else
    
}

@end
