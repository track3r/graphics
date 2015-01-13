/*
 * Created by IntelliJ IDEA.
 * User: rcam
 * Date: 04/06/14
 * Time: 14:45
 */
package graphics;

import gl.GL;
import gl.GLDefines;
import gl.GLContext;
import graphics.GraphicsTypes;
import haxe.ds.GenericStack;
import graphics.RenderTarget;

import haxe.ds.GenericStack;

class GraphicsContext
{
    public var depthWrite : Null<Bool> = null;
    public var depthFunc : DepthFunc;

    public var stencilingEnabled : Null<Bool> = null;

    public var antialias: Bool;
    public var premultipliedAlpha: Bool;
    public var preserveDrawingBuffer: Bool;

    /// implementation specific
    public var currentShader : GLProgram;
    public var currentAttributeFlags = 0;
    public var currentActiveTextures = new Array<GLTexture>();
    public var currentActiveTexture : Int;
    public var defaultRenderTarget : RenderTarget;
    public var currentRenderTargetStack : GenericStack<RenderTarget>;
    public var currentBlendingEnabled : Bool;
    public var currentBlendFactorSrcRGB : BlendFactor;
    public var currentBlendFactorDestRGB : BlendFactor;
    public var currentBlendFactorSrcA : BlendFactor;
    public var currentBlendFactorDestA : BlendFactor;
    public var currentBlendModeRGB : BlendMode;
    public var currentBlendModeA : BlendMode;
    public var currentFaceCullingMode : FaceCullingMode;
    public var currentLineWidth : Float;
    public var currentDepthTesting : Bool = true;
    public var glContext : GLContext;
    public function new() : Void
    {
        ///only the main context is currently implemented fully
    }
}