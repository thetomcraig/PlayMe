#import "AboutViewController.h"

@implementation AboutViewController

@synthesize aboutTextString;

@synthesize backdrop;
@synthesize applicationLogo;
@synthesize titleTextField;
@synthesize versionTextField;
@synthesize companyLogo;
@synthesize copyrightTextField;
@synthesize websiteButton;

-(id)init
{
    return [super initWithNibName:@"AboutView" bundle:nil];
}

#pragma mark -
#pragma mark MASPreferencesViewController

-(NSString *)identifier
{
    return @"About";
}

-(NSImage *)toolbarItemImage
{
    ///Change this later
    return [NSImage imageNamed:NSImageNamePreferencesGeneral];
}

-(NSString *)toolbarItemLabel
{
    return NSLocalizedString(@"About", @"Toolbar item name for the About preference pane");
}

-(void)updateWidowElements
{
    
    backdrop.frame = self.view.frame;


    NSSize backdropFrameSize = NSMakeSize(backdrop.frame.size.width, backdrop.frame.size.height);
    NSImage *backdropImage = [[NSImage alloc] initWithSize:backdropFrameSize];
    
    [backdropImage lockFocus];
    NSBezierPath* blackPath = [NSBezierPath bezierPathWithRect
                               :NSMakeRect(0.0, 0.0,
                                           backdropFrameSize.width,
                                           backdropFrameSize.height)];
    [blackPath setWindingRule:NSEvenOddWindingRule];
        [[NSColor colorWithCalibratedRed:.443137255 green:.749019608 blue:.309803922 alpha:1.0] setFill];
    [blackPath fill];

    [backdropImage unlockFocus];
    
    [backdrop setImage:backdropImage];

    
    double topBuffer = 10;
    
    //-------------------------------------------------------------------------
    //Icon
    //-------------------------------------------------------------------------
    applicationLogo.frame = CGRectMake(self.view.frame.size.width/2 - applicationLogo.frame.size.width/2,
                                       self.view.frame.size.height - 40/*self.view.frame.size.height - applicationLogo.frame.size.height - topBuffer*/,
                                       applicationLogo.frame.size.width,
                                       applicationLogo.frame.size.height);
    
    ///[[self applicationLogo] setImage:[NSImage imageNamed:@"icon"]];
    
    //-------------------------------------------------------------------------
    //Title text
    //-------------------------------------------------------------------------
    titleTextField.frame = CGRectMake(self.view.frame.origin.x,
                                      applicationLogo.frame.origin.y - 80,
                                      self.view.frame.size.width,
                                      150);
    
    NSString *titleText = @"PlayMe";
    [titleTextField setStringValue:titleText];
    
    //-------------------------------------------------------------------------
    //Version text
    //-------------------------------------------------------------------------
    versionTextField.frame = CGRectMake(self.view.frame.origin.x,
                                      titleTextField.frame.origin.y + 30,
                                      self.view.frame.size.width,
                                      20);
    
    NSString *versionText = @"          Version 0.5";

    NSString *version = [NSString stringWithFormat:@"%@", versionText];
    [versionTextField setStringValue:version];

    //-------------------------------------------------------------------------
    //Company Logo
    //-------------------------------------------------------------------------
    companyLogo.frame = CGRectMake(self.view.frame.size.width/2 - companyLogo.frame.size.width/2,
                                          titleTextField.frame.origin.y - companyLogo.frame.size.height - 135
                                        /*versionTextField.frame.origin.y - companyLogo.frame.size.height - 10*/,
                                          companyLogo.frame.size.width,
                                          companyLogo.frame.size.height);
    
    [companyLogo setImage:[NSImage imageNamed:@"companyLogo"]];
    
    //-------------------------------------------------------------------------
    //Copyright text
    //-------------------------------------------------------------------------
    copyrightTextField.frame = CGRectMake(self.view.frame.origin.x,
                                        companyLogo.frame.origin.y - 20,
                                        self.view.frame.size.width,
                                        20);
    
    NSString *copyrightText = @"Copyright 2014";
    NSString *copyright = [NSString stringWithFormat:@"%@", copyrightText];
    [copyrightTextField setStringValue:copyright];
    
    //-------------------------------------------------------------------------
    //Website button
    //-------------------------------------------------------------------------
    websiteButton.frame = CGRectMake(self.view.frame.size.width/2 - websiteButton.frame.size.width/2,
                                     0,
                                     websiteButton.frame.size.width,
                                     websiteButton.frame.size.height);
}

- (IBAction)openMyWebsite:(id)sender
{
    [self updateWidowElements];
    ///[[NSWorkspace sharedWorkspace] openURL: [NSURL URLWithString:@"http://about.me/tomcraig/"]];
}
@end
