#import <Cocoa/Cocoa.h>


@interface StatusItemView : NSView <NSMenuDelegate>
{
    NSStatusItem *statusItem;
    NSString *title;
    BOOL isHighlighted;
}

@property (retain, nonatomic) NSStatusItem *statusItem;
@property (retain, nonatomic) NSString *title;
@property (nonatomic, strong) NSImage *image;
@property (nonatomic, strong) NSImage *alternateImage;
@property (nonatomic, strong) NSMenu *menu;
@property (nonatomic, strong) NSMenuItem *preferences;
@property (nonatomic, strong) NSMenuItem *openIniTunes;
@property (nonatomic, strong) NSMenuItem *quitApp;
@property (nonatomic) NSRect statusRect;
@property (retain, nonatomic) NSString *currentStatus;

- (void)setImagesForStatus:(NSString *)statusFromController;

@end
