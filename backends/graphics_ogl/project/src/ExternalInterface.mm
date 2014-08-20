#ifndef STATIC_LINK
#define IMPLEMENT_API
#endif

#include <hx/CFFI.h>

#import "GraphicsResponder.h"


static value graphics_plugin_initialize()
{
	[GraphicsResponder initializeGraphics];
	return alloc_null();
}
DEFINE_PRIM (graphics_plugin_initialize, 0);


extern "C" int graphics_plugin_register_prims () { return 0; }