#import "GraphicsResponder.h"

@interface GraphicsResponder ()
{
    //AutoGCRoot *_memoryWarningCallback;
}

@end

@implementation GraphicsResponder

+ (void) initializeGraphics
{
    [[UIApplication sharedApplication] delegate].window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];

    [[[UIApplication sharedApplication] delegate].window makeKeyAndVisible];


}

@end
