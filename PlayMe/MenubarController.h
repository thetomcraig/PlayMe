#define STATUS_ITEM_VIEW_WIDTH 128.0

#import <Foundation/Foundation.h>

@class StatusItemView;

@interface MenubarController : NSObject
{
    @private
    StatusItemView *_statusItemView;
}

@property (nonatomic) BOOL hasActiveIcon;
@property (nonatomic, strong, readonly) NSStatusItem *statusItem;
@property (nonatomic, strong, readonly) StatusItemView *statusItemView;

-(void)updateSatusItemView:(NSString *)songTitle
              iTunesStatus:(NSString *)iTunesStatusString;

@end
