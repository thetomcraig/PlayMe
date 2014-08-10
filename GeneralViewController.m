#import "GeneralViewController.h"

@implementation GeneralViewController

-(id)init
{
    return [super initWithNibName:@"GeneralView" bundle:nil];
}

#pragma mark -
#pragma mark MASPreferencesViewController

-(NSString *)identifier
{
    return @"General";
}

-(NSImage *)toolbarItemImage
{
    //Change this later
    return [NSImage imageNamed:NSImageNamePreferencesGeneral];
}

-(NSString *)toolbarItemLabel
{
    return NSLocalizedString(@"General", @"Toolbar item name for the General preference pane");
}

//############################################################################
//Method for toggling the option of quitting the app when iTunes quits
//############################################################################
- (IBAction)toggleQuitOption:(id)sender
{
    if ([sender state] == NSOnState)
    {
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"Quit When iTunes Quits"];
    }
    else
    {
        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"Quit When iTunes Quits"];
    }
}

@end
