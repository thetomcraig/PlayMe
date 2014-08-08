#import "MenubarController.h"
#include "StatusItemView.h"

@implementation MenubarController

@synthesize statusItemView;
@synthesize statusItem;

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
        
        [statusItem setTitle:@"TEST"];
        
        ///[statusItem setView:statusItemView];
        [statusItem setTarget:self];
        [statusItem setAction:@selector(testMethod:)];
        
        
        /*
        NSMenuItem *preferences = [[NSMenuItem alloc] initWithTitle:@"Preferences..."
                                                 action:@selector(showPreferences:)
                                          keyEquivalent:@""];
        
        NSMenu *menuButtonMenu = [[NSMenu alloc] initWithTitle:@"Menu"];
        
        [menuButtonMenu addItem:preferences];
        
        [statusItem setMenu:menuButtonMenu];
        */
        



        ///statusItemView = [[StatusItemView alloc] initWithStatusItem:statusItem];
        ///[statusItemView update:@"" :@"Stopped"];
        
        ///[self setView:statusItemView];
        
        [[NSNotificationCenter defaultCenter]
         addObserver:self
         selector:@selector(receivedTagsNotification:)
         name:@"TagsNotification"
         object:nil];
    }
    return self;
}

- (void)testMethod:(id)sender
{
    NSLog(@"ALPHA");
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
    
    ///[statusItemView update:currentSong :currentStatus];
}

#
#pragma mark - updating
#
//##############################################################################
//For udating the info in the statusItemView
//##############################################################################
-(void)updateSatusItemView:(NSString *)songTitle
              iTunesStatus:(NSString *)iTunesStatusString
{
    ///[statusItemView update:songTitle :iTunesStatusString];
}

#
#pragma mark - icon methods
#
- (BOOL)hasActiveIcon
{
    return self.statusItemView.isHighlighted;
}

- (void)setHasActiveIcon:(BOOL)flag
{
    self.statusItemView.isHighlighted = flag;
}





@end
