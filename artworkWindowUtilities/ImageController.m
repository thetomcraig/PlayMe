#import "ImageController.h"

#define ARTWORK_WIDTH 400
#define ARTWORK_HEIGHT 400
#define WINDOW_HEIGHT 500

@implementation ImageController

@synthesize bgBlack;
@synthesize albumColorPicker;
@synthesize albumColors;
@synthesize lastArtCalculated;
@synthesize nothingPlaying;

//############################################################################
//The threshold is used for clipping nonsquare images
//The placeholder is used when there is not artwork or nothing is playing
//The color picker is used to find the colors of the current album
//The the album colors dict holds the found colors
//############################################################################
-(id)init
{
    self = [super init];
    if (self)
    {
         self.albumColors = [[NSDictionary alloc] initWithObjectsAndKeys:@"backgroundColor",
                            @"primaryColor", @"secondaryColor", @"detailColor",
                            nil, nil, nil, nil, nil];

        self.lastArtCalculated = @"";
        
        nothingPlaying = [NSImage imageNamed:@"NothingPlaying"];
        nothingPlaying = [self resizeNothingPlaying];
        nothingPlaying = [self roundCorners:nothingPlaying];
    }
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
    return true;
}

//Take the art from the iTunes object and get it ready for the window
-(NSImage *)prepareNewArt :(NSImage *)resourceImage :(NSString *)status
{
    if ([status isEqualToString:@"Playing"])
    {
        NSImage *square_art = [self clipArtToSquare:resourceImage];
        NSImage *small_art = [self resizeArt:square_art];
        NSImage *rounded_art = [self roundCorners:small_art];
        return rounded_art;
    }

    else if ([status isEqualToString:@"Paused"])
    {
        NSImage *square_art = [self clipArtToSquare:resourceImage];
        NSImage *small_art = [self resizeArt:square_art];
        [self putOnPausedMask:small_art];
        NSImage *rounded_art = [self roundCorners:small_art];
        return rounded_art;
    }
    
    //Stopepd case should not be passed to this fn.
    
    return resourceImage;
}

//Check is difference between width and height is under the threshold;
//it's then considered 'square' and just clipped.  It it's above the threshold,
//It's just resized and letterboxed
-(NSImage *)clipArtToSquare :(NSImage *)nonSquareArt
{
    [nonSquareArt setScalesWhenResized:YES];
    [[NSGraphicsContext currentContext] setImageInterpolation:NSImageInterpolationHigh];
 
    threshold = ARTWORK_WIDTH*.075;
    if (0 < abs((int)nonSquareArt.size.height -(int)nonSquareArt.size.width) &&
        abs((int)nonSquareArt.size.height - (int)nonSquareArt.size.width) < threshold)
    {
        NSSize zoomedSize = NSMakeSize(0.0, 0.0);
        
        if (nonSquareArt.size.width < nonSquareArt.size.height)
        {
            zoomedSize.height = nonSquareArt.size.width;
            zoomedSize.width = nonSquareArt.size.width;
        }
        else if (nonSquareArt.size.height < nonSquareArt.size.width)
        {
            zoomedSize.height = nonSquareArt.size.height;
            zoomedSize.width = nonSquareArt.size.height;
        }
        
        NSImage *zoomedArt = [[NSImage alloc] initWithSize: zoomedSize];
        
        [zoomedArt lockFocus];
        [nonSquareArt setSize: zoomedSize];
        [nonSquareArt drawAtPoint:NSZeroPoint fromRect:NSZeroRect operation:NSCompositeSourceOver fraction:1.0];
        [zoomedArt unlockFocus];
        return zoomedArt;
    }
    
    //Fallback, didn't need to do anything
    return nonSquareArt;
}

//make it the target size
-(NSImage *)resizeArt :(NSImage *)bigArt
{
    double targetWidth = ARTWORK_WIDTH;
    double targetHeight = 0.0;
    
    //Set all these values properly based on relationship between h and w of
    //the bigArt
    //The new size of a non-square artwork
    NSSize newRectangularSize;
    //The new point at which to draw the artwork
    NSPoint centerPoint;
    
    //CASE 1: W < H
    // _____
    // |   |
    // |   |
    // |___|
    //  
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
    
    //CASE 2: W > H and W == H
    //                _______
    // ----------     |     |
    // |        | OR  |     |
    // |________|     |_____|
    //
    else
    {
        //If it's square, we make it this size
        double divisionFactor = [bigArt size].width/targetWidth;
        //If it's not square, we use this to resize
        targetHeight = [bigArt size].height/divisionFactor;
        newRectangularSize = NSMakeSize(targetWidth, targetHeight);
        centerPoint = NSMakePoint(0.0, targetWidth/2 - targetHeight/2);
    }
    
    //Black square background, that goes behind the artwork
    //This letterboxes nonsquare artwork
    NSSize newSquareSize = NSMakeSize(ARTWORK_WIDTH, ARTWORK_WIDTH);
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
    
    //Finally, resizing and letterboxing if needed
    NSRect smallRect = NSMakeRect(0.0, 0.0, targetWidth, targetHeight);
    NSImage *smallArt = [[NSImage alloc] initWithSize: newSquareSize];
    
    [smallArt lockFocus];
    [bigArt setSize: newRectangularSize];
    
    [bgBlack drawAtPoint:NSZeroPoint
                fromRect:NSZeroRect
               operation:NSCompositeSourceOver
                fraction:1.0];
    
    
    [bigArt drawAtPoint:centerPoint
               fromRect:smallRect
              operation:NSCompositeSourceOver
               fraction:1.0];
    
    [smallArt unlockFocus];
    
    return smallArt;
}

//############################################################################
//This is a stripped down version of the resizeArt function, and it resized
//the nothing playing resource image
//############################################################################
-(NSImage *)resizeNothingPlaying
{
    NSImage *bigArt = [NSImage imageNamed:@"NothingPlaying"];
    NSSize targetSize = NSMakeSize(ARTWORK_WIDTH, ARTWORK_HEIGHT);
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
-(NSImage *)resizeResource :(NSImage *) origImage :(NSSize)targetSize
{
    return origImage;
}

//############################################################################
//If iTunes is paused, we want to show semi-transparent mask over the artwork.
//############################################################################
-(void)putOnPausedMask :(NSImage *)art
{
    NSImage *mask = [NSImage imageNamed:@"PausedMask"];
    NSSize smallSize = NSMakeSize(art.size.width, art.size.height);
    [mask setSize:smallSize];

    [art lockFocus];
    [mask drawAtPoint:NSZeroPoint fromRect:NSZeroRect
            operation:NSCompositeSourceOver fraction:.65];
    [art unlockFocus];
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
