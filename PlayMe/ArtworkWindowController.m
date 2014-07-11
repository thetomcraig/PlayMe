#define LARGE_WIDTH 400
#define LARGE_HEIGHT 800
#define SMALL_BUFFER 15
//For this class, artwork sizes
#define LARGE_ARTWORK_WIDTH 400
#define LARGE_ARTWORK_HEIGHT 400
#define NSFloatingWindowLevel kCGFloatingWindowLevel

#import "ArtworkWindowController.h"

@implementation ArtworkWindowController

@synthesize artworkWindow =  _artworkWindow;

@synthesize menuButtonMenu;
@synthesize preferences;
@synthesize openIniTunes;
@synthesize quitApp;

@synthesize currentArtwork;
@synthesize currentSong;
@synthesize currentArtistAndAlbum;
@synthesize currentLyrics;

@synthesize songTimeLeft;
@synthesize songSlider;
@synthesize songSliderCell;

@synthesize buttonsBackdrop;
@synthesize playPauseButton;
@synthesize playPauseButtonCell;
@synthesize nextButton;
@synthesize nextButtonCell;
@synthesize previousButton;
@synthesize previousButtonCell;
@synthesize trackingArea;

//##############################################################################
//We initialize with the nib that has everything on it
//The iTunesController gives us access to iTunes info
//We set the defualt colors here, which are black and white.  If it gets
//opened before the color algorithm is done, it can just show black and white.
//##############################################################################
- (id)init
{
    self = [super initWithWindowNibName:@"ArtworkWindowController"];
    
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
    return self;
}

//##############################################################################
//After the window has loaded, we make sure everything is aligned
//The artwork is positioned just below the top arrow.  We call the mouseExited
//function to make sure the buttons are hidden when the window opens.
//We call updateWindowElements to position everything else.
//The observers atthe top are for the color algorithm; they are called when
//the algorithm comes up woith new colors or times out
//##############################################################################
-(void)windowDidLoad
{
    [super windowDidLoad];
    
    NSRect artworkFrame = currentArtwork.frame;
    NSImage *bgTopArrow = [NSImage imageNamed:@"bgTopArrow"];
    artworkFrame.origin.y = self.window.frame.size.height -
    currentArtwork.frame.size.height - bgTopArrow.size.height;
    [currentArtwork setFrame:artworkFrame];
    
    preferences = [[NSMenuItem alloc] initWithTitle:@"Preferences..."
                                             action:@selector(showPreferences:)
                                      keyEquivalent:@""];
    openIniTunes = [[NSMenuItem alloc] initWithTitle:@"Go to song in iTunes"
                                              action:@selector(openIniTunes:)
                                       keyEquivalent:@""];
    quitApp = [[NSMenuItem alloc] initWithTitle:@"Quit PlayMe"
                                         action:@selector(quitPlayMe:)
                                  keyEquivalent:@""];

    [playPauseButton setBordered:NO];
    [nextButton setBordered:NO];
    [previousButton setBordered:NO];

    //Hiding this because I have not implemented it yet
    [currentLyrics setHidden:YES];
    
    [self mouseExited:nil];
    [self updateColors];
}


//##############################################################################
//Setting up the colors of the UI elements
//##############################################################################
-(void)updateColors
{
    NSColor *backgroundColor =
        [NSColor colorWithCalibratedRed:0.9 green:0.9 blue:0.9 alpha:1.0];
    NSColor *primaryColor =
        [NSColor colorWithCalibratedRed:0.30 green:0.30 blue:0.30 alpha:1.0];

    _artworkWindow.artworkView.backgroundColor = backgroundColor;
    _artworkWindow.artworkView.arrowColor = backgroundColor;
    songSlider.backgroundColor = backgroundColor;
    songSliderCell.backgroundColor = backgroundColor;
    buttonsBackdrop.mainColor = backgroundColor;
    
    currentSong.textColor = primaryColor;
    currentArtistAndAlbum.textColor = primaryColor;
    
    songTimeLeft.textColor = primaryColor;
    nextButtonCell.buttonsColor = primaryColor;
    playPauseButtonCell.buttonsColor = primaryColor;
    previousButtonCell.buttonsColor = primaryColor;
    songSliderCell.progressColor = primaryColor;
    
    [nextButton setImage:[NSImage imageNamed:@"NextButton"]];
    [nextButton setAlternateImage:[NSImage imageNamed:@"NextButtonDepressed"]];
    [previousButton setImage:[NSImage imageNamed:@"PreviousButton"]];
    [previousButton setAlternateImage:[NSImage imageNamed:@"PreviousButtonDepressed"]];
}

#
#pragma mark - Receiving notifications
#
//##############################################################################
//Message to update sent from the iTunesController, with a notification that has
//tag information.
//##############################################################################
- (void)receivedTagsNotification:(NSNotification *)note
{
    //--------------------------------------------------------------------------
    //Updating the labels with the song name, artist and album name.
    //It calls the trimString method to make sure they're clipped properly
    //--------------------------------------------------------------------------
    [currentSong setStringValue:[note.userInfo objectForKey:@"CurrentSong"]];

    if ([[note.userInfo objectForKey:@"CurrentArtist"] isEqualToString:@""])
    {
        [currentArtistAndAlbum setStringValue:@""];
    } else
    {
        NSString *combinedString =
                                [NSString stringWithFormat:@"%@ - %@",
                                [note.userInfo objectForKey:@"CurrentArtist"],
                                [note.userInfo objectForKey:@"CurrentAlbum"]];
        
        [currentArtistAndAlbum setStringValue: combinedString];
    }

    //--------------------------------------------------------------------------
    //Updating the control buttons
    //--------------------------------------------------------------------------
    NSString *nameOfButton = @"PlayButton";
    
    if ([[note.userInfo objectForKey:@"CurrentStatus"]
         isEqualToString:@"Paused"] ||
        [[note.userInfo objectForKey:@"CurrentStatus"]
        isEqualToString:@"Stopped"])
     {
         nameOfButton = @"PlayButton";
     }
     else if ([[note.userInfo objectForKey:@"CurrentStatus"]
               isEqualToString:@"Playing"])
     {
         nameOfButton = @"PausedButton";
     }
    
    NSString *nameOfAltButton = [NSString stringWithFormat:@"%@%@",
                                 nameOfButton,
                                 @"ButtonDepressed"];
    //Actually assigning the button resource image
    [playPauseButton setImage:[NSImage imageNamed:nameOfButton]];
    [playPauseButton setAlternateImage:[NSImage imageNamed:nameOfAltButton]];
    
    //--------------------------------------------------------------------------
    //Updating the artwork.
    //If there was NO artwork, we put in the black artwork image
    //--------------------------------------------------------------------------
    [currentArtwork setImage:[note.userInfo objectForKey:@"CurrentArtwork"]];

    //--------------------------------------------------------------------------
    //Timing - sliders
    //--------------------------------------------------------------------------
    //Sliders - have to use NSNumbers forth notification, so we make them into
    //doubles here
     [songSlider setDoubleValue:
                [[note.userInfo objectForKey:@"CurrentProgress"] doubleValue]];
     [songSlider setMaxValue:
                [[note.userInfo objectForKey:@"CurrentLength"] doubleValue]];
    
    //--------------------------------------------------------------------------
    //Timing - countdown label
    //--------------------------------------------------------------------------
    double totalSecsLeft =
        ([[note.userInfo objectForKey:@"CurrentLength"] doubleValue] -
         [[note.userInfo objectForKey:@"CurrentProgress"] doubleValue]);
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
    
    //--------------------------------------------------------------------------
    //Other updates
    //--------------------------------------------------------------------------
    [self updateColors];
}

//##############################################################################
//This makes sure the labels and progess bar just below the artwork.
//The bottomOfArtBuffer is the distance from the bottom of the artwork to the
//progress bar.  The leftEdgeBuffer is how far the labels are from the left
//side of the window.  The controlButtons buffers are used to position the
//control buttons.  Also updates the tracking area w/ artwork size
//##############################################################################
-(void)updateWindowElements
{
    //-------------------------------------------------------------------------
    //Finding all the buffers for positioning
    //-------------------------------------------------------------------------
    //The distance of the the elements from the edge of the window, and one another
    //This buffer is the only constant value
    int smallBuffer = 4;
    int bottomOfArt = [currentArtwork frame].origin.y;
    //Buttons seperated by half their width
    int bottomOfBar = [songSlider frame].origin.y;
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
    
    //-------------------------------------------------------------------------
    //Repositioning everything
    //-------------------------------------------------------------------------
    //Making sure that the slider is the same height as the knob, so it is seemless
    songSlider.frame = CGRectMake(-[songSliderCell knobRectFlipped:NO].size.width/2, bottomOfArt - sliderBuffer,
                                  [_artworkWindow.artworkView frame].size.width + [songSliderCell knobRectFlipped:NO].size.width,
                                  sliderBuffer);
    currentSong.frame = CGRectMake(smallBuffer, bottomOfBar - currentSong.frame.size.height - smallBuffer,
                                   [_artworkWindow.artworkView frame].size.width - smallBuffer*2,
                                   fontHeight);
    currentArtistAndAlbum.frame = CGRectMake(smallBuffer, currentSong.frame.origin.y - fontHeight - smallBuffer,
                                             [_artworkWindow.artworkView frame].size.width - smallBuffer*2,
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
    songTimeLeft.frame = CGRectMake(_artworkWindow.artworkView.frame.size.width - songTimeLeft.frame.size.width,
                                    buttonsBackdrop.frame.origin.y + smallBuffer,
                                    [songTimeLeft frame].size.width - smallBuffer,
                                    [songTimeLeft frame].size.height);
    
    //-------------------------------------------------------------------------
    //Setting thie variable to have the view drawn correctly, then showing it
    //-------------------------------------------------------------------------
    self.artworkWindow.artworkView.tagsBottom = currentArtistAndAlbum.frame.origin.y;
    [self.artworkWindow.artworkView display];

    [self updateTrackingAreas];
}

//##############################################################################
//This is essentually the same as the upper method, but for when iTunes is
//stopped and we have no artwork.  In this case, we just want to show 3 buttons
//##############################################################################
-(void)updateWindowElementsWithiTunesStopped
{
    //-------------------------------------------------------------------------
    //We only give a shit about the three buttons - quit, close, iTunes
    //-------------------------------------------------------------------------
    int bottomOfArt = [currentArtwork frame].origin.y;
    //Buffer in a third the button's height, for making them equidistant
    int controlButtonsBuffer = playPauseButton.frame.size.width/5;
    
    //Buttons
    buttonsBackdrop.frame = CGRectMake(currentArtwork.frame.origin.x,
                                       currentArtwork.frame.origin.y,
                                       [currentArtwork frame].size.width,
                                       [playPauseButton frame].size.height + controlButtonsBuffer*2);
    
    [self updateTrackingAreas];
}


//##############################################################################
//Used to make sure the tracking are is the same size as the artwork frame.
//It's used to detect when the cursor is hovering over the artwork, to bring
//up buttons
//##############################################################################
-(void)updateTrackingAreas
{
    if(trackingArea != nil)
    {
        [self.artworkWindow.artworkView removeTrackingArea:trackingArea];
    }
    
    NSRect rectForTracking = currentArtwork.frame;
    rectForTracking.size.height += songSlider.frame.size.height;
    rectForTracking.origin.y = songSlider.frame.origin.y;
    
    int opts = (NSTrackingMouseEnteredAndExited | NSTrackingActiveAlways);
    trackingArea = [ [NSTrackingArea alloc] initWithRect:rectForTracking
                                                 options:opts
                                                   owner:self
                                                userInfo:nil];
    [self.artworkWindow.artworkView addTrackingArea:trackingArea];
}


//##############################################################################
//Opening and closing the window with the menubar icon is clicked.
//##############################################################################
-(void)receivedMouseDownNotification:(NSNotification *)note
{

    //If the window is open, close it
    if ([_artworkWindow isVisible])
    {
        NSLog(@"ALPHA");
        [_artworkWindow close];
        //[self update:NO];
    }
    
    //Otherwise its closed, so open it
    else
    {
        NSLog(@"BETA");
        //[self update:YES];
        
        [self updateUIElements];
        
         //Clear notifications from the screen,
         [[NSUserNotificationCenter defaultUserNotificationCenter]
         removeAllDeliveredNotifications];
         
         [_artworkWindow.artworkView setNeedsDisplay:YES];
         
         
         struct DangerZone
         {
             double lowerBound;
             double upperBound;
         };
        

        CGRect statusRect = NSRectFromString(
                    [note.userInfo objectForKey:@"GlobalRect"]);
        

         statusRect.origin.y = NSMinY(statusRect) - NSHeight(statusRect);
        
        
         NSRect windowRect = [_artworkWindow frame];
         windowRect.size.width = LARGE_WIDTH;
         windowRect.size.height = LARGE_HEIGHT;
         windowRect.origin.x = roundf(NSMidX(statusRect) - NSWidth(windowRect) / 2);
         windowRect.origin.y = NSMaxY(statusRect) - NSHeight(windowRect);
         
         [_artworkWindow setFrame:windowRect display:YES];
         
         [_artworkWindow makeKeyAndOrderFront:self];
         [_artworkWindow setLevel:kCGFloatingWindowLevel];
        [self window] = _artworkWindow;
         [NSApp activateIgnoringOtherApps:YES];
    }
    
    
    /**
     //Finding the origin
     CGPoint origin = statusItemWindowframe.origin;
     //The size of the window we want to open
     CGSize statusItemWindowSize = [artworkWindowController window].frame.size;
     //Calculations...
     double halfOfIcon = statusItemWindowframe.size.width/2.f;
     double halfOfWindow = statusItemWindowSize.width/2.f;
     //Getting the position for the window
     CGPoint windowTopLeftPosition = CGPointMake(origin.x + halfOfIcon - halfOfWindow, origin.y);
     
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
     dangerZone.lowerBound = rightEdge - [artworkWindowController window].frame.size.width;
     dangerZone.upperBound = rightEdge - [artworkWindowController window].frame.size.width/2;
     dangerZones[i] = dangerZone;
     }
     
     //-------------------------------------------------------------------------
     //Now, checking the topLeftPosition against all the danger zones.  This
     //could probably be put in with the above code but it is seperated for
     //clarity and because I may want to recalculate the window positions
     //differently at a later time
     //-------------------------------------------------------------------------
     NSImage *bgTopArrow = [NSImage imageNamed:@"bgTopArrow"];
     //This has to start as zero, (arrow in the middle = 0)
     double arrowLocation = 0;
     
     for (int i = 0; i < [screens count]; i++)
     {
     //If this gets hit, the point is in the danger zone!
     if ((dangerZones[i].lowerBound < windowTopLeftPosition.x) &&
     (windowTopLeftPosition.x < dangerZones[i].upperBound))
     {
     double rightBuffer = bgTopArrow.size.height;
     //Here, we reset the arrow location
     double postionOfRightSideOfWindow = windowTopLeftPosition.x + [artworkWindowController window].frame.size.width;
     double xPositionOfRightSideOfScreen = [screens[i] frame].origin.x + [screens[i] frame].size.width;
     arrowLocation = (postionOfRightSideOfWindow - xPositionOfRightSideOfScreen) + rightBuffer;
     
     //Here, we reset the window location
     windowTopLeftPosition.x = dangerZones[i].lowerBound - rightBuffer;
     }
     }
     
     //-------------------------------------------------------------------------
     //Finally, Setting the window position and arrow location
     //-------------------------------------------------------------------------
     [[artworkWindowController window] setFrameTopLeftPoint:windowTopLeftPosition];
     artworkWindowController.artworkWindow.artworkView.topArrowLocation = arrowLocation;
     */
    
}


///Moving this to the delegate so it can be a right click meun
/**
 - (IBAction)openMenu:(id)sender
 {
 //The menu we are going to open
 menuButtonMenu = [[NSMenu alloc] initWithTitle:@"Menu"];
 
 [menuButtonMenu addItem:openIniTunes];
 [menuButtonMenu addItem:preferences];
 [menuButtonMenu addItem:quitApp];
 
 //Finding the position for the menu
 
 int menuXPos = [menuButton frame].origin.x - [menuButtonMenu size].width + [menuButton frame].size.width;
 int menuYPos = menuYPos = buttonsBackdrop.frame.origin.y;
 if (artworkWindow.frame.size.height == SMALL_HEIGHT)
 {
 menuYPos = 0;
 }
 
 
 NSPoint locationInWindow = NSMakePoint(menuXPos, menuYPos);
 
 //Make this event to properly position the menu
 NSEvent *menuMouseEvent = [NSEvent mouseEventWithType:NSLeftMouseDown
 location:locationInWindow
 modifierFlags:0
 timestamp:0
 windowNumber:[[self window] windowNumber]
 context:nil
 eventNumber:0
 clickCount:0
 pressure:0];
 //Open the menu
 [NSMenu popUpContextMenu:menuButtonMenu withEvent:menuMouseEvent forView:sender];
 }
 */


#
#pragma mark - Sending notifications
#

#
#pragma mark - IBActions
#
//##############################################################################
//This action taken out by the play/pause button, pauses and plays iTunes
//accordingly
//##############################################################################
-(IBAction)playpause:(id)sender
{
    ///r need to send not. to itC
    /**
    ///[iTunesController playpause];
    //This is so it knows the correct status
    ///[iTunesController update];
    if ([[iTunesController currentStatus] isEqualToString:@"Playing"])
    {
        [self mouseExited:nil];
    }
    [self updateArtwork];
    [self updateControlButtons];
     */
}

//##############################################################################
//This action taken out by the next button, going to the next song
//##############################################################################
-(IBAction)next:(id)sender
{
        ///r need to send not. to itC
    ///[iTunesController nextSong];
}

//##############################################################################
//This action taken out by the previous button, going to the previous song.
//If the song has progressed past the threshold, it instead skips to the be-
//geinning of the current song
//##############################################################################
-(IBAction)previous:(id)sender
{
        ///r need to send not. to itC
    /**
    double goToPreviousThreshold = 2.0;
    if ([iTunesController currentProgress] > goToPreviousThreshold)
    {
        ///[iTunesController setPlayerPosition:0.0];
    } else
    {
        ///[iTunesController previousSong];
    }
     */

}

//##############################################################################
//Opens the preferences window
//##############################################################################
///r figure this out with nots.
/**
-(void)showPreferences:(id)sender
{
    //-------------------------------------------------------------------------
    //Positioning the window
    //------------------------------------------------------------------------
    //preferencesWinowController = [[NSWindowController alloc] initWithWindowNibName:@"PreferencesWindowController"];
    preferencesWindowController = [[PreferencesWindowController alloc] init];

    NSScreen *mainScreen = [NSScreen mainScreen];
    CGPoint center = CGPointMake(mainScreen.frame.size.width/2, mainScreen.frame.size.height/2);
    //This perfectly centers the window
    CGPoint topLeftPos = CGPointMake(center.x - [preferencesWindowController window].frame.size.width/2,
                                     center.y + [preferencesWindowController window].frame.size.height/2);
    
    //-------------------------------------------------------------------------
    //Setting the window position, and opening it
    //-------------------------------------------------------------------------
    [[preferencesWindowController window] setFrameTopLeftPoint:topLeftPos];
    
    [[preferencesWindowController window] setLevel:kCGFloatingWindowLevel];
    [preferencesWindowController showWindow:nil];
     
}
 */

//##############################################################################
//Closes PlayMe and goes to the song in iTunes
//It also closes the window that's open and it sends a notification
//so the delegate knows to update the menubar.
//##############################################################################
-(void)openIniTunes:(id)sender
{
     [self mouseExited:nil];
    
     [[self window] orderOut:sender];
     
     NSNotification *iTunesButtonNotification = [NSNotification
     notificationWithName:@"iTunesButtonClicked"
     object:nil];
     [[NSDistributedNotificationCenter defaultCenter] postNotification:iTunesButtonNotification];
     
     NSString *path = [[NSBundle mainBundle] pathForResource:@"revealTrack"
     ofType:@"scpt"];
     NSAppleScript *script = [[NSAppleScript alloc]
     initWithContentsOfURL:[NSURL fileURLWithPath:path]
     error:nil];
     
     [script executeAndReturnError:nil];
}


//##############################################################################
//Triggered when the cursor is hovering over the artwork
//##############################################################################
-(void)mouseEntered:(NSEvent *)theEvent
{
    ///r why did I need this if?
    /**
     if (!([[iTunesController currentStatus] isEqualToString:@"Stopped"]))
     {
     [buttonsBackdrop setHidden:NO];
     playPauseButton.hidden = NO;
     nextButton.hidden = NO;
     previousButton.hidden = NO;
     [songTimeLeft setHidden:NO];
     }
     */
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

//##############################################################################
//This is invoked when the used manually moves the progress slider.  It moves
//the player position in iTunes to the corresponding location.
//##############################################################################
-(IBAction)sliderDidMove:(id)sender
{
    ///[iTunesController setPlayerPosition:[songSlider doubleValue]];
    ///[iTunesController updateProgress];
}

#
#pragma mark -Utilities
#
//##############################################################################
//When iTunes status changes, we need to update the positioning of everything
//in the window.  This is done if the window is open.
//##############################################################################
-(void)updateUIElements
{
    NSImage *bgTopArrow = [NSImage imageNamed:@"bgTopArrow"];
    NSRect tempFrame = NSMakeRect(0.0, 0.0, 0.0, 0.0);
    tempFrame.size.width = LARGE_ARTWORK_WIDTH;
    tempFrame.size.height = LARGE_ARTWORK_HEIGHT;
    tempFrame.origin.y =  tempFrame.size.height - bgTopArrow.size.height;
    [currentArtwork setFrame:tempFrame];
    
    ///[self updateArtwork];
    ///r figure this one out...
    /**
     if (![self iTunesIsRunning] ||
     ([[self iTunesController].currentStatus isEqualToString:@"Stopped"]))
     {
     [self updateWindowElementsWithiTunesStopped];
     }
     else
     {
     [self updateWindowElements];
     }
     */
    ///[self updateControlButtons];
    
}

//##############################################################################
//This quits the application.
//##############################################################################
-(void)quitPlayMe:(id)sender
{
    [NSApp terminate:self];
}

@end