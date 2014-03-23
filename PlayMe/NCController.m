#import "NCController.h"

@implementation NCController

//############################################################################
//We override this to make the notification cetner a delgate of itself,
//this is necessary to bring up iTunes when the notification is clicked
//############################################################################
-(id)init
{
    [[NSUserNotificationCenter defaultUserNotificationCenter] setDelegate:self];
    //iTunes = [SBApplication applicationWithBundleIdentifier:@"com.apple.iTunes"];
    return self;
}

//############################################################################
//Send the notification from the delegate
//############################################################################
-(void)sendNotification:(NSString *)title
                       :(NSString *)subtitle
                       :(NSString *)informativeText
                       :(NSImage *)artwork
{
    notification = [[NSUserNotification alloc] init];
    notification.title = [NSString stringWithFormat:@"%@%@", @"", title];
    notification.subtitle = [NSString stringWithFormat:@"%@%@", @"", subtitle];
    notification.informativeText =
        [NSString stringWithFormat:@"%@%@", @"", informativeText];
    notification.contentImage = artwork;
    
    [[NSUserNotificationCenter defaultUserNotificationCenter] deliverNotification:notification];
}

-(void) userNotificationCenter:(NSUserNotificationCenter *)center
       didActivateNotification:(NSUserNotification *)notification
{
    NSString *path = [[NSBundle mainBundle] pathForResource:@"revealTrack"
                                                     ofType:@"scpt"];
    NSAppleScript *script = [[NSAppleScript alloc]
                              initWithContentsOfURL:[NSURL fileURLWithPath:path]
                              error:nil];
    
    [script executeAndReturnError:nil];
}


@end
