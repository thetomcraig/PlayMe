#import <Cocoa/Cocoa.h>
#import "ArtworkView.h"
#import "ArtworkWindow.h"
#import "ButtonsBackdrop.h"
#import "ControlButtonsCell.h"
#import "SongSliderCell.h"

@interface ArtworkWindowController : NSWindowController

//For sizing
@property (nonatomic, strong) NSImage *topArrow;

//The menu button and its options
@property (retain, nonatomic) NSMenu *menuButtonMenu;
@property (retain, nonatomic) NSMenuItem *preferences, *openIniTunes, *quitApp;

//Instance variables to hold the iTunes information
//These need to be stored internally because the window
//elements cannot be set when the window has not yet loaded
@property (nonatomic, strong) NSString *currentSongState;
@property (nonatomic, strong) NSString *currentArtistAndAlbumState;
@property (nonatomic, strong) NSString *currentStatusState;
@property (nonatomic, strong) NSString *currentButtonNameState;
@property (nonatomic, strong) NSString *currentAltButtonNameState;
@property (nonatomic, strong) NSImage *currentArtworkState;
@property (nonatomic, strong) NSNumber *currentProgressState;
@property (nonatomic, strong) NSNumber *currentLengthState;
@property (nonatomic, strong) NSString *currentTimeLeftState;

//The tags we get from iTunes
@property (weak) IBOutlet ArtworkView *artworkView;
@property (nonatomic, retain) IBOutlet NSImageView *currentArtwork;
@property (weak) IBOutlet NSTextField *currentSong;
@property (weak) IBOutlet NSTextField *currentArtistAndAlbum;

//Slider and timer
@property (weak) IBOutlet SongSlider *songSlider;
@property (weak) IBOutlet SongSliderCell *songSliderCell;
@property (weak) IBOutlet NSTextField *songTimeLeft;

//Buttons and tracking area
@property (weak) IBOutlet ButtonsBackdrop *buttonsBackdrop;
@property (weak) IBOutlet NSButton *playPauseButton;
@property (weak) IBOutlet NSButton *playPauseButtonOverlay;
@property (weak) IBOutlet ControlButtonsCell *playPauseButtonCell;
@property (weak) IBOutlet NSButton *nextButton;
@property (weak) IBOutlet ControlButtonsCell *nextButtonCell;
@property (weak) IBOutlet NSButton *previousButton;
@property (weak) IBOutlet ControlButtonsCell *previousButtonCell;
@property (retain, nonatomic) NSTrackingArea *trackingArea;

//IBActions
- (IBAction)playpause:(id)sender;
- (IBAction)next:(id)sender;
- (IBAction)previous:(id)sender;
- (IBAction)sliderDidMove:(id)sender;

@end