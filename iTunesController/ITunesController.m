#import "ITunesController.h"

#define ARTWORK_WIDTH 400
#define ARTWORK_HEIGHT 400
#define WINDOW_HEIGHT 500


@implementation ITunesController

@synthesize imageController = _imageController;
@synthesize iTunes = _iTunes;
@synthesize artworks = _artworks;
@synthesize currentArtwork = _currentArtwork;
@synthesize iTunesTags = _iTunesTags;
@synthesize countDownTimer = _countDownTimer;
@synthesize currentProgress = _currentProgress;
@synthesize currentProgressDouble = _currentProgressDouble;
@synthesize currentLength = _currentLength;
@synthesize currentLengthDouble = _currentLengthDouble;
@synthesize currentTimeLeft = _currentTimeLeft;

- (id)init
{
    _iTunes = [SBApplication applicationWithBundleIdentifier:@"com.apple.iTunes"];
    
    _currentLengthDouble = 0.0;
    _currentProgressDouble = 0.0;
    
    _currentLength = [NSNumber numberWithDouble:_currentLengthDouble];
    _currentProgress = [NSNumber numberWithDouble:_currentLengthDouble];
    
    _currentArtwork = @"";
    
    _iTunesTags = [NSMutableDictionary dictionaryWithDictionary:
    @{
      @"CurrentSong": @"",
      @"CurrentArtist": @"",
      @"CurrentAlbum": @"",
      @"CurrentLength": _currentLength,
      @"CurrentArtwork": _currentArtwork,
      @"CurrentProgress": _currentProgress,
      @"CurrentStatus": @""
      }];
    
    
    ///_imageController = [[ImageController alloc] init];
    
    if([_iTunes isRunning])
    {
        [self updateTagsPoll];
    }
    else
    {
        //iTunes is not open
        [self updateWithNill];
    }
    /**
    if ([_currentStatus isEqualToString:@"Playing"])
    {
        [self startTimer];
    }
    */
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
//Poll iTunes to get the info
- (void)updateTagsPoll
{
    /**
    _currentSong = [[_iTunes currentTrack] name];
    _currentArtist = [[_iTunes currentTrack] artist];
    _currentAlbum = [[_iTunes currentTrack] album];
    _currentLengthDouble  = [[_iTunes currentTrack] duration];

    //Update the status.  If nothing is playing, make sure to wipeout the tags
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
            [self updateArtwork:YES];
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
                [self updateArtwork:YES];
            }
            //end default
    }//end switch
     */
}

//"Updates" everything with zeroed out tags.  It wipes everything.
- (void)updateWithNill
{
    /**
    _currentSong = @" ";
    _currentArtist = @" ";
    _currentAlbum = @" ";
    _currentLength = 0;
    _currentProgress = 0;
    _currentStatus = @"Stopped";
    
    //Taking the nothing playingartwork and pretending its itunes artwork
    NSSize targetSize = NSMakeSize(ARTWORK_WIDTH, ARTWORK_HEIGHT);
    NSImage *nothingPlaying = [NSImage imageNamed:@"NothingPlaying"];
    nothingPlaying = [_imageController resizeArt:nothingPlaying forSize:targetSize];
    nothingPlaying = [_imageController roundCorners:nothingPlaying];
    _currentArtwork = nothingPlaying;
     */
 
}


//Update the artwork from iTunes.  We don't want to poll iTunes when we don't
//have to, so the boolean is telling us if we really want to do that.  When it
//is true we update from itunes, if not, we retain the current artwork.
- (void)updateArtwork:(BOOL)getNewArt
{
    
    //Getting the new artwork from iTunes
    if (getNewArt)
    {
        @autoreleasepool
        {
            /**
            iTunesApplication *iTunes = [SBApplication applicationWithBundleIdentifier:@"com.apple.iTunes"];
             */
             _artworks = [[_iTunes currentTrack] artworks];
            
            [_iTunesTags setObject:(NSImage*)[_artworks[0] rawData] forKey:@"CurrentArtwork"];
            [_iTunesTags setObject:            [NSImage imageNamed:@"BlankArtwork"] forKey:@"CurrentArtwork"];
            
    
        }
        
    }
    /**
    //Resizing/manipulation
    //For resizing
    NSSize targetSize = NSMakeSize(ARTWORK_WIDTH, ARTWORK_HEIGHT);

    //If there is nothing playing, grab the resource image for this instead
    if ([_currentStatus isEqualToString:@"Stopped"])
    {
        _currentArtwork = [_imageController resizeNothingPlaying: targetSize];
    }
    
    //There was no artwork :(
    //Get the blank resource image
    if (_currentArtwork.size.width == 0.0)
    {
        _currentArtwork = [NSImage imageNamed:@"BlankArtwork"];
    }
    
    
    //Resize the image
    _currentArtwork = [_imageController resizeArt:_currentArtwork forSize:targetSize];

    //Make sure to mask it if the song is paused
    if ([_currentStatus isEqualToString:@"Paused"])
    {
        _currentArtwork = [_imageController putOnPausedMask:_currentArtwork];
    }
    
    //Finalize and put in the image
   _currentArtwork = [_imageController roundCorners:_currentArtwork];
   */
}

//Update the progress of the current track
- (void)updateProgress
{
    _currentProgressDouble = _currentProgressDouble + 1;
    
}


#
#pragma mark - Receiving notifications
#

- (void)receivedStatusNotification:(NSNotification *)note
{
    /*
    for(NSString *key in [note.userInfo allKeys]) {
        NSLog(@"%@ : %@", key, [note.userInfo objectForKey:key]);
        NSLog(@"--");
    }
    */
    

    NSString *incomingPlayerState =[note.userInfo objectForKey:@"Player State"];

    if ([incomingPlayerState isEqualToString:@"Playing"])
    {
        [self playingUpdate: note.userInfo];
    }
    
    //The current track stopped and there are no following songs,
    //or there is just not anything playing.  This can be triggered if iTunes
    //skips to a new song while paused, so it is paused with the scrubber set
    //at 0 secs.
    else if ([incomingPlayerState isEqualToString:@"Stopped"])
    {
        //If this is the case then we have a song qeueued
        if ([note.userInfo count] > 1)
        {
            //Playing update to get all the new tags
            //then paused update because we know it
            //is paused
            [self playingUpdate: note.userInfo];
        }
        else
        {
            [self stoppedUpdate];
        }

    }

    else if ([incomingPlayerState isEqualToString:@"Paused"])
    {
        [self pausedUpdate];
    }
    
}

- (void)playingUpdate:(NSDictionary *)dict
{
    [_iTunesTags setObject:@"Playing" forKey:@"CurrentStatus"];
    [_iTunesTags setObject:[dict objectForKey:@"Name"] forKey:@"CurrentSong"];
    [_iTunesTags setObject:[dict objectForKey:@"Artist"] forKey:@"CurrentArtist"];
    [_iTunesTags setObject:[dict objectForKey:@"Album"] forKey:@"CurrentAlbum"];
    _currentLengthDouble = [[dict objectForKey:@"Total Time"] doubleValue];
    [self updateProgress];
    
    
    [self updateArtwork:YES];

    //Sending the notification that the ArtworkWindowController will pick up
    [self sendTagsNotification];
    
    //Start the timer again
    ///[self startTimer];
 }

//The NO flag allows us to NOT poll iTunes because if we do it causes iTunes
//to relaunch accidentally.
- (void)pausedUpdate
{
    [_iTunesTags setObject:@"Paused" forKey:@"CurrentStatus"];
    [self updateArtwork:NO];
    [self sendTagsNotification];
    [self stopTimer];
     
}

//If the player state was stopped ALREADY, then updated to stopped again,
//then itunes must be quitting.  So its a false positive
- (void)stoppedUpdate
{
    /**
    //False positive - iTunes is actually quitting when this if statement
    //catches.  But this notification gets sent first, so we catch it here, then
    //allow the actual quit notificatino to get handled at the proper location.
    if ([_currentStatus isEqualToString:@"Stopped"]) return;

    [self updateWithNill];
    [self sendTagsNotification];
    [self stopTimer];
     */
    
}

- (void)receivedCommandNotification:(NSNotification *)note
{
    iTunesApplication *iTunes = [SBApplication applicationWithBundleIdentifier:@"com.apple.iTunes"];
    NSString *command = [note.userInfo objectForKey:@"Command"];
    
    if ([command isEqualToString:@"PlayPause"])
    {
        [iTunes playpause];
    }
    else if ([command isEqualToString:@"NextTrack"])
    {
        [iTunes nextTrack];
    }
    else if ([command isEqualToString:@"PreviousTrack"])
    {
        [iTunes previousTrack];
    }
    //Setting the position of the song, through the UI
    else if ([command isEqualToString:@"SetPosition"])
    {
        double pos = [[note.userInfo objectForKey:@"Position"] doubleValue];
        [iTunes setPlayerPosition:pos];
    }
    else if ([command isEqualToString:@"UpdateProgress"])
    {
        [self updateProgress];
    }
}

- (void)receivedITunesQuitNotification:(NSNotification *)note
{
    if ([[note.userInfo
          objectForKey:@"NSApplicationName"] isEqualToString:@"iTunes"])
    {
        [self updateWithNill];
        [self sendTagsNotification];
        [self stopTimer];
    }
}

#
#pragma mark - Sending notifications
#

//Sends a notification to the NSDistributedNotificationCenter, It is picked up
//by the ArtworkwindowController
- (void)sendTagsNotification
{
    [[NSNotificationCenter defaultCenter]
                                    postNotificationName:@"TagsNotification"
                                                  object:self
                                                userInfo:_iTunesTags];
}

#
#pragma mark - timer stuff
#

//Starts the timer used for the progress bar.  We seperate this because we
//want to stop the timer when the window closes.
- (void)startTimer
{

     _countDownTimer = [NSTimer scheduledTimerWithTimeInterval:1.0
     target:self
     selector:@selector(advanceTimerProgress:)
     userInfo:nil repeats:YES];
}
 

//We do this when the window is closed the timer can be stopped
- (void)stopTimer
{
    if (_countDownTimer != nil)
    {
        [_countDownTimer invalidate];
        _countDownTimer = nil;
    }
}

- (void)advanceTimerProgress:(NSTimer *)timer
{
    [self updateProgress];
    [self sendTagsNotification];
}


@end