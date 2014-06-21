#define SMALL_WIDTH 130
#define SMALL_HEIGHT 70
#define LARGE_WIDTH 400
#define LARGE_HEIGHT 800
#define MENU_BAR_HEIGHT 22
#define NSFloatingWindowLevel kCGFloatingWindowLevel
#import "PMAAppDelegate.h"

@implementation PMAAppDelegate

///@synthesize statusItem;

@synthesize ncController;
@synthesize artworkWindowController;

#
#pragma mark - Struct for positioning the window properly
#
struct DangerZone
{
    double lowerBound;
    double upperBound;
};

#
#pragma mark - Initalizing Methods
#
//############################################################################
//Set up statusbar stuff.  Because awakeFromNib is called before
//applicationDidFinish, it needs only user interface stuff
//############################################################################
-(void)awakeFromNib
{
    NSDictionary *appDefaults = [NSDictionary dictionaryWithObjectsAndKeys:
                                 @"YES", @"showSongName",
                                 @"NO", @"quitWheniTunesQuits",
                                 nil];
    [[NSUserDefaults standardUserDefaults] registerDefaults:appDefaults];

    /**
    statusItem = [[NSStatusBar systemStatusBar] statusItemWithLength:NSVariableStatusItemLength];
    
    [statusItem setAction:@selector(clicked:)];
    [statusItem setHighlightMode: YES];
    [statusItem setTarget:self];
     */
}

//############################################################################
//Sets up the method for when the icon is clicked
//Sets up the method or when iTunes sends a status change notification
//Sets up methods for when iTunes quit or launches
//############################################################################
-(void)applicationDidFinishLaunching:(NSNotification *)notification
{
    //-------------------------------------------------------------------------
    //Initialize stuff
    //-------------------------------------------------------------------------
    ncController = [[NCController alloc] init];
    artworkWindowController = [[ArtworkWindowController alloc] init];
    [artworkWindowController closeWindow];
    
    [artworkWindowController.iTunesController createiTunesObjectIfNeeded];
    
    [self update:NO];
    ///[self updateIcon:NO];
    [self updateUIElements];
    [self updateWindowPosition];

    //-------------------------------------------------------------------------
    //Set up observers and methods
    //-------------------------------------------------------------------------
    
    ///[self.statusBar setAction:@selector(clicked:)];
    ///[statusBar setTarget:self];
    
    ///
    self.menubarController = [[MenubarController alloc] init];
    ///
   
    //For when iTunes plays/pauses/stops
    [[NSDistributedNotificationCenter defaultCenter] addObserver:self
                                                        selector:@selector(iTunesStatusChange:)
                                                            name:nil object:nil];
    //For receiving iTunes launch/quit information
    //Because I am monitoring the status of iTunes,
    //I need to use the shared notification center
    NSNotificationCenter *sharedNC = [[NSWorkspace sharedWorkspace] notificationCenter];
    //Observer for whe iTunes launches
    [sharedNC addObserver:self selector:@selector(iTunesLaunched:)
                     name:NSWorkspaceDidLaunchApplicationNotification
                   object:nil];
    //Observer for whe iTunes quits
    [sharedNC addObserver:self
                 selector:@selector(iTunesQuit:)
                     name:NSWorkspaceDidTerminateApplicationNotification
                   object:nil];
    
}

#
#pragma mark - Updating Methods
#
//############################################################################
//This method updates the window controller and menu bar icon
//############################################################################
-(void)update:(BOOL)windowIsOpen
{
    //Update the iTunes Controller
    [artworkWindowController update:windowIsOpen];
    
    //-------------------------------------------------------------------------
    //Update the text in the menubar.  It should be nothing if the window is
    //closed, but if the window is open, it should be the song title
    //-------------------------------------------------------------------------
    NSString *titleForBar = @"";
    if (!windowIsOpen)
    {
        titleForBar= [artworkWindowController
                                 trimString:artworkWindowController.iTunesController.currentSong
                                 :250.0 //This number is the amount of menubar space we dedicate the the title
                                 :[NSFont menuBarFontOfSize:0]
                                 :@""];
    }
    
    //If the UserDefaults option for showing
    //the name in the menubar IS ENABLED, then we show
    //the name.  Otherwise there shuold be no title
    if([[NSUserDefaults standardUserDefaults] boolForKey:@"showSongName"])
    {
        ///self.statusItem.title = titleForBar;
    }
}

//############################################################################
//Update the menu bar icon.  If the window is open we can use the opened icon
//Otherswise, update according to the state of iTunes.
//We need windowIsOpen to determine what kind of things we need to update
//############################################################################
/**
-(void)updateIcon:(BOOL)windowIsOpen
{
    if (windowIsOpen)
    {
        self.statusItem.image = [NSImage imageNamed:@"Open"];
        self.statusItem.alternateImage = [NSImage imageNamed:@"OpenWhite"];
    }
    else
    {
        if ([artworkWindowController.iTunesController.currentStatus isEqualToString:@"Stopped"])
        {
            self.statusItem.image = [NSImage imageNamed:@"Stopped"];
            self.statusItem.alternateImage = [NSImage imageNamed:@"StoppedWhite"];
        }
        else if ([artworkWindowController.iTunesController.currentStatus isEqualToString:@"Paused"])
        {
            self.statusItem.image = [NSImage imageNamed:@"Paused"];
            self.statusItem.alternateImage = [NSImage imageNamed:@"PausedWhite"];
        }
        else if ([artworkWindowController.iTunesController.currentStatus isEqualToString:@"Playing"])
        {
            self.statusItem.image = [NSImage imageNamed:@"Playing"];
            self.statusItem.alternateImage = [NSImage imageNamed:@"PlayingWhite"];
        }
    }
}
 */

//############################################################################
//Sets the window to the appropriate frame.  Small size for iTunes stopped,
//large size otherwise.
//
//It only takes the width and height information, because it does not always
//correspond to a window reposition.
//
//There is some extra logic about when the window is open, because setting the
//frame when the window is open can result in flicker
//############################################################################
-(void)updateUIElements
{
    //This tells us if we should redisplay the window or not
    //It essentualy cleans up the window, because there were residuce images from
    //when iTunes stats changes
    BOOL shouldReDisplay = false;
    
    //Create a frame to be the new one
    NSRect tempFrame = [artworkWindowController window].frame;
    
    //-------------------------------------------------------------------------
    //Set dimensions and then set the frame.  Bear in mind, it will only
    //set the frame if is a different size from the current frame
    //-------------------------------------------------------------------------
    //Is iTunes is stopped?
    if ([artworkWindowController.iTunesController.currentStatus isEqualToString:@"Stopped"])
    {
        //Does it have the small frame?
        if ([artworkWindowController window].frame.size.height != SMALL_HEIGHT)
        {
            //If not, set the small frame
            tempFrame.size.width = SMALL_WIDTH;
            tempFrame.size.height = SMALL_HEIGHT;
            
            if ([[artworkWindowController window] isVisible])
            {
                shouldReDisplay = true;
            }
        }
    }
    //Else it should have the large frame
    else
    {
        //Does it have the large frame?
        if ([artworkWindowController window].frame.size.height != LARGE_HEIGHT)
        {
            //If not, set the large frame
            tempFrame.size.width = LARGE_WIDTH;
            tempFrame.size.height = LARGE_HEIGHT;
            
            if ([[artworkWindowController window] isVisible])
            {
                shouldReDisplay = true;
            }
        }
    }
    
    //-------------------------------------------------------------------------
    //Set the frame
    //-------------------------------------------------------------------------
    [[artworkWindowController window] setFrame:tempFrame display:shouldReDisplay];
    
    //-------------------------------------------------------------------------
    //Updating every other element
    //-------------------------------------------------------------------------
    [self updateWindowPosition];
    [artworkWindowController updateCurrentArtworkFrame];
    [artworkWindowController updateArtwork];
    
    if (![artworkWindowController iTunesIsRunning] ||
        ([[artworkWindowController iTunesController].currentStatus isEqualToString:@"Stopped"]))
    {
        [artworkWindowController updateWindowElementsWithiTunesStopped];
    }
    else
    {
        [artworkWindowController updateWindowElements];
    }
    [artworkWindowController updateControlButtons];
    
    
    //-------------------------------------------------------------------------
    //Last thing - need to know when the window changes size if we want to have
    //the buttons be visible.  We consrtuct a rect for the actual screen
    //location of the currentArtwork image and check this against the mouse
    //location
    //-------------------------------------------------------------------------
    NSPoint mouseLoc = [NSEvent mouseLocation];
    
    NSRect currentArtworkFrame = [artworkWindowController artworkWindow].frame;
    currentArtworkFrame.size.height = [artworkWindowController trackingArea].rect.size.height;
    currentArtworkFrame.origin.y += [artworkWindowController artworkWindow].frame.size.height;
    currentArtworkFrame.origin.y -= MENU_BAR_HEIGHT;
    
    NSImage *bgTopArrow = [NSImage imageNamed:@"bgTopArrow"];
    currentArtworkFrame.origin.y -= bgTopArrow.size.height;
    currentArtworkFrame.origin.y -= [artworkWindowController trackingArea].rect.size.width;
    
    //If the mouse is inside the window bounds
    if ((currentArtworkFrame.origin.x < mouseLoc.x) &&
        (mouseLoc.x < currentArtworkFrame.origin.x + currentArtworkFrame.size.width) &&
        (currentArtworkFrame.origin.y < mouseLoc.y) &&
        (mouseLoc.y < currentArtworkFrame.origin.y + currentArtworkFrame.size.height))
    {
        if ([[artworkWindowController window] isVisible])
        {
            [artworkWindowController mouseEntered:nil];
        }
    }
    
    else
    {
        [artworkWindowController mouseExited:nil];
    }
    
    //-------------------------------------------------------------------------
    //If the window was open when we had to change its size, we close it
    //then open it again by simulating a click.  This worked better than trying
    //to update certain elements in a certain element.  This flushes everyting
    //out nicely
    //-------------------------------------------------------------------------
    if (shouldReDisplay)
    {
        [artworkWindowController closeWindow];
        ///[self clicked:nil];
    }
}

//############################################################################
//Fids the actual location on screen for the window to be.
//############################################################################
-(void)updateWindowPosition
{
    //-------------------------------------------------------------------------
    //Find the location for the window
    //-------------------------------------------------------------------------
    //The frame of the menu bar icon, and location for the arrow
    ///NSRect statusItemWindowframe = [[self.statusItem valueForKey:@"window"] frame];
    ///
    NSRect statusItemWindowframe = NSMakeRect(0.0, 0.0, 10.0, 10.0);
    ///
    //Finding the origin
    CGPoint origin = statusItemWindowframe.origin;
    //The size of the window we want to open
    CGSize statusItemWindowSize = [artworkWindowController window].frame.size;
    //Calculations...
    double halfOfIcon = statusItemWindowframe.size.width/2.f;
    double halfOfWindow = statusItemWindowSize.width/2.f;
    //Getting the position for the window
    CGPoint windowTopLeftPosition = CGPointMake(origin.x + halfOfIcon - halfOfWindow, origin.y);
    
    //-------------------------------------------------------------------------
    //Checking to make sure it is not hanging off the screen
    //This block sets up an array of "danger zones" which are bounds of x
    //positions.  If the left position of the window is between the higher and
    //lower numbers of any of the danger zones in the array, we know that window
    //will be hanging off the edge of one of the screens.  This means we have
    //to reposition the window so it is just on the right edge of the screen
    //-------------------------------------------------------------------------
    //Creating the danger zones
    NSArray *screens = [NSScreen screens];
    struct DangerZone dangerZones[[screens count]];
    for (int i = 0; i < [screens count]; i++)
    {
        struct DangerZone dangerZone;
        double rightEdge = [screens[i] frame].origin.x + [screens[i] frame].size.width;
        dangerZone.lowerBound = rightEdge - [artworkWindowController window].frame.size.width;
        dangerZone.upperBound = rightEdge - [artworkWindowController window].frame.size.width/2;
        dangerZones[i] = dangerZone;
    }
    
    //-------------------------------------------------------------------------
    //Now, checking the topLeftPosition against all the danger zones.  This
    //could probably be put in with the above code but it is seperated for
    //clarity and because I may want to recalculate the window positions
    //differently at a later time
    //-------------------------------------------------------------------------
    NSImage *bgTopArrow = [NSImage imageNamed:@"bgTopArrow"];
    //This has to start as zero, (arrow in the middle = 0)
    double arrowLocation = 0;
    
    for (int i = 0; i < [screens count]; i++)
    {
        //If this gets hit, the point is in the danger zone!
        if ((dangerZones[i].lowerBound < windowTopLeftPosition.x) &&
            (windowTopLeftPosition.x < dangerZones[i].upperBound))
        {
            double rightBuffer = bgTopArrow.size.height;
            //Here, we reset the arrow location
            double postionOfRightSideOfWindow = windowTopLeftPosition.x + [artworkWindowController window].frame.size.width;
            double xPositionOfRightSideOfScreen = [screens[i] frame].origin.x + [screens[i] frame].size.width;
            arrowLocation = (postionOfRightSideOfWindow - xPositionOfRightSideOfScreen) + rightBuffer;
            
            //Here, we reset the window location
            windowTopLeftPosition.x = dangerZones[i].lowerBound - rightBuffer;
        }
    }
    
    //-------------------------------------------------------------------------
    //Finally, Setting the window position and arrow location
    //-------------------------------------------------------------------------
    [[artworkWindowController window] setFrameTopLeftPoint:windowTopLeftPosition];
    artworkWindowController.artworkWindow.artworkView.topArrowLocation = arrowLocation;
}

//############################################################################
//Called when the icon is clicked.
//If the window is opened, it gets closed, and vice versa.
//We make sure to update either way, so the icon and menu bar title are correct
//############################################################################
/**
-(void)clicked:(id)sender
{
    
    NSEvent *event = [NSApp currentEvent];
    
    NSLog(@"%lu", (unsigned long)[event modifierFlags]);
    
    if([event modifierFlags] & NSControlKeyMask)
    {
        NSLog(@"Right click");
        //[self openRightWindow:nil];
    } else
    {
        NSLog(@"Left click");
        //[self openLeftWindow:nil];
    }
    
    //-------------------------------------------------------------------------
    //Toggle: if the window is open, close it.  Otherwise open it.
    //-------------------------------------------------------------------------
    if ([[artworkWindowController window] isVisible])
    {
        [artworkWindowController closeWindow];
        [self update:NO];
        [self updateIcon:NO];
    }
    
    else
    {
        //Find out the window size and location
        [self update:YES];
        [self updateIcon:YES];
        [self updateUIElements];
        [artworkWindowController updateCurrentArtworkFrame];
        
        //Clear notifications from the screen,
        [[NSUserNotificationCenter defaultUserNotificationCenter] removeAllDeliveredNotifications];
        
        [artworkWindowController.artworkWindow.artworkView setNeedsDisplay:YES];
        //Open the window
        [[artworkWindowController window] makeKeyAndOrderFront:self];
        [[artworkWindowController window] setLevel:kCGFloatingWindowLevel];
        [NSApp activateIgnoringOtherApps:YES];
    }
    
}

- (void)openWindow:(id)sender
{
    
        NSLog(@"Left click");
       

}
     */
-(void)newClickedMethodForWindow:(id)sender
{
    NSLog(@"Entered the new method for toggling the main window!");
}

//############################################################################
//These three functions seperated from the above for clarity.
//They are only called by the receive method.
//This one gets the information from iTunes and updates it accordingly
//If the small window is open, it replaces this with the large window
//At the end it makes sure all the UI elements are arranged properly
//############################################################################
-(void)playingUpdate
{

    [artworkWindowController.iTunesController createiTunesObjectIfNeeded];
    
    if ([[artworkWindowController window] isVisible])
    {
        [self update:YES];
        ///[self updateIcon:YES];
    }
    else
    {
        [self update:NO];
        ///[self updateIcon:NO];
        
        //Post notification after clearing any existing ones
        [[NSUserNotificationCenter defaultUserNotificationCenter] removeAllDeliveredNotifications];
        [ncController sendNotification:artworkWindowController.iTunesController.currentSong
                                      :artworkWindowController.iTunesController.currentArtist
                                      :artworkWindowController.iTunesController.currentAlbum
                                      :artworkWindowController.iTunesController.currentArtwork];
    }

    [self updateUIElements];
}

//############################################################################
//This function sets paused information, mkaing sure to only update the
//menubar icon if the window is closed
//If the small window is open, it replaces this with the large window
//At the end it makes sure all the UI elements are arranged properly
//############################################################################
-(void)pausedUpdate
{
    artworkWindowController.iTunesController.currentStatus = @"Paused";
    
    if ([[artworkWindowController window] isVisible])
    {
        ///[self updateIcon:YES];
    }
    else ///[self updateIcon:NO];

    [self updateUIElements];
}

//############################################################################
//Essentially the same as the paused one
//If the large window is open, it replaces this with the small window.
//Putting the frame and window position updates at the end make sure
//everything is nice and clean looking
//At the end it makes sure all the UI elements are arranged properly
//
//This case is also hit when skipping to the next song while iTunes is
//paused.  Because of this, it may actually have to do the paused update,
//so I check for that.  In this case, we may actually need to update some
//info, so we check if iTunes is running, then do that
//
//Recently put in the very first if statement, which says that if the player
//state was stopped, then update to stopped again, then itunes must be
//quitting.  If it went from playing or paused to stopped we can assume it
//actually did just stop playback.  But if it goe sfrom stopped to stopped,
//its a false positive - iTunes sends out a stopped updated when it quits...
//############################################################################
-(void)stoppedUpdate
{
    if ([artworkWindowController.iTunesController.currentStatus isEqualToString:@"Stopped"])
    {
        return;
    }
    
    if (![artworkWindowController iTunesIsRunning])
    {
        [artworkWindowController.iTunesController updateWithNill];
        ///self.statusItem.title = @"";
    }
    
    if ([[artworkWindowController window] isVisible])
    {
        [self update:YES];
        ///[self updateIcon:YES];
    }
    else
    {
        [self update:NO];
        ///[self updateIcon:NO];
    }
   
    [self updateUIElements];
    
    [artworkWindowController.artworkWindow.artworkView setNeedsDisplay:NO];
}

#
#pragma mark - iTunes utilities
#
//############################################################################
//Receives system notifications from the nsnotifcaion center.
//Called when iTunes' status changes.  It is actually called whenever there
//is a notification sent, but I filter out the non-iTunes ones.  When the
//iTunes button it clicked, it sends a notification picked up here as well,
//to make sure the menubar is updated.
//we filter notifications that tell if iTunes has played, paused, or stopped
//############################################################################
-(void)iTunesStatusChange:(NSNotification *)note
{
    //-------------------------------------------------------------------------
    //FILTERING....
    //-------------------------------------------------------------------------
    //This came from the window controller, because the reveal in iTunes button
    //was pressed.  We can update the menubar icon and be done after that
    if ([note.name rangeOfString:@"iTunesButtonClicked"].location != NSNotFound)
    {
        [self update:NO];
        ///[self updateIcon:NO];
        return;
    }
    
    //This also came from the window controller, because the close button was
    //pressed.  Same shit as above
    else if ([note.name rangeOfString:@"closeButtonClicked"].location != NSNotFound)
    {
        [self update:NO];
        ///[self updateIcon:NO];
        return;
    }
    
    //This also came from the window controller, because the close button was
    //pressed.  Same shit as above
    else if ([note.name rangeOfString:@"ESCKeyHit"].location != NSNotFound)
    {
        [self update:NO];
        ///[self updateIcon:NO];
        return;
    }
    
    //This comes from the preferences window, because the website button has
    //been clicked, and the windows need to be closed, and everything else
    //needs to be update appropriately
    else if ([note.name rangeOfString:@"preferencesWindowButtonClicked"].location != NSNotFound)
    {
        [artworkWindowController closeWindowWithButton:nil];
        [self update:NO];
        ///[self updateIcon:NO];
        return;
    }
    
    //This makes sure we only worry about the notification from iTunes
    if ([note.name rangeOfString:@"iTunes"].location == NSNotFound) return;
    //If the notification looks like this, iTunes has just
    //been opened, and we do not need to update anything
    if ([note.name isEqualToString:@"com.apple.iTunes.sourceInfo"]) return;
    
    //-------------------------------------------------------------------------
    //UPDATING
    //-------------------------------------------------------------------------
    NSString *incomingPlayerState = [note.userInfo objectForKey:@"Player State"];
    
    //-------------------------------------------------------------------------
    //PLAYING UPDATE
    //If it is playing, a new track has begun, or a track has been unpaused
    //We can do all the updating, and send a notification
    //-------------------------------------------------------------------------
    if ([incomingPlayerState isEqualToString:@"Playing"])
    {
        [self playingUpdate];
    }
    //-------------------------------------------------------------------------
    //STOPPED UPDATE
    //Here, the current track stopped and there are no following songs, or
    //there is just not anything playing.
    //-------------------------------------------------------------------------
    else if ([incomingPlayerState isEqualToString:@"Stopped"])
    {
        [self stoppedUpdate];
    }
    //-------------------------------------------------------------------------
    //PAUSED UPDATE
    //Because we have no new song starting all we need to
    //update it the artwork, and put the paused mask on it
    //-------------------------------------------------------------------------
    else if ([incomingPlayerState isEqualToString:@"Paused"])
    {
        [self pausedUpdate];
    }
}

//############################################################################
//This method is called when iTunes launches, and it tells the iTunesController
//to create an iTunes object if it has not already.
//Really, this is tripped whenever any application is launched, and I do a
//double check to make sure it was iTunes,  This is mimicked in the quitting
//function as well
//############################################################################
-(void)iTunesLaunched:(NSNotification *)note
{
    if ([artworkWindowController iTunesIsRunning])
    {
        [artworkWindowController.iTunesController createiTunesObjectIfNeeded];
    }
}

//############################################################################
//This is called when iTune quits, and it destorys the iTunes object, and it
//calls the stopped update to zero out tags and other info.  Not that when ANY
//progarm quits, this method pick it up and we filter to just get the iTunes
//notifications.  There is a check with an if statement to quit the entire app
//if that optin was checked in the preferences.
//############################################################################
-(void)iTunesQuit:(NSNotification *)note
{
    if ([[note.userInfo objectForKey:@"NSApplicationName"] isEqualToString:@"iTunes"])
    {        
       [artworkWindowController.iTunesController destroyiTunes];
       [self stoppedUpdate];
    
        //If the UserDefaults option for quitting playme when
        //itunes quits IS ENABLED, quit.  Otherwise do not
        if([[NSUserDefaults standardUserDefaults] boolForKey:@"quitWheniTunesQuits"])
        {
            [artworkWindowController quitPlayMe:nil];
        }
    }
}

@end