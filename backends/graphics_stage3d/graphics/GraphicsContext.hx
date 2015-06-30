/*
 * Created by IntelliJ IDEA.
 * User: epai
 * Date: 06/06/14
 * Time: 14:00
 */
package graphics;

import flash.geom.Rectangle;
import flash.display3D.textures.Texture;
import flash.display3D.Context3D;
import graphics.GraphicsTypes;
import haxe.ds.GenericStack;
import graphics.RenderTarget;

import haxe.ds.GenericStack;

class GraphicsContext
{
    static public var maxActiveTextures = 16;

    public var depthWrite : Null<Bool> = null;
    public var depthFunc : DepthFunc;

    public var stencilingEnabled : Null<Bool> = null;

    public var antialias: Bool;
    public var premultipliedAlpha: Bool;
    public var preserveDrawingBuffer: Bool;

    public var currentBlendFactorSrc : BlendFactor;
    public var currentBlendFactorDest : BlendFactor;

    public var defaultRenderTarget : RenderTarget;
    public var currentActiveTextures = new Array<Texture>();
    public var currentActiveTexture : Int;

    public var currentFaceCullingMode : FaceCullingMode;
    public var currentRenderTargetStack:GenericStack<RenderTarget>;

    public var currentScissoringEnabled : Bool;
    public var currentScissorRect : Rectangle = null;

    public var currentStencilFunc : StencilFunc = StencilFuncAlways;
    public var currentReferenceValue : Int = 0;
    public var currentStencilReadMask : Int = 255;   // All 1111s
    public var currentStencilWriteMask : Int = 255;   // All 1111s

    public var currentStencilFail : StencilOp = StencilOpKeep;
    public var currentDepthFail : StencilOp = StencilOpKeep;
    public var currentStencilAndDepthPass : StencilOp = StencilOpKeep;


    public var context3D(get_context3D, set_context3D):Context3D;
    private var _context3D:Context3D;

    public function get_context3D():Context3D {
        return _context3D;
    }

    public function set_context3D(value:Context3D):Context3D {
        this._context3D = value;
        return this._context3D;
    }

    public function new():Void
    {
        currentRenderTargetStack = new GenericStack<RenderTarget>();
        defaultRenderTarget = new RenderTarget();
        currentRenderTargetStack.add(defaultRenderTarget);
    }

    public function invalidateCaches(): Void
    {
        currentActiveTexture = maxActiveTextures + 1;

        for (i in 0...maxActiveTextures)
        {
            currentActiveTextures[i] = null;
        }
    }
}