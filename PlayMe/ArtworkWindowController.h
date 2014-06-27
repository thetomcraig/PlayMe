#import <Cocoa/Cocoa.h>
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

@class ArtworkWindowController;

@protocol ArtworkWindowControllerDelegate <NSObject>

@optional

- (StatusItemView *)statusItemViewForArtworkWindowController:(ArtworkWindowController *)controller;

@end

@interface ArtworkWindowController : NSWindowController <NSWindowDelegate>
{
    __unsafe_unretained id<ArtworkWindowControllerDelegate> _delegate;
}


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



@property (nonatomic, unsafe_unretained, readonly) id<ArtworkWindowControllerDelegate> delegate;
-(id)initWithDelegate:(id<ArtworkWindowControllerDelegate>)delegate;



-(void)update:(BOOL)windowIsOpen;
-(void)updateArtwork;
-(void)updateLabels;
-(void)updateColors:(BOOL)defaultColors;
-(void)updateControlButtons;
-(void)updateMaxValue;
-(void)updateWindowElements;
-(void)updateWindowElementsWithiTunesStopped;
-(void)updateCurrentArtworkFrame;
-(void)updateTrackingAreas;

-(void)updateUIElements;
-(void)toggleWindow;
-(void)openWindow;


-(void)advanceProgress:(NSTimer *)timer;
-(IBAction)playpause:(id)sender;
-(IBAction)next:(id)sender;
-(IBAction)previous:(id)sender;
-(IBAction)sliderDidMove:(id)sender;

-(void)startTimer;
-(void)stopTimer;
-(void)closeWindow;
-(void)showPreferences:(id)sender;
-(void)quitPlayMe:(id)sender;
-(IBAction)closeWindowWithButton:(id)sender;
-(NSString *)trimString:(NSString *)longString :(CGFloat)targetWidth :(NSFont *)font :(NSString *)elipseToBeFilled;
-(BOOL)iTunesIsRunning;

@end