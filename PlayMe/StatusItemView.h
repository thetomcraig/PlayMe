#import <Cocoa/Cocoa.h>

@interface StatusItemView : NSView

@property (nonatomic, strong, readonly) NSStatusItem *statusItem;
@property (nonatomic, strong) NSImage *image;
@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSImage *alternateImage;
@property (nonatomic) BOOL isHighlighted;
@property (nonatomic, readonly) NSRect globalRect;

- (id)initWithStatusItem:(NSStatusItem *)statusItemInp;
- (void)update:(NSString *)songTitle :(NSString *)iTunesStatus;

@end
