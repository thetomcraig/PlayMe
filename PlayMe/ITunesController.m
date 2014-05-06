#import "ITunesController.h"

@implementation ITunesController

#
#pragma mark - Tags
#
@synthesize iTunesRunning;
@synthesize currentStatus;
@synthesize currentSong;
@synthesize currentArtist;
@synthesize currentAlbum;
@synthesize currentLyrics;
@synthesize currentProgress;
@synthesize currentLength;
@synthesize currentArtwork;

#
#pragma mark - Initalizing Method
#
//############################################################################
//Initialize self, and wipeout all the tags
//############################################################################
-(id)init
{
    [self updateWithNill];
    return self;
}

//############################################################################
//This creates the iTunes object if iTunes is running on the mac.
//It returns whether iTunes is open.  Shouldn't need to fuck wit this
//############################################################################
-(bool)createiTunesObjectIfNeeded
{
    NSArray *appNames = [[NSWorkspace sharedWorkspace] runningApplications];
    for (int i = 0; i < [appNames count]; i++)
    {
        if ([[appNames[i] localizedName] isEqualToString:@"iTunes"])
        {
            if (!iTunes)
            {
                iTunes = [SBApplication applicationWithBundleIdentifier:@"com.apple.iTunes"];
                iTunesRunning = true;
            }
            return true;
        }
    }
    return false;
}

#
#pragma mark - Updating Methods
#
//############################################################################
//Updates all the information from iTunes.  Bear in mind that this assumes
//iTunes is open.  If it tries to poll iTunes when iTunes is closed, it will
//launch iTunes.  This should never happen though, and we make sure of that
//in the delegate.
//############################################################################
-(void)update
{
    //-------------------------------------------------------------------------
    //Update tags
    //-------------------------------------------------------------------------
    currentSong = [[iTunes currentTrack] name];
    currentArtist = [[iTunes currentTrack] artist];
    currentAlbum = [[iTunes currentTrack] album];
    currentLength  = [[iTunes currentTrack] duration];
    [self updateArtwork];
    [self updateProgress];
    [self updateLyrics];
    
    //-------------------------------------------------------------------------
    //Update the status.  If nothing is playing, make sure to wipeout the tags
    //-------------------------------------------------------------------------
    switch ([iTunes playerState])
    {
            //Playing
        case 1800426320:
            currentStatus = @"Playing";
            break;
            //Paused
        case 1800426352:
            currentStatus = @"Paused";
            break;
            //Two cases for stopped
        default:
            //Stopped - Nothing playing
            if (!currentSong)
            {
                [self updateWithNill];
            }
            //Stopped - begining of a song
            else
            {
                currentStatus = @"Paused";
            }
    }
}

//############################################################################
//"Updates" everything with zeroed out tags.  It wipes everything.
//############################################################################
-(void)updateWithNill
{
    currentStatus = @"Stopped";
    currentSong = @"";
    currentArtist = @"";
    currentAlbum = @"";
    currentLyrics = @"";
    currentProgress = 0;
    currentLength = 0;
}

//############################################################################
//Update the artwork from iTunes.
//############################################################################
-(void)updateArtwork
{
    iTunesArtwork *rawArtwork = (iTunesArtwork *)[[[[iTunes currentTrack] artworks] get] lastObject];
    NSImage *theArtwork = [[NSImage alloc] initWithData:[rawArtwork rawData]];
    currentArtwork = theArtwork;
}

//############################################################################
//Update the progress of the current track
//This is seperated from the other tags so it can be called independently.
//Our timer in the window controller calls this function to set itself to
//the correct position.
//############################################################################
-(void)updateProgress
{
    currentProgress = [iTunes playerPosition];
}

//############################################################################
//Update the lyrics, will need to do some scraping here.  For now it's blank
//############################################################################
-(void)updateLyrics
{
    currentLyrics = @"";
}

#
#pragma mark - iTunes utilities
#
//############################################################################
//'Destroy' iTunes - set the object to nil, so I don't poll
//when iTunes has been quit
//############################################################################
-(bool)destroyiTunes;
{
    iTunesRunning = false;
    iTunes = nil;
    return true;
}

//############################################################################
//Sets the position of the current track, invoked when the user moves the
//slider from the window controller.
//############################################################################
-(void)setPlayerPosition:(double)newPosition
{
    [iTunes setPlayerPosition:newPosition];
}

//############################################################################
//Plays and pauses iTunes
//############################################################################
-(void)playpause
{
    [iTunes playpause];
}

//############################################################################
//Goes to the next song
//############################################################################
-(void)nextSong
{
    [iTunes nextTrack];
}

//############################################################################
//Goes to the previous song
//############################################################################
-(void)previousSong
{
    [iTunes previousTrack];
}

@end