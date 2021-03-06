#define TEXT_WIDTH 20

#import "MenubarController.h"
#import "StatusItemView.h"

@implementation MenubarController

@synthesize statusItem;
@synthesize statusItemView;

//##############################################################################
//Init by making sure tha thte NSStatusItem in the statusItemView is given blank
//title and the stopped icon.
//##############################################################################
- (id)init
{
    self = [super init];
    if (self != nil)
    {
        // Install status item into the menu bar
        statusItem = [[NSStatusBar systemStatusBar] statusItemWithLength:NSVariableStatusItemLength];
        
        statusItemView = [[StatusItemView alloc] init];
        
        statusItemView.statusItem = statusItem;
        [statusItem setView:statusItemView];
        [statusItemView setTitle:@""];
        
        [[NSNotificationCenter defaultCenter]
         addObserver:self
         selector:@selector(receivedTagsNotification:)
         name:@"TagsNotification"
         object:nil];
    }
    return self;
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
    NSString *currentSong = [note.userInfo objectForKey:@"CurrentSong"];
    NSString *currentStatus = [note.userInfo objectForKey:@"CurrentStatus"];
        
    //Setting up the text, which will determine the size of the entire
    //NSSTatusItem, butonly up to the threshold - TEXT_WIDTH
    [statusItem setView:statusItemView];
    
    //If the UserDefaults option for showing
    //the name in the menubar IS ENABLED, then we show
    //the name.  Otherwise there shuold be no title
    if(![[NSUserDefaults standardUserDefaults] boolForKey:@"showSongName"])
    {
        currentSong = @" ";
    }
    
    else
    {
        //Range we care about
        NSRange stringRange = {0, MIN([currentSong length], TEXT_WIDTH)};
        //Adjust the range to include dependent chars
        stringRange = [currentSong rangeOfComposedCharacterSequencesForRange:stringRange];
        currentSong = [currentSong substringWithRange:stringRange];
    }
    
    //Setting the title
    [statusItemView setTitle:currentSong];

    [statusItemView setImagesForStatus:currentStatus];
}

@end
