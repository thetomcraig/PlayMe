//From the Delegate, window sizes
#define SMALL_WIDTH 130
#define SMALL_HEIGHT 70
#define LARGE_WIDTH 400
#define LARGE_HEIGHT 800
#define SMALL_BUFFER 15
//For this class, artwork sizes
#define SMALL_ARTWORK_WIDTH 130
#define SMALL_ARTWORK_HEIGHT 70
#define LARGE_ARTWORK_WIDTH 400
#define LARGE_ARTWORK_HEIGHT 400

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
@synthesize menuButton;
@synthesize moreButtonCell;
@synthesize closeButton;
@synthesize closeButtonCell;
@synthesize trackingArea;

@synthesize countdownTimer;

#
#pragma mark - Initalizing Method
#
//############################################################################
//We initialize with the nib that has everything on it
//The iTunesController gives us access to iTunes info
//We set the defualt colors here, which are black and white.  If it gets
//opened before the color algorithm is done, it can just show black and white.
//############################################################################
-(id)init
{
    self = [[ArtworkWindowController alloc]
            initWithWindowNibName:@"ArtworkWindowController"];
    
    iTunesController = [[ITunesController alloc] init];
    
    return self;
}

//############################################################################
//After the window has loaded, we make sure everything is aligned
//The artwork is positioned just below the top arrow.  We call the mouseExited
//function to make sure the buttons are hidden when the window opens.
//We call updateWindowElements to position everything else.
//The observers atthe top are for the color algorithm; they are called when
//the algorithm comes up woith new colors or times out
//############################################################################
-(void)windowDidLoad
{
    [super windowDidLoad];
    
    imageController = [[ImageController alloc] init];
    
    NSRect artworkFrame = currentArtwork.frame;
    NSImage *bgTopArrow = [NSImage imageNamed:@"bgTopArrow"];
    artworkFrame.origin.y = self.window.frame.size.height -
    currentArtwork.frame.size.height - bgTopArrow.size.height;
    [currentArtwork setFrame:artworkFrame];
    
    [menuButton setToolTip:@"Open menu"];
    [closeButton setToolTip:@"Close window"];
    
    preferences = [[NSMenuItem alloc] initWithTitle:@"Preferences..." action:@selector(showPreferences:) keyEquivalent:@""];
    openIniTunes = [[NSMenuItem alloc] initWithTitle:@"Go to song in iTunes" action:@selector(openIniTunes:) keyEquivalent:@""];
    quitApp = [[NSMenuItem alloc] initWithTitle:@"Quit PlayMe" action:@selector(quitPlayMe:) keyEquivalent:@""];

    [playPauseButton setBordered:NO];
    [nextButton setBordered:NO];
    [previousButton setBordered:NO];
    [menuButton setBordered:NO];
    [closeButton setBordered:NO];

    //Hiding this because I have not implemented it yet
    [currentLyrics setHidden:YES];
    [self mouseExited:nil];
    [self updateColors:YES];
}

#
#pragma mark - Updating Methods
#
//############################################################################
//Updating everything in the window from the iTunesController object
//If windowIsOpen is TRUE we do more work that if it is FALSE
//First, we start and stop the timer accordingly
//If the window is not open, we can exit.
//If the window is open, we have more stuff to do...
//In the first if statement, we intialize the imageController if is hasn't
//been done before, and analyze the album playing for colors.
//This is the main function that calls smaller updater methods
//############################################################################
-(void)update:(BOOL)windowIsOpen
{
    if ([self iTunesIsRunning])
    {
        [iTunesController update];
    }
    if (!windowIsOpen)
    {
        [self stopTimer];
    }
    
    else
    {
        if ([[iTunesController currentStatus] isEqualToString:@"Playing"])
        {
            [self startTimer];
            [openIniTunes setTitle:@"Go to song in iTunes"];
        }
        
        else if ([[iTunesController currentStatus] isEqualToString:@"Stopped"])
        {
            [openIniTunes setTitle:@"Go to iTunes"];
        }
        
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

//############################################################################
//If iTunes is stopped, we have the small window showing, and get the small
//artwork for it.
//Otherwise, if the window is open, we resize the artwork, bevel its edges,
//and put it in the view.
//If there was NO artwork, we put in the black artwork image
//############################################################################
-(void)updateArtwork
{
    //If it is stopped, we want the small window with logo
    if ([[iTunesController currentStatus] isEqualToString:@"Stopped"])
    {
        NSImage *newArtwork = [imageController
                               resizeNothingPlaying
                               :NSMakeSize(SMALL_ARTWORK_WIDTH - SMALL_BUFFER, SMALL_ARTWORK_HEIGHT)];

        [currentArtwork setImage:newArtwork];
        
    }
    
    //Else, we have artwork to work with
    else
    {
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
}

//############################################################################
//Updating the labels with the song name, artist and album name.
//It calls the trimString method to make sure they're clipped properly
//############################################################################
-(void)updateLabels
{
    [currentSong setStringValue:[self trimString:[iTunesController currentSong]
                                                :currentSong.frame.size.width
                                                :currentSong.font :@""]];
    
    if ([[iTunesController currentArtist] isEqualToString:@""])
    {
        [currentArtistAndAlbum setStringValue:@""];
    } else
    {
        NSString *combinedString = [NSString stringWithFormat:@"%@ - %@",
                                         [iTunesController currentArtist],
                                           [iTunesController currentAlbum]];
        
        [currentArtistAndAlbum setStringValue:[self trimString:combinedString
                                                              :currentArtistAndAlbum.frame.size.width
                                                              :currentArtistAndAlbum.font :@""]];
    }
  
}

//############################################################################
//Updates everything that needs to be colored, colors come from the color
//algorithm carried ou by the imageController.  The control buttons are white,
//and we adjust their hue so it matches the calculated color.
//Currently, only the names of the resource images matter, not their actual
//color.  This is because the actual resource image is used like a mask, and
//the depressed color is created programatically.
//############################################################################
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
    moreButtonCell.buttonsColor = secondaryColor;
    closeButtonCell.buttonsColor = secondaryColor;
    songSliderCell.progressColor = secondaryColor;
    
    [nextButton setImage:[NSImage imageNamed:@"NextButton"]];
    [nextButton setAlternateImage:[NSImage imageNamed:@"NextButtonDepressed"]];
    [previousButton setImage:[NSImage imageNamed:@"PreviousButton"]];
    [previousButton setAlternateImage:[NSImage imageNamed:@"PreviousButtonDepressed"]];
    [menuButton setImage:[NSImage imageNamed:@"moreButton"]];
    [menuButton setAlternateImage:[NSImage imageNamed:@"moreButtonDepressed"]];
    [closeButton setImage:[NSImage imageNamed:@"closeButton"]];
    [closeButton setAlternateImage:[NSImage imageNamed:@"closeButtonDepressed"]];
}

//############################################################################
//This method used to update the control buttons when the status changes.
//Called when they're clicked, and in by the app delegate.  If this update was
//called when the last song in the iTunes cue finished, we hide everything and
//are done.  Otherwise, we need to update the buttons.
//############################################################################
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

//############################################################################
//Here, we make sure the progress bar values are calculated.  We set the
//max value to the song length.  This reflects what the bar looks like right
//when the window opens.  We want to make sure it is at the right place right
//off the bat, before the timer even starts
//############################################################################
-(void)updateMaxValue
{
    [songSlider setDoubleValue:0.0];
    [songSlider setMaxValue:[iTunesController currentLength]];
    [self advanceProgress:nil];
}

//############################################################################
//This is called by the timer, to update the progress bar and countdown label.
//Updated because we need to  account for the position moving independent of a
//state change ie. user moves the scrubber bar when iTunes paused
//In the last line, we redraw the view.
//############################################################################
-(void)advanceProgress:(NSTimer *)timer
{
    [iTunesController updateProgress];
    
    double totalSecsLeft = ([iTunesController currentLength] -
                            [iTunesController currentProgress]);
    int numMinsLeft = (floor(totalSecsLeft/60));
    int numSecsLeft = (totalSecsLeft - numMinsLeft*60);
    
    //It needlessly showes 60's so we can just replace it
    if (numSecsLeft == 60)
    {
        numMinsLeft = 0;
        numSecsLeft = 0;
    }
    [songTimeLeft setStringValue:[NSString stringWithFormat:@"-%i:%02d",
                                  numMinsLeft, numSecsLeft]];
    
    [songSlider setDoubleValue:[iTunesController currentProgress]];
    [self.artworkWindow.artworkView display];
}

//############################################################################
//This makes sure the labels and progess bar just below the artwork.
//The bottomOfArtBuffer is the distance from the bottom of the artwork to the
//progress bar.  The leftEdgeBuffer is how far the labels are from the left
//side of the window.  The controlButtons buffers are used to position the
//control buttons.  Also updates the tracking area w/ artwork size
//############################################################################
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
    double outerButtonsSiderBuffer = playPauseButton.frame.size.width/2.5;
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
    menuButton.frame = CGRectMake([nextButton frame].origin.x + nextButton.frame.size.width + outerButtonsSiderBuffer,
                                    bottomOfArt + controlButtonsTopBuffer,
                                    [menuButton frame].size.width,
                                    [menuButton frame].size.height);
    closeButton.frame = CGRectMake([previousButton frame].origin.x - previousButton.frame.size.width - outerButtonsSiderBuffer,
                                  bottomOfArt + controlButtonsTopBuffer,
                                  [closeButton frame].size.width,
                                  [closeButton frame].size.height);
    
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

//############################################################################
//This is essentually the same as the upper method, but for when iTunes is
//stopped and we have no artwork.  In this case, we just want to show 3 buttons
//############################################################################
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
    closeButton.frame = CGRectMake(currentArtwork.frame.size.width/2 - [closeButton frame].size.width - controlButtonsBuffer,
                                       bottomOfArt + controlButtonsBuffer,
                                       [closeButton frame].size.width,
                                       [closeButton frame].size.height);
    menuButton.frame = CGRectMake(currentArtwork.frame.size.width/2 + controlButtonsBuffer,
                                  bottomOfArt + controlButtonsBuffer,
                                  [menuButton frame].size.width,
                                  [menuButton frame].size.height);
    
    [self updateTrackingAreas];
}

//############################################################################
//This method fixes the currentArtwork frame.
//This was confusing to me.  It works, but some of the position is awkward
//and confusing
//############################################################################
-(void)updateCurrentArtworkFrame
{
    //Make it the correct dimensions
    NSImage *bgTopArrow = [NSImage imageNamed:@"bgTopArrow"];
    NSRect tempFrame = NSMakeRect(0.0, 0.0, 0.0, 0.0);
    if ([[iTunesController currentStatus] isEqualToString:@"Stopped"] || !([self iTunesIsRunning]))
    {
        [buttonsBackdrop setHidden:YES];
        playPauseButton.hidden = YES;
        nextButton.hidden = YES;
        previousButton.hidden = YES;
        [songTimeLeft setHidden:YES];
        closeButton.hidden = NO;
        menuButton.hidden = NO;
        
        tempFrame.size.height = SMALL_ARTWORK_HEIGHT - bgTopArrow.size.height;
        tempFrame.size.width = SMALL_ARTWORK_WIDTH;
        tempFrame.origin.y =  LARGE_HEIGHT - SMALL_ARTWORK_HEIGHT;
    }
    else
    {
        //Hits this statement if the size of the window is changing
        //From small to big
        if (currentArtwork.frame.size.height != LARGE_ARTWORK_HEIGHT)
        {

            menuButton.hidden = YES;
            closeButton.hidden = YES;
        }
        
        tempFrame.size.width = LARGE_ARTWORK_WIDTH;
        tempFrame.size.height = LARGE_ARTWORK_HEIGHT;
        tempFrame.origin.y =  tempFrame.size.height - bgTopArrow.size.height;
    }
    
    [currentArtwork setFrame:tempFrame];
}

//############################################################################
//Used to make sure the tracking are is the same size as the artwork frame.
//It's used to detect when the cursor is hovering over the artwork, to bring
//up buttons
//############################################################################
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
//############################################################################
//This action taken out by the play/pause button, pauses and plays iTunes
//accordingly
//############################################################################
-(IBAction)playpause:(id)sender
{
    [iTunesController playpause];
    //This is so it knows the correct status
    [iTunesController update];
    if ([[iTunesController currentStatus] isEqualToString:@"Playing"])
    {
        [self mouseExited:nil];
    }
    [self updateArtwork];
    [self updateControlButtons];
}

//############################################################################
//This action taken out by the next button, going to the next song
//############################################################################
-(IBAction)next:(id)sender
{
    [iTunesController nextSong];
}

//############################################################################
//This action taken out by the previous button, going to the previous song.
//If the song has progressed past the threshold, it instead skips to the be-
//geinning of the current song
//############################################################################
-(IBAction)previous:(id)sender
{
    double goToPreviousThreshold = 2.0;
    if ([iTunesController currentProgress] > goToPreviousThreshold)
    {
        [iTunesController setPlayerPosition:0.0];
    } else
    {
        [iTunesController previousSong];
    }

}

//############################################################################
//When the menuButton is pressed, this method is called to present the optins
//menu
//############################################################################
- (IBAction)openMenu:(id)sender
{
    //The menu we are going to open
    menuButtonMenu = [[NSMenu alloc] initWithTitle:@"Menu"];
    
    [menuButtonMenu addItem:openIniTunes];
    [menuButtonMenu addItem:preferences];
    [menuButtonMenu addItem:quitApp];
    
    //Finding the position for the menu
    
    int menuXPos = [menuButton frame].origin.x - [menuButtonMenu size].width + [menuButton frame].size.width;
    int menuYPos = [menuButton frame].origin.y;
    menuYPos = buttonsBackdrop.frame.origin.y;
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

//############################################################################
//Opens the preferences window
//############################################################################
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

//############################################################################
//Closes PlayMe and goes to the song in iTunes
//It also closes the window that's open and it sends a notification
//so the delegate knows to update the menubar.
//############################################################################
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

//############################################################################
//This quits the application.
//############################################################################
-(void)quitPlayMe:(id)sender
{
    [NSApp terminate:self];
}

//############################################################################
//This closes the window
//############################################################################
- (IBAction)closeWindowWithButton:(id)sender
{
    [self mouseExited:nil];
    [self closeWindow];
    NSNotification *iTunesButtonNotification = [NSNotification
                                                notificationWithName:@"closeButtonClicked"
                                                object:nil];
    [[NSDistributedNotificationCenter defaultCenter] postNotification:iTunesButtonNotification];
}

//############################################################################
//Triggered when the cursor is hovering over the artwork
//############################################################################
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

    //We don't ever want to hide these
    //we want to see the when nothing is playing
    closeButton.hidden = NO;
    menuButton.hidden = NO;
}

//############################################################################
//Triggered when the cursor stops hovering over the artwork
//############################################################################
-(void)mouseExited:(NSEvent *)theEvent
{
    //This first if makes sure that if nothing is playing, the buttons don't
    //autohide and just show up statically
    if ((![self iTunesIsRunning]) || ([currentSong.stringValue isEqualToString:@""]))
    {
        menuButton.hidden = NO;
        closeButton.hidden = NO;
    }
    else
    {
        menuButton.hidden = YES;
        closeButton.hidden = YES;
    }

    [buttonsBackdrop setHidden:YES];
    playPauseButton.hidden = YES;
    nextButton.hidden = YES;
    previousButton.hidden = YES;
    [songTimeLeft setHidden:YES];
}

//############################################################################
//This is invoked when the used manually moves the progress slider.  It moves
//the player position in iTunes to the corresponding location.
//############################################################################
-(IBAction)sliderDidMove:(id)sender
{
    [iTunesController setPlayerPosition:[songSlider doubleValue]];
    [iTunesController updateProgress];
}

#
#pragma mark -Utilities
#
//############################################################################
//Starts the timer used for the progress bar.  We seperate this because we
//want to stop the timer when the window closes
//############################################################################
-(void)startTimer
{
    countdownTimer = [NSTimer scheduledTimerWithTimeInterval:1.0
                                                      target:self
                                                    selector:@selector(advanceProgress:)
                                                    userInfo:nil repeats:YES];
}

//############################################################################
//This is used to invalidate the timer when it does not need to be running.
//We do this when the window is closed because the progress bar is not
//visible if that happens
//############################################################################
-(void)stopTimer
{
    if (countdownTimer != nil)
    {
        [countdownTimer invalidate];
        countdownTimer = nil;
        
    }
}

//############################################################################
//Closes the active PlayMe window, and does a few other related tasks
//############################################################################
-(void)closeWindow
{
    [[self window] close];
    
    if ([[preferencesWindowController window] isVisible])
    {
        [[preferencesWindowController window] close];
    }
}

//############################################################################
//This function trims tags that are too long for their containers.  It finds
//the width of the string with the given font, and keeps removing charaters
//until it is short enough, then adds an elipsis, and returns the short string.
//The elipseToBeFilled is an empty string passed to the function that is appen
//-ded to the output.  If the string was shortened, this is made into an elipse
//otherwise, it remains empty.
//############################################################################
-(NSString *)trimString:(NSString *)longString :(CGFloat)targetWidth :(NSFont *)font :(NSString *)elipseToBeFilled
{
    NSDictionary *attributes = [NSDictionary
                                dictionaryWithObjectsAndKeys:font,
                                NSFontAttributeName, nil];
    CGFloat elipsisWidth = [@"..." sizeWithAttributes:attributes].width;
    
    CGFloat widthOfLongString = [longString sizeWithAttributes:attributes].width;
    
    if (widthOfLongString + elipsisWidth >= targetWidth)
    {
        elipseToBeFilled = @"...";
        return [self trimString:[longString substringToIndex:longString.length - 1] :targetWidth :font: elipseToBeFilled];
    }

    return [NSString stringWithFormat:@"%@%@", longString, elipseToBeFilled];
}

//############################################################################
//Returns true when the iTunesController says iTunes is running.
//############################################################################
-(BOOL)iTunesIsRunning
{
    if ([iTunesController iTunesRunning])
    {
        return true;
    }
    return false;
}

@end