#import <Foundation/Foundation.h>

@class StatusItemView;

@interface MenubarController : NSViewController


@property (nonatomic, strong, readonly) StatusItemView *statusItemView;
@property (nonatomic, strong) NSStatusItem *statusItem;
@property (nonatomic) BOOL hasActiveIcon;

-(void)updateSatusItemView:(NSString *)songTitle
              iTunesStatus:(NSString *)iTunesStatusString;

@end