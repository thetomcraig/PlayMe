#import "MASPreferencesViewController.h"

@interface AboutViewController : NSViewController <MASPreferencesViewController>

@property (nonatomic, retain) NSMutableAttributedString *aboutTextString;

@property (strong) IBOutlet NSImageView *backdrop;
@property (strong) IBOutlet NSImageView *applicationLogo;
@property (strong) IBOutlet NSTextField *titleTextField;
@property (strong) IBOutlet NSTextField *versionTextField;
@property (strong) IBOutlet NSImageView *companyLogo;
@property (strong) IBOutlet NSTextField *copyrightTextField;

@property (strong) IBOutlet NSButton *websiteButton;

-(void)updateWidowElements;

- (IBAction)openMyWebsite:(id)sender;

@end
