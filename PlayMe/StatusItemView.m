#import "StatusItemView.h"

@implementation StatusItemView

@synthesize statusItem = _statusItem;
@synthesize title = _title;
@synthesize image = _image;
@synthesize alternateImage = _alternateImage;
@synthesize isHighlighted = _isHighlighted;

//##############################################################################
//Initilaizing with an NSStatusItem
//##############################################################################
- (id)initWithStatusItem
{
    _statusItem =[[NSStatusBar systemStatusBar]
                               statusItemWithLength:STATUS_ITEM_VIEW_WIDTH];

    CGFloat itemWidth = [_statusItem length];
    CGFloat itemHeight = [[NSStatusBar systemStatusBar] thickness];
    NSRect itemRect = NSMakeRect(0.0, 0.0, itemWidth, itemHeight);
    self = [super initWithFrame:itemRect];
    
    //StatusItemView has its own status item that get set
    if (self != nil)
    {
        _statusItem.view = self;
    }
    return self;
}

//##############################################################################
//For updating the iTunes informatoin tahts displayed in the menubar
//Know that the name of the rsource image is going to be the same as
//the name of the iTunes status
//##############################################################################
- (void)update:(NSString *)songTitle :(NSString *)iTunesStatus
{
    _title = songTitle;
    _image = [NSImage imageNamed:iTunesStatus];
    _alternateImage =
        [NSImage imageNamed:[iTunesStatus stringByAppendingString:@"White"]];
    [self setNeedsDisplay:YES];
    

}

//##############################################################################
//Draws the resource image and the string of the iTunesStatus
//##############################################################################
- (void)drawRect:(NSRect)dirtyRect
{
    [self.statusItem
     drawStatusBarBackgroundInRect:dirtyRect withHighlight:self.isHighlighted];
    //Deciding which icon to draw...
    NSImage *icon = self.isHighlighted ? self.alternateImage : self.image;
    NSSize iconSize = [icon size];
    NSRect bounds = self.bounds;
    CGFloat iconX = 0;
    CGFloat iconY = roundf((NSHeight(bounds) - iconSize.height) / 2);
    NSPoint iconPoint = NSMakePoint(iconX, iconY);
    
    [icon drawAtPoint:iconPoint
             fromRect:NSZeroRect
            operation:NSCompositeSourceOver
             fraction:1.0];
    
    NSPoint textPoint = NSMakePoint(40, 0);

    //Getting the default menubar font attributes
    //0 means default size
    NSDictionary *attributes =
    @{
                 NSFontAttributeName: [NSFont menuBarFontOfSize: 0],
       NSParagraphStyleAttributeName: [NSParagraphStyle defaultParagraphStyle]
    };
    [_title drawAtPoint:textPoint withAttributes:attributes];
}

#
#pragma mark - mouse events
#
//##############################################################################
//The super is called for both of these methods
//##############################################################################
- (void)mouseDown:(NSEvent *)theEvent
{
    [super mouseDown:theEvent];
}

- (void)rightMouseDown:(NSEvent *)theEvent
{
    [super rightMouseDown:theEvent];
}

#
#pragma mark - setters
#
- (void)setHighlighted:(BOOL)newFlag
{
    if (_isHighlighted == newFlag) return;
    _isHighlighted = newFlag;
    [self setNeedsDisplay:YES];
}


- (void)setImage:(NSImage *)newImage
{
    if (_image != newImage) {
        _image = newImage;
        [self setNeedsDisplay:YES];
    }
}

- (void)setAlternateImage:(NSImage *)newImage
{
    if (_alternateImage != newImage) {
        _alternateImage = newImage;
        if (self.isHighlighted) {
            [self setNeedsDisplay:YES];
        }
    }
}

- (void)setTitle:(NSString *)newTitle
{
    _title = newTitle;
}

#
#pragma mark - getters
#
//##############################################################################
//Used to get the dimenions of the reect in screen coords
//##############################################################################
- (NSRect)globalRect
{

    NSRect frame = [self frame];
    frame.origin = [self.window convertBaseToScreen:frame.origin];
    return frame;
}

@end
