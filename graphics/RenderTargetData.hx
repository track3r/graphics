/*
 * Created by IntelliJ IDEA.
 * User: rcam
 * Date: 22/05/14
 * Time: 15:53
 */
package graphics;

import graphics.GraphicsTypes;

extern class RenderTargetData
{
    public var width: UInt;
    public var height: UInt;

    public var colorFormat : ColorFormat;
    public var depthFormat : DepthFormat;
    public var stencilFormat : StencilFormat;

    public var colorTextureData : TextureData;
    public var depthTextureData : TextureData;
    public var stencilTextureData : TextureData;

    // False by default
    public var discardColor: Bool;
    public var discardDepth: Bool;
    public var discardStencil: Bool;
}