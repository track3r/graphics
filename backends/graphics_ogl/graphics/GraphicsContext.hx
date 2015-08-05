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
import graphics.RenderTargetData;

import haxe.ds.GenericStack;

class GraphicsContext
{
    static public var maxActiveTextures = 16;

    public var depthWrite : Null<Bool> = null;
    public var depthFunc : Null<DepthFunc> = null;

    public var stencilingEnabled : Null<Bool> = null;

    public var antialias: Bool;
    public var premultipliedAlpha: Bool;
    public var preserveDrawingBuffer: Bool;

    /// implementation specific
    public var currentShader : GLProgram;
    public var currentAttributeFlags = 0;
    public var currentActiveTextures = new Array<GLTexture>();
    public var currentActiveTexture : Int;
    public var defaultRenderTargetData : RenderTargetData;
    public var currentRenderTargetDataStack : GenericStack<RenderTargetData>;
    public var currentBlendingEnabled : Null<Bool>;
    public var currentBlendFactorSrcRGB : BlendFactor;
    public var currentBlendFactorDestRGB : BlendFactor;
    public var currentBlendFactorSrcA : BlendFactor;
    public var currentBlendFactorDestA : BlendFactor;
    public var currentBlendModeRGB : BlendMode;
    public var currentBlendModeA : BlendMode;
    public var currentFaceCullingMode : Null<FaceCullingMode>;
    public var currentLineWidth : Null<Float> = 1.0;
    public var currentDepthTesting : Null<Bool> = true;
    public var glContext : GLContext;

    public function new() : Void
    {
        ///only the main context is currently implemented fully
    }

    public function invalidateCaches(): Void
    {
        currentAttributeFlags = 0;

        currentLineWidth = null;
        currentActiveTexture = maxActiveTextures + 1;
        currentShader = GL.nullProgram;

        currentBlendingEnabled = null;
        stencilingEnabled = null;
        depthFunc = null;
        depthWrite = null;
        currentDepthTesting = null;
        currentFaceCullingMode = null;

        defaultRenderTargetData.invalidate();
        defaultRenderTargetData.framebufferID = GL.getParameter(GLDefines.FRAMEBUFFER_BINDING);

        for (i in 0...maxActiveTextures)
        {
            currentActiveTextures[i] = GL.nullTexture;
        }
    }
}