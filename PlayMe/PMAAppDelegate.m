#import "PMAAppDelegate.h"

@implementation PMAAppDelegate

@synthesize iTunesController = _iTunesController;
@synthesize menubarController = _menubarController;
@synthesize artworkWindowController = _artworkWindowController;

//##############################################################################
//Setting up the default settings for the app.  Because awakeFromNib is called
//before applicationDidFinish, it needs only user interface stuff
//##############################################################################
- (void)awakeFromNib
{
    NSDictionary *appDefaults = [NSDictionary dictionaryWithObjectsAndKeys:
                                 @"YES", @"showSongName",
                                 @"NO", @"quitWheniTunesQuits",
                                 nil];
    [[NSUserDefaults standardUserDefaults] registerDefaults:appDefaults];

}

//##############################################################################
//Sets up the method for when the icon is clicked
//Sets up the method or when iTunes sends a status change notification
//Sets up methods for when iTunes quit or launches
//##############################################################################
- (void)applicationDidFinishLaunching:(NSNotification *)notification
{
    //-------------------------------------------------------------------------
    //Initialize stuff
    //-------------------------------------------------------------------------
    _iTunesController = [[ITunesController alloc] init];
    _menubarController = [[MenubarController alloc] init];
    _artworkWindowController = [[ArtworkWindowController alloc] init];
    
    ///r
    /**
    [_iTunesController createiTunesObjectIfNeeded];
    
    [self update:NO];
    [_artworkWindowController updateUIElements];
    */
    ///r
    /**
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
     */
    
}

#
#pragma mark - Updating Methods
#
//##############################################################################
//For updating the artworkWindowController and menubarController with new
//info form iTunes
//##############################################################################
- (void)update:(BOOL)windowIsOpen
{
    //Update the iTunes Controller
    [_artworkWindowController update:windowIsOpen];
    
    ///r
    if ([_iTunesController iTunesRunning])
    {
        [_iTunesController update];
    }

    
    //If the UserDefaults option for showing
    //the name in the menubar IS ENABLED, then we show
    //the name.  Otherwise there shuold be no title
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"showSongName"])
    {
        [_menubarController updateSatusItemView:_iTunesController.currentSong
                                   iTunesStatus:_iTunesController.currentStatus];
    }
}








///r move
//##############################################################################
//Called when the icon is clicked.
//If the window is opened, it gets closed, and vice versa.
//##############################################################################
/**
- (IBAction)toggleMainWindow:(id)sender
{
    _menubarController.hasActiveIcon = !_menubarController.hasActiveIcon;
    [_artworkWindowController toggleWindow];
}


- (IBAction)toggleMenu:(id)sender
{
    _menubarController.hasActiveIcon = !_menubarController.hasActiveIcon;
    NSLog(@"Stub menu needs to toggle");
}
*/









//##############################################################################
//These three functions seperated from the above for clarity.
//They are only called by the receive method.
//This one gets the information from iTunes and updates it accordingly
//If the small window is open, it replaces this with the large window
//At the end it makes sure all the UI elements are arranged properly
//##############################################################################
///r move
/**
- (void)playingUpdate
{
    ///r
    [_iTunesController createiTunesObjectIfNeeded];
    
    if ([[_artworkWindowController window] isVisible])
    {
        [self update:YES];
    }
    else
    {
        [self update:NO];
        
        //Post notification after clearing any existing ones
        [[NSUserNotificationCenter defaultUserNotificationCenter] removeAllDeliveredNotifications];
        [_ncController sendNotification:_iTunesController.currentSong
                                      :_iTunesController.currentArtist
                                      :_iTunesController.currentAlbum
                                      :_iTunesController.currentArtwork];
    }

    [_artworkWindowController updateUIElements];

    [_artworkWindowController startTimer];
    [_artworkWindowController.openIniTunes setTitle:@"Go to song in iTunes"];
}
*/
//##############################################################################
//This function sets paused information, mkaing sure to only update the
//menubar icon if the window is closed
//If the small window is open, it replaces this with the large window
//At the end it makes sure all the UI elements are arranged properly
//##############################################################################
///r move
/**
- (void)pausedUpdate
{
    _iTunesController.currentStatus = @"Paused";


    [_artworkWindowController updateUIElements];
    
    ///r
    ///make sure this is opdating properly, dont poll itunes, just update the icon
    [_menubarController updateSatusItemView:nil iTunesStatus:_iTunesController.currentStatus];
}
 */

//##############################################################################
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
//##############################################################################
///r move
/**
- (void)stoppedUpdate
{
    if ([_iTunesController.currentStatus isEqualToString:@"Stopped"])
    {
        return;
    }
 
    //if (![artworkWindowController iTunesIsRunning])
    //{
        [artworkWindowController.iTunesController updateWithNill];
        //self.statusItem.title = @"";
    //}
 
    if ([[_artworkWindowController window] isVisible])
    {
        [self update:YES];
    }
    else
    {
        [self update:NO];
    }
   
    [_artworkWindowController updateUIElements];
    [_artworkWindowController.artworkWindow.artworkView setNeedsDisplay:NO];
    [_artworkWindowController.openIniTunes setTitle:@"Go to iTunes"];
}
*/

#
#pragma mark - iTunes utilities
#
//##############################################################################
//Receives system notifications from the nsnotifcaion center.
//Called when iTunes' status changes.  It is actually called whenever there
//is a notification sent, but I filter out the non-iTunes ones.  When the
//iTunes button it clicked, it sends a notification picked up here as well,
//to make sure the menubar is updated.
//we filter notifications that tell if iTunes has played, paused, or stopped
//##############################################################################
///r move
/**
- (void)iTunesStatusChange:(NSNotification *)note
{
    //-------------------------------------------------------------------------
    //FILTERING....
    //-------------------------------------------------------------------------
    //This came from the window controller, because the reveal in iTunes button
    //was pressed.  We can update the menubar icon and be done after that
    if ([note.name rangeOfString:@"iTunesButtonClicked"].location != NSNotFound)
    {
        [self update:NO];
        return;
    }
    
    //This also came from the window controller, because the close button was
    //pressed.  Same shit as above
    else if ([note.name rangeOfString:@"closeButtonClicked"].location != NSNotFound)
    {
        [self update:NO];
        return;
    }
    
    //This also came from the window controller, because the close button was
    //pressed.  Same shit as above
    else if ([note.name rangeOfString:@"ESCKeyHit"].location != NSNotFound)
    {
        [self update:NO];
        return;
    }
    
    //This comes from the preferences window, because the website button has
    //been clicked, and the windows need to be closed, and everything else
    //needs to be update appropriately
    else if ([note.name rangeOfString:@"preferencesWindowButtonClicked"].location != NSNotFound)
    {
        [_artworkWindowController closeWindowWithButton:nil];
        [self update:NO];
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
*/
//##############################################################################
//This method is called when iTunes launches, and it tells the iTunesController
//to create an iTunes object if it has not already.
//Really, this is tripped whenever any application is launched, and I do a
//double check to make sure it was iTunes,  This is mimicked in the quitting
//function as well
//##############################################################################
///r move
/**
- (void)iTunesLaunched:(NSNotification *)note
{
    if ([artworkWindowController iTunesIsRunning])
    {
        [artworkWindowController.iTunesController createiTunesObjectIfNeeded];
    }
}
*/

//##############################################################################
//This is called when iTune quits, and it destorys the iTunes object, and it
//calls the stopped update to zero out tags and other info.  Not that when ANY
//progarm quits, this method pick it up and we filter to just get the iTunes
//notifications.  There is a check with an if statement to quit the entire app
//if that optin was checked in the preferences.
//##############################################################################
///r move
/**
- (void)iTunesQuit:(NSNotification *)note
{
    if ([[note.userInfo objectForKey:@"NSApplicationName"] isEqualToString:@"iTunes"])
    {        
       [_iTunesController destroyiTunes];
       [self stoppedUpdate];
    
        //If the UserDefaults option for quitting playme when
        //itunes quits IS ENABLED, quit.  Otherwise do not
        if([[NSUserDefaults standardUserDefaults] boolForKey:@"quitWheniTunesQuits"])
        {
            [_artworkWindowController quitPlayMe:nil];
        }
    }
}
*/

@end