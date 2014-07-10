
#import <Foundation/Foundation.h>

@class StatusItemView;

@interface MenubarController : NSViewController
{
@private
    StatusItemView *_statusItemView;
}

@property (nonatomic, strong, readonly) StatusItemView *statusItemView;
@property (nonatomic) BOOL hasActiveIcon;

-(void)updateSatusItemView:(NSString *)songTitle
              iTunesStatus:(NSString *)iTunesStatusString;

@end
