#import <Cocoa/Cocoa.h>
#import "AboutViewController.h"
#import "PreferencesBackdrop.h"

@interface PreferencesWindowController : NSWindowController

@property (retain, nonatomic) AboutViewController *aboutViewController;

@property (strong) IBOutlet PreferencesBackdrop *preferencesBackdrop;
@property (strong) IBOutlet NSImageView *applicationIcon;
@property (strong) IBOutlet NSTextField *title;
@property (strong) IBOutlet NSTextField *versionText;
@property (strong) IBOutlet NSButton *openAtLogin;
@property (strong) IBOutlet NSButton *quitWithiTunes;
@property (strong) IBOutlet NSButton *showSongName;
@property (strong) IBOutlet NSImageView *logo;

-(IBAction)toggleOpenAtLogin:(id)sender;
-(IBAction)toggleQuitWheniTunesQuits:(id)sender;
-(IBAction)toggleShowSongName:(id)sender;

@end
