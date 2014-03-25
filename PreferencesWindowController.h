#import <Cocoa/Cocoa.h>
#import "AboutViewController.h"
#import "PreferencesBackdrop.h"

@interface PreferencesWindowController : NSWindowController

@property (retain, nonatomic) AboutViewController *aboutViewController;

@property (strong) IBOutlet PreferencesBackdrop *preferencesBackdrop;
@property (strong) IBOutlet NSImageView *applicationIcon;
@property (strong) IBOutlet NSTextField *title;
@property (strong) IBOutlet NSTextField *versionText;
@property (strong) IBOutlet NSButton *quitWithiTunes;
@property (strong) IBOutlet NSButton *showSongName;
@property (strong) IBOutlet NSButton *websiteButton;
@property (strong) IBOutlet NSImageView *logo;

-(IBAction)toggleQuitWheniTunesQuits:(id)sender;
-(IBAction)toggleShowSongName:(id)sender;
- (IBAction)openWebsite:(id)sender;

@end
