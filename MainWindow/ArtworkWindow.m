#import "artworkWindow.h"

@implementation ArtworkWindow

@synthesize artworkView;

//############################################################################
//I haven't really done a lot in this class, it is essentually a middle-man,
//becuause I do a nlot of work in the ArtworkWindowController and ArtworkView
//classes.  One thing I DID do was made the window transparent, I don't know
//if I needed to though.  I will probably need to do stuff in this class when
//I add functionality to the window and make it detatchable
//############################################################################
-(id)initWithContentRect:(NSRect)contentRect
                styleMask:(NSUInteger)aStyle
                  backing:(NSBackingStoreType)bufferingType
                    defer:(BOOL)flag
{
    //Reslts in a window with no titlebar
    self = [super initWithContentRect:contentRect
                            styleMask:NSBorderlessWindowMask
                              backing:NSBackingStoreBuffered defer:NO];
    if (self != nil)
    {
        [self setAlphaValue:1.0];
        [self setOpaque:NO];
    }
    return self;
}

- (void)setContentView:(NSView *)aView
{
/*
	if ([artworkView isEqualTo:aView])
	{

		return;
	}
    */
	
	NSRect bounds = [self frame];
	bounds.origin = NSZeroPoint;
    
	ArtworkView *frameView = [super contentView];
	if (!frameView)
	{
		frameView = [[ArtworkView alloc] initWithFrame:bounds];
		
		[super setContentView:frameView];
	}
	
    NSView *childContentView;
    
	if (childContentView)
	{
		[childContentView removeFromSuperview];
	}
	childContentView = aView;
	[childContentView setFrame:[self contentRectForFrameRect:bounds]];
	[childContentView setAutoresizingMask:NSViewWidthSizable | NSViewHeightSizable];
	[frameView addSubview:childContentView];
}

-(BOOL)canBecomeKeyWindow
{
    return YES;
}

//############################################################################
//This gets hit when the esc key is pressed; closes the window
//############################################################################
 -(void)keyDown:(NSEvent *)theEvent
 {
     switch([theEvent keyCode])
     {
         case 53:
         {
             [self close];
             NSNotification *iTunesButtonNotification = [NSNotification
                                                         notificationWithName:@"ESCKeyHit"
                                                         object:nil];
             [[NSDistributedNotificationCenter defaultCenter] postNotification:iTunesButtonNotification];
             break;
        }
        default:
        {
            [super keyDown:theEvent];
        }
     }
 }


@end
