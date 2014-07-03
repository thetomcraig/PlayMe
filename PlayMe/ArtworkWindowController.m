#define LARGE_WIDTH 400
#define LARGE_HEIGHT 800
#define SMALL_BUFFER 15
//For this class, artwork sizes
#define LARGE_ARTWORK_WIDTH 400
#define LARGE_ARTWORK_HEIGHT 400
#define NSFloatingWindowLevel kCGFloatingWindowLevel

#import "ArtworkWindowController.h"


@implementation ArtworkWindowController
{
    //Colors used for all the
    //colors of the window
    NSColor *backgroundColor;
    NSColor *primaryColor;
    NSColor *secondaryColor;
}

@synthesize iTunesController;
@synthesize imageController;
@synthesize preferencesWindowController;

@synthesize artworkWindow;

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

@synthesize countdownTimer;


#
#pragma mark - Initalizing Method
#
//##############################################################################
//We initialize with the nib that has everything on it
//The iTunesController gives us access to iTunes info
//We set the defualt colors here, which are black and white.  If it gets
//opened before the color algorithm is done, it can just show black and white.
//##############################################################################
- (id)init
{
    self = [super initWithWindowNibName:@"ArtworkWindowController"];
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
    
    imageController = [[ImageController alloc] init];
    
    NSRect artworkFrame = currentArtwork.frame;
    NSImage *bgTopArrow = [NSImage imageNamed:@"bgTopArrow"];
    artworkFrame.origin.y = self.window.frame.size.height -
    currentArtwork.frame.size.height - bgTopArrow.size.height;
    [currentArtwork setFrame:artworkFrame];
    
    preferences = [[NSMenuItem alloc] initWithTitle:@"Preferences..." action:@selector(showPreferences:) keyEquivalent:@""];
    openIniTunes = [[NSMenuItem alloc] initWithTitle:@"Go to song in iTunes" action:@selector(openIniTunes:) keyEquivalent:@""];
    quitApp = [[NSMenuItem alloc] initWithTitle:@"Quit PlayMe" action:@selector(quitPlayMe:) keyEquivalent:@""];

    [playPauseButton setBordered:NO];
    [nextButton setBordered:NO];
    [previousButton setBordered:NO];

    //Hiding this because I have not implemented it yet
    [currentLyrics setHidden:YES];
    [self mouseExited:nil];
    [self updateColors:YES];
}

#
#pragma mark - Updating Methods
#
//##############################################################################
//Updating everything in the window from the iTunesController object
//If windowIsOpen is TRUE we do more work that if it is FALSE
//First, we start and stop the timer accordingly
//If the window is not open, we can exit.
//If the window is open, we have more stuff to do...
//In the first if statement, we intialize the imageController if is hasn't
//been done before, and analyze the album playing for colors.
//This is the main function that calls smaller updater methods
//##############################################################################
-(void)update:(BOOL)windowIsOpen
{
    if (!windowIsOpen)
    {
        ///[self stopTimer];
    }
    
    else
    {
        [self updateLabels];
        [self updateControlButtons];
        
        [self updateMaxValue];
        [self updateArtwork];
        
        //-------------------------------------------------------------------------
        //Updating the colors, if there is an art for algorithm to work with, run
        //the algorithm, otherwise, just do default, black and white colors.
        //Bear in mind it will run on a sperate thread
        //-------------------------------------------------------------------------
        [self updateColors:YES];
        ///b
        /**
        if (([[iTunesController currentStatus] isEqualToString:@"Playing"]) ||
            ([[iTunesController currentStatus] isEqualToString:@"Paused"]))
        {
            [imageController findColorsOpSeperateThread:[iTunesController currentArtwork]
                                                forSong:[iTunesController currentSong]];
        }
        else
        {
            [self updateColors:YES];
        }
         */
    }
    
}

//################################################################################
//If iTunes is stopped, we have the small window showing, and get the small
//artwork for it.
//Otherwise, if the window is open, we resize the artwork, bevel its edges,
//and put it in the view.
//If there was NO artwork, we put in the black artwork image
//################################################################################
-(void)updateArtwork
{
    ///r
    ///take out resizenothingplaying stuff too
    /**
    //If it is stopped, we want the small window with logo
    if ([[iTunesController currentStatus] isEqualToString:@"Stopped"])
    {
        NSImage *newArtwork = [imageController
                               resizeNothingPlaying
                               :NSMakeSize(SMALL_ARTWORK_WIDTH - SMALL_BUFFER, SMALL_ARTWORK_HEIGHT)];

        [currentArtwork setImage:newArtwork];
        
    }
     */
    
    
    
    ///_statusItemView.leftaction = NSSelectorFromString(@"toggleMainWindow:");
 
    //If we HAVE artwork tagged.....
    if ([iTunesController currentArtwork].size.width != 0.0)
    {
        NSImage *newArtwork = [imageController resizeArt:[iTunesController currentArtwork]
                                                        :currentArtwork.frame];
        
        //Make sure to mask it if the song is pasued
        if ([[iTunesController currentStatus] isEqualToString:@"Paused"])
        {
            [imageController putOnPausedMask:newArtwork];
        }
        
        //Finalize and put in the image
        newArtwork = [imageController roundCorners:newArtwork];
        [currentArtwork setImage:newArtwork];
    }
    
    //There was no artwork :(
    else
    {
        iTunesController.currentArtwork = [NSImage imageNamed:@"BlankArtwork"];
    }
    
}

//##############################################################################
//Updating the labels with the song name, artist and album name.
//It calls the trimString method to make sure they're clipped properly
//##############################################################################
-(void)updateLabels
{
    [currentSong setStringValue:[iTunesController currentSong]];
    
    if ([[iTunesController currentArtist] isEqualToString:@""])
    {
        [currentArtistAndAlbum setStringValue:@""];
    } else
    {
        NSString *combinedString = [NSString stringWithFormat:@"%@ - %@",
                                         [iTunesController currentArtist],
                                           [iTunesController currentAlbum]];
        
        [currentArtistAndAlbum setStringValue:
                                    [NSString stringWithFormat:@"%@ - %@",
                                    [iTunesController currentArtist],
                                    [iTunesController currentAlbum]]];
    }
  
}

//##############################################################################
//Updates everything that needs to be colored, colors come from the color
//algorithm carried ou by the imageController.  The control buttons are white,
//and we adjust their hue so it matches the calculated color.
//Currently, only the names of the resource images matter, not their actual
//color.  This is because the actual resource image is used like a mask, and
//the depressed color is created programatically.
//##############################################################################
///b
-(void)updateColors:(BOOL)defaultColors
{
    //This gets hit when we want the default colors
    NSColor *back = [NSColor colorWithCalibratedRed:0.9 green:0.9 blue:0.9 alpha:1.0];
    NSColor *front = [NSColor colorWithCalibratedRed:0.30 green:0.30 blue:0.30 alpha:1.0];
    backgroundColor = back;
    primaryColor =  front;
    secondaryColor = front;
    
    if (!defaultColors)
    {
        //-------------------------------------------------------------------------
        //Get the colors we just found with the algorithm...
        //-------------------------------------------------------------------------
        backgroundColor = [imageController.albumColors objectForKey:@"backgroundColor"];
        primaryColor = [imageController.albumColors objectForKey:@"primaryColor"];
        secondaryColor = [imageController.albumColors objectForKey:@"secondaryColor"];
    }

    //-------------------------------------------------------------------------
    //Assign all the colors
    //-------------------------------------------------------------------------
    artworkWindow.artworkView.backgroundColor = backgroundColor;
    artworkWindow.artworkView.arrowColor = backgroundColor;
    //songSlider.backgroundColor = backgroundColor;
    songSliderCell.backgroundColor = backgroundColor;
    buttonsBackdrop.mainColor = backgroundColor;
    
    currentSong.textColor = primaryColor;
    currentArtistAndAlbum.textColor = primaryColor;
    
    songTimeLeft.textColor = secondaryColor;
    nextButtonCell.buttonsColor = secondaryColor;
    playPauseButtonCell.buttonsColor = secondaryColor;
    previousButtonCell.buttonsColor = secondaryColor;
    songSliderCell.progressColor = secondaryColor;
    
    [nextButton setImage:[NSImage imageNamed:@"NextButton"]];
    [nextButton setAlternateImage:[NSImage imageNamed:@"NextButtonDepressed"]];
    [previousButton setImage:[NSImage imageNamed:@"PreviousButton"]];
    [previousButton setAlternateImage:[NSImage imageNamed:@"PreviousButtonDepressed"]];
}

//##############################################################################
//This method used to update the control buttons when the status changes.
//Called when they're clicked, and in by the app delegate.  If this update was
//called when the last song in the iTunes cue finished, we hide everything and
//are done.  Otherwise, we need to update the buttons.
//##############################################################################
-(void)updateControlButtons
{
    if ([[iTunesController currentStatus] isEqualToString:@"Stopped"])
    {
        [playPauseButton setImage:[NSImage imageNamed:@"PlayButton"]];
        [playPauseButton setAlternateImage:[NSImage imageNamed:@"PlayButtonDepressed"]];
        return;
    }
    
    if ([iTunesController.currentStatus isEqualToString:@"Paused"] || [iTunesController.currentStatus isEqualToString:@"Stopped"])
    {
        
        [playPauseButton setImage:[NSImage imageNamed:@"PlayButton"]];
        [playPauseButton setAlternateImage:[NSImage imageNamed:@"PlayButtonDepressed"]];
    }
    else if ([[iTunesController currentStatus] isEqualToString:@"Playing"])
    {
        [playPauseButton setImage:[NSImage imageNamed:@"PauseButton"]];
        [playPauseButton setAlternateImage:[NSImage imageNamed:@"PauseButtonDepressed"]];
    }
}

//##############################################################################
//Here, we make sure the progress bar values are calculated.  We set the
//max value to the song length.  This reflects what the bar looks like right
//when the window opens.  We want to make sure it is at the right place right
//off the bat, before the timer even starts
//##############################################################################
///r
///Get this info from notiication
/**
-(void)updateMaxValue
{
    [songSlider setDoubleValue:0.0];
    [songSlider setMaxValue:[iTunesController currentLength]];
    [self advanceProgress:nil];
}
*/



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
                                  [artworkWindow.artworkView frame].size.width + [songSliderCell knobRectFlipped:NO].size.width,
                                  sliderBuffer);
    currentSong.frame = CGRectMake(smallBuffer, bottomOfBar - currentSong.frame.size.height - smallBuffer,
                                   [artworkWindow.artworkView frame].size.width - smallBuffer*2,
                                   fontHeight);
    currentArtistAndAlbum.frame = CGRectMake(smallBuffer, currentSong.frame.origin.y - fontHeight - smallBuffer,
                                             [artworkWindow.artworkView frame].size.width - smallBuffer*2,
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
    songTimeLeft.frame = CGRectMake(artworkWindow.artworkView.frame.size.width - songTimeLeft.frame.size.width,
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

#
#pragma mark - Window Actions
#
//##############################################################################
//This action taken out by the play/pause button, pauses and plays iTunes
//accordingly
//##############################################################################
-(IBAction)playpause:(id)sender
{
    ///[iTunesController playpause];
    //This is so it knows the correct status
    ///[iTunesController update];
    if ([[iTunesController currentStatus] isEqualToString:@"Playing"])
    {
        [self mouseExited:nil];
    }
    [self updateArtwork];
    [self updateControlButtons];
}

//##############################################################################
//This action taken out by the next button, going to the next song
//##############################################################################
-(IBAction)next:(id)sender
{
    ///[iTunesController nextSong];
}

//##############################################################################
//This action taken out by the previous button, going to the previous song.
//If the song has progressed past the threshold, it instead skips to the be-
//geinning of the current song
//##############################################################################
-(IBAction)previous:(id)sender
{
    double goToPreviousThreshold = 2.0;
    if ([iTunesController currentProgress] > goToPreviousThreshold)
    {
        ///[iTunesController setPlayerPosition:0.0];
    } else
    {
        ///[iTunesController previousSong];
    }

}

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
    
    [self updateArtwork];
    
    if (![self iTunesIsRunning] ||
        ([[self iTunesController].currentStatus isEqualToString:@"Stopped"]))
    {
        [self updateWindowElementsWithiTunesStopped];
    }
    else
    {
        [self updateWindowElements];
    }
    [self updateControlButtons];
  
}

//##############################################################################
//Opening and closing the window with the menubar icon is clicked.
//Called from the delegate most of the time, via the menubar controller.
//##############################################################################
-(void)toggleWindow
{
    //If the window is open, close it
    if ([[self window] isVisible])
    {
        [[self window] close];
        [self update:NO];
    }
    
    //Otherwise its closed, so open it
    else
    {
        [self update:YES];

        [self updateUIElements];

        
        //Clear notifications from the screen,
        [[NSUserNotificationCenter defaultUserNotificationCenter] removeAllDeliveredNotifications];
        
        [self.artworkWindow.artworkView setNeedsDisplay:YES];
  
        
        struct DangerZone
        {
            double lowerBound;
            double upperBound;
        };
        
        NSRect screenRect = [[[NSScreen screens] objectAtIndex:0] frame];
        NSRect statusRect = NSZeroRect;
        
        StatusItemView *statusItemView = nil;
        /**
        if ([self.delegate respondsToSelector:@selector(statusItemViewForArtworkWindowController:)])
        {
            statusItemView = [self.delegate statusItemViewForArtworkWindowController:self];
        }
         */
    
        if (statusItemView)
        {
            statusRect = statusItemView.globalRect;
            statusRect.origin.y = NSMinY(statusRect) - NSHeight(statusRect);
        }
        else
        {
            statusRect.size = NSMakeSize(STATUS_ITEM_VIEW_WIDTH, [[NSStatusBar systemStatusBar] thickness]);
            statusRect.origin.x = roundf((NSWidth(screenRect) - NSWidth(statusRect)) / 2);
            statusRect.origin.y = NSHeight(screenRect) - NSHeight(statusRect) * 2;
        }
        
        NSRect windowRect = [[self window] frame];
        windowRect.size.width = LARGE_WIDTH;
        windowRect.size.height = LARGE_HEIGHT;
        windowRect.origin.x = roundf(NSMidX(statusRect) - NSWidth(windowRect) / 2);
        windowRect.origin.y = NSMaxY(statusRect) - NSHeight(windowRect);
        
            [[self window] setFrame:windowRect display:YES];
            
            [[self window] makeKeyAndOrderFront:self];
            [[self window] setLevel:kCGFloatingWindowLevel];
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

//##############################################################################
//Opens the preferences window
//##############################################################################
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
//This quits the application.
//##############################################################################
-(void)quitPlayMe:(id)sender
{
    [NSApp terminate:self];
}



//##############################################################################
//Triggered when the cursor is hovering over the artwork
//##############################################################################
-(void)mouseEntered:(NSEvent *)theEvent
{
    if (!([[iTunesController currentStatus] isEqualToString:@"Stopped"]))
    {
        [buttonsBackdrop setHidden:NO];
        playPauseButton.hidden = NO;
        nextButton.hidden = NO;
        previousButton.hidden = NO;
        [songTimeLeft setHidden:NO];
    }
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
//Returns true when the iTunesController says iTunes is running.
//##############################################################################
-(BOOL)iTunesIsRunning
{
    if ([iTunesController iTunesRunning])
    {
        return true;
    }
    return false;
}

@end