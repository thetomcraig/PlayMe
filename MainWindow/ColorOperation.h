#import <Foundation/Foundation.h>
#import "ImageController.h"

@interface ColorOperation : NSOperation

@property (retain, nonatomic) ImageController *imageController;

//These needed for the algorithm to run
@property (retain, nonatomic) NSImage *artForAlg;
@property (retain, nonatomic) NSString *songTitleForAlg;

//These will be found after the algorithm completes
@property (retain, nonatomic) NSColor *backgroundColor;
@property (retain, nonatomic) NSColor *primaryColor;
@property (retain, nonatomic) NSColor *secondaryColor;

-(void)findColors;

@end
