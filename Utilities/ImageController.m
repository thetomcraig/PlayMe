#import "ImageController.h"

@implementation ImageController

@synthesize bgBlack;
@synthesize albumColorPicker;
@synthesize albumColors;
@synthesize lastArtCalculated;

//############################################################################
//The threshold is used for clipping nonsquare images
//The placeholder is used when there is not artwork or nothing is playing
//The color picker is used to find the colors of the current album
//The the album colors dict holds the found colors
//############################################################################
-(id)init
{
    self.albumColors = [[NSDictionary alloc] initWithObjectsAndKeys:@"backgroundColor",
                   @"primaryColor", @"secondaryColor", @"detailColor",
                   nil, nil, nil, nil, nil];
    
    self.lastArtCalculated = @"";
    return self;
}

//############################################################################
//We pass both the art and the song title, so it can rememeber what songs it
//calculated art for.  If we ask it to do the same song two times in a row,
//it just quits and doesn't run the algorithm.
//
//Note that it runs this on a seperate thread to not hang the program.
//
//Basically we find out what queue we're working with, make a group and find
//out how long we want to wait for the algorithm, in this case, 6 seconds.
//Then we ASYNCHRONOUSLY run the algorithm.  In the dispatch_group_wait line,
//we see if it found the right colors.
//
//If it finds the right colors, or timesout without having fond any colors,
//it cancels the color algorithm and sends a message so the artwork window
//controller knows there are new colors to work with
//############################################################################
-(BOOL)findColorsOpSeperateThread :(NSImage *)albumArt forSong:(NSString *)songTitle
{
    ///All of this commented out because I have dis-enabled the color stuff for now
    /**
    albumColorPicker = [[AlbumColorPicker alloc] init];
    
    if ([songTitle isEqualToString:lastArtCalculated])
    {
        return false;
    }
    
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    //Group to add blocks to for the work to be done
    dispatch_group_t group = dispatch_group_create();
    //How long to wait on the timeout, the number before
    //"ull" is the number of seconds
    dispatch_time_t time = dispatch_time(DISPATCH_TIME_NOW, 6ull*NSEC_PER_SEC);
    
    //This whole block done asynchonously
    dispatch_async(queue,
                   ^{
                       // Add a task to the group
                       dispatch_group_async(group, queue,
                                            ^{
                                                lastArtCalculated = songTitle;
                                                albumColorPicker.imageToBeAnalyzed = albumArt;
                                                [albumColorPicker start];
                                            });
                       
                       //This checks if the algorithm was successful
                       long result = dispatch_group_wait(group, time);
                       
                       if (result == 0)
                       {
                           //NSLog(@"Successful");
                           albumColors = albumColorPicker.colorDict;
                           [[NSNotificationCenter defaultCenter] postNotificationName:@"colorsUpdated" object:nil];
                           return;
                        }
                       
                       else
                       {
                           //NSLog(@"Unsuccessful");
                           [albumColorPicker cancel];
                           [[NSNotificationCenter defaultCenter] postNotificationName:@"colorsNotUpdated" object:nil];
                           return;
                       }
                   });
     */
    return true;
}

//############################################################################
//Resize the the iTunes art to the size of the window.
//Most of the time it is shrunk
//If given a nonsquare artwork, this algorithm checks for the difference
//between the height and width.  If this difference is over a given threshold,
//the image is letterboxed.  If the difference is under thisthreshold,
//the image is clipped and made square.  I think iTunes does this too, and it
//is hardly noticable on irregular album arts
//############################################################################
-(NSImage *)resizeArt: (NSImage *) bigArt :(NSRect)targetSize
{
    [bigArt setScalesWhenResized:YES];
    [[NSGraphicsContext currentContext] setImageInterpolation:NSImageInterpolationHigh];
    
    double targetWidth = targetSize.size.width;
    double targetHeight = 0.0;
    
    //-------------------------------------------------------------------------
    //If the difference between the original length and height is any less
    //than the threshold, it's considered "square", so no letterbox is applied,
    //instead it is zoomed in until square,
    //This just makes the image square, it still needs to be resized
    //-------------------------------------------------------------------------
    threshold = targetSize.size.width*.075;
    if (0 < abs(bigArt.size.height - bigArt.size.width) &&
        abs(bigArt.size.height - bigArt.size.width) < threshold)
    {
        NSSize zoomedSize = NSMakeSize(0.0, 0.0);
        
        if (bigArt.size.width < bigArt.size.height)
        {
            zoomedSize.height = bigArt.size.width;
            zoomedSize.width = bigArt.size.width;
        }
        else if (bigArt.size.height < bigArt.size.width)
        {
            zoomedSize.height = bigArt.size.height;
            zoomedSize.width = bigArt.size.height;
        }

        NSImage *zoomedArt = [[NSImage alloc] initWithSize: zoomedSize];
        
        [zoomedArt lockFocus];
        [bigArt setSize: zoomedSize];
        [bigArt drawAtPoint:NSZeroPoint fromRect:NSZeroRect operation:NSCompositeSourceOver fraction:1.0];
        [zoomedArt unlockFocus];
        bigArt = zoomedArt ;
    }
    
    //-------------------------------------------------------------------------
    //Putting these here for clairity, used below...
    //-------------------------------------------------------------------------
    //The size that will be used for the back background
    NSSize newSquareSize = NSMakeSize(targetWidth, targetWidth);
    //The new size of a non-square artwork
    NSSize newRectangularSize = NSMakeSize(0.0, 0.0);
    //The new rectangle in which to draw the artwork
    NSRect smallRect = NSMakeRect(0.0, 0.0, 0.0, 0.0);
    //The new point at which to draw the artwork
    NSPoint centerPoint = NSMakePoint(0.0, 0.0);
    
    //-------------------------------------------------------------------------
    //There are three main cases to worry about with "square" images.
    //W > H & W < H & and W == H.  This first case handles W < H
    //-------------------------------------------------------------------------
    if (bigArt.size.height > bigArt.size.width)
    {
        //the target width in the width of the view in the xib
        targetHeight = targetWidth;
        
        //If it's square, we make it this size
        double divisionFactor = [bigArt size].height/targetHeight;
        //If it's not square, we use this to resize
        targetWidth = [bigArt size].width/divisionFactor;
        newRectangularSize = NSMakeSize(targetWidth, targetHeight);
        centerPoint = NSMakePoint(targetHeight/2 - targetWidth/2, 0.0);
    }
    
    //-------------------------------------------------------------------------
    //This case handles W > H and W == H
    //-------------------------------------------------------------------------
    else
    {
        //the target width in the width of the view in the xib
        //If it's square, we make it this size
        double divisionFactor = [bigArt size].width/targetWidth;
        //If it's not square, we use this to resize
        targetHeight = [bigArt size].height/divisionFactor;
        newSquareSize = NSMakeSize(targetWidth, targetWidth);
        newRectangularSize = NSMakeSize(targetWidth, targetHeight);
        centerPoint = NSMakePoint(0.0, targetWidth/2 - targetHeight/2);
    }
    
    //-------------------------------------------------------------------------
    //If the art is not "square", (difference between W & H is above thresh),
    //we want to letterbox it.
    //So we create a black square background, that goes behind the artwork
    //-------------------------------------------------------------------------
    if (targetHeight != targetWidth)
    {
        bgBlack = [[NSImage alloc] initWithSize:newSquareSize];
        [bgBlack lockFocus];
        [[NSGraphicsContext currentContext] setImageInterpolation:NSImageInterpolationHigh];
        NSColor *back = [NSColor colorWithCalibratedRed:0.9 green:0.9 blue:0.9 alpha:1.0];
        [back set];
        NSBezierPath* blackPath = [NSBezierPath bezierPathWithRect
                                   :NSMakeRect(0.0, 0.0,
                                    newSquareSize.width,
                                    newSquareSize.height)];
        [blackPath setWindingRule:NSEvenOddWindingRule];
        [blackPath addClip];
        [blackPath fill];
        [bgBlack unlockFocus];
    }
    
    //-------------------------------------------------------------------------
    //Finally, resizing and letterboxing if needed
    //-------------------------------------------------------------------------
    smallRect = NSMakeRect(0.0, 0.0, targetWidth, targetHeight);
    NSImage *smallArt = [[NSImage alloc] initWithSize: newSquareSize];
    
    [smallArt lockFocus];
    [bigArt setSize: newRectangularSize];
    
    //If the artwork is not square, we draw a black background
    if (bgBlack)
    {
        [bgBlack drawAtPoint:NSZeroPoint
                    fromRect:NSZeroRect
                   operation:NSCompositeSourceOver
                    fraction:1.0];
    }
    
    [bigArt drawAtPoint:centerPoint
               fromRect:smallRect operation:NSCompositeSourceOver fraction:1.0];
    [smallArt unlockFocus];
    
    return smallArt;
}

//############################################################################
//This is a stripped down version of the resizeArt function, and it resized
//the nothing playing resource image
//############################################################################
-(NSImage *)resizeNothingPlaying: (NSSize)targetSize;
{
    NSImage *bigArt = [NSImage imageNamed:@"NothingPlaying"];
    [bigArt setSize:targetSize];

    [bigArt setScalesWhenResized:YES];
    [[NSGraphicsContext currentContext] setImageInterpolation:NSImageInterpolationHigh];
    
    //Here we find out what size the new image needs to be
    double targetHeight = targetSize.height;
    double targetWidth = bigArt.size.width/(bigArt.size.height/targetHeight);
    NSPoint centerPoint = NSMakePoint(0.0, 0.0);
    
    //Creating the rect that is the new size for the image
    NSSize newImageSize = NSMakeSize(targetWidth, targetHeight);
    NSRect smallRect = NSMakeRect(0.0, 0.0, targetWidth, targetHeight);
    
    bgBlack = [[NSImage alloc] initWithSize:newImageSize];
    [bgBlack lockFocus];
    [[NSGraphicsContext currentContext] setImageInterpolation:NSImageInterpolationHigh];
    NSColor *back = [NSColor colorWithCalibratedRed:0.9 green:0.9 blue:0.9 alpha:1.0];
    [back set];
    NSBezierPath* blackPath = [NSBezierPath bezierPathWithRect
                               :NSMakeRect(0.0, 0.0,
                                           newImageSize.width,
                                           newImageSize.height)];
    [blackPath setWindingRule:NSEvenOddWindingRule];
    [blackPath addClip];
    [blackPath fill];
    [bgBlack unlockFocus];
    
    NSImage *smallImage = [[NSImage alloc] initWithSize: newImageSize];
    
    [smallImage lockFocus];
    [bigArt setSize: newImageSize];

    if (bgBlack)
    {
        [bgBlack drawAtPoint:NSZeroPoint
                    fromRect:NSZeroRect
                   operation:NSCompositeSourceOver
                    fraction:1.0];
    }
    
    [bigArt drawAtPoint:centerPoint
               fromRect:smallRect operation:NSCompositeSourceOver fraction:1.0];
    [smallImage unlockFocus];
    
    return smallImage;
}

//############################################################################
//This is used to resize resource images, so they don't look shitty on retina
//############################################################################
-(NSImage *)resizeResource :(NSImage *) origImage :(NSRect)targetSize
{
    return origImage;
}

//############################################################################
//If iTunes is paused, we want to show semi-transparent mask over the artwork.
//############################################################################
-(NSImage *)putOnPausedMask :(NSImage *)art
{
    NSImage *mask = [NSImage imageNamed:@"PausedMask"];
    NSSize smallSize = NSMakeSize(art.size.width, art.size.height);
    [mask setSize:smallSize];

    [art lockFocus];
    [mask drawAtPoint:NSZeroPoint fromRect:NSZeroRect
            operation:NSCompositeSourceOver fraction:.65];
    [art unlockFocus];
    
    return art;
}

//############################################################################
//Round the corners of the artwork because it looks pretty.  We only want to
//round the top two corners, so we do the top and bottom half independently.
//The overlap is where they meet.
//############################################################################
-(NSImage *)roundCorners:(NSImage *)squareArt
{
    int overlap = 10;
    NSImage *roundedArt = [[NSImage alloc] initWithSize:[squareArt size]];
    
    [roundedArt lockFocus];
    [[NSGraphicsContext currentContext] setImageInterpolation:NSImageInterpolationHigh];

    //Doing the bottom half of the image, square
    NSRect bottomHalfRect = NSRectFromCGRect(CGRectMake(0, 0,
                                                        [roundedArt size].width,
                                                        [roundedArt size].height/2 + overlap));
    
    [squareArt drawInRect:bottomHalfRect
                 fromRect:bottomHalfRect
                operation:NSCompositeSourceOver
                 fraction:1.0];
    
    //Doing the top half of the image, rounded
    NSRect topHalfRect = NSRectFromCGRect(CGRectMake(0, [roundedArt size].height/2,
                                                     [roundedArt size].width,
                                                     [roundedArt size].height/2));
    int xClip = 6;
    int yClip = 6;
    NSBezierPath *topHalfPath = [NSBezierPath bezierPathWithRoundedRect:topHalfRect xRadius:xClip yRadius:yClip];
    [topHalfPath setWindingRule:NSEvenOddWindingRule];
    [topHalfPath addClip];

    [squareArt drawInRect:topHalfRect
                 fromRect:topHalfRect
                operation:NSCompositeSourceOver
                 fraction:1.0];
    [roundedArt unlockFocus];
    return roundedArt;
}

@end