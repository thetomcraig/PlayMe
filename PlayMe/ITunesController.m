#import "ITunesController.h"

#define ARTWORK_WIDTH 400
#define ARTWORK_HEIGHT 400
#define WINDOW_HEIGHT 500


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
@synthesize countDownTimer = _countDownTimer;
@synthesize currentProgress = _currentProgress;
@synthesize currentLength = _currentLength;
@synthesize currentTimeLeft = _currentTimeLeft;
@synthesize iTunesRunning = _iTunesRunning;

//##############################################################################
//We we initliaze, we create our iTunes object if it' needed
//(if iTunes.app is open).  Then we set up observers for when
//##############################################################################
- (id)init
{
    _imageController = [[ImageController alloc] init];
    
    if([self createiTunesObjectIfNeeded])
    {
        [self updateTags];
    }
    else
    {
        [self updateWithNill];
    }

    if ([_currentStatus isEqualToString:@"Playing"])
    {
        [self startTimer];
    }
    
    //Send a notification to get the AC updated
    [self sendTagsNotification];
    
    //For when iTunes plays/pauses/stops
    [[NSDistributedNotificationCenter defaultCenter]
                            addObserver:self
                               selector:@selector(receivedStatusNotification:)
                                   name:@"com.apple.iTunes.playerInfo"
                                 object:nil];
    
    //For when the user hits a button in the app's window
    [[NSNotificationCenter defaultCenter]
                            addObserver:self
                               selector:@selector(receivedCommandNotification:)
                                   name:@"commandNotification"
                                 object:nil];
    
    //For receiving iTunes launch/quit information
    //Because I am monitoring the status of iTunes,
    //I need to use the shared notification center
    NSNotificationCenter *sharedNC =
                            [[NSWorkspace sharedWorkspace] notificationCenter];
    //Observer for when iTunes launches
    [sharedNC addObserver:self
                 selector:@selector(receivedITunesLaunchedNotification:)
                     name:NSWorkspaceDidLaunchApplicationNotification
                   object:nil];
    //Observer for whe iTunes quits
    [sharedNC addObserver:self
                 selector:@selector(receivedITunesQuitNotification:)
                     name:NSWorkspaceDidTerminateApplicationNotification
                   object:nil];    
    return self;
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
- (void)updateTags
{
    //--------------------------------------------------------------------------
    //Update tags
    //--------------------------------------------------------------------------
    _currentSong = [[_iTunes currentTrack] name];
    _currentArtist = [[_iTunes currentTrack] artist];
    _currentAlbum = [[_iTunes currentTrack] album];
    _currentLength  = [[_iTunes currentTrack] duration];
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
            [self updateArtwork:YES];
            break;
        //Paused
        case 1800426352:
            _currentStatus = @"Paused";
            [self updateArtwork:NO];
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
                [self updateArtwork:NO];
            }
    }
}

//##############################################################################
//"Updates" everything with zeroed out tags.  It wipes everything.
//##############################################################################
- (void)updateWithNill
{
    _currentSong = @" ";
    _currentArtist = @" ";
    _currentAlbum = @" ";
    _currentLength = 0;
    _currentArtwork = [NSImage imageNamed:@"PausedMask"];
    _currentProgress = 0;
    _currentLyrics = @" ";
    _currentStatus = @"Stopped";
}

//##############################################################################
//Update the artwork from iTunes.  We don't want to poll iTunes when we don't
//have to, so the boolean is telling us if we really want to do that.  When it
//is true we update from itunes, if not, we retain the current artwork.
//##############################################################################
- (void)updateArtwork:(BOOL)getNewArt
{
    NSImage *newArtwork = _currentArtwork;
    
    //Getting the new artwork from iTunes
    if (getNewArt)
    {
        iTunesArtwork *rawArtwork =
        (iTunesArtwork *)[[[[_iTunes currentTrack] artworks] get] lastObject];
        newArtwork = [[NSImage alloc] initWithData:[rawArtwork rawData]];
    }

    //Resizing/manipulation
    //For resizing
    NSSize targetSize = NSMakeSize(ARTWORK_WIDTH, ARTWORK_HEIGHT);

    //If there is nothing playing, grab the resource image for this instead
    if ([_currentStatus isEqualToString:@"Stopped"])
    {
        newArtwork = [_imageController resizeNothingPlaying: targetSize];
    }
    
    //There was no artwork :(
    //Get the blank resource image
    if (newArtwork.size.width == 0.0)
    {
        newArtwork = [NSImage imageNamed:@"BlankArtwork"];
    }
    
    //Resize the image
    newArtwork = [_imageController resizeArt:newArtwork forSize:targetSize];

    //Make sure to mask it if the song is paused
    if ([_currentStatus isEqualToString:@"Paused"])
    {
        newArtwork = [_imageController putOnPausedMask:newArtwork];
    }
    
    //Finalize and put in the image
    newArtwork = [_imageController roundCorners:newArtwork];
    
    _currentArtwork = newArtwork;
}

//##############################################################################
//Update the progress of the current track
//This is seperated from the other tags so it can be called independently.
//Our timer in the window controller calls this function to set itself to
//the correct position.
//##############################################################################
- (void)updateProgress
{
    if (_iTunesRunning)
    {
        _currentProgress = [_iTunes playerPosition];
    }
    
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
#pragma mark - Receiving notifications
#
//##############################################################################
//Receives system notifications from the nsnotifcaion center.
//Called when iTunes' status changes.  We filter notifications that tell if
//iTunes has played, paused, or stopped
//##############################################################################
- (void)receivedStatusNotification:(NSNotification *)note
{
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
    
    [self updateTags];
    
    //Sending the notification that the ArtworkWindowController will pick up
    [self sendTagsNotification];
    
    //Post a notification to the notification center
    [[NSUserNotificationCenter defaultUserNotificationCenter]
                                            removeAllDeliveredNotifications];
    
    [_ncController sendNotification:_currentSong
                                   :_currentArtist
                                   :_currentAlbum
                                   :_currentArtwork];
    //Start the timer again
    [self startTimer];
 }

//##############################################################################
//This function sets paused information, making sure to only update the
//menubar icon if the window is closed
//At the end it makes sure all the UI elements are arranged properly
//##############################################################################
- (void)pausedUpdate
{
    _currentStatus = @"Paused";
    [self updateArtwork:NO];
    [self sendTagsNotification];
    [self stopTimer];
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
    if ([_currentStatus isEqualToString:@"Stopped"]) return;

    [self updateWithNill];
    [self sendTagsNotification];
    [self stopTimer];
}

//##############################################################################
//Takes the notfication posted by some other part of the app to control iTunes,
//parses the message and performs the action.
//##############################################################################
- (void)receivedCommandNotification:(NSNotification *)note
{
    NSString *command = [note.userInfo objectForKey:@"Command"];
    
    if ([command isEqualToString:@"PlayPause"])
    {
        [_iTunes playpause];
    }
    else if ([command isEqualToString:@"NextTrack"])
    {
        [_iTunes nextTrack];
    }
    else if ([command isEqualToString:@"PreviousTrack"])
    {
        [_iTunes previousTrack];
    }
    //Setting the position of the song, through the UI
    else if ([command isEqualToString:@"SetPosition"])
    {
        double pos = [[note.userInfo objectForKey:@"Position"] doubleValue];
        [_iTunes setPlayerPosition:pos];
    }
    else if ([command isEqualToString:@"UpdateProgress"])
    {
        [self updateProgress];
    }
}
 //#############################################################################
//This method is called when iTunes launches, and it tells the iTunesController
//to create an iTunes object if it has not already.
//##############################################################################
- (void)receivedITunesLaunchedNotification:(NSNotification *)note
{
    if (_iTunesRunning)
    {
        [self createiTunesObjectIfNeeded];
    }
}

//##############################################################################
//This is called when iTune quits, and it destorys the iTunes object, and it
//calls the stopped update to zero out tags and other info.
//##############################################################################
- (void)receivedITunesQuitNotification:(NSNotification *)note
{
    if ([[note.userInfo
          objectForKey:@"NSApplicationName"] isEqualToString:@"iTunes"])
    {
        [self destroyiTunes];
        [self stoppedUpdate];
    }
}

#
#pragma mark - Sending notifications
#
//##############################################################################
//Sends a notification to the NSDistributedNotificationCenter, the notification
//has all the iTunes tags in it.  It is picked up by the ArtworkwindowController
//##############################################################################
- (void)sendTagsNotification
{
    //Need to update this here because it cahnged literally every second
    
    //This cannpt happen in here because when itunes quites it send a
    //paused update before anything else, this makes itunes reopen when its quit
    //so I need to handle this updaing outside of this function
    [self updateProgress];
    
    //Set up all the tags
    NSDictionary *iTunesTags =
    @{
          @"CurrentSong": _currentSong,
        @"CurrentArtist": _currentArtist,
         @"CurrentAlbum": _currentAlbum,
        @"CurrentLength": [NSNumber numberWithDouble:_currentLength],
       @"CurrentArtwork": _currentArtwork,
      @"CurrentProgress": [NSNumber numberWithDouble:_currentProgress],
        @"CurrentLyrics": _currentLyrics,
        @"CurrentStatus": _currentStatus
      };

    [[NSNotificationCenter defaultCenter]
                                    postNotificationName:@"TagsNotification"
                                                  object:self
                                                userInfo:iTunesTags];
}

#
#pragma mark - timer stuff
#
//##############################################################################
//Starts the timer used for the progress bar.  We seperate this because we
//want to stop the timer when the window closes.
//##############################################################################
- (void)startTimer
{
     _countDownTimer = [NSTimer scheduledTimerWithTimeInterval:1.0
     target:self
     selector:@selector(advanceTimerProgress:)
     userInfo:nil repeats:YES];
}
 
//##############################################################################
//This is used to invalidate the timer when it does not need to be running.
//We do this when the window is closed because the progress bar is not
//visible if that happens
//##############################################################################
- (void)stopTimer
{
    if (_countDownTimer != nil)
    {
        [_countDownTimer invalidate];
        _countDownTimer = nil;
    }
}

//##############################################################################
//Called by the timer every interval
//##############################################################################
- (void)advanceTimerProgress:(NSTimer *)timer
{
    [self sendTagsNotification];
}

#
#pragma mark - iTunes utilities
#
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

@end