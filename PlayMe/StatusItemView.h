#import <Cocoa/Cocoa.h>


@interface StatusItemView : NSView
{
    NSStatusItem *statusItem;
    NSString *title;
    BOOL isHighlighted;
}

@property(retain, nonatomic) NSStatusItem *statusItem;
@property (retain, nonatomic) NSString *title;
@property (nonatomic, strong) NSImage *image;
@property (nonatomic, strong) NSImage *alternateImage;

- (void)update:(NSString *)songTitle :(NSString *)iTunesStatus;

@end
