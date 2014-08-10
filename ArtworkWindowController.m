#import "ArtworkWindowController.h"

#define ARTWORK_WIDTH 400
#define ARTWORK_HEIGHT 400
#define WINDOW_HEIGHT 500


@implementation ArtworkWindowController

@synthesize menuButtonMenu;
@synthesize preferences;
@synthesize openIniTunes;
@synthesize quitApp;

@synthesize artworkView;
@synthesize currentArtwork;
@synthesize currentSong;
@synthesize currentArtistAndAlbum;
@synthesize currentLyrics;

@synthesize songSlider;
@synthesize songSliderCell;
@synthesize songTimeLeft;

@synthesize buttonsBackdrop;
@synthesize playPauseButton;
@synthesize playPauseButtonCell;
@synthesize nextButton;
@synthesize nextButtonCell;
@synthesize previousButton;
@synthesize previousButtonCell;
@synthesize trackingArea;

#
#pragma mark - Setup mehods
#
//##############################################################################
//The init method makes sure we observer notificatinos from the iTunesContrller
//and from the menuBarController
//##############################################################################
- (id)initWithWindowNibName:(NSString *)windowNibName
{
    self = [super initWithWindowNibName:windowNibName];
    if (self)
    {
        [[NSNotificationCenter defaultCenter]
                             addObserver:self
                             selector:@selector(receivedTagsNotification:)
                             name:@"TagsNotification"
                             object:nil];
        [[NSNotificationCenter defaultCenter]
                             addObserver:self
                             selector:@selector(receivedMouseDownNotification:)
                             name:@"MouseDownNotification"
                             object:nil];
    }
    return self;
}

//##############################################################################
//We call the mouseExited function to make sure the buttons are hidden when
//the window opens.
//We call updateWindowElements to position everything else.
//##############################################################################
-(void)windowDidLoad
{
    [super windowDidLoad];
    
    [playPauseButton setBordered:NO];
    [nextButton setBordered:NO];
    [previousButton setBordered:NO];

    [self mouseExited:nil];
    
    [nextButton setImage:[NSImage imageNamed:@"NextButton"]];
    [nextButton setAlternateImage:[NSImage imageNamed:@"NextButtonDepressed"]];
    [previousButton setImage:[NSImage imageNamed:@"PreviousButton"]];
    [previousButton setAlternateImage:[NSImage imageNamed:@"PreviousButtonDepressed"]];
    
    NSColor *backgroundColor =
    [NSColor colorWithCalibratedRed:0.9 green:0.9 blue:0.9 alpha:1.0];
    NSColor *primaryColor =
    [NSColor colorWithCalibratedRed:0.30 green:0.30 blue:0.30 alpha:1.0];
    
    currentSong.textColor = primaryColor;
    currentArtistAndAlbum.textColor = primaryColor;
    
    [artworkView setBackgroundColor: backgroundColor];
    [buttonsBackdrop setBackgroundColor: backgroundColor];
    [buttonsBackdrop setBackgroundColor: backgroundColor];
    [nextButtonCell setButtonsColor: primaryColor];
    [playPauseButtonCell setButtonsColor: primaryColor];
    [previousButtonCell setButtonsColor: primaryColor];

    [songSlider setBackgroundColor: backgroundColor];
    [songSliderCell setBackgroundColor: backgroundColor];
    [songSliderCell setProgressColor: primaryColor];
    songTimeLeft.textColor = primaryColor;
    
}


#
#pragma mark - Receiving notifications
#
//##############################################################################
//Message to update sent from the iTunesController, with a notification that has
//tag information.  Calls the updating window elements method
//##############################################################################
- (void)receivedTagsNotification:(NSNotification *)note
{
    [self updateWindowElements:[note.userInfo objectForKey:@"CurrentSong"]
                              :[note.userInfo objectForKey:@"CurrentArtist"]
                              :[note.userInfo objectForKey:@"CurrentAlbum"]
                              :[note.userInfo objectForKey:@"CurrentStatus"]
                              :[note.userInfo objectForKey:@"CurrentArtwork"]
                              :[note.userInfo objectForKey:@"CurrentProgress"]
                              :[note.userInfo objectForKey:@"CurrentLength"]];
}

//##############################################################################
//Opening and closing the window with the menubar icon is clicked.
//##############################################################################
- (void)receivedMouseDownNotification:(NSNotification *)note
{
    //If the window is open, close it
    if ([[self window] isVisible])
    {
        [[self window] close];
    }
    
    //Otherwise its closed, so open it
    else
    {
        //Telling the window where to open using ths corresponding string
        [self positionAndOpenWindow:[note.userInfo objectForKey:@"GlobalRect"]];
        //After it's opened, position the window elementt properly
        [self updateWindowGeometry];
    }
}

//##############################################################################
//This makes sure the labels and progess bar just below the artwork.
//The bottomOfArtBuffer is the distance from the bottom of the artwork to the
//progress bar.  The leftEdgeBuffer is how far the labels are from the left
//side of the window.  The controlButtons buffers are used to position the
//control buttons.  Also updates the tracking area w/ artwork size
//##############################################################################
- (void)updateWindowGeometry
{
    NSImage *bgTopArrow = [NSImage imageNamed:@"bgTopArrow"];
    
    //This puts the artwork just below the top arrow
    NSRect tempFrame = NSMakeRect(0.0, 0.0, 0.0, 0.0);
    tempFrame.size.width = ARTWORK_WIDTH;
    tempFrame.size.height = ARTWORK_HEIGHT;
    tempFrame.origin.y = [self window].frame.size.height -
    tempFrame.size.height -
    bgTopArrow.size.height;
    
    [currentArtwork setFrame:tempFrame];
    
    //--------------------------------------------------------------------------
    //Finding all the buffers for positioning
    //--------------------------------------------------------------------------
    //The distance of the the elements from the edge of the window, and one
    //another.  This buffer is the only constant value
    int smallBuffer = 3;
    int bottomOfArt = [currentArtwork frame].origin.y;
    //Buffer in a third the button's height, for making them equidistant
    int controlButtonsSideBufer = playPauseButton.frame.size.width/4;
    //Buffer for the menu and close buttons
    //Buffer in a fifth the button's height
    int controlButtonsTopBuffer = playPauseButton.frame.size.width/5;
    //Height of the knob (and bar) for positioning
    int sliderBuffer = [songSliderCell knobRectFlipped:NO].size.height;
    //Finding the height of the actual text in the label
    NSDictionary *songAttributes = [NSDictionary
                                    dictionaryWithObjectsAndKeys:currentSong.font,
                                    NSFontAttributeName, nil];
    CGFloat fontHeight = [[currentSong stringValue] sizeWithAttributes:songAttributes].height;
    
    //--------------------------------------------------------------------------
    //Repositioning everything
    //--------------------------------------------------------------------------
    //Making sure that the slider is the same height as the knob, so it is seemless
    songSlider.frame = CGRectMake(-[songSliderCell knobRectFlipped:NO].size.width/2, bottomOfArt - sliderBuffer,
                                  ARTWORK_WIDTH + [songSliderCell knobRectFlipped:NO].size.width,
                                  sliderBuffer);
    
    //Buttons seperated by half their width
    int bottomOfBar = [songSlider frame].origin.y;
    
    currentSong.frame = CGRectMake(smallBuffer, bottomOfBar - currentSong.frame.size.height - smallBuffer,
                                   ARTWORK_WIDTH - smallBuffer*2,
                                   fontHeight);
    currentArtistAndAlbum.frame = CGRectMake(smallBuffer, currentSong.frame.origin.y - fontHeight - smallBuffer,
                                             ARTWORK_WIDTH - smallBuffer*2,
                                             fontHeight + smallBuffer);
    //Buttons
    buttonsBackdrop.frame = CGRectMake(currentArtwork.frame.origin.x,
                                       currentArtwork.frame.origin.y,
                                       [currentArtwork frame].size.width,
                                       [playPauseButton frame].size.height + controlButtonsTopBuffer*2);
    //Put this button in the middle
    playPauseButton.frame = CGRectMake(currentArtwork.frame.size.width/2 - [playPauseButton frame].size.width/2,
                                       bottomOfArt + controlButtonsTopBuffer,
                                       [playPauseButton frame].size.width,
                                       [playPauseButton frame].size.height);
    nextButton.frame = CGRectMake(playPauseButton.frame.origin.x + playPauseButton.frame.size.width + controlButtonsSideBufer,
                                  bottomOfArt + controlButtonsTopBuffer,
                                  [nextButton frame].size.width,
                                  [nextButton frame].size.height);
    previousButton.frame = CGRectMake(playPauseButton.frame.origin.x - playPauseButton.frame.size.width - controlButtonsSideBufer,
                                      bottomOfArt + controlButtonsTopBuffer,
                                      [previousButton frame].size.width,
                                      [previousButton frame].size.height);
    
    //Using the edge buffer in both dimensions because we want the art to be the same distance in x and y from the bottom of the art
    //Note: NOT the same as being in line with the botton of the button images, that would look weird
    NSDictionary *attributes = [NSDictionary
                                dictionaryWithObjectsAndKeys:currentSong.font,
                                NSFontAttributeName, nil];
    CGFloat exactBoxWidth = [songTimeLeft.stringValue sizeWithAttributes:attributes].width;
    //Resize
    songTimeLeft.frame = CGRectMake([songTimeLeft frame].origin.x,
                                    [songTimeLeft frame].origin.y,
                                    exactBoxWidth + smallBuffer*1.5,
                                    [songTimeLeft frame].size.height);
    
    //Reposition
    songTimeLeft.frame = CGRectMake(ARTWORK_WIDTH - songTimeLeft.frame.size.width,
                                    buttonsBackdrop.frame.origin.y + smallBuffer,
                                    [songTimeLeft frame].size.width - smallBuffer,
                                    [songTimeLeft frame].size.height);
    
    //--------------------------------------------------------------------------
    //Tracking areas
    //--------------------------------------------------------------------------
    if(trackingArea != nil)
    {
        [artworkView removeTrackingArea:trackingArea];
    }
    
    int opts = (NSTrackingMouseEnteredAndExited | NSTrackingActiveAlways);
    trackingArea = [ [NSTrackingArea alloc] initWithRect:currentArtwork.frame
                                                 options:opts
                                                   owner:self
                                                userInfo:nil];
    [artworkView addTrackingArea:trackingArea];
}

//##############################################################################
//Updating all the onscreen window elements.
//##############################################################################
- (void)updateWindowElements:(NSString *) currentSongInp
                            :(NSString *) currentArtistInp
                            :(NSString *) currentAlbumInp
                            :(NSString *) currentStatusInp
                            :(NSImage *) currentArtworkInp
                            :(NSNumber *) currentProgressInp
                            :(NSNumber *) currentLengthInp
{
    //--------------------------------------------------------------------------
    //Updating the labels with the song name, artist and album name.
    //It calls the trimString method to make sure they're clipped properly
    //--------------------------------------------------------------------------
    [currentSong setStringValue:currentSongInp];
    
    if ([currentArtistInp isEqualToString:@""])
    {
        [currentArtistAndAlbum setStringValue:@""];
    } else
    {
        NSString *combinedString =
        [NSString stringWithFormat:@"%@ - %@",
         currentArtistInp,
         currentAlbumInp];
        
        [currentArtistAndAlbum setStringValue: combinedString];
    }
    
    //--------------------------------------------------------------------------
    //Updating the control buttons
    //--------------------------------------------------------------------------
    NSString *nameOfButton = @"PlayButton";
    
    if ([currentStatusInp
         isEqualToString:@"Paused"] ||
        [currentStatusInp
         isEqualToString:@"Stopped"])
    {
        nameOfButton = @"PlayButton";
    }
    else if ([currentStatusInp
              isEqualToString:@"Playing"])
    {
        nameOfButton = @"PausedButton";
    }
    
    NSString *nameOfAltButton = [NSString stringWithFormat:@"%@%@",
                                 nameOfButton,
                                 @"Depressed"];
    
    //Actually assigning the button resource image
    [playPauseButton setImage:[NSImage imageNamed:nameOfButton]];
    [playPauseButton setAlternateImage:[NSImage imageNamed:nameOfAltButton]];
    
    //--------------------------------------------------------------------------
    //Updating the artwork.
    //If there was NO artwork, we put in the black artwork image
    //--------------------------------------------------------------------------
    [currentArtwork setImage:currentArtworkInp];
    
    //--------------------------------------------------------------------------
    //Timing - sliders
    //--------------------------------------------------------------------------
    //Sliders - have to use NSNumbers forth notification, so we make them into
    //doubles here
    [songSlider setDoubleValue:
     [currentProgressInp doubleValue]];
    [songSlider setMaxValue:
    [currentLengthInp doubleValue]];
    
    //--------------------------------------------------------------------------
    //Timing - countdown label
    //--------------------------------------------------------------------------
    double totalSecsLeft =
    ([currentLengthInp doubleValue] - [currentProgressInp doubleValue]);
    int numMinsLeft = (floor(totalSecsLeft/60));
    int numSecsLeft = (totalSecsLeft - numMinsLeft*60);
    
    //It needlessly showes 60's so we can just replace it
    if (numSecsLeft == 60)
    {
        numMinsLeft = 0;
        numSecsLeft = 0;
    }
    
    NSString *timeLeft = [NSString stringWithFormat:@"-%i:%02d",
                          numMinsLeft,
                          numSecsLeft];
    
    [songTimeLeft setStringValue:timeLeft];
}

//##############################################################################
//This method calculates where to open the window using the gllobal rect
//supplied by the nsstatusitem.  It does screen edge detection and slide the
//window over appropriately
//##############################################################################
- (void)positionAndOpenWindow: (NSString *)globalRect
{
    //Clear notifications from the screen,
    [[NSUserNotificationCenter defaultUserNotificationCenter]
     removeAllDeliveredNotifications];
    
    [[self window] display];
    
    struct DangerZone
    {
        double lowerBound;
        double upperBound;
    };
    
    //Need to get the position of where the window should open
    CGRect statusRect =
    NSRectFromString(globalRect);
    statusRect.origin.y = NSMinY(statusRect) - NSHeight(statusRect);
    //Move the window to under here
    NSRect windowRect = [[self window] frame];
    windowRect.origin.x = roundf(NSMidX(statusRect) - NSWidth(windowRect)/2);
    windowRect.origin.y = NSMaxY(statusRect) - NSHeight(windowRect);
    [[self window] setFrame:windowRect display:YES];
    
    //Display the window
    [[self window] makeKeyAndOrderFront:self];
    [[self window] setLevel:kCGFloatingWindowLevel];
    [NSApp activateIgnoringOtherApps:YES];
}

#
#pragma mark - Sending Notifications (IBActions)
#
//##############################################################################
//This action taken out by the play/pause button, pauses and plays iTunes
//accordingly
//##############################################################################
- (IBAction)playpause:(id)sender
{
    NSDictionary *commandNotification =
    @{
      @"Command": @"PlayPause"
      };
    
    [[NSNotificationCenter defaultCenter]
                                     postNotificationName:@"commandNotification"
                                     object:self
                                     userInfo:commandNotification];
}

//##############################################################################
//This action taken out by the next button, going to the next song
//##############################################################################
- (IBAction)next:(id)sender
{
    NSDictionary *commandNotification =
    @{
      @"Command": @"NextTrack"
      };
    
    [[NSNotificationCenter defaultCenter]
                                     postNotificationName:@"commandNotification"
                                     object:self
                                     userInfo:commandNotification];
}

//##############################################################################
//This action taken out by the previous button, going to the previous song.
//If the song has progressed past the threshold, it instead skips to the be-
//geinning of the current song
//##############################################################################
-(IBAction)previous:(id)sender
{
    NSDictionary *commandNotification =
    @{
      @"Command": @"PreviousTrack"
      };

    
    //If a few second into a song, skip to its beginning
    //instead of actually going to the previous song.
    double goToPreviousThreshold = 2.0;
     if ([songSlider doubleValue] > goToPreviousThreshold)
     {
         commandNotification =
         @{
             @"Command": @"SetPosition",
             @"Position" : [NSNumber numberWithDouble: 0.0]
             };
     }
    
    [[NSNotificationCenter defaultCenter]
                                     postNotificationName:@"commandNotification"
                                     object:self
                                     userInfo:commandNotification];
}

//##############################################################################
//When the slier is mutated, this method is called, and it send a notification
//to the iTunesController object, with the actual value of the slider, so it can
//tell iTunes to move there.
//##############################################################################
- (IBAction)sliderDidMove:(id)sender
{
    NSDictionary *commandNotification =
    @{
      @"Command": @"SetPosition",
      @"Position": [NSNumber numberWithDouble: [songSlider doubleValue]]
      };
    
    [[NSNotificationCenter defaultCenter]
     postNotificationName:@"commandNotification"
     object:self
     userInfo:commandNotification];
}

#
#pragma mark - Utilities
#
//##############################################################################
//Triggered when the cursor is hovering over the artwork
//##############################################################################
-(void)mouseEntered:(NSEvent *)theEvent
{
     [buttonsBackdrop setHidden:NO];
     playPauseButton.hidden = NO;
     nextButton.hidden = NO;
     previousButton.hidden = NO;
     [songTimeLeft setHidden:NO];
}

//##############################################################################
//Triggered when the cursor stops hovering over the artwork
//##############################################################################
-(void)mouseExited:(NSEvent *)theEvent
{
    [buttonsBackdrop setHidden:YES];
    playPauseButton.hidden = YES;
    nextButton.hidden = YES;
    previousButton.hidden = YES;
    [songTimeLeft setHidden:YES];
}
@end
