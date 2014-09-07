#import <Cocoa/Cocoa.h>
#import "AboutViewController.h"
#import "PreferencesBackdrop.h"

@interface PreferencesWindowController : NSWindowController

@property (retain, nonatomic) AboutViewController *aboutViewController;

@property (strong) IBOutlet PreferencesBackdrop *preferencesBackdrop;
@property (strong) IBOutlet NSImageView *applicationIcon;
@property (strong) IBOutlet NSImageView *title;
@property (strong) IBOutlet NSTextField *versionText;
@property (strong) IBOutlet NSButton *showSongName;
@property (strong) IBOutlet NSButton *websiteButton;
@property (strong) IBOutlet NSButton *twitterButton;
@property (strong) IBOutlet NSImageView *logo;

- (IBAction)toggleShowSongName:(id)sender;
- (IBAction)openEmail:(id)sender;

@end
