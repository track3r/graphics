/*
 * Created by IntelliJ IDEA.
 * User: rcam
 * Date: 04/06/14
 * Time: 14:45
 */
package graphics;

import gl.GL;
import gl.GLDefines;
import graphics.GraphicsTypes;
import haxe.ds.GenericStack;
import graphics.RenderTarget;

import haxe.ds.GenericStack;

class GraphicsContext
{
    public var alpha : Bool;
    public var antialias : Bool;
    public var depth : Bool;
    public var premultipliedAlpha : Bool;
    public var preserveDrawingBuffer : Bool;
    public var stencil : Bool;

    /// implementation specific
    public var currentShader : GLProgram;
    public var currentAttributeFlags = 0;
    public var currentActiveTextures = new Array<GLTexture>();
    public var currentActiveTexture : Int;
    public var defaultRenderTarget : RenderTarget;
    public var currentRenderTargetStack : GenericStack<RenderTarget>;
    public var currentBlendFactorSrcRGB : BlendFactor;
    public var currentBlendFactorDestRGB : BlendFactor;
    public var currentBlendFactorSrcA : BlendFactor;
    public var currentBlendFactorDestA : BlendFactor;
    public var currentBlendModeRGB : BlendMode;
    public var currentBlendModeA : BlendMode;
    public var currentFaceCullingMode : FaceCullingMode;
    public var currentLineWidth : Float;
    public var currentDepthWrite : Bool;
    public var currentDepthTesting : Bool;

    public function new() : Void
    {
        currentShader = GL.nullProgram;
        var maxActiveTextures = Graphics.maxActiveTextures;
        currentActiveTexture = maxActiveTextures + 1;
        for(val in 0...maxActiveTextures)
        {
            currentActiveTextures.push(GL.nullTexture);
        }

        currentRenderTargetStack = new GenericStack<RenderTarget>();
        currentLineWidth = 1;
        currentDepthTesting = false;
        currentDepthWrite = true;

        /// TEMPORARY, this is supposed to be created with each platform specific implementation
        defaultRenderTarget = new RenderTarget();
        defaultRenderTarget.framebufferID = GL.getParameter(GLDefines.FRAMEBUFFER_BINDING);
        currentRenderTargetStack.add(defaultRenderTarget);
    }
}