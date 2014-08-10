#import <Foundation/Foundation.h>

@class StatusItemView;

@interface MenubarController : NSViewController

@property (nonatomic, strong) NSStatusItem *statusItem;
@property (nonatomic, strong) StatusItemView *statusItemView;

@end