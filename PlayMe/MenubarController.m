#import "MenubarController.h"
#include "StatusItemView.h"

@implementation MenubarController

@synthesize statusItemView = _statusItemView;

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
        _statusItemView = [[StatusItemView alloc] init];
        [_statusItemView update:@"" :@"Stopped"];
        
        [self setView:_statusItemView];
        
    }
    return self;
}

#
#pragma mark - mouse events - Sending Notifications
#
//##############################################################################
//When he user clicks.  If they are holding the control key, this counts as a
//right click, so we call right mouseDown.  RightMouseDown is similar, but sends
//a different notification.
//##############################################################################
- (void)mouseDown:(NSEvent *)theEvent
{
    [_statusItemView setHighlighted: ![_statusItemView isHighlighted]];
    
    if ([theEvent modifierFlags] & NSControlKeyMask)
    {
        [self rightMouseDown:nil];
    }
    else
    {
        
        //We need to pass the position of the rect in the menubar,
        //and we convert it to an NSValue
        NSString *globalRectString = NSStringFromRect([_statusItemView globalRect]);
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
    [_statusItemView setHighlighted: ![_statusItemView isHighlighted]];
    
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
    [_statusItemView update:songTitle :iTunesStatusString];
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
