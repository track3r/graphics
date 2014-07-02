/*
 * Created by IntelliJ IDEA.
 * User: epai
 * Date: 04/06/14
 * Time: 17:35
 */
package graphics;

import types.SizeI;
import types.Color4B;
import graphics.GraphicsTypes;

class RenderTarget
{
    public var size : SizeI;

    public var colorFormat : ColorFormat;
    public var depthFormat : DepthFormat;
    public var stencilFormat : StencilFormat;

    public var colorTextureData : TextureData;
    public var depthTextureData : TextureData;
    public var stencilTextureData : TextureData;

    public var currentClearColor : Color4B;
    public var alreadyLoaded : Bool;

    public function new () : Void
    {
        currentClearColor = new Color4B();
        alreadyLoaded = false;
    }

}