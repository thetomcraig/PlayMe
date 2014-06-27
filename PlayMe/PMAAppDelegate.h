#import "NCController.h"
#import "MenubarController.h"
#import "ArtworkWindowController.h"

@interface PMAAppDelegate : NSObject <NSApplicationDelegate, ArtworkWindowControllerDelegate>

@property (nonatomic, strong) MenubarController *menubarController;
@property (nonatomic, strong, readonly) ArtworkWindowController *artworkWindowController;
@property (nonatomic, retain) NCController *ncController;

- (IBAction)toggleMainWindow:(id)sender;
-(IBAction)toggleMenu:(id)sender;
-(void)update:(BOOL)windowIsOpen;
-(void)updateIcon:(BOOL)windowIsOpen;

@end