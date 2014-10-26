#import "MenubarController.h"
#import "ArtworkWindowController.h"
#import "PreferencesWindowController.h"
#import "ITunesController.h"

@interface PMAAppDelegate : NSObject
{
    ITunesController *_iTunesController;
    MenubarController *_menubarController;
    ArtworkWindowController *_artworkWindowController;
    PreferencesWindowController *_preferencesWindowController;
}

@property (nonatomic, strong, readonly) ITunesController *iTunesController;
@property (nonatomic, strong, readonly) MenubarController *menubarController;
@property (nonatomic, strong, readonly) ArtworkWindowController *artworkWindowController;
@property (nonatomic, strong, readonly) PreferencesWindowController *preferencesWindowController;

@end