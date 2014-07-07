#import "ITunesController.h"
#import "ArtworkWindow.h"
#import "ImageController.h"
#import "ButtonsBackdrop.h"
#import "ControlButtonsCell.h"
#import "SongSliderCell.h"
#import "GeneralViewController.h"
#import "AboutViewController.h"
#import "PreferencesWindowController.h"
#import "StatusItemView.h"
#import "MenubarController.h"

@interface ArtworkWindowController : NSWindowController

///All of this needs to be taken out and moved elsewhere
///@property (retain, nonatomic) ITunesController *iTunesController;
///@property (retain, nonatomic) ImageController *imageController;
///@property (retain, nonatomic) NSWindowController *preferencesWindowController;

@property (strong) IBOutlet ArtworkWindow *artworkWindow;

///r group these together somehow?
@property (retain, nonatomic) NSMenu *menuButtonMenu;
@property (retain, nonatomic) NSMenuItem *preferences;
@property (retain, nonatomic) NSMenuItem *openIniTunes;
@property (retain, nonatomic) NSMenuItem *quitApp;

@property (nonatomic, retain) IBOutlet NSImageView *currentArtwork;
@property (weak) IBOutlet NSTextField *currentSong;
@property (weak) IBOutlet NSTextField *currentArtistAndAlbum;
@property (weak) IBOutlet NSTextField *currentLyrics;

@property (weak) IBOutlet SongSlider *songSlider;
@property (weak) IBOutlet SongSliderCell *songSliderCell;
@property (weak) IBOutlet NSTextField *songTimeLeft;

///r group these together also?
@property (weak) IBOutlet ButtonsBackdrop *buttonsBackdrop;
@property (weak) IBOutlet NSButton *playPauseButton;
@property (weak) IBOutlet ControlButtonsCell *playPauseButtonCell;
@property (weak) IBOutlet NSButton *nextButton;
@property (weak) IBOutlet ControlButtonsCell *nextButtonCell;
@property (weak) IBOutlet NSButton *previousButton;
@property (weak) IBOutlet ControlButtonsCell *previousButtonCell;
@property (retain, nonatomic) NSTrackingArea *trackingArea;

///prob dont need all the updates in the h file
- (void)update:(BOOL)windowIsOpen;
- (void)updateArtwork;
- (void)updateLabels;
- (void)updateColors;
- (void)updateControlButtons;
- (void)updateMaxValue;
- (void)updateWindowElements;
- (void)updateWindowElementsWithiTunesStopped;
- (void)updateCurrentArtworkFrame;
- (void)updateTrackingAreas;
- (void)updateUIElements;

- (void)toggleWindow;

- (IBAction)playpause:(id)sender;
- (IBAction)next:(id)sender;
- (IBAction)previous:(id)sender;
- (IBAction)sliderDidMove:(id)sender;

- (void)showPreferences:(id)sender;
- (void)quitPlayMe:(id)sender;

/// r can prob take out
///- (IBAction)closeWindowWithButton:(id)sender;


@end