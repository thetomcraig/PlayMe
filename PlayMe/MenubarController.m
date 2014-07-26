#import "MenubarController.h"
#include "StatusItemView.h"

@implementation MenubarController

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
        statusItemView = [[StatusItemView alloc] init];
        [statusItemView update:@"" :@"Stopped"];
        
        [self setView:statusItemView];
        
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
    
    [statusItemView update:currentSong :currentStatus];
}

#
#pragma mark - Sending Notifications (mouse events )
#
//##############################################################################
//When he user clicks.  If they are holding the control key, this counts as a
//right click, so we call right mouseDown.  RightMouseDown is similar, but sends
//a different notification.
//##############################################################################
- (void)mouseDown:(NSEvent *)theEvent
{
    if ([theEvent modifierFlags] & NSControlKeyMask)
    {
        [self rightMouseDown:nil];
    }
    else
    {
        ///[statusItemView setHighlighted: ![statusItemView isHighlighted]];
        //We need to pass the position of the rect in the menubar,
        //and we convert it to an NSValue
        NSString *globalRectString = NSStringFromRect([statusItemView globalRect]);
        NSDictionary *menubarInfo =
        @{
          @"GlobalRect": globalRectString
        };
        
        //Sending the notification
        [[NSNotificationCenter defaultCenter]
                                 postNotificationName:@"MouseDownNotification"
                                 object:self
                                 userInfo:menubarInfo];
    }
   
}

- (void)rightMouseDown:(NSEvent *)theEvent
{
    [statusItemView setHighlighted: ![statusItemView isHighlighted]];
    
    //Sending the notification
    [[NSNotificationCenter defaultCenter]
                             postNotificationName:@"RightMouseDownNotification"
                             object:self
                             userInfo:nil];
    
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
    [statusItemView update:songTitle :iTunesStatusString];
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
