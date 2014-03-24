#import "PreferencesWindowController.h"

@implementation PreferencesWindowController

@synthesize aboutViewController;
@synthesize preferencesBackdrop;
@synthesize applicationIcon;
@synthesize title;
@synthesize versionText;
@synthesize logo;

-(id)init
{
    self = [[PreferencesWindowController alloc] initWithWindowNibName:@"PreferencesWindowController"];
    return self;
}


- (void)windowDidLoad
{
    [super windowDidLoad];
    [self setUpUIElements];
}

-(void)setUpUIElements
{
    float width = 200;
    float height = 25;
    [title setStringValue:@"PlayMe"];
    [versionText setStringValue:@"v. 1.0.5"];
    [logo setImage:[NSImage imageNamed:@"companyLogo"]];
    [logo setImageFrameStyle:0];
    [logo setFrame:NSMakeRect([self window].frame.size.width/2 - width/2, 5, width, height)];
    [preferencesBackdrop setNeedsDisplay:YES];
}

-(IBAction)toggleOpenAtLogin:(id)sender
{
    ///Nothing here because handled via bdingins in NIB
    NSLog(@"ALPHA");
    [preferencesBackdrop setNeedsDisplay:YES];
}

-(IBAction)toggleShowSongName:(id)sender
{
    ///Nothing here because handled via bdingins in NIB
}

-(IBAction)toggleQuitWheniTunesQuits:(id)sender
{
    ///Nothing here because handled via bdingins in NIB
}


@end
