/*
 * Created by IntelliJ IDEA.
 * User: rcam
 * Date: 22/05/14
 * Time: 15:53
 */
package graphics;

import types.SizeI;
import types.Color4B;
import graphics.GraphicsTypes;

extern class RenderTargetData
{
    public var size : SizeI;

    public var colorFormat : ColorFormat;
    public var depthFormat : DepthFormat;
    public var stencilFormat : StencilFormat;

    public var colorTextureData : TextureData;
    public var depthTextureData : TextureData;
    public var stencilTextureData : TextureData;

    public var clearColor : Color4B;
}