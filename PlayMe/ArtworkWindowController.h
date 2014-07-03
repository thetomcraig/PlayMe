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

@property (retain, nonatomic) ITunesController *iTunesController;
@property (retain, nonatomic) ImageController *imageController;
@property (retain, nonatomic) NSWindowController *preferencesWindowController;

@property (strong) IBOutlet ArtworkWindow *artworkWindow;

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

@property (weak) IBOutlet ButtonsBackdrop *buttonsBackdrop;
@property (weak) IBOutlet NSButton *playPauseButton;
@property (weak) IBOutlet ControlButtonsCell *playPauseButtonCell;
@property (weak) IBOutlet NSButton *nextButton;
@property (weak) IBOutlet ControlButtonsCell *nextButtonCell;
@property (weak) IBOutlet NSButton *previousButton;
@property (weak) IBOutlet ControlButtonsCell *previousButtonCell;
@property (retain, nonatomic) NSTrackingArea *trackingArea;

@property (nonatomic, retain) NSTimer *countdownTimer;

- (void)update:(BOOL)windowIsOpen;
- (void)updateArtwork;
- (void)updateLabels;
- (void)updateColors:(BOOL)defaultColors;
- (void)updateControlButtons;
- (void)updateMaxValue;
- (void)updateWindowElements;
- (void)updateWindowElementsWithiTunesStopped;
- (void)updateCurrentArtworkFrame;
- (void)updateTrackingAreas;

- (void)updateUIElements;
- (void)toggleWindow;
- (void)openWindow;

- (IBAction)playpause:(id)sender;
- (IBAction)next:(id)sender;
- (IBAction)previous:(id)sender;
- (IBAction)sliderDidMove:(id)sender;

- (void)closeWindow;
- (void)showPreferences:(id)sender;
- (void)quitPlayMe:(id)sender;
- (IBAction)closeWindowWithButton:(id)sender;


@end