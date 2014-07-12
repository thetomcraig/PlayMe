#import "ArtworkWindowController.h"

@implementation ArtworkWindowController

@synthesize menuButtonMenu;
@synthesize preferences;
@synthesize openIniTunes;
@synthesize quitApp;

@synthesize currentArtwork;
@synthesize currentSong;
@synthesize currentArtistAndAlbum;
@synthesize currentLyrics;

@synthesize songSlider;
@synthesize songSliderCell;
@synthesize songTimeLeft;

@synthesize buttonsBackdrop;
@synthesize playPauseButton;
@synthesize playPauseButtonCell;
@synthesize nextButton;
@synthesize nextButtonCell;
@synthesize previousButton;
@synthesize previousButtonCell;
@synthesize trackingArea;

//##############################################################################
//The init method makes sure we observer notificatinos from the iTunesContrller
//and from the menuBarController
//##############################################################################
- (id)initWithWindowNibName:(NSString *)windowNibName
{
    self = [super initWithWindowNibName:windowNibName];
    if (self)
    {
        [[NSNotificationCenter defaultCenter]
                             addObserver:self
                             selector:@selector(receivedTagsNotification:)
                             name:@"TagsNotification"
                             object:nil];
        [[NSNotificationCenter defaultCenter]
                             addObserver:self
                             selector:@selector(receivedMouseDownNotification:)
                             name:@"MouseDownNotification"
                             object:nil];
    }
    return self;
}

//##############################################################################
//We call the mouseExited function to make sure the buttons are hidden when
//the window opens.
//We call updateWindowElements to position everything else.
//##############################################################################
-(void)windowDidLoad
{
    ///r frame alignment?
    [super windowDidLoad];
    
    //Setting up the menuItems
    preferences = [[NSMenuItem alloc] initWithTitle:@"Preferences..."
                                             action:@selector(showPreferences:)
                                      keyEquivalent:@""];
    openIniTunes = [[NSMenuItem alloc] initWithTitle:@"Go to song in iTunes"
                                              action:@selector(openIniTunes:)
                                       keyEquivalent:@""];
    quitApp = [[NSMenuItem alloc] initWithTitle:@"Quit PlayMe"
                                         action:@selector(quitPlayMe:)
                                  keyEquivalent:@""];
    
    [playPauseButton setBordered:NO];
    [nextButton setBordered:NO];
    [previousButton setBordered:NO];

    [self mouseExited:nil];
    
    [nextButton setImage:[NSImage imageNamed:@"NextButton"]];
    [nextButton setAlternateImage:[NSImage imageNamed:@"NextButtonDepressed"]];
    [previousButton setImage:[NSImage imageNamed:@"PreviousButton"]];
    [previousButton setAlternateImage:[NSImage imageNamed:@"PreviousButtonDepressed"]];
    
    NSColor *backgroundColor =
    [NSColor colorWithCalibratedRed:0.9 green:0.9 blue:0.9 alpha:1.0];
    NSColor *primaryColor =
    [NSColor colorWithCalibratedRed:0.30 green:0.30 blue:0.30 alpha:1.0];
    
    currentSong.textColor = primaryColor;
    currentArtistAndAlbum.textColor = primaryColor;
    /*
    buttonsBackdrop.mainColor = backgroundColor;
    */
    [nextButtonCell setButtonsColor: primaryColor];
    [playPauseButtonCell setButtonsColor: primaryColor];
    [previousButtonCell setButtonsColor: primaryColor];
    ///MAKE THESE COLORS STRONG!
    /*
    songSlider.backgroundColor = backgroundColor;
    songSliderCell.backgroundColor = backgroundColor;
    songSliderCell.progressColor = primaryColor;
    songTimeLeft.textColor = primaryColor;
     */
     
}

#
#pragma mark - Receiving notifications
#
//##############################################################################
//Message to update sent from the iTunesController, with a notification that has
//tag information.
//##############################################################################
- (void)receivedTagsNotification:(NSNotification *)note
{
    //--------------------------------------------------------------------------
    //Updating the labels with the song name, artist and album name.
    //It calls the trimString method to make sure they're clipped properly
    //--------------------------------------------------------------------------
    [currentSong setStringValue:[note.userInfo objectForKey:@"CurrentSong"]];
    
    if ([[note.userInfo objectForKey:@"CurrentArtist"] isEqualToString:@""])
    {
        [currentArtistAndAlbum setStringValue:@""];
    } else
    {
        NSString *combinedString =
        [NSString stringWithFormat:@"%@ - %@",
         [note.userInfo objectForKey:@"CurrentArtist"],
         [note.userInfo objectForKey:@"CurrentAlbum"]];
        
        [currentArtistAndAlbum setStringValue: combinedString];
    }
    
    //--------------------------------------------------------------------------
    //Updating the control buttons
    //--------------------------------------------------------------------------
    NSString *nameOfButton = @"PlayButton";
    
    if ([[note.userInfo objectForKey:@"CurrentStatus"]
         isEqualToString:@"Paused"] ||
        [[note.userInfo objectForKey:@"CurrentStatus"]
         isEqualToString:@"Stopped"])
    {
        nameOfButton = @"PlayButton";
    }
    else if ([[note.userInfo objectForKey:@"CurrentStatus"]
              isEqualToString:@"Playing"])
    {
        nameOfButton = @"PausedButton";
    }
    
    NSString *nameOfAltButton = [NSString stringWithFormat:@"%@%@",
                                 nameOfButton,
                                 @"ButtonDepressed"];
    //Actually assigning the button resource image
    [playPauseButton setImage:[NSImage imageNamed:nameOfButton]];
    [playPauseButton setAlternateImage:[NSImage imageNamed:nameOfAltButton]];
    
    //--------------------------------------------------------------------------
    //Updating the artwork.
    //If there was NO artwork, we put in the black artwork image
    //--------------------------------------------------------------------------
    [currentArtwork setImage:[note.userInfo objectForKey:@"CurrentArtwork"]];
    
    //--------------------------------------------------------------------------
    //Timing - sliders
    //--------------------------------------------------------------------------
    //Sliders - have to use NSNumbers forth notification, so we make them into
    //doubles here
    [songSlider setDoubleValue:
     [[note.userInfo objectForKey:@"CurrentProgress"] doubleValue]];
    [songSlider setMaxValue:
     [[note.userInfo objectForKey:@"CurrentLength"] doubleValue]];
    
    //--------------------------------------------------------------------------
    //Timing - countdown label
    //--------------------------------------------------------------------------
    double totalSecsLeft =
    ([[note.userInfo objectForKey:@"CurrentLength"] doubleValue] -
     [[note.userInfo objectForKey:@"CurrentProgress"] doubleValue]);
    int numMinsLeft = (floor(totalSecsLeft/60));
    int numSecsLeft = (totalSecsLeft - numMinsLeft*60);
    
    //It needlessly showes 60's so we can just replace it
    if (numSecsLeft == 60)
    {
        numMinsLeft = 0;
        numSecsLeft = 0;
    }
    
    NSString *timeLeft = [NSString stringWithFormat:@"-%i:%02d",
                          numMinsLeft,
                          numSecsLeft];
    
    [songTimeLeft setStringValue:timeLeft];
}

//##############################################################################
//Opening and closing the window with the menubar icon is clicked.
//##############################################################################
- (void)receivedMouseDownNotification:(NSNotification *)note
{
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

        [[self window] display];
        
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
