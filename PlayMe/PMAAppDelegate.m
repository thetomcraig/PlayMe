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
    _iTunesController = [[ITunesController alloc] init];
    _menubarController = [[MenubarController alloc] init];
    
}

#
#pragma mark - Updating Methods
#
//##############################################################################
//For updating the artworkWindowController and menubarController with new
//info form iTunes
//##############################################################################
///r porb dont need this
/**
- (void)update:(BOOL)windowIsOpen
{
    //Update the iTunes Controller
    [_artworkWindowController update:windowIsOpen];
        
    //If the UserDefaults option for showing
    //the name in the menubar IS ENABLED, then we show
    //the name.  Otherwise there shuold be no title
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"showSongName"])
    {
        [_menubarController updateSatusItemView:_iTunesController.currentSong
                                   iTunesStatus:_iTunesController.currentStatus];
    }
}
 */


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

@end