#import <Cocoa/Cocoa.h>
#import "NCController.h"
#import "ArtworkWindowController.h"

@interface PMAAppDelegate : NSObject <NSApplicationDelegate>

@property (nonatomic, retain) NSStatusItem *statusItem;
@property (nonatomic, retain) NCController *ncController;
@property (nonatomic, retain) ArtworkWindowController *artworkWindowController;

-(void)update:(BOOL)windowIsOpen;
-(void)updateIcon:(BOOL)windowIsOpen;
-(void)updateUIElements;
-(void)updateWindowPosition;
-(void)clicked:(id)sender;

@end