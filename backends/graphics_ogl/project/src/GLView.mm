/*
     File: GLView.m
 Abstract: The OpenGL ES view which renders a rotating cube. Responsible for creating a CADisplayLink for the new target display when a connection/disconnection occurs.
  Version: 1.0
 
 Disclaimer: IMPORTANT:  This Apple software is supplied to you by Apple
 Inc. ("Apple") in consideration of your agreement to the following
 terms, and your use, installation, modification or redistribution of
 this Apple software constitutes acceptance of these terms.  If you do
 not agree with these terms, please do not use, install, modify or
 redistribute this Apple software.
 
 In consideration of your agreement to abide by the following terms, and
 subject to these terms, Apple grants you a personal, non-exclusive
 license, under Apple's copyrights in this original Apple software (the
 "Apple Software"), to use, reproduce, modify and redistribute the Apple
 Software, with or without modifications, in source and/or binary forms;
 provided that if you redistribute the Apple Software in its entirety and
 without modifications, you must retain this notice and the following
 text and disclaimers in all such redistributions of the Apple Software.
 Neither the name, trademarks, service marks or logos of Apple Inc. may
 be used to endorse or promote products derived from the Apple Software
 without specific prior written permission from Apple.  Except as
 expressly stated in this notice, no other rights or licenses, express or
 implied, are granted by Apple herein, including but not limited to any
 patent rights that may be infringed by your derivative works or by other
 works in which the Apple Software may be incorporated.
 
 The Apple Software is provided by Apple on an "AS IS" basis.  APPLE
 MAKES NO WARRANTIES, EXPRESS OR IMPLIED, INCLUDING WITHOUT LIMITATION
 THE IMPLIED WARRANTIES OF NON-INFRINGEMENT, MERCHANTABILITY AND FITNESS
 FOR A PARTICULAR PURPOSE, REGARDING THE APPLE SOFTWARE OR ITS USE AND
 OPERATION ALONE OR IN COMBINATION WITH YOUR PRODUCTS.
 
 IN NO EVENT SHALL APPLE BE LIABLE FOR ANY SPECIAL, INDIRECT, INCIDENTAL
 OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
 SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
 INTERRUPTION) ARISING IN ANY WAY OUT OF THE USE, REPRODUCTION,
 MODIFICATION AND/OR DISTRIBUTION OF THE APPLE SOFTWARE, HOWEVER CAUSED
 AND WHETHER UNDER THEORY OF CONTRACT, TORT (INCLUDING NEGLIGENCE),
 STRICT LIABILITY OR OTHERWISE, EVEN IF APPLE HAS BEEN ADVISED OF THE
 POSSIBILITY OF SUCH DAMAGE.
 
 Copyright (C) 2013 Apple Inc. All Rights Reserved.
 
 */

#import <OpenGLES/ES2/gl.h>
#import <OpenGLES/ES2/glext.h>
#import <QuartzCore/QuartzCore.h>

#import "GLView.h"

static double GetTimeMS()
{
	return (CACurrentMediaTime()*1000.0);
}

@interface GLView ()
{
    NSInteger _animationFrameInterval;
	CADisplayLink *_displayLink;
    
    EAGLContext *_context;
	
	// The pixel dimensions of the CAEAGLLayer
	GLint _backingWidth;
	GLint _backingHeight;
	
	// The OpenGL names for the framebuffer and renderbuffer used to render to this view
	GLuint _defaultFramebuffer, _colorRenderbuffer;
    
    // The OpenGL frame for the depth buffer
    GLuint _depthRenderbuffer;
    
    double _renderTime;
    BOOL _zeroDeltaTime;


    // HAXE
    //AutoGCRoot *_drawCallback;
}

@end


@implementation GLView

+ (Class)layerClass
{
    return [CAEAGLLayer class];
}

- (instancetype)initWithFrame:(CGRect)frame
{
    if ((self = [super initWithFrame:frame]))
    {
        // Get the layer
        CAEAGLLayer *eaglLayer = (CAEAGLLayer *)self.layer;
        
        eaglLayer.opaque = TRUE;
        eaglLayer.drawableProperties = [NSDictionary dictionaryWithObjectsAndKeys:
                                        [NSNumber numberWithBool:FALSE], kEAGLDrawablePropertyRetainedBacking, kEAGLColorFormatRGBA8, kEAGLDrawablePropertyColorFormat, nil];
		
		_context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
        
        if (!_context || ![EAGLContext setCurrentContext:_context])
		{
            return nil;
        }
        
        [self setupGL];
        
		_animating = FALSE;
        _animationFrameInterval = 1;
		_displayLink = nil;
        
        _zeroDeltaTime = TRUE;
    }
    
    return self;
}

- (void)setupGL
{
    // Create default framebuffer object. The backing will be allocated for the current layer in -resizeFromLayer
    glGenFramebuffers(1, &_defaultFramebuffer);
    glGenRenderbuffers(1, &_colorRenderbuffer);
    glBindFramebuffer(GL_FRAMEBUFFER, _defaultFramebuffer);
    glBindRenderbuffer(GL_RENDERBUFFER, _colorRenderbuffer);
    glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_RENDERBUFFER, _colorRenderbuffer);
    
    // Create a depth buffer as we want to enable GL_DEPTH_TEST in this sample
    glGenRenderbuffers(1, &_depthRenderbuffer);

    glEnable(GL_DEPTH_TEST);
}

- (void)drawView:(id)sender
{
    double currentTime = GetTimeMS();
    double deltaTime = _zeroDeltaTime ? 0.0 : currentTime - _renderTime;
    _renderTime = currentTime;
    
    if (_zeroDeltaTime)
        _zeroDeltaTime = FALSE;

    [EAGLContext setCurrentContext:_context];


    // ourRendering here

    glBindFramebuffer(GL_FRAMEBUFFER, _defaultFramebuffer);
    glViewport(0, 0, _backingWidth, _backingHeight);

    glClearColor(1.00f, 0.65f, 0.00f, 1.0f);
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);


    glBindRenderbuffer(GL_RENDERBUFFER, _colorRenderbuffer);
    [_context presentRenderbuffer:GL_RENDERBUFFER];

    // ourrending ends here
}

- (BOOL)resizeFromLayer
{
    CAEAGLLayer *layer = (CAEAGLLayer*)self.layer;
    
	// Allocate color buffer backing based on the current layer size
    glBindRenderbuffer(GL_RENDERBUFFER, _colorRenderbuffer);
    [_context renderbufferStorage:GL_RENDERBUFFER fromDrawable:layer];
	glGetRenderbufferParameteriv(GL_RENDERBUFFER, GL_RENDERBUFFER_WIDTH, &_backingWidth);
    glGetRenderbufferParameteriv(GL_RENDERBUFFER, GL_RENDERBUFFER_HEIGHT, &_backingHeight);
    
    // Allocate storage for the depth buffer, and attach it to the framebuffer’s depth attachment point
    glBindRenderbuffer(GL_RENDERBUFFER, _depthRenderbuffer);
    glRenderbufferStorage(GL_RENDERBUFFER, GL_DEPTH_COMPONENT16, _backingWidth, _backingHeight);
    glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_DEPTH_ATTACHMENT, GL_RENDERBUFFER, _depthRenderbuffer);

    if (glCheckFramebufferStatus(GL_FRAMEBUFFER) != GL_FRAMEBUFFER_COMPLETE)
    {
        NSLog(@"Failed to make complete framebuffer object %x", glCheckFramebufferStatus(GL_FRAMEBUFFER));
        return NO;
    }
        
    return YES;
}

- (void)layoutSubviews
{
	if ([self resizeFromLayer])
    {
        // An external display might just have been connected/disconnected. We do not want to
        // consider time spent in the connection/disconnection in the animation.
        _zeroDeltaTime = TRUE;
        [self drawView:nil];
    }
}

#pragma Display Link 

- (NSInteger)animationFrameInterval
{
	return _animationFrameInterval;
}

- (void)setAnimationFrameInterval:(NSInteger)frameInterval
{
	// Frame interval defines how many display frames must pass between each time the
	// display link fires. The display link will only fire 30 times a second when the
	// frame internal is two on a display that refreshes 60 times a second. The default
	// frame interval setting of one will fire 60 times a second when the display refreshes
	// at 60 times a second. A frame interval setting of less than one results in undefined
	// behavior.
	if (frameInterval >= 1)
	{
		_animationFrameInterval = frameInterval;
		
		if (_animating)
		{
			[self stopAnimation];
			[self startAnimation];
		}
	}
}

- (void)startAnimation
{
	if (!_animating)
	{
	    // A CADisplayLink created using the class method is always bound to the internal display.
        _displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(drawView:)];

        [_displayLink setFrameInterval:self.animationFrameInterval];
        [_displayLink addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];

        _zeroDeltaTime = TRUE;
		_animating = TRUE;
	}
}

- (void)stopAnimation
{
	if (_animating)
	{
        [_displayLink invalidate];
		_animating = FALSE;
	}
}

- (void)dealloc
{
    // tear down OpenGL
	if (_defaultFramebuffer)
	{
		glDeleteFramebuffers(1, &_defaultFramebuffer);
		_defaultFramebuffer = 0;
	}
	
	if (_colorRenderbuffer)
	{
		glDeleteRenderbuffers(1, &_colorRenderbuffer);
		_colorRenderbuffer = 0;
	}
    
    // tear down context
	if ([EAGLContext currentContext] == _context)
        [EAGLContext setCurrentContext:nil];


    if (_displayLink != nil)
    {
        [_displayLink invalidate];
    }

    if (_context != nil)
    {
        [_context release];
    }
}

@end
