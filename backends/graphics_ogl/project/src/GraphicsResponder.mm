#import "GraphicsResponder.h"
#import "GLViewController.h"

@interface GraphicsResponder ()
{
    //AutoGCRoot *_memoryWarningCallback;
}

@end

static UIWindow *__window;

@implementation GraphicsResponder

+ (void) initializeGraphics
{
    __window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    __window.rootViewController = [[GLViewController alloc] init];

    [__window makeKeyAndVisible];
}

@end
