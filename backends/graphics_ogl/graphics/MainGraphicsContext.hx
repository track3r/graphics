/*
 * Created by IntelliJ IDEA.
 * User: rcam
 * Date: 04/06/14
 * Time: 14:45
 */
package graphics;

import graphics.GraphicsContext;
import gl.GL;
import gl.GLDefines;
import gl.GLContext;
import graphics.GraphicsTypes;
import haxe.ds.GenericStack;
import graphics.RenderTarget;

import haxe.ds.GenericStack;

class MainGraphicsContext extends GraphicsContext
{
    public function new() : Void
    {
        super();
    }

    public function initialize(finishedCallback : Void->Void)
    {
        currentShader = GL.nullProgram;
        var maxActiveTextures = GraphicsContext.maxActiveTextures;
        currentActiveTexture = maxActiveTextures + 1;

        for(val in 0...maxActiveTextures)
        {
            currentActiveTextures.push(GL.nullTexture);
        }

        currentRenderTargetStack = new GenericStack<RenderTarget>();
        currentLineWidth = 1;
        currentDepthTesting = false;
        GLContext.setupMainContext(function ()
        {
            glContext = GLContext.getMainContext();
            defaultRenderTarget = new RenderTarget();
            defaultRenderTarget.framebufferID = GL.getParameter(GLDefines.FRAMEBUFFER_BINDING);
            currentRenderTargetStack.add(defaultRenderTarget);
            finishedCallback();
        });
    }
}