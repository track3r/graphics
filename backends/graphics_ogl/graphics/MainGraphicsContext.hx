/*
 * Created by IntelliJ IDEA.
 * User: rcam
 * Date: 04/06/14
 * Time: 14:45
 */
package graphics;

import gl.GLExtDefines;
import gl.GLExt;
import haxe.ds.Vector;
import graphics.GraphicsContext;
import gl.GL;
import gl.GLDefines;
import gl.GLContext;
import graphics.GraphicsTypes;
import haxe.ds.GenericStack;
import graphics.RenderTargetData;

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

        currentRenderTargetDataStack = new GenericStack<RenderTargetData>();
        currentLineWidth = 1;
        currentDepthTesting = false;

        GLContext.setupMainContext(function ()
        {
            glContext = GLContext.getMainContext();
            defaultRenderTargetData = new RenderTargetData();
            defaultRenderTargetData.framebufferID = GL.getParameter(GLDefines.FRAMEBUFFER_BINDING);
            defaultRenderTargetData.discardColor = true;
            defaultRenderTargetData.discardDepth = true;
            defaultRenderTargetData.discardStencil = true;
            currentRenderTargetDataStack.add(defaultRenderTargetData);

            determinePlatformGraphicsCapabilities();

            finishedCallback();
        });
    }

    private function determinePlatformGraphicsCapabilities(): Void
    {
        GraphicsContext.vendor = GL.getParameter(GLDefines.VENDOR);
        GraphicsContext.version = GL.getParameter(GLDefines.VERSION);
        GraphicsContext.renderer = GL.getParameter(GLDefines.RENDERER);

        var extensions: Vector<String> = null;
        var extensionsArray: Array<String> = null;

#if html5
        extensionsArray = GL.getSupportedExtensions();
        extensions = Vector.fromArrayCopy(extensionsArray);
#else
        var extensionsString: String = GL.getParameter(GLDefines.EXTENSIONS);

        if (extensionsString != null)
        {
            extensionsArray = extensionsString.split(" ");
            extensions = new Vector(extensionsArray.length - 1);

            for (index in 0...extensionsArray.length - 1)
            {
                extensions[index] = extensionsArray[index];
            }
        }
        else
        {
            extensionsArray = new Array();
            extensions = new Vector(1);
            extensions[0] = "GL_INVALID_ENUM";
        }
#end
        GraphicsContext.extensions = extensions;

        if (extensionsArray.indexOf(GLExtDefines.EXT_discard_framebuffer) != -1)
        {
            this.supportsDiscardRenderTarget = true;
        }
    }
}