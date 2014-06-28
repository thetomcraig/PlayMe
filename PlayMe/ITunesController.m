#import "ITunesController.h"

@implementation ITunesController

@synthesize iTunes = _iTunes;
@synthesize imageController = _imageController;
@synthesize ncController = _ncController;
@synthesize currentStatus = _currentStatus;
@synthesize currentSong = _currentSong;
@synthesize currentArtist = _currentArtist;
@synthesize currentAlbum = _currentAlbum;
@synthesize currentLyrics = _currentLyrics;
@synthesize currentArtwork = _currentArtwork;
@synthesize currentProgress = _currentProgress;
@synthesize currentLength = _currentLength;
@synthesize iTunesRunning = _iTunesRunning;

//##############################################################################
//We we initliaze, we create our iTunes object if it' needed
//(if iTunes.app is open).  Then we set up observers for when
//##############################################################################
- (id)init
{
    [self createiTunesObjectIfNeeded];
    
    //For when iTunes plays/pauses/stops
    [[NSDistributedNotificationCenter defaultCenter]
                            addObserver:self
                               selector:@selector(iTunesStatusChange:)
                                   name:@"com.apple.iTunes.sourceInfo"
                                 object:nil];
    
    //For when the user hits a button in the app's window
    [[NSDistributedNotificationCenter defaultCenter]
                            addObserver:self
                               selector:@selector(iTunesCommand:)
                                   name:@"commandFromArtworkWindowController"
                                 object:nil];
    
    //For receiving iTunes launch/quit information
    //Because I am monitoring the status of iTunes,
    //I need to use the shared notification center
    NSNotificationCenter *sharedNC =
                            [[NSWorkspace sharedWorkspace] notificationCenter];
    //Observer for when iTunes launches
    [sharedNC addObserver:self
                 selector:@selector(iTunesLaunched:)
                     name:NSWorkspaceDidLaunchApplicationNotification
                   object:nil];
    //Observer for whe iTunes quits
    [sharedNC addObserver:self
                 selector:@selector(iTunesQuit:)
                     name:NSWorkspaceDidTerminateApplicationNotification
                   object:nil];
    
    return self;
}
//##############################################################################
//This creates the iTunes object if iTunes is running on the mac.
//It returns whether iTunes is open.  Shouldn't need to fuck wit this
//##############################################################################
- (bool)createiTunesObjectIfNeeded
{
    NSArray *appNames = [[NSWorkspace sharedWorkspace] runningApplications];
    for (int i = 0; i < [appNames count]; i++)
    {
        if ([[appNames[i] localizedName] isEqualToString:@"iTunes"])
        {
            if (!_iTunes)
            {
                _iTunes = [SBApplication
                           applicationWithBundleIdentifier:@"com.apple.iTunes"];
                _iTunesRunning = true;
            }
            return true;
        }
    }
    return false;
}

#
#pragma mark - Updating Methods
#
//##############################################################################
//Updates all the information from iTunes.  Bear in mind that this assumes
//iTunes is open.  If it tries to poll iTunes when iTunes is closed, it will
//launch iTunes.  This should never happen though, and we make sure of that
//in the delegate.
//##############################################################################
- (void)update
{
    //--------------------------------------------------------------------------
    //Update tags
    //--------------------------------------------------------------------------
    _currentSong = [[_iTunes currentTrack] name];
    _currentArtist = [[_iTunes currentTrack] artist];
    _currentAlbum = [[_iTunes currentTrack] album];
    _currentLength  = [[_iTunes currentTrack] duration];
    [self updateArtwork];
    [self updateProgress];
    [self updateLyrics];
    
    //--------------------------------------------------------------------------
    //Update the status.  If nothing is playing, make sure to wipeout the tags
    //--------------------------------------------------------------------------
    switch ([_iTunes playerState])
    {
        //Playing
        case 1800426320:
            _currentStatus = @"Playing";
            break;
        //Paused
        case 1800426352:
            _currentStatus = @"Paused";
            break;
        //Two cases for stopped
        default:
            //Stopped - Nothing playing
            if (!_currentSong)
            {
                [self updateWithNill];
            }
            //Stopped - begining of a song
            else
            {
                _currentStatus = @"Paused";
            }
    }
}

//##############################################################################
//"Updates" everything with zeroed out tags.  It wipes everything.
//##############################################################################
- (void)updateWithNill
{
    _currentStatus = @"Stopped";
    _currentSong = @"";
    _currentArtist = @"";
    _currentAlbum = @"";
    _currentLyrics = @"";
    _currentProgress = 0;
    _currentLength = 0;
}

//##############################################################################
//Update the artwork from iTunes.
//##############################################################################
- (void)updateArtwork
{
    iTunesArtwork *rawArtwork =
        (iTunesArtwork *)[[[[_iTunes currentTrack] artworks] get] lastObject];
    
    NSImage *theArtwork = [[NSImage alloc] initWithData:[rawArtwork rawData]];
    _currentArtwork = theArtwork;
}

//##############################################################################
//Update the progress of the current track
//This is seperated from the other tags so it can be called independently.
//Our timer in the window controller calls this function to set itself to
//the correct position.
//##############################################################################
- (void)updateProgress
{
    _currentProgress = [_iTunes playerPosition];
}

//##############################################################################
//Update the lyrics, will need to do some scraping here.  For now it's blank
//##############################################################################
///b
- (void)updateLyrics
{
    _currentLyrics = @"";
}

#
#pragma mark - Notification selector methods
#
//##############################################################################
//Receives system notifications from the nsnotifcaion center.
//Called when iTunes' status changes.  We filter notifications that tell if
//iTunes has played, paused, or stopped
//##############################################################################
- (void)iTunesStatusChange:(NSNotification *)note
{
    ///r
    ///move these around the rest of the app...
     /**
    //--------------------------------------------------------------------------
    //FILTERING....
    //--------------------------------------------------------------------------
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
      */
    
    //--------------------------------------------------------------------------
    //UPDATING
    //--------------------------------------------------------------------------
    NSString *incomingPlayerState =[note.userInfo objectForKey:@"Player State"];
    
    //--------------------------------------------------------------------------
    //PLAYING UPDATE
    //If it is playing, a new track has begun, or a track has been unpaused
    //--------------------------------------------------------------------------
    if ([incomingPlayerState isEqualToString:@"Playing"])
    {
        [self playingUpdate];
    }
    //--------------------------------------------------------------------------
    //STOPPED UPDATE
    //The current track stopped and there are no following songs,
    //or there is just not anything playing.
    //--------------------------------------------------------------------------
    else if ([incomingPlayerState isEqualToString:@"Stopped"])
    {
        [self stoppedUpdate];
    }
    //--------------------------------------------------------------------------
    //PAUSED UPDATE
    //Because we have no new song starting, all we need to
    //update it the artwork, and put the paused mask on it
    //--------------------------------------------------------------------------
    else if ([incomingPlayerState isEqualToString:@"Paused"])
    {
        [self pausedUpdate];
    }
}

//##############################################################################
//Gets the information from iTunes and updates it accordingly.
//Makes sure all the UI elements are arranged properly
//##############################################################################
 - (void)playingUpdate
{
    [self createiTunesObjectIfNeeded];
    _currentStatus = @"Playing";
    
    ///r
    ///Send not. to artworkwindow controller telling it to do these following tasks
    /**
    if ([[_artworkWindowController window] isVisible])
    {
     [self update:YES];
    }
    else
    {
     [self update:NO];
    }

    [_artworkWindowController updateUIElements];

    [_artworkWindowController startTimer];
    [_artworkWindowController.openIniTunes setTitle:@"Go to song in iTunes"];
    */

    //Post notification after clearing any existing ones
    [[NSUserNotificationCenter defaultUserNotificationCenter]
                                            removeAllDeliveredNotifications];
    
    [_ncController sendNotification:_currentSong
                                   :_currentArtist
                                   :_currentAlbum
                                   :_currentArtwork];
 }

//##############################################################################
//This function sets paused information, making sure to only update the
//menubar icon if the window is closed
//At the end it makes sure all the UI elements are arranged properly
//##############################################################################
 - (void)pausedUpdate
{
     _currentStatus = @"Paused";
    
    ///r
     ///Send not. to artwcontroller to do this
     ///[_artworkWindowController updateUIElements];
    ///send not. menubarcont. to do this
     ///make sure this is opdating properly, dont poll itunes, just update the icon
     ///[_menubarController updateSatusItemView:nil iTunesStatus:_iTunesController.currentStatus];
}

//##############################################################################
//Essentially the same as the paused one
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
//actually did just stop playback.  But if it goes from stopped to stopped,
//its a false positive - iTunes sends out a stopped updated when it quits...
//##############################################################################
- (void)stoppedUpdate
{
    //False positive - iTunes is actually quitting when this if statement
    //catches.  But this notification gets sent first, so we catch it here, then
    //allow the actual quit notificatino to get handled at the proper location.
    if ([_currentStatus isEqualToString:@"Stopped"])
    {
        return;
    }

    [self updateWithNill];
    
    ///r
    ///send not. to menubar cont. to do this
    ///self.statusItem.title = @"";
    
    ///sned not. to artworkwindowcontroller to do this
    /**
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
     */
}

#
#pragma mark - iTunes utilities
#

 //#############################################################################
//This method is called when iTunes launches, and it tells the iTunesController
//to create an iTunes object if it has not already.
///r
///Can change this method to onlu pick up what I want, I think
///Really, this is tripped whenever any application is launched, and I do a
///double check to make sure it was iTunes,  This is mimicked in the quitting
///function as well
//##############################################################################
- (void)iTunesLaunched:(NSNotification *)note
{
    if (_iTunesRunning)
    {
        [self createiTunesObjectIfNeeded];
    }
}

//##############################################################################
//This is called when iTune quits, and it destorys the iTunes object, and it
//calls the stopped update to zero out tags and other info.
///r
///Might be able to change this behavior just in like in previous func.
///Not that when ANY
///progarm quits, this method pick it up and we filter to just get the iTunes
///notifications.  There is a check with an if statement to quit the entire app
///if that optin was checked in the preferences.
//##############################################################################
- (void)iTunesQuit:(NSNotification *)note
{
    if ([[note.userInfo
          objectForKey:@"NSApplicationName"] isEqualToString:@"iTunes"])
    {
        [self destroyiTunes];
        [self stoppedUpdate];
        
        ///r
        ///Will want to send this message to the Delegate
        /**
        //If the UserDefaults option for quitting playme when
        //itunes quits IS ENABLED, quit.  Otherwise do not
        if([[NSUserDefaults standardUserDefaults]
                                        boolForKey:@"quitWheniTunesQuits"])
        {
            [_artworkWindowController quitPlayMe:nil];
        }
         */
    }
}

//##############################################################################
//'Destroy' iTunes - set the object to nil, so I don't poll
//when iTunes has been quit - this caused iTunes to reopen when quit - muy malo
//##############################################################################
- (bool)destroyiTunes;
{
    _iTunesRunning = false;
    _iTunes = nil;
    return true;
}

//##############################################################################
//Sets the position of the current track, invoked when the user moves the
//slider from the window controller.
//##############################################################################
- (void)setPlayerPosition:(double)newPosition
{
    [_iTunes setPlayerPosition:newPosition];
}

//##############################################################################
//Takes the notfication posted by some other part of the app to control iTunes,
//parses the message and performs the action.
//##############################################################################
- (void)iTunesCommand:(NSNotification *)note
{
    NSString *command =[note.userInfo objectForKey:@"Command"];
    
    if ([command isEqualToString:@"Playpause"])
    {
        [_iTunes playpause];
    }
    else if ([command isEqualToString:@"Next Track"])
    {
        [_iTunes nextTrack];
    }
    else if ([command isEqualToString:@"Previous Track"])
    {
        [_iTunes previousTrack];
    }
    
}

@end