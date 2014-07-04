package graphics;

import types.Color4B;
import graphics.MeshData;
import graphics.Shader;
import graphics.TextureData;
import graphics.GraphicsTypes;
import graphics.GLUtils;
import graphics.GraphicsContext;

import gl.GL;
import gl.GLDefines;

import types.DataType;
import types.Data;

import haxe.ds.GenericStack;

#if cpp
import cpp.vm.Thread;
#end

#if html5
import platform.Platform;
import lime.Lime;
#end

class Graphics
{
#if cpp
    private var contextStackPerThread : Map<Dynamic, GenericStack<GraphicsContext> >;
#else
    private var contextStack : GenericStack<GraphicsContext>;
#end

	private function new() 
	{
		#if html5
		GL.context = Platform.instance().lime.render.direct_renderer_handle;
		#end


        #if cpp
            contextStackPerThread = new Map<Thread, GenericStack<GraphicsContext>>();
        #else
            contextStack = new GenericStack<GraphicsContext>();
        #end


	}

    public static function initialize(callback:Void->Void)
    {

        sharedInstance = new Graphics();

        ///TEMPORARY
        var context = new GraphicsContext();
        sharedInstance.pushContext(new GraphicsContext());

        ///blending is not enabled by default on webgl
        GL.enable(GLDefines.BLEND);
        ///clear color is black by default on webgl
        GL.clearColor(1.0, 1.0, 1.0, 1.0);

        callback();
    }

	static var sharedInstance : Graphics;
	public static function instance() : Graphics
	{
		return sharedInstance;
	}

	public static var maxActiveTextures = 16;


    public function loadFilledContext(context : GraphicsContext) : Void
    {

    }

    public function isLoadedContext(context:GraphicsContext) : Void
    {

    }

    public function unloadFilledContext(context : GraphicsContext) : Void
    {

    }

    public function getCurrentContext() : GraphicsContext
    {
        #if cpp
        if(!contextStackPerThread.exists(Thread.current().handle))
        {
            return null;
        }
        else
        {
            return contextStackPerThread[Thread.current().handle].first();
        }
        #else
        return contextStack.first();
        #end

    }

    public function pushContext(context : GraphicsContext) : Void
    {
        #if cpp
            if(!contextStackPerThread.exists(Thread.current().handle))
            {
                contextStackPerThread.set(Thread.current().handle, new GenericStack<GraphicsContext>());
            }
            contextStackPerThread.get(Thread.current().handle).add(context);
        #else
            contextStack.add(context);
        #end
    }

    public function popContext(context : GraphicsContext) : Void
    {
        #if cpp
            if(contextStackPerThread.exists(Thread.current().handle))
            {
                contextStackPerThread.get(Thread.current().handle).pop();
            }
        #else
            contextStack.pop();
        #end


    }

	public function loadFilledMeshData(meshData : MeshData)
	{
		if(meshData == null)
			return;

		loadFilledMeshDataBuffer(GLDefines.ARRAY_BUFFER, cast meshData.attributeBuffer);
		loadFilledMeshDataBuffer(GLDefines.ELEMENT_ARRAY_BUFFER, cast meshData.indexBuffer);
	}
	
	public function loadFilledMeshDataBuffer(bufferType : Int, meshDataBuffer : MeshDataBuffer)
	{
		if(meshDataBuffer == null)
			return;

		if(!meshDataBuffer.bufferAlreadyOnHardware)
		{
			meshDataBuffer.glBuffer = GL.createBuffer();
			meshDataBuffer.sizeOfHardwareBuffer = 0;
		}

		if(meshDataBuffer.data != null)
		{
			if(meshDataBuffer.data.offsetLength < meshDataBuffer.sizeOfHardwareBuffer)
			{
				GL.bindBuffer(bufferType, meshDataBuffer.glBuffer);
				GL.bufferSubData(bufferType, 0, meshDataBuffer.data);
			}
			else
			{
				GL.bindBuffer(bufferType, meshDataBuffer.glBuffer);
				GL.bufferData(bufferType, meshDataBuffer.data,
							  GLUtils.convertBufferModeToOGL(meshDataBuffer.bufferMode));

			}
			meshDataBuffer.sizeOfHardwareBuffer = meshDataBuffer.data.offsetLength;
			meshDataBuffer.bufferAlreadyOnHardware = true;
		}
		GL.bindBuffer(bufferType, GL.nullBuffer);
	}


	public function loadFilledShader(shader : Shader) 
	{
		if(shader.alreadyLoaded)
			return;


		/// COMPILE

		var vs = compileShader(GLDefines.VERTEX_SHADER, shader.vertexShaderCode);

		if(vs == GL.nullShader)
		{
			trace("Failed to compile vertex shader:" + shader.name);
			return;
		}

		var fs = compileShader(GLDefines.FRAGMENT_SHADER, shader.fragmentShaderCode);

		if(fs == GL.nullShader)
		{
			trace("Failed to compile fragment shader:" + shader.name);
			return;
		}

		/// CREATE

		shader.programName = GL.createProgram();
		GL.attachShader(shader.programName, vs);
		GL.attachShader(shader.programName, fs);
		
		/// BIND ATTRIBUTE LOCATIONS

		for(i in 0...shader.attributeNames.length)
		{
			var attribute : String = shader.attributeNames[i];
			GL.bindAttribLocation(shader.programName, i, attribute);
		}		


		/// LINK

		if(!linkShader(shader.programName))
		{
			trace("Failed to link program " + shader.name);

			if(vs != GL.nullShader)
			{
				GL.deleteShader(vs);
			}
			if(fs != GL.nullShader)
			{
				GL.deleteShader(fs);
			}

			GL.deleteProgram(shader.programName);
			return;
		}

		/// BIND UNIFORM LOCATIONS

		if(shader.uniformInterfaces != null)
		{
			for(uniInterface in shader.uniformInterfaces)
			{
				var uniformLocation : GLUniformLocation;
				uniformLocation = GL.getUniformLocation(shader.programName, uniInterface.shaderVariableName);

				if(uniformLocation == GL.nullUniformLocation)
				{
					trace("Failed to link uniform " + uniInterface.shaderVariableName + " in shader: " + shader.name);
				}
				uniInterface.uniformLocation = uniformLocation;
			}
		}

		/// CLEANUP

		if(vs != GL.nullShader)
		{
			GL.detachShader(shader.programName, vs);
			GL.deleteShader(vs);
		}
		if(fs != GL.nullShader)
		{
			GL.detachShader(shader.programName, fs);
			GL.deleteShader(fs);
		}

        shader.alreadyLoaded = true;
	}

	private function compileShader(type : Int, code : String) : GLShader
	{
		#if desktop
		code = StringTools.replace(code, "lowp", "");
		code = StringTools.replace(code, "mediump", "");
		code = StringTools.replace(code, "highp", "");
		#end

		var s = GL.createShader(type);
		GL.shaderSource(s, code);
		GL.compileShader(s);

		#if debug
		var log = GL.getShaderInfoLog(s);
		if(log.length > 0)
		{
			trace("Shader log:");
			trace(log);
		}
		#end

		if(GL.getShaderParameter(s, GLDefines.COMPILE_STATUS) != cast 1 ) 
		{
			GL.deleteShader(s);
			return GL.nullShader;
		}
		return s;
	}

	private function linkShader(shaderProgramName : GLProgram) : Bool
	{
		GL.linkProgram(shaderProgramName);

		#if debug
		var log = GL.getProgramInfoLog(shaderProgramName);
		if(log.length > 0)
		{
			trace("Shader program log:");
			trace(log);
		}
		#end

		if(GL.getProgramParameter(shaderProgramName, GLDefines.LINK_STATUS) == 0)
			return false;
		return true;
	}

	public function loadFilledTextureData(texture : TextureData) : Void
	{
        if(texture.alreadyLoaded)
            return;

		texture.glTexture = GL.createTexture();
		bindTexture(texture);

		configureFilteringMode(texture);
		configureMipmaps(texture);
		configureWrap(texture);

		pushTextureData(texture);

        texture.alreadyLoaded = true;
	}

	private function pushTextureData(texture : TextureData) : Void
	{
		var glTextureType = GLUtils.convertTextureTypeToOGL(texture.textureType);

		if(texture.textureType == TextureType2D)
		{
			pushTextureDataForType(glTextureType, texture.pixelFormat, texture.data, texture.originalWidth, texture.originalHeight);
		}
		else
		{
			pushTextureDataForType( GLDefines.TEXTURE_CUBE_MAP_POSITIVE_X, 
									texture.pixelFormat, 
									texture.dataForCubeMapPositiveX, 
									texture.originalWidth, 
									texture.originalHeight);

			pushTextureDataForType( GLDefines.TEXTURE_CUBE_MAP_NEGATIVE_X, 
									texture.pixelFormat, 
									texture.dataForCubeMapNegativeX, 
									texture.originalWidth, 
									texture.originalHeight);

			pushTextureDataForType( GLDefines.TEXTURE_CUBE_MAP_POSITIVE_Y, 
									texture.pixelFormat, 
									texture.dataForCubeMapPositiveY, 
									texture.originalWidth, 
									texture.originalHeight);

			pushTextureDataForType( GLDefines.TEXTURE_CUBE_MAP_NEGATIVE_Y, 
									texture.pixelFormat, 
									texture.dataForCubeMapNegativeY, 
									texture.originalWidth, 
									texture.originalHeight);

			pushTextureDataForType( GLDefines.TEXTURE_CUBE_MAP_POSITIVE_Z, 
									texture.pixelFormat, 
									texture.dataForCubeMapPositiveZ, 
									texture.originalWidth, 
									texture.originalHeight);

			pushTextureDataForType( GLDefines.TEXTURE_CUBE_MAP_NEGATIVE_Z, 
									texture.pixelFormat, 
									texture.dataForCubeMapNegativeZ, 
									texture.originalWidth, 
									texture.originalHeight);
		}
	}

	private function pushTextureDataForType(textureType : Int, textureFormat : TextureFormat, data : Data, width : Int, height : Int)
	{
		switch(textureFormat)
		{
			case(TextureFormatRGB565):
				GL.texImage2D(textureType, 0, GLDefines.RGB, width, height, 0, GLDefines.RGB, GLDefines.UNSIGNED_SHORT_5_6_5, data);

			case(TextureFormatA8):
				GL.texImage2D(textureType, 0, GLDefines.ALPHA, width, height, 0, GLDefines.ALPHA, GLDefines.UNSIGNED_BYTE, data);

			case(TextureFormatRGBA8888):
				GL.texImage2D(textureType, 0, GLDefines.RGBA, width, height, 0, GLDefines.RGBA, GLDefines.UNSIGNED_BYTE, data);
		}
	}

	private function configureFilteringMode(texture : TextureData) : Void
	{
		bindTexture(texture);

		var textureType = GLUtils.convertTextureTypeToOGL(texture.textureType);

		if(texture.filteringMode == TextureFilteringModeLinear)
		{
			GL.texParameteri(textureType, GLDefines.TEXTURE_MAG_FILTER, GLDefines.LINEAR);

	        if (texture.hasMipMaps)
	            GL.texParameteri(textureType, GLDefines.TEXTURE_MIN_FILTER, GLDefines.LINEAR_MIPMAP_LINEAR);
	        else
	            GL.texParameteri(textureType, GLDefines.TEXTURE_MIN_FILTER, GLDefines.LINEAR);
	    }
	    else
	    {
	        GL.texParameteri(textureType, GLDefines.TEXTURE_MAG_FILTER, GLDefines.NEAREST);
	        
	        if (texture.hasMipMaps)
	            GL.texParameteri(textureType, GLDefines.TEXTURE_MIN_FILTER, GLDefines.LINEAR_MIPMAP_NEAREST);
	        else
	            GL.texParameteri(textureType, GLDefines.TEXTURE_MIN_FILTER, GLDefines.NEAREST);
	    }
	}

	private function configureWrap(texture : TextureData) : Void
	{
		bindTexture(texture);

		var textureType = GLUtils.convertTextureTypeToOGL(texture.textureType);
	    
	    if (texture.wrap == TextureWrapClamp)
	    {
	        GL.texParameteri(textureType, GLDefines.TEXTURE_WRAP_S, GLDefines.CLAMP_TO_EDGE);
	        GL.texParameteri(textureType, GLDefines.TEXTURE_WRAP_T, GLDefines.CLAMP_TO_EDGE);
	    }else
	    {
	        GL.texParameteri(textureType, GLDefines.TEXTURE_WRAP_S, GLDefines.REPEAT);
	        GL.texParameteri(textureType, GLDefines.TEXTURE_WRAP_T, GLDefines.REPEAT);
	    }
	}

	private function configureMipmaps(texture : TextureData) : Void
	{
	    if(!texture.hasMipMaps)
	        return;
	    
		bindTexture(texture);
	    GL.hint(GLDefines.GENERATE_MIPMAP_HINT, GLDefines.NICEST);
	    
		var textureType = GLUtils.convertTextureTypeToOGL(texture.textureType);
	    
	   	GL.generateMipmap(textureType);
	    
	    configureFilteringMode(texture);
	}

    public function loadFilledRenderTarget(renderTarget : RenderTarget) : Void
    {
        var context = getCurrentContext();

        if(renderTarget == context.defaultRenderTarget)
        {
            return;
        }

        destroyRenderbuffers(renderTarget);

        if(!renderTarget.alreadyLoaded)
        {
            renderTarget.framebufferID = GL.createFramebuffer();
            renderTarget.alreadyLoaded = true;
        }

        GL.bindFramebuffer(GLDefines.FRAMEBUFFER, renderTarget.framebufferID);
        if(renderTarget.colorTextureData != null)
        {
            GL.framebufferTexture2D(GLDefines.FRAMEBUFFER,
                                    GLDefines.COLOR_ATTACHMENT0,
                                    GLDefines.TEXTURE_2D,
                                    renderTarget.colorTextureData.glTexture,
                                    0);
        }
        else
        {
            setupColorRenderbuffer(renderTarget);
        }

        if(renderTarget.depthTextureData == null && renderTarget.stencilTextureData == null)
        {
            setupDepthStencilRenderbuffer(renderTarget);
        }
        else
        {
            if(renderTarget.depthTextureData != null)
            {
                GL.framebufferTexture2D(GLDefines.FRAMEBUFFER,
                                        GLDefines.DEPTH_ATTACHMENT,
                                        GLDefines.TEXTURE_2D,
                                        renderTarget.depthTextureData.glTexture,
                                        0);
            }
            else
            {
                setupDepthRenderbuffer(renderTarget);
            }

            if(renderTarget.stencilTextureData != null)
            {
                GL.framebufferTexture2D(GLDefines.FRAMEBUFFER,
                                        GLDefines.STENCIL_ATTACHMENT,
                                        GLDefines.TEXTURE_2D,
                                        renderTarget.stencilTextureData.glTexture,
                                        0);
            }
            else
            {
                setupStencilRenderbuffer(renderTarget);
            }
        }

        var result = GL.checkFramebufferStatus(GLDefines.FRAMEBUFFER);
        if(result != GLDefines.FRAMEBUFFER_COMPLETE)
        {
            trace("Framebuffer error: 0x%x", result);
        }
    }

    private function setupColorRenderbuffer(renderTarget : RenderTarget) : Void
    {
        if(renderTarget.colorFormat == null)
            return;

        var format = GLDefines.RGBA;
        if(renderTarget.colorFormat == ColorFormatRGB565)
        {
            format = GLDefines.RGB565;
        }

        renderTarget.colorRenderbufferID = GL.createRenderbuffer();
        GL.bindRenderbuffer(GLDefines.RENDERBUFFER, renderTarget.colorRenderbufferID);
        GL.renderbufferStorage(GLDefines.RENDERBUFFER, format, renderTarget.size.width, renderTarget.size.height);
        GL.framebufferRenderbuffer(GLDefines.FRAMEBUFFER, GLDefines.COLOR_ATTACHMENT0, GLDefines.RENDERBUFFER, renderTarget.colorRenderbufferID);
    }

    private function setupDepthRenderbuffer(renderTarget : RenderTarget) : Void
    {
        if(renderTarget.depthFormat == null)
            return;

        var format = GLDefines.DEPTH_COMPONENT;
        if(renderTarget.depthFormat == DepthFormat16)
        {
            format = GLDefines.DEPTH_COMPONENT16;
        }

        renderTarget.depthRenderbufferID = GL.createRenderbuffer();
        GL.bindRenderbuffer(GLDefines.RENDERBUFFER, renderTarget.depthRenderbufferID);
        GL.renderbufferStorage(GLDefines.RENDERBUFFER, format, renderTarget.size.width, renderTarget.size.height);
        GL.framebufferRenderbuffer(GLDefines.FRAMEBUFFER, GLDefines.DEPTH_ATTACHMENT, GLDefines.RENDERBUFFER, renderTarget.depthRenderbufferID);
    }

    private function setupStencilRenderbuffer(renderTarget : RenderTarget) : Void
    {
        if(renderTarget.stencilFormat == null)
            return;

        renderTarget.stencilRenderbufferID = GL.createRenderbuffer();
        GL.bindRenderbuffer(GLDefines.RENDERBUFFER, renderTarget.stencilRenderbufferID);
        GL.renderbufferStorage(GLDefines.RENDERBUFFER, GLDefines.STENCIL_INDEX8, renderTarget.size.width, renderTarget.size.height);
        GL.framebufferRenderbuffer(GLDefines.FRAMEBUFFER, GLDefines.STENCIL_ATTACHMENT, GLDefines.RENDERBUFFER, renderTarget.stencilRenderbufferID);
    }

    private function setupDepthStencilRenderbuffer(renderTarget : RenderTarget) : Void
    {
        if(renderTarget.stencilFormat == null && renderTarget.depthFormat == null)
            return;

        if(renderTarget.stencilFormat == null)
        {
            setupDepthRenderbuffer(renderTarget);
            return;
        }

        if(renderTarget.depthFormat == null)
        {
            setupStencilRenderbuffer(renderTarget);
            return;
        }

        renderTarget.depthStencilRenderbufferID = GL.createRenderbuffer();
        GL.bindRenderbuffer(GLDefines.RENDERBUFFER, renderTarget.depthStencilRenderbufferID);
        GL.renderbufferStorage(GLDefines.RENDERBUFFER, GLDefines.DEPTH24_STENCIL8, renderTarget.size.width, renderTarget.size.height);
        GL.framebufferRenderbuffer(GLDefines.FRAMEBUFFER, GLDefines.STENCIL_ATTACHMENT, GLDefines.RENDERBUFFER, renderTarget.depthStencilRenderbufferID);
        GL.framebufferRenderbuffer(GLDefines.FRAMEBUFFER, GLDefines.DEPTH_ATTACHMENT, GLDefines.RENDERBUFFER, renderTarget.depthStencilRenderbufferID);

    }

    public function isLoadedRenderTarget(renderTarget : RenderTarget) : Bool
    {
        return renderTarget.alreadyLoaded;
    }

    public function isLoadedMeshData(meshData : MeshData) : Bool
    {
        var attributeBuffer : Bool = true;
        if(meshData.attributeBuffer != null)
        {
            attributeBuffer = isLoadedMeshDataBuffer(meshData.attributeBuffer);
        }

        var indexBuffer : Bool = true;
        if(meshData.indexBuffer != null)
        {
            indexBuffer = isLoadedMeshDataBuffer(meshData.indexBuffer);
        }

        return attributeBuffer && indexBuffer;
    }

    public function isLoadedMeshDataBuffer(meshDataBuffer : MeshDataBuffer) : Bool
    {
        if(meshDataBuffer != null)
            return meshDataBuffer.bufferAlreadyOnHardware;
        return false;
    }

    public function isLoadedShader(shader : Shader) : Bool
    {
        return shader.alreadyLoaded;
    }

    public function isLoadedTextureData(textureData : TextureData) : Bool
    {
        return textureData.alreadyLoaded;
    }

    public function unloadMeshDataBuffer(meshDataBuffer : MeshDataBuffer) : Void
    {
        if(meshDataBuffer.bufferAlreadyOnHardware)
        {
            GL.deleteBuffer(meshDataBuffer.glBuffer);
            meshDataBuffer.bufferAlreadyOnHardware = false;
        }
    }

    public function unloadMeshData(meshData : MeshData) : Void
    {
        if(meshData.attributeBuffer != null)
        {
            unloadMeshDataBuffer(meshData.attributeBuffer);
        }

        if(meshData.indexBuffer != null)
        {
            unloadMeshDataBuffer(meshData.indexBuffer);
        }
    }

    public function unloadShader(shader : Shader) : Void
    {
        if(shader.alreadyLoaded)
        {
            GL.deleteProgram(shader.programName);
            shader.alreadyLoaded = false;
        }
    }

    public function unloadTextureData(textureData : TextureData) : Void
    {
        if(textureData.alreadyLoaded)
        {
            GL.deleteTexture(textureData.glTexture);
            textureData.alreadyLoaded = false;
        }
    }

    public function unloadRenderTarget(renderTarget : RenderTarget) : Void
    {
        var context = getCurrentContext();
        if(renderTarget == context.defaultRenderTarget)
        {
            return;
        }
        destroyRenderbuffers(renderTarget);

        GL.deleteFramebuffer(renderTarget.framebufferID);
        renderTarget.alreadyLoaded = false;
    }

    public function destroyRenderbuffers(renderTarget : RenderTarget) : Void
    {
        if(renderTarget.colorRenderbufferID != GL.nullRenderbuffer)
        {
            GL.deleteRenderbuffer(renderTarget.colorRenderbufferID);
            renderTarget.colorRenderbufferID = GL.nullRenderbuffer;
        }

        if(renderTarget.depthRenderbufferID != GL.nullRenderbuffer)
        {
            GL.deleteRenderbuffer(renderTarget.depthRenderbufferID);
            renderTarget.depthRenderbufferID = GL.nullRenderbuffer;
        }

        if(renderTarget.stencilRenderbufferID != GL.nullRenderbuffer)
        {
            GL.deleteRenderbuffer(renderTarget.stencilRenderbufferID);
            renderTarget.stencilRenderbufferID = GL.nullRenderbuffer;
        }

        if(renderTarget.depthStencilRenderbufferID != GL.nullRenderbuffer)
        {
            GL.deleteRenderbuffer(renderTarget.depthStencilRenderbufferID);
            renderTarget.depthStencilRenderbufferID = GL.nullRenderbuffer;
        }
    }

    public function setBlendFunc(sourceFactor : BlendFactor, destinationFactor : BlendFactor) : Void
    {
        var context = getCurrentContext();

        if(context.currentBlendFactorSrcRGB != sourceFactor || context.currentBlendFactorDestRGB != destinationFactor ||
           context.currentBlendFactorSrcA != sourceFactor || context.currentBlendFactorDestA != destinationFactor)
        {
            context.currentBlendFactorSrcRGB = sourceFactor;
            context.currentBlendFactorDestRGB = destinationFactor;
            context.currentBlendFactorSrcA = sourceFactor;
            context.currentBlendFactorDestA = destinationFactor;
            GL.blendFunc(GLUtils.convertBlendFactorToOGL(sourceFactor),
                         GLUtils.convertBlendFactorToOGL(destinationFactor));
        }
    }

    public function setBlendFuncSeparate(sourceFactorRGB : BlendFactor,
                                         destinationFactorRGB : BlendFactor,
                                         sourceFactorA : BlendFactor,
                                         destinationFactorA : BlendFactor) : Void
    {
        var context = getCurrentContext();

        if(context.currentBlendFactorSrcRGB != sourceFactorRGB || context.currentBlendFactorDestRGB != destinationFactorRGB ||
        context.currentBlendFactorSrcA != sourceFactorA || context.currentBlendFactorDestA != destinationFactorA)
        {
            context.currentBlendFactorSrcRGB = sourceFactorRGB;
            context.currentBlendFactorDestRGB = destinationFactorRGB;
            context.currentBlendFactorSrcA = sourceFactorA;
            context.currentBlendFactorDestA = destinationFactorA;
            GL.blendFuncSeparate(GLUtils.convertBlendFactorToOGL(sourceFactorRGB),
                                 GLUtils.convertBlendFactorToOGL(destinationFactorRGB),
                                 GLUtils.convertBlendFactorToOGL(sourceFactorA),
                                 GLUtils.convertBlendFactorToOGL(destinationFactorA));
        }
    }

    public function setBlendMode(blendMode : BlendMode) : Void
    {
        var context = getCurrentContext();

        if(blendMode != context.currentBlendModeA && blendMode != context.currentBlendModeRGB)
        {
            context.currentBlendModeA = blendMode;
            context.currentBlendModeRGB = blendMode;
            GL.blendEquation(GLUtils.convertBlendModeToOGL(blendMode));
        }
    }

    public function setBlendModeSeparate(blendModeRGB : BlendMode, blendModeA : BlendMode) : Void
    {
        var context = getCurrentContext();

        if(blendModeRGB != context.currentBlendModeA && blendModeA != context.currentBlendModeRGB)
        {
            context.currentBlendModeA = blendModeA;
            context.currentBlendModeRGB = blendModeRGB;
            GL.blendEquationSeparate(GLUtils.convertBlendModeToOGL(blendModeRGB),
                                     GLUtils.convertBlendModeToOGL(blendModeA));
        }
    }

    public function enableDepthTesting(enabled : Bool) : Void
    {
        var context = getCurrentContext();

        if(context.currentDepthTesting == enabled)
            return;

        if(enabled)
        {
            GL.enable(GLDefines.DEPTH_TEST);
        }
        else
        {
            GL.disable(GLDefines.DEPTH_TEST);
        }
        context.currentDepthTesting = enabled;
    }

    public function enableDepthWrite(enabled : Bool) : Void
    {
        var context = getCurrentContext();
        if(context.currentDepthWrite == enabled)
            return;

        GL.depthMask(enabled);
        context.currentDepthWrite = enabled;
    }

    public function isDepthTesting() : Bool
    {
        var context = getCurrentContext();
        return context.currentDepthTesting;
    }

    public function isDepthWriting() : Bool
    {
        var context = getCurrentContext();
        return context.currentDepthWrite;
    }

    public function setFaceCullingMode(cullingMode : FaceCullingMode) : Void
    {
        var context = getCurrentContext();

        if(cullingMode != context.currentFaceCullingMode)
        {
            if(cullingMode == FaceCullingModeOff)
            {
                GL.disable(GLDefines.CULL_FACE);
            }
            else
            {
                GL.cullFace(GLDefines.CULL_FACE);

                if(context.currentFaceCullingMode == FaceCullingModeOff || context.currentFaceCullingMode == null)
                {
                    GL.enable(GLDefines.CULL_FACE);
                }
            }
            context.currentFaceCullingMode = cullingMode;
        }
    }

    public function getFaceCullingMode() : FaceCullingMode
    {
        var context = getCurrentContext();

        return context.currentFaceCullingMode;
    }

    public function setLineWidth(lineWidth : Float) : Void
    {
        var context = getCurrentContext();

        if(context.currentLineWidth == lineWidth)
            return;

        GL.lineWidth(lineWidth);
        context.currentLineWidth = lineWidth;
    }

    public function setColorMask(writeRed : Bool, writeGreen : Bool, writeRed : Bool, writeAlpha : Bool) : Void
    {
        GL.colorMask(writeRed, writeGreen, writeRed, writeAlpha);
    }

    public function pushRenderTarget(renderTarget : RenderTarget) : Void
    {
        var context = getCurrentContext();

        var framebuffer = renderTarget.framebufferID;

        if(context.currentRenderTargetStack.first().framebufferID != framebuffer)
        {
            GL.bindFramebuffer(GLDefines.FRAMEBUFFER, framebuffer);
        }

        context.currentRenderTargetStack.add(renderTarget);
    }

    public function popRenderTarget() : Void
    {
        var context = getCurrentContext();

        context.currentRenderTargetStack.pop();

        if(!context.currentRenderTargetStack.isEmpty())
        {
            GL.bindFramebuffer(GLDefines.FRAMEBUFFER, context.currentRenderTargetStack.first().framebufferID);
        }
    }

    public function enableScissorTesting(enabled : Bool) : Void
    {
        if(enabled)
        {
            GL.enable(GLDefines.SCISSOR_TEST);
        }
        else
        {
            GL.disable(GLDefines.SCISSOR_TEST);
        }
    }

    public function setScissorTestRect(x : Int, y : Int, width : Int, height : Int) : Void
    {
        GL.scissor(x, y, width, height);
    }

    public function bindShader(shader : Shader)
	{
        var context = getCurrentContext();

		if(context.currentShader != shader.programName)
		{
			GL.useProgram(shader.programName);
            context.currentShader = shader.programName;
		}

		for(uniformInterface in shader.uniformInterfaces)
		{

			switch(uniformInterface.uniformType)
			{
                case UniformTypeSingleInt:
                    GL.uniform1i(uniformInterface.uniformLocation, uniformInterface.data.readInt(DataTypeInt32));
                case UniformTypeSingleIntArray:
                    GL.uniform1iv(uniformInterface.uniformLocation, uniformInterface.dataActiveCount, uniformInterface.data);
                case UniformTypeSingleFloat:
                    GL.uniform1f(uniformInterface.uniformLocation, uniformInterface.data.readFloat(DataTypeFloat32));
                case UniformTypeSingleFloatArray:
                    GL.uniform1fv(uniformInterface.uniformLocation, uniformInterface.dataActiveCount, uniformInterface.data);

                case UniformTypeVector2Int:
                    var x = uniformInterface.data.readInt(DataTypeInt32);
                    uniformInterface.data.offset += 4;
                    var y = uniformInterface.data.readInt(DataTypeInt32);
                    uniformInterface.data.offset -= 4;
                    GL.uniform2i(uniformInterface.uniformLocation, x, y);
                case UniformTypeVector2IntArray:
                    GL.uniform2iv(uniformInterface.uniformLocation, uniformInterface.dataActiveCount, uniformInterface.data);
                case UniformTypeVector2Float:
                    var x = uniformInterface.data.readFloat(DataTypeFloat32);
                    uniformInterface.data.offset += 4;
                    var y = uniformInterface.data.readFloat(DataTypeFloat32);
                    uniformInterface.data.offset -= 4;
                    GL.uniform2f(uniformInterface.uniformLocation, x, y);
                case UniformTypeVector2FloatArray:
                    GL.uniform2fv(uniformInterface.uniformLocation, uniformInterface.dataActiveCount, uniformInterface.data);

                case UniformTypeVector3Int:
                    var x = uniformInterface.data.readInt(DataTypeInt32);
                    uniformInterface.data.offset += 4;
                    var y = uniformInterface.data.readInt(DataTypeInt32);
                    uniformInterface.data.offset += 4;
                    var z = uniformInterface.data.readInt(DataTypeInt32);
                    uniformInterface.data.offset -= 8;
                    GL.uniform3i(uniformInterface.uniformLocation, x, y, z);
                case UniformTypeVector3IntArray:
                    GL.uniform3iv(uniformInterface.uniformLocation, uniformInterface.dataActiveCount, uniformInterface.data);
                case UniformTypeVector3Float:
                    var x = uniformInterface.data.readFloat(DataTypeFloat32);
                    uniformInterface.data.offset += 4;
                    var y = uniformInterface.data.readFloat(DataTypeFloat32);
                    uniformInterface.data.offset += 4;
                    var z = uniformInterface.data.readFloat(DataTypeFloat32);
                    uniformInterface.data.offset -= 8;
                    GL.uniform3f(uniformInterface.uniformLocation, x, y, z);
                case UniformTypeVector3FloatArray:
                    GL.uniform3fv(uniformInterface.uniformLocation, uniformInterface.dataActiveCount, uniformInterface.data);

                case UniformTypeVector4Int:
                    var x = uniformInterface.data.readInt(DataTypeInt32);
                    uniformInterface.data.offset += 4;
                    var y = uniformInterface.data.readInt(DataTypeInt32);
                    uniformInterface.data.offset += 4;
                    var z = uniformInterface.data.readInt(DataTypeInt32);
                    uniformInterface.data.offset += 4;
                    var w = uniformInterface.data.readInt(DataTypeInt32);
                    uniformInterface.data.offset -= 12;
                    GL.uniform4i(uniformInterface.uniformLocation, x, y, z, w);
                case UniformTypeVector4IntArray:
                    GL.uniform4iv(uniformInterface.uniformLocation, uniformInterface.dataActiveCount, uniformInterface.data);
                case UniformTypeVector4Float:
                    var x = uniformInterface.data.readFloat(DataTypeFloat32);
                    uniformInterface.data.offset += 4;
                    var y = uniformInterface.data.readFloat(DataTypeFloat32);
                    uniformInterface.data.offset += 4;
                    var z = uniformInterface.data.readFloat(DataTypeFloat32);
                    uniformInterface.data.offset += 4;
                    var w = uniformInterface.data.readFloat(DataTypeFloat32);
                    uniformInterface.data.offset -= 12;
                    GL.uniform4f(uniformInterface.uniformLocation, x, y, z, w);
                case UniformTypeVector4FloatArray:
                    GL.uniform4fv(uniformInterface.uniformLocation, uniformInterface.dataActiveCount, uniformInterface.data);

                case UniformTypeMatrix2:
                    GL.uniformMatrix2fv(uniformInterface.uniformLocation, uniformInterface.dataActiveCount, false, uniformInterface.data);
                case UniformTypeMatrix2Transposed:
                    GL.uniformMatrix2fv(uniformInterface.uniformLocation, uniformInterface.dataActiveCount, true, uniformInterface.data);

                case UniformTypeMatrix3:
                    GL.uniformMatrix3fv(uniformInterface.uniformLocation, uniformInterface.dataActiveCount, false, uniformInterface.data);
                case UniformTypeMatrix3Transposed:
                    GL.uniformMatrix3fv(uniformInterface.uniformLocation, uniformInterface.dataActiveCount, true, uniformInterface.data);

                case UniformTypeMatrix4:
                    GL.uniformMatrix4fv(uniformInterface.uniformLocation, uniformInterface.dataActiveCount, false, uniformInterface.data);
                case UniformTypeMatrix4Transposed:
                    GL.uniformMatrix4fv(uniformInterface.uniformLocation, uniformInterface.dataActiveCount, true, uniformInterface.data);

                default:
			}
		}
	}

	public function bindMeshData(data : MeshData, bakedFrame : Int) 
	{
		if(data.bakedFrameCount > 0 && bakedFrame >= data.bakedFrameCount)
		{
			trace("Tried to set invalid frame on render buffer data");
			return;
		}

		if(data.attributeBuffer != null)
		{
			GL.bindBuffer(GLDefines.ARRAY_BUFFER, data.attributeBuffer.glBuffer);
		}
		else
		{
			GL.bindBuffer(GLDefines.ARRAY_BUFFER, GL.nullBuffer);
		}

		if(data.indexBuffer != null)
		{
			GL.bindBuffer(GLDefines.ELEMENT_ARRAY_BUFFER, data.indexBuffer.glBuffer);
		}
		else
		{
			GL.bindBuffer(GLDefines.ELEMENT_ARRAY_BUFFER, GL.nullBuffer);
		}

		enableVertexAttributes(data);

		for(attributeConfig in data.attributeConfigs)
		{
			var offsetForFrame = 0;

			if(attributeConfig.offsetPerBakedFrame != null)
			{
				offsetForFrame = attributeConfig.offsetPerBakedFrame[bakedFrame];
			}
			GL.vertexAttribPointer(attributeConfig.attributeNumber,
								   attributeConfig.vertexElementCount,
								   GLUtils.convertDataTypeToOGL(attributeConfig.vertexElementType),
								   attributeConfig.vertexElementsNormalized,
								   data.attributeStride,
								   attributeConfig.offsetInData + offsetForFrame);
		}
	}

	private function enableVertexAttributes(meshData : MeshData)
	{
		var combinedAttributes = 0;
		for(attributeConfig in meshData.attributeConfigs)
		{
			combinedAttributes |= 1 << attributeConfig.attributeNumber;
		}

		enableVertexAttributesFromCombinedAttributes(combinedAttributes);

	}

	private function enableVertexAttributesFromCombinedAttributes(combinedFlagsFromVertexAttributes : Int)
	{
        var context = getCurrentContext();

		var currentMask = 1;
		for(i in 0...8)
		{
			var enableNow = combinedFlagsFromVertexAttributes & currentMask;
			var prevState = context.currentAttributeFlags & currentMask;

			if(enableNow != prevState)
			{
				if(enableNow > 0)
				{
					GL.enableVertexAttribArray(i);
				}
				else
				{
					GL.enableVertexAttribArray(i);
				}
			}

			currentMask = currentMask << 1;
		}

        context.currentAttributeFlags = combinedFlagsFromVertexAttributes;
	}

	public function render(meshData : MeshData, bakedFrame : Int)
	{
		if(meshData.bakedFrameCount > 0 && bakedFrame >= meshData.bakedFrameCount)
		{
			trace("Tried to set invalid frame on render buffer data");
			return;
		}

		var primitiveType = GLUtils.convertPrimitiveTypeToOGL(meshData.primitiveType);

		if(meshData.indexBuffer != null) 
		{///dont know if it is working
			var count : Int;
			var offset : Int;

			if(meshData.bakedFrameCount == 0)
			{
				count = meshData.indexCount;
				offset = 0;
			}
			else
			{
				count = meshData.indexCountPerBakedFrame[bakedFrame];
				offset = meshData.indexOffsetPerBakedFrame[bakedFrame] * DataTypeUtils.dataTypeByteSize(meshData.indexDataType);
			}

			GL.drawElements(primitiveType,
							count,
							GLUtils.convertDataTypeToOGL(meshData.indexDataType),
							offset);
		}
		else
		{
			var count : Int;
			var offset : Int;
			if(meshData.bakedFrameCount == 0)
			{
				count = meshData.vertexCount;
				offset = 0;
			}
			else
			{
				count = meshData.indexCountPerBakedFrame[bakedFrame];
				offset = meshData.indexOffsetPerBakedFrame[bakedFrame];
			}

			GL.drawArrays(primitiveType,
						  offset, 
						  count);
		}
	};

	public function bindTextureData(texture : TextureData, position : Int) : Void
	{
    	if(texture == null)
  	    	return;
        activeTexture(position);
        bindTexture(texture);
	}

	private function bindTexture(texture : TextureData)
	{
        var context = getCurrentContext();
		if(context.currentActiveTextures[context.currentActiveTexture] != texture.glTexture)
		{
            context.currentActiveTextures[context.currentActiveTexture] = texture.glTexture;
    	    GL.bindTexture(GLUtils.convertTextureTypeToOGL(texture.textureType), texture.glTexture);
		}
	}

	private function activeTexture(position)
	{
		if(position > maxActiveTextures)
		{
			trace("Tried to active a texture at position " + position + ", and max active textures is " + maxActiveTextures + "!");
			return;
		}

        var context = getCurrentContext();
		if(position != context.currentActiveTexture)
		{
            context.currentActiveTexture = position;
			GL.activeTexture(position + GLDefines.TEXTURE0);

		}

	}

    public function setClearColor(color : Color4B) : Void
    {
        var context = getCurrentContext();
        var renderTarget = context.currentRenderTargetStack.first();

        var fuckingLimeNeedsACleanUp:Bool = true;  // We can not cache this when lime/nme is taking care of the opengl state

        if(fuckingLimeNeedsACleanUp == true ||
            renderTarget.currentClearColor.r != color.r || renderTarget.currentClearColor.g != color.g ||
           renderTarget.currentClearColor.b != color.b || renderTarget.currentClearColor.a != color.a)
        {
            renderTarget.currentClearColor.data.writeData(color.data);
            GL.clearColor(color.r/255.0, color.g/255.0, color.b/255.0, color.a/255.0);
        }
    }

    public function clearColorBuffer() : Void
    {
        GL.clear(GLDefines.COLOR_BUFFER_BIT);
    }

    public function clearDepthBuffer() : Void
    {
        GL.clear(GLDefines.DEPTH_BUFFER_BIT);
    }

    public function clearStencilBuffer() : Void
    {
        GL.clear(GLDefines.STENCIL_BUFFER_BIT);
    }
    public function clearAllBuffers() : Void
    {
        GL.clear(GLDefines.COLOR_BUFFER_BIT & GLDefines.DEPTH_BUFFER_BIT & GLDefines.STENCIL_BUFFER_BIT);
    }

    public function enableStencilTest(enabled : Bool) : Void
    {
        if(enabled)
        {
            GL.enable(GLDefines.SCISSOR_TEST);
        }
        else
        {
            GL.disable(GLDefines.SCISSOR_TEST);
        }
    }

    public function isStencilTestEnabled() : Bool
    {
        return GL.getParameter(GLDefines.STENCIL_TEST);
    }

    public function setStencilOp(stencilFail : StencilOp, depthFail : StencilOp, stencilAndDepthPass : StencilOp) : Void
    {
        GL.stencilOp(GLUtils.convertStencilOpToOGL(stencilFail),
                     GLUtils.convertStencilOpToOGL(depthFail),
                     GLUtils.convertStencilOpToOGL(stencilAndDepthPass));
    }
    public function setStencilFunc(stencilFunc : StencilFunc, referenceValue : Int, mask : Int) : Void
    {
        GL.stencilFunc(GLUtils.convertStencilFuncToOGL(stencilFunc), referenceValue, mask);
    }
}