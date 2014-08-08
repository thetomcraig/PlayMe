#import <Cocoa/Cocoa.h>


@interface StatusItemView : NSView
{
    NSStatusItem *statusItem;
    NSString *title;
    BOOL isMenuVisible;
}

@property(retain, nonatomic) NSStatusItem *statusItem;
@property (retain, nonatomic) NSString *title;

@property (nonatomic, strong) NSImage *image;

- (void)update:(NSString *)songTitle :(NSString *)iTunesStatus;

@end
