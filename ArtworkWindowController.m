#import "ArtworkWindowController.h"

@interface ArtworkWindowController ()

@end

@implementation ArtworkWindowController

- (instancetype)initWithWindow:(NSWindow *)window
{
    self = [super initWithWindow:window];
    if (self) {
        // Initialization code here.
    }
    
    [[NSNotificationCenter defaultCenter]
                             addObserver:self
                             selector:@selector(receivedMouseDownNotification:)
                             name:@"MouseDownNotification"
                             object:nil];
    

    
    return self;
}

- (void)windowDidLoad
{
    [super windowDidLoad];
    
    // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
}

//##############################################################################
//Opening and closing the window with the menubar icon is clicked.
//##############################################################################
-(void)receivedMouseDownNotification:(NSNotification *)note
{
    
    //If the window is open, close it
    if ([[self window] isVisible])
    {
        NSLog(@"ALPHA");
        [[self window] close];
    }
    
    //Otherwise its closed, so open it
    else
    {
        NSLog(@"BETA");
        CGRect statusRect = NSRectFromString(
                                    [note.userInfo objectForKey:@"GlobalRect"]);
        
        
        statusRect.origin.y = NSMinY(statusRect) - NSHeight(statusRect);
        
        
        NSRect windowRect = [[self window] frame];
        windowRect.origin.x = roundf(NSMidX(statusRect) - NSWidth(windowRect) / 2);
        windowRect.origin.y = NSMaxY(statusRect) - NSHeight(windowRect);
        
        [[self window] setFrame:windowRect display:YES];
        
        [[self window] makeKeyAndOrderFront:self];
        [[self window] setLevel:kCGFloatingWindowLevel];
        [NSApp activateIgnoringOtherApps:YES];
    }
}

@end
