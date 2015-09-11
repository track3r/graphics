= Description =

The graphics library bridges the graphics interface over OpenGL and other Graphics APIs (RIP Stage3D).
This is basically our own graphics driver api. Here we could potentially also have backend's for Metal
and DirectX.

= Release Log =

== v7.0.0 ==

- OpenGL major

== v6.0.0 ==

- Removed backend for Flash, since we are not supporting it anymore.
- Renamed RenderTarget to RenderTargetData to be more consistent with other data types.
- Replaced Color4B type by Color4F type for clearColor.
- Using discardFramebuffer extensions if available.
- Using Vertex Array Object if available.

== v5.0.0 ==

- Updated dependency to OpenGL library version 5
- Set minimum version of flash to 11.8 to support npot textures and 4k by 4k textures.
- Added functionality to handle state invalidation. This is needed for recreating the context, if lost.