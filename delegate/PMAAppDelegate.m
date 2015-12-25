#import "PMAAppDelegate.h"

@implementation PMAAppDelegate

@synthesize iTunesController = _iTunesController;
@synthesize menubarController = _menubarController;
@synthesize artworkWindowController = _artworkWindowController;
@synthesize preferencesWindowController = _preferencesWindowController;

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
    //--------------------------------------------------------------------------
    //Initialize stuff.  ArtworkWindowController first so it can get the update
    //from the iTunesController's init method
    //--------------------------------------------------------------------------
    _artworkWindowController = [[ArtworkWindowController alloc] initWithWindowNibName:@"ArtworkWindow"];
    _preferencesWindowController = [[PreferencesWindowController alloc] initWithWindowNibName:@"PreferencesWindow"];
    _menubarController = [[MenubarController alloc] init];
    _iTunesController = [[ITunesController alloc] init];
    
    /**
     - (void)updateTagsPoll;
     - (void)updateArtwork:(BOOL)getNewArt;
     - (void)updateWithNill;
     - (void)receivedStatusNotification:(NSNotification *)note;
     - (void)receivedCommandNotification:(NSNotification *)note;
     - (void)sendTagsNotification;
     - (void)playingUpdate:(NSDictionary *)dict;
     - (void)pausedUpdate;
     - (void)stoppedUpdate;
     */
    ///Stress test - pass many itunes notifications
    NSDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:
                          @{
                            @"Display Line 1" : @"The Acid — Liminal",
                            @"Track Count" : @"11",
                            @"Name" : @"Fame",
                            @"Album Artist" : @"The Acid"
                            }];

    /**
    usleep(10000000);
    for (int i = 0; i < 10000; i++)
    {
        [[NSDistributedNotificationCenter defaultCenter]
         postNotificationName:@"com.apple.iTunes.playerInfo"
         object:nil
         userInfo:dict];
    }
    */
     
    
    
    
}

@end