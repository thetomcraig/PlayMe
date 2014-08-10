#import "PreferencesWindowController.h"

@implementation PreferencesWindowController

@synthesize aboutViewController;
@synthesize preferencesBackdrop;
@synthesize applicationIcon;
@synthesize title;
@synthesize versionText;
@synthesize logo;

//##############################################################################
//Initialize with the nib
//##############################################################################
- (id)initWithWindowNibName:(NSString *)windowNibName
{
    self = [super initWithWindowNibName:windowNibName];
    if (self != nil)
    {
        [[NSNotificationCenter defaultCenter]
         addObserver:self
         selector:@selector(receivedPreferencesSelectionNotification:)
         name:@"PreferencesSelectionNotification"
         object:nil];
    }
    return self;
}

//##############################################################################
//Whenever the window opens, we arrane the elemtns properly, by calling the
//setUpUIElements method.
//##############################################################################
-(void)windowDidLoad
{
    [super windowDidLoad];
    [self setUpUIElements];
}

//##############################################################################
//Arrange the elements.  Here I set the version number and logos
//and arrange them.
//##############################################################################
-(void)setUpUIElements
{
    float width = 200;
    float height = 25;
    [title setImageFrameStyle:NSImageFrameNone];
    [title setImage:[NSImage imageNamed:@"appNameLogo"]];
    [versionText setStringValue:@"v. 1.0.5"];
    [logo setImage:[NSImage imageNamed:@"companyLogo"]];
    [logo setImageFrameStyle:0];
    [logo setFrame:NSMakeRect([self window].frame.size.width/2 - width/2, 5, width, height)];
    [preferencesBackdrop setNeedsDisplay:YES];
}

//##############################################################################
//The notification is received telling the window to open, and this does that
//##############################################################################
- (void)receivedPreferencesSelectionNotification:(NSNotification *)note
{
    NSScreen *mainScreen = [NSScreen mainScreen];
    CGPoint center = CGPointMake(mainScreen.frame.size.width/2, mainScreen.frame.size.height/2);
    //This perfectly centers the window
    CGPoint topLeftPos = CGPointMake(center.x - [self window].frame.size.width/2,
                                     center.y + [self window].frame.size.height/2);
    
    //--------------------------------------------------------------------------
    //Setting the window position, and opening it
    //--------------------------------------------------------------------------
    [[self window] setFrameTopLeftPoint:topLeftPos];
    
    [[self window] setLevel:kCGFloatingWindowLevel];
    [self showWindow:nil];
    
}

//##############################################################################
//This is here to remember that it is connected to the nib, but its
//functionality is handled through the nib, setup with IB.
//##############################################################################
-(IBAction)toggleShowSongName:(id)sender
{
    //pass
}

//##############################################################################
//Opens my website when that button is clicked.  Also sends a notification
//that the delegate picks up to close the windows.
//##############################################################################
- (IBAction)openWebsite:(id)sender
{
    [[NSWorkspace sharedWorkspace] openURL: [NSURL URLWithString:@"http://about.me/tomcraig/"]];
    NSNotification *iTunesButtonNotification = [NSNotification
                                                notificationWithName:@"preferencesWindowButtonClicked"
                                                object:nil];
    [[NSDistributedNotificationCenter defaultCenter] postNotification:iTunesButtonNotification];
}

- (IBAction)openTwitter:(id)sender
{
    [[NSWorkspace sharedWorkspace] openURL: [NSURL URLWithString:@"https://twitter.com/thetomcraig"]];
    NSNotification *iTunesButtonNotification = [NSNotification
                                                notificationWithName:@"preferencesWindowButtonClicked"
                                                object:nil];
    [[NSDistributedNotificationCenter defaultCenter] postNotification:iTunesButtonNotification];
}


@end
