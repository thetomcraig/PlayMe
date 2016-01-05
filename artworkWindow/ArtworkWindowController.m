#import "ArtworkWindowController.h"

#define ARTWORK_WIDTH 400
#define ARTWORK_HEIGHT 400
#define WINDOW_HEIGHT 475


@implementation ArtworkWindowController

@synthesize topArrow;
@synthesize menuButtonMenu;
@synthesize preferences;
@synthesize openIniTunes;
@synthesize quitApp;

//These all hold iTunes information for assigning
//to window elements at the right time
@synthesize currentSongState;
@synthesize currentArtistAndAlbumState;
@synthesize currentStatusState;
@synthesize currentButtonNameState;
@synthesize currentAltButtonNameState;
@synthesize currentArtworkState;
@synthesize currentProgressState;
@synthesize currentLengthState;
@synthesize currentTimeLeftState;

@synthesize artworkView;
@synthesize currentArtwork;

@synthesize currentSong;
@synthesize currentArtistAndAlbum;


@synthesize songSlider;
@synthesize songSliderCell;
@synthesize songTimeLeft;

@synthesize buttonsBackdrop;
@synthesize playPauseButton;
@synthesize playPauseButtonOverlay;
@synthesize playPauseButtonCell;
@synthesize nextButton;
@synthesize nextButtonCell;
@synthesize previousButton;
@synthesize previousButtonCell;
@synthesize trackingArea;

#
#pragma mark - Setup methods
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
        topArrow = [NSImage imageNamed:@"bgTopArrow"];
        
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
    
    [self assignStateVariables];
    
    [playPauseButton setBordered:NO];
    [nextButton setBordered:NO];
    [previousButton setBordered:NO];

    [self mouseExited:nil];
    
    [nextButton setImage:[NSImage imageNamed:@"NextButton"]];
    [nextButton setAlternateImage:[NSImage imageNamed:@"NextButtonDepressed"]];
    [previousButton setImage:[NSImage imageNamed:@"PreviousButton"]];
    [previousButton setAlternateImage:[NSImage imageNamed:@"PreviousButtonDepressed"]];
    
    NSColor *backgroundColor =
    [NSColor colorWithCalibratedRed:0.92 green:0.92 blue:0.92 alpha:1.0];
    NSColor *primaryColor =
    [NSColor colorWithCalibratedRed:0.20 green:0.20 blue:0.20 alpha:1.0];
    
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
    if ([[self window] isKeyWindow])
    {
        [[self window] close];
    }
    
    //Otherwise its closed, so open it
    else
    {
        [self positionAndOpenWindow:note];
        //After it's opened, position the window elementt properly
        [self updateWindowGeometry];
    }
}

//##############################################################################
//Positions the window to in the center of the menubar icon, which is stationary
//##############################################################################
- (void)positionAndOpenWindow:(NSNotification *)note
{
     NSString *imageRectString = [note.userInfo objectForKey:@"ImagePoint"];
     //Need to get the position of where the window should open
     NSRect statusRect = NSRectFromString(imageRectString);

    //Need to get the position of where the window should open
    statusRect.origin.y = NSMinY(statusRect) - NSHeight(statusRect);
    //Move the window to under here
    NSRect windowRect = [[self window] frame];
    windowRect.origin.x = roundf(NSMidX(statusRect) - NSWidth(windowRect)/2);
    windowRect.origin.y = NSMaxY(statusRect) - NSHeight(windowRect);
    [[self window] setFrame:windowRect display:YES];

    [self fixForDangerZones];

    //Clear notifications from the screen,
    [[NSUserNotificationCenter defaultUserNotificationCenter]
    removeAllDeliveredNotifications];

    //Telling the window where to open using ths corresponding string
    //Display the window
    [NSApp activateIgnoringOtherApps:YES];
    [[self window] makeKeyAndOrderFront:self];
    [[self window] setLevel:kCGFloatingWindowLevel];
    [[self window] setHidesOnDeactivate:YES];
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
    //This puts the artwork just below the top arrow
    NSRect tempFrame = NSMakeRect(0.0, 0.0, 0.0, 0.0);
    tempFrame.size.width = ARTWORK_WIDTH;
    tempFrame.size.height = ARTWORK_HEIGHT;
    tempFrame.origin.y = [self window].frame.size.height -
    tempFrame.size.height -
    topArrow.size.height;
    
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
    //Making sure that the slider is the same height as the knob,
    //so it is seemless
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
    
    //Using the edge buffer in both dimensions because we want the art to be the
    //same distance in x and y from the bottom of the art
    //Note: NOT the same as being in line with the botton of the button images,
    //that would look weird
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
//Updating all the onscreen window elements.  This method sets all of the
//"-state" variables which are set to the onscreen elements in the
//"assignStateVariables" method
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
    //Set the song, but if it's PlayMe, then nothing is playing, so we want to
    //zero this out, it needs to have at least one character to be set, so it is
    //a space.
    currentSongState = currentSongInp;

    if ([currentArtistInp isEqualToString:@" "])
    {
        currentArtistAndAlbumState = @"";
    } else
    {
        NSString *combinedString =
        [NSString stringWithFormat:@"%@ - %@",
         currentArtistInp,
         currentAlbumInp];
        currentArtistAndAlbumState = combinedString;
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
    currentButtonNameState = nameOfButton;
    currentAltButtonNameState = nameOfAltButton;
    
    //--------------------------------------------------------------------------
    //Updating the artwork.
    //If there was NO artwork, we put in the black artwork image
    //--------------------------------------------------------------------------
    currentArtworkState = currentArtworkInp;
    
    //--------------------------------------------------------------------------
    //Timing
    //--------------------------------------------------------------------------
    currentProgressState = currentProgressInp;
    currentLengthState = currentLengthInp;
    
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
    
    currentTimeLeftState = timeLeft;
    
    //--------------------------------------------------------------------------
    //Assign all thse state variables
    //--------------------------------------------------------------------------
    [self assignStateVariables];
}

//##############################################################################
//This assigns all the state variables to the window elements.  Called at the
//end of the updateWindowElements method, but also in the windowDidLoad method
//this allows the variables to be assigned when iTunes is paused.
//##############################################################################
- (void)assignStateVariables
{
    [currentSong setStringValue:currentSongState];
    
    [currentArtistAndAlbum setStringValue:currentArtistAndAlbumState];
    
    [currentArtwork setImage: currentArtworkState];

    [playPauseButton setImage:[NSImage imageNamed:currentButtonNameState]];
    [playPauseButton setAlternateImage:[NSImage imageNamed:currentAltButtonNameState]];
    
    [songSlider setDoubleValue: [currentProgressState doubleValue]];
    [songSlider setMaxValue: [currentLengthState doubleValue]];
    
    [songTimeLeft setStringValue: currentTimeLeftState];
}

//##############################################################################
//This method makes sure the window doesnt fall off the edge of the screen.
//It has to check the top LEFT side of the window because there could be mutli
//-ple screens.  If the window is falling off the right side of the screen,
//this method moves it over to the right edge.
//##############################################################################
- (BOOL)fixForDangerZones
{
    BOOL hadToReposition = false;
    
    double rightBuffer = topArrow.size.height;
    
    struct DangerZone
    {
        double lowerBound;
        double upperBound;
    };
    
    
    //Finding the origin
    CGPoint origin = [[self window] frame].origin;
    //The size of the window we want to open
    CGSize windowSize = [self window].frame.size;
    //Getting the position for the window
    CGPoint windowTopLeftPosition =
            CGPointMake(origin.x, origin.y + [[self window] frame].size.height);
    
    //-------------------------------------------------------------------------
    //Checking to make sure it is not hanging off the screen
    //This block sets up an array of "danger zones" which are bounds of x
    //positions.  If the left position of the window is between the higher and
    //lower numbers of any of the danger zones in the array, we know that window
    //will be hanging off the edge of one of the screens.  This means we have
    //to reposition the window so it is just on the right edge of the screen
    //-------------------------------------------------------------------------
    //Creating the danger zones
    NSArray *screens = [NSScreen screens];
    struct DangerZone dangerZones[[screens count]];
    for (int i = 0; i < [screens count]; i++)
    {
        struct DangerZone dangerZone;
        double rightEdge = [screens[i] frame].origin.x + [screens[i] frame].size.width;
        dangerZone.lowerBound = rightEdge - [self window].frame.size.width - rightBuffer;
        dangerZone.upperBound = rightEdge - [self window].frame.size.width/2 + rightBuffer;
        dangerZones[i] = dangerZone;
    }
    
    //-------------------------------------------------------------------------
    //Now, checking the topLeftPosition against all the danger zones.  This
    //could probably be put in with the above code but it is seperated for
    //clarity and because I may want to recalculate the window positions
    //differently at a later time
    //-------------------------------------------------------------------------
    //This has to start as zero, (arrow in the middle = 0)
    double arrowLocation = 0;
    
    for (int i = 0; i < [screens count]; i++)
    {
        //If this gets hit, the point is in the danger zone!
        if ((dangerZones[i].lowerBound < windowTopLeftPosition.x) &&
            (windowTopLeftPosition.x < dangerZones[i].upperBound))
        {
            //Here, we reset the arrow location
            double postionOfRightSideOfWindow = windowTopLeftPosition.x + [self window].frame.size.width;
            double xPositionOfRightSideOfScreen = [screens[i] frame].origin.x + [screens[i] frame].size.width;
            arrowLocation = (postionOfRightSideOfWindow - xPositionOfRightSideOfScreen) + rightBuffer;
            
            //Here, we reset the window location
            windowTopLeftPosition.x = dangerZones[i].lowerBound - rightBuffer;
            
            hadToReposition = true;
        }
    }
    
    //-------------------------------------------------------------------------
    //Finally, Setting the window position and arrow location
    //-------------------------------------------------------------------------
    [[self window] setFrameTopLeftPoint:windowTopLeftPosition];
    
    return hadToReposition;
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
