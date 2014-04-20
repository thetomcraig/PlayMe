#import <Foundation/Foundation.h>
//#import "iTunes.h"

@interface NCController :NSObject <NSApplicationDelegate, NSUserNotificationCenterDelegate>
{
    NSUserNotification* notification;
}


-(void)sendNotification:(NSString *)title
                       :(NSString *)subtitle
                       :(NSString *)informativeText
                       :(NSImage *)artwork;
@end