/*
 * Created by IntelliJ IDEA.
 * User: rcam
 * Date: 04/06/14
 * Time: 17:35
 */
package graphics;

import gl.GL;
import types.SizeI;
import types.Color4B;
import graphics.GraphicsTypes;

class RenderTargetData
{
    public var size : SizeI;

    public var colorFormat : ColorFormat;
    public var depthFormat : DepthFormat;
    public var stencilFormat : StencilFormat;

    public var colorTextureData : TextureData;
    public var depthTextureData : TextureData;
    public var stencilTextureData : TextureData;

    public var clearColor : Color4B;

    public var currentClearColor : Color4B;

    /// GL Specific data
    public var alreadyLoaded : Bool;
    public var framebufferID : GLFramebuffer;
    public var colorRenderbufferID : GLRenderbuffer;
    public var depthRenderbufferID : GLRenderbuffer;
    public var stencilRenderbufferID : GLRenderbuffer;
    public var depthStencilRenderbufferID : GLRenderbuffer;

    public function new () : Void
    {
        colorRenderbufferID = GL.nullRenderbuffer;
        depthRenderbufferID = GL.nullRenderbuffer;
        stencilRenderbufferID = GL.nullRenderbuffer;
        depthStencilRenderbufferID = GL.nullRenderbuffer;
        framebufferID = GL.nullFramebuffer;

        clearColor = new Color4B();
        currentClearColor = new Color4B();

        size = new SizeI();

        alreadyLoaded = false;
    }

    public function invalidate(): Void
    {
        currentClearColor.setRGBA(0, 0, 0, 255);
    }

}