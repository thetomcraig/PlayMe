#import <Cocoa/Cocoa.h>
#import "NCController.h"
#import "ArtworkWindowController.h"
#import "MenubarController.h"

@interface PMAAppDelegate : NSObject <NSApplicationDelegate, ArtworkWindowControllerDelegate>

///@property (nonatomic, retain) NSStatusItem *statusItem;
@property (nonatomic, strong) MenubarController *menubarController;
@property (nonatomic, retain) NCController *ncController;
@property (nonatomic, retain) ArtworkWindowController *artworkWindowController;


-(IBAction)toggleMainWindow:(id)sender;
-(IBAction)togglePreferencesMenu:(id)sender;
-(void)update:(BOOL)windowIsOpen;
-(void)updateIcon:(BOOL)windowIsOpen;
-(void)updateUIElements;
-(void)updateWindowPosition;
-(void)clicked:(id)sender;

@end