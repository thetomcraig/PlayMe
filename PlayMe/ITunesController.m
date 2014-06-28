#import "ITunesController.h"

@implementation ITunesController

#
#pragma mark - Tags
#

@synthesize iTunes = _iTunes;
@synthesize currentStatus = _currentStatus;
@synthesize currentSong = _currentSong;
@synthesize currentArtist = _currentArtist;
@synthesize currentAlbum = _currentAlbum;
@synthesize currentLyrics = _currentLyrics;
@synthesize currentArtwork = _currentArtwork;
@synthesize currentProgress = _currentProgress;
@synthesize currentLength = _currentLength;
@synthesize iTunesRunning = _iTunesRunning;

#
#pragma mark - Initalizing Method
#

///
- (void)iTunesControllerDelegateTest
{
    NSLog(@"iTunes Controller Delegate Test!");
}
///

//##############################################################################
//Initialize self, and wipeout all the tags
//##############################################################################
- (id)initWithDelegate:(id<ITunesControllerDelegate>)delegate
{
    if (self != nil)
    {
        _delegate = delegate;
    }

    [self updateWithNill];
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
                _iTunes = [SBApplication applicationWithBundleIdentifier:@"com.apple.iTunes"];
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
    //-------------------------------------------------------------------------
    //Update tags
    //-------------------------------------------------------------------------
    _currentSong = [[_iTunes currentTrack] name];
    _currentArtist = [[_iTunes currentTrack] artist];
    _currentAlbum = [[_iTunes currentTrack] album];
    _currentLength  = [[_iTunes currentTrack] duration];
    [self updateArtwork];
    [self updateProgress];
    [self updateLyrics];
    
    //-------------------------------------------------------------------------
    //Update the status.  If nothing is playing, make sure to wipeout the tags
    //-------------------------------------------------------------------------
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
    iTunesArtwork *rawArtwork = (iTunesArtwork *)[[[[_iTunes currentTrack] artworks] get] lastObject];
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
- (void)updateLyrics
{
    _currentLyrics = @"";
}

#
#pragma mark - iTunes utilities
#
//##############################################################################
//'Destroy' iTunes - set the object to nil, so I don't poll
//when iTunes has been quit
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
//Plays and pauses iTunes
//##############################################################################
- (void)playpause
{
    [_iTunes playpause];
}

//##############################################################################
//Goes to the next song
//##############################################################################
- (void)nextSong
{
    [_iTunes nextTrack];
}

//##############################################################################
//Goes to the previous song
//##############################################################################
- (void)previousSong
{
    [_iTunes previousTrack];
}

@end