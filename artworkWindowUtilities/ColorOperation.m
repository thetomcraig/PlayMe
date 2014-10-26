#import "ColorOperation.h"

@implementation ColorOperation

@synthesize imageController;
@synthesize backgroundColor;
@synthesize primaryColor;
@synthesize secondaryColor;
@synthesize artForAlg;
@synthesize songTitleForAlg;

- (void)main
{
    @autoreleasepool
    {
        if (self.isCancelled)
        {
            return;
        }

        backgroundColor = [NSColor colorWithCalibratedRed:0.0 green:0.0 blue:0.0 alpha:1.0];
        primaryColor = [NSColor colorWithCalibratedRed:1.0 green:1.0 blue:1.0 alpha:1.0];
        secondaryColor = [NSColor colorWithCalibratedRed:1.0 green:1.0 blue:1.0 alpha:1.0];
        [self findColors];
    }
}

-(void)findColors
{
    if (!imageController)
    {
        imageController = [[ImageController alloc] init];
    }
    
    [imageController findColorsOpSeperateThread :artForAlg forSong:songTitleForAlg];
    
    backgroundColor = [imageController.albumColors objectForKey:@"backgroundColor"];
    primaryColor = [imageController.albumColors objectForKey:@"primaryColor"];
    secondaryColor = [imageController.albumColors objectForKey:@"secondaryColor"];
    
    return;
}

@end
