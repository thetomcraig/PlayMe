#import "ControlButtonsCell.h"

@implementation ControlButtonsCell

@synthesize buttonsColor;

//############################################################################
//This is overriden, so the color of the image can be whaetever we want.
//The resource is white, but we colorize it.  I believe this method makes a
//mask from the original image, so it doesn't really matter what color the
//original image is.  It tests if the image has "depressed" in the name
//if it does it is darkened, because the buttons should get darker when they
//are clicked.
//############################################################################
-(void)drawImage:(NSImage*)image withFrame:(NSRect)frame inView:(NSView*)controlView
{    
    NSGraphicsContext *ctx = [NSGraphicsContext currentContext];
    CGContextRef contextRef = [ctx graphicsPort];
    
    NSData *data = [image TIFFRepresentation];
    CGImageSourceRef source = CGImageSourceCreateWithData((__bridge CFDataRef)data, NULL);
    
    CGImageRef imageRef = CGImageSourceCreateImageAtIndex(source, 0, NULL);
    CFRelease(source);
    
    CGContextSaveGState(contextRef);
    {
        //These two lines account for the flipping of the image when the
        //cliptomask operation is performed
        CGContextTranslateCTM(contextRef, 0, frame.size.height);
        CGContextScaleCTM(contextRef, 1.0, -1.0);
        
        //Magical line that clips the rect the mask (resource image)
        CGContextClipToMask(contextRef, NSRectToCGRect(frame), imageRef);
        
        if ([image.name rangeOfString:@"Depressed"].location == NSNotFound)
        {
            [buttonsColor setFill];
            NSRectFill(frame);
        } else
        {
            CGFloat hue, saturation, brightness, alpha;
            [buttonsColor getHue:&hue saturation:&saturation
                      brightness:&brightness alpha:&alpha];
            
            brightness -= 0.25;
            NSColor *darkerButtonsColor = [NSColor colorWithCalibratedHue:hue
                                                               saturation:saturation
                                                               brightness:brightness
                                                                    alpha:alpha];
            [darkerButtonsColor setFill];
            NSRectFill(frame);
        }
    }
    CGContextRestoreGState(contextRef);
    
    CFRelease(imageRef);
}

@end