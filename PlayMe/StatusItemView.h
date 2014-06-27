@interface StatusItemView : NSView
{
@private
    NSImage *_image;
    NSImage *_alternateImage;
    NSStatusItem *_statusItem;
    NSString *title;
    BOOL _isHighlighted;
    SEL _leftaction;
    SEL _rightaction;
    __unsafe_unretained id _target;
}

@property (nonatomic, strong, readonly) NSStatusItem *statusItem;
@property (nonatomic, strong) NSImage *image;
@property (nonatomic, strong) NSImage *alternateImage;
@property (nonatomic, strong) NSString *title;
@property (nonatomic, setter = setHighlighted:) BOOL isHighlighted;
@property (nonatomic, readonly) NSRect globalRect;
@property (nonatomic) SEL leftaction;
@property (nonatomic) SEL rightaction;
@property (nonatomic, unsafe_unretained) id target;

- (id)initWithStatusItem:(NSStatusItem *)statusItem;
- (void)update:(NSString *)songTitle :(NSString *)iTunesStatus;

@end
