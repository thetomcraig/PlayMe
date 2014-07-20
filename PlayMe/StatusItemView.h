#define STATUS_ITEM_VIEW_WIDTH 128.0
#import <Cocoa/Cocoa.h>

@interface StatusItemView : NSView
{
@private
    NSImage *_image;
    NSString *_title;
    NSImage *_alternateImage;
    NSStatusItem *_statusItem;
    BOOL _isHighlighted;
}

@property (nonatomic, strong, readonly) NSStatusItem *statusItem;
@property (nonatomic, strong) NSImage *image;
@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSImage *alternateImage;
@property (nonatomic) BOOL isHighlighted;
@property (nonatomic, readonly) NSRect globalRect;

- (void)update:(NSString *)songTitle :(NSString *)iTunesStatus;
- (void)setHighlighted:(BOOL)newFlag;

@end
