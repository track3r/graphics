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
    public var width: UInt = 0;
    public var height: UInt = 0;

    public var colorFormat : ColorFormat;
    public var depthFormat : DepthFormat;
    public var stencilFormat : StencilFormat;

    public var colorTextureData : TextureData;
    public var depthTextureData : TextureData;
    public var stencilTextureData : TextureData;

    public var discardColor: Bool;
    public var discardDepth: Bool;
    public var discardStencil: Bool;

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

        discardColor = false;
        discardDepth = false;
        discardStencil = false;

        alreadyLoaded = false;

        width = 0;
        height = 0;
    }

    public function invalidate(): Void
    {

    }
}