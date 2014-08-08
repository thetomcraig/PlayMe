#import "MenubarController.h"
#include "StatusItemView.h"

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
        [statusItemView setTitle:@"PlayMe"];
        
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
    
    statusItemView.statusItem = statusItem;
    [statusItem setView:statusItemView];
    [statusItemView setTitle:currentSong];
}

@end
