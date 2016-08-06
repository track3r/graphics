/*
 * Copyright (c) 2003-2016, GameDuell GmbH
 * All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions are met:
 *
 * 1. Redistributions of source code must retain the above copyright notice,
 * this list of conditions and the following disclaimer.
 *
 * 2. Redistributions in binary form must reproduce the above copyright notice,
 * this list of conditions and the following disclaimer in the documentation
 * and/or other materials provided with the distribution.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
 * ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
 * WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED.
 * IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY
 * DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
 * (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
 * LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
 * ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
 * (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
 * SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

package graphics;

import gl.GLExtDefines;
import types.Color4F;
import graphics.RenderTargetData;
import graphics.GraphicsContext;
import types.Color4B;
import graphics.MeshData;
import graphics.Shader;
import graphics.TextureData;
import graphics.GraphicsTypes;
import graphics.GLUtils;
import graphics.GraphicsContext;
import graphics.MainGraphicsContext;
import graphics.GraphicsInitialState;

import gl.GL;
import gl.GLDefines;

import gl.GLExt;
import gl.GLExtDefines;

import gl.GLContext;

import types.DataType;
import types.Data;

import haxe.ds.GenericStack;

import msignal.Signal;

class Graphics
{
    public var onRender(default, null): Signal0;

    private var mainContext: GraphicsContext;

    public var onMainContextRecreated: Signal0;
    public var onMainContextSizeChanged: Signal0;
    public var mainContextWidth(get, null): Int;
    public var mainContextHeight(get, null): Int;

	private function new()
	{}

	public function get_mainContextWidth(): Int
	{
		return mainContext.glContext.contextWidth;
	}

	public function get_mainContextHeight(): Int
	{
		return mainContext.glContext.contextHeight;
    }

    public function setDefaultGraphicsState(): Void
    {
        // TODO: Make all of this functionality available in the library configuration

        /// Default state to sync with all other platforms

        enableBlending(true);
        setBlendFunc(BlendFactor.BlendFactorSrcAlpha, BlendFactor.BlendFactorOneMinusSrcAlpha);

        /// Depth
        setDepthFunc(DepthFunc.DepthFuncLEqual);
        enableDepthWrite(false);
        enableDepthTesting(false);
        GL.clearDepth(1);

        /// Stencil
        enableStencilTest(false);
        setStencilFunc(StencilFuncAlways, 0, 0xFFFFFFFF);
        setStencilOp(StencilOpKeep, StencilOpKeep, StencilOpKeep);
        setStencilMask(0xFFFFFFFF);
        GL.clearStencil(0);

        setColorMask(true, true, true, true);

        var color: Color4F = new Color4F();

        color.r = GraphicsInitialState.clearColorRed;
        color.g = GraphicsInitialState.clearColorGreen;
        color.b = GraphicsInitialState.clearColorBlue;
        color.a = GraphicsInitialState.clearColorAlpha;

        setClearColor(color);

        clearAllBuffers();

        GL.frontFace(GLDefines.CW);
        setFaceCullingMode(FaceCullingMode.FaceCullingModeOff);

        enableScissorTesting(false);
    }

    public function rebindDefaultBackbuffer(): Void
    {
        // TODO loop through all contexts, when we have them
        var context = getCurrentContext();
        context.rebindDefaultBackbuffer();
    }

    public static function initialize(callback:Void->Void)
    {
        sharedInstance = new Graphics();
        disabledSharedInstance = new DisabledGraphics();

        sharedInstance.enableGraphicsAPI(true);

        sharedInstance.mainContext = new MainGraphicsContext();

         cast(sharedInstance.mainContext, MainGraphicsContext).initialize(function()
         {
 	        sharedInstance.onRender = GLContext.onRenderOnMainContext;

 	        sharedInstance.onRender.addOnceWithPriority(function() {
 	        	sharedInstance.setDefaultGraphicsState();
 	        	sharedInstance.onMainContextSizeChanged = sharedInstance.mainContext.glContext.onContextSizeChanged;
                sharedInstance.onMainContextRecreated = sharedInstance.mainContext.glContext.onContextRecreated;
 	        	callback();
 	        });
 	    });
    }

	static var sharedInstance: Graphics;
    static var disabledSharedInstance: DisabledGraphics;
    static var selectedSharedInstance: Graphics;

	public static function instance(): Graphics
	{
		return selectedSharedInstance;
	}

    public function enableGraphicsAPI(enable: Bool): Void
    {
        if (enable)
        {
            selectedSharedInstance = sharedInstance;
        }
        else
        {
            selectedSharedInstance = disabledSharedInstance;
        }
    }

    public function invalidateCaches(): Void
    {
        // TODO loop through all contexts, when we have them
        var context = getCurrentContext();
        context.invalidateCaches();
    }

    public function getMainContext(): GraphicsContext
    {
    	return mainContext;
    }

    public function loadFilledContext(context: GraphicsContext): Void
    {
    }

    public function isLoadedContext(context:GraphicsContext): Bool
    {
        return context != null;
    }

    public function unloadFilledContext(context: GraphicsContext): Void
    {
    }

    public function getCurrentContext(): Null<GraphicsContext>
    {
    	/// temporary
        return mainContext;
    }

    public function pushContext(context: GraphicsContext): Void
    {
    }

    public function popContext(): Null<GraphicsContext>
    {
        return null;
    }

	public function loadFilledMeshData(meshData: MeshData)
	{
		if(meshData == null)
        {
            return;
        }

        loadFilledVertexBuffer(meshData);
        loadFilledIndexBuffer(meshData);
	}

    public function loadFilledVertexBuffer(meshData: MeshData): Void
    {
        loadFilledMeshDataBuffer(GLDefines.ARRAY_BUFFER, meshData.attributeBuffer);
    }

    public function loadFilledIndexBuffer(meshData: MeshData): Void
    {
        loadFilledMeshDataBuffer(GLDefines.ELEMENT_ARRAY_BUFFER, meshData.indexBuffer);
    }

	private function loadFilledMeshDataBuffer(bufferType: Int, meshDataBuffer: MeshDataBuffer)
	{
		if(meshDataBuffer == null) return;

		if(!meshDataBuffer.bufferAlreadyOnHardware)
		{
			meshDataBuffer.glBuffer = GL.createBuffer();
			meshDataBuffer.sizeOfHardwareBuffer = 0;
            meshDataBuffer.bufferAlreadyOnHardware = true;
		}

		if(meshDataBuffer.data != null)
		{
			if(meshDataBuffer.data.offsetLength <= meshDataBuffer.sizeOfHardwareBuffer)
			{
				GL.bindBuffer(bufferType, meshDataBuffer.glBuffer);
				GL.bufferSubData(bufferType, 0, meshDataBuffer.data);
			}
			else
			{
				GL.bindBuffer(bufferType, meshDataBuffer.glBuffer);
				GL.bufferData(bufferType, meshDataBuffer.data,
							  GLUtils.convertBufferModeToOGL(meshDataBuffer.bufferMode));
                meshDataBuffer.sizeOfHardwareBuffer = meshDataBuffer.data.offsetLength;
			}
		}
		GL.bindBuffer(bufferType, GL.nullBuffer);
	}


	public function loadFilledShader(shader: Shader)
	{
		if(shader.alreadyLoaded) return;

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
			var attribute: String = shader.attributeNames[i];
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
				var uniformLocation: GLUniformLocation;
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

	private function compileShader(type: Int, code: String): GLShader
	{
		#if mac
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

	private function linkShader(shaderProgramName: GLProgram): Bool
	{
		GL.linkProgram(shaderProgramName);

		#if debug
		var log = GL.getProgramInfoLog(shaderProgramName);
		if(log.length > 1)
		{
			trace("Shader program log:");
			trace(log);
		}
		#end

		if(GL.getProgramParameter(shaderProgramName, GLDefines.LINK_STATUS) == 0)
			return false;
		return true;
	}

	public function loadFilledTextureData(texture: TextureData): Void
	{
        if(texture.alreadyLoaded) return;

		texture.glTexture = GL.createTexture();
		bindTexture(texture);
		configureFilteringMode(texture);
		configureWrap(texture);

		pushTextureData(texture);

		configureMipmaps(texture);

        texture.alreadyLoaded = true;
	}

    public function updateFilledTextureData(texture: TextureData, offsetX: Int, offsetY: Int) : Void
    {
        if(!texture.alreadyLoaded) return;

        bindTexture(texture);
        updateTextureDataForType(GLDefines.TEXTURE_2D, texture.pixelFormat, texture.data, offsetX, offsetY, texture.originalWidth, texture.originalHeight);
    }

	public function updateLoadedTextureData(texture: TextureData, data: Data, offsetX: Int, offsetY: Int, width: Int, height: Int): Void
	{
		if(!texture.alreadyLoaded) return;

		bindTexture(texture);
		updateTextureDataForType(GLDefines.TEXTURE_2D, texture.pixelFormat, data, offsetX, offsetY, width, height);
	}

	private function pushTextureData(texture: TextureData): Void
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

	private function pushTextureDataForType(textureType: Int, textureFormat: TextureFormat, data: Data, width: Int, height: Int)
	{
		switch(textureFormat)
		{
			case(TextureFormatRGB565):
				GL.pixelStorei(GLDefines.UNPACK_ALIGNMENT, 2);
				GL.texImage2D(textureType, 0, GLDefines.RGB, width, height, 0, GLDefines.RGB, GLDefines.UNSIGNED_SHORT_5_6_5, data);

			case(TextureFormatA8):
				GL.pixelStorei(GLDefines.UNPACK_ALIGNMENT, 1);
				GL.texImage2D(textureType, 0, GLDefines.ALPHA, width, height, 0, GLDefines.ALPHA, GLDefines.UNSIGNED_BYTE, data);

			case(TextureFormatRGBA8888):
				GL.pixelStorei(GLDefines.UNPACK_ALIGNMENT, 4);
				GL.texImage2D(textureType, 0, GLDefines.RGBA, width, height, 0, GLDefines.RGBA, GLDefines.UNSIGNED_BYTE, data);

			case(TextureFormatD24S8):
				GL.pixelStorei(GLDefines.UNPACK_ALIGNMENT, 4);
				GL.texImage2D(textureType, 0, GLDefines.DEPTH_STENCIL, width, height, 0, GLDefines.DEPTH_STENCIL, GLDefines.UNSIGNED_INT_24_8, data);
		}
	}

    private function updateTextureDataForType(textureType: Int, textureFormat: TextureFormat, data: Data, offsetX: Int, offsetY: Int, width: Int, height: Int)
    {
        switch(textureFormat)
        {
            case(TextureFormatRGB565):
                GL.pixelStorei(GLDefines.UNPACK_ALIGNMENT, 2);
                GL.texSubImage2D(textureType, 0, offsetX, offsetY, width, height, GLDefines.RGB, GLDefines.UNSIGNED_SHORT_5_6_5, data);

            case(TextureFormatA8):
                GL.pixelStorei(GLDefines.UNPACK_ALIGNMENT, 1);
                GL.texSubImage2D(textureType, 0, offsetX, offsetY, width, height, GLDefines.ALPHA, GLDefines.UNSIGNED_BYTE, data);

            case(TextureFormatRGBA8888):
                GL.pixelStorei(GLDefines.UNPACK_ALIGNMENT, 4);
                GL.texSubImage2D(textureType, 0, offsetX, offsetY, width, height, GLDefines.RGBA, GLDefines.UNSIGNED_BYTE, data);

			case(TextureFormatD24S8):
				GL.pixelStorei(GLDefines.UNPACK_ALIGNMENT, 4);
				GL.texImage2D(textureType, 0, GLDefines.DEPTH_STENCIL, width, height, 0, GLDefines.DEPTH_STENCIL, GLDefines.UNSIGNED_INT_24_8, data);
        }
    }

	private function configureFilteringMode(texture: TextureData): Void
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

	private function configureWrap(texture: TextureData): Void
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

	private function configureMipmaps(texture: TextureData): Void
	{
	    if(!texture.hasMipMaps)
        {
            return;
        }

        if (texture.originalWidth != texture.originalHeight)
        {
            trace("Mimaps requested for Texture, but texture is not square.");
            return;
        }

        if (!GLUtils.isPowerOfTwo(texture.originalWidth))
        {
            trace("Mimaps requested for Texture, but texture dimensions are not power of two.");
            return;
        }

		bindTexture(texture);
	    GL.hint(GLDefines.GENERATE_MIPMAP_HINT, GLDefines.NICEST);

		var textureType = GLUtils.convertTextureTypeToOGL(texture.textureType);

	   	GL.generateMipmap(textureType);

	    configureFilteringMode(texture);
	}

    public function loadFilledRenderTargetData(renderTarget: RenderTargetData): Void
    {
        var context = getCurrentContext();

        if(renderTarget == context.defaultRenderTargetData)
        {
            return;
        }

        var previousRenderTarget = context.currentRenderTargetDataStack.first();

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
			if (renderTarget.depthTextureData != null
				&& renderTarget.stencilTextureData != null
				&& renderTarget.depthTextureData.glTexture == renderTarget.stencilTextureData.glTexture)
			{
				GL.framebufferTexture2D(GLDefines.FRAMEBUFFER,
                                        GLDefines.DEPTH_STENCIL_ATTACHMENT,
                                        GLDefines.TEXTURE_2D,
                                        renderTarget.depthTextureData.glTexture,
                                        0);
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
        }

        var result = GL.checkFramebufferStatus(GLDefines.FRAMEBUFFER);
        if(result != GLDefines.FRAMEBUFFER_COMPLETE)
        {
            trace("Framebuffer error: 0x%x", result);
        }

        GL.bindFramebuffer(GLDefines.FRAMEBUFFER, previousRenderTarget.framebufferID);
    }

    private function setupColorRenderbuffer(renderTarget: RenderTargetData): Void
    {
        if(renderTarget.colorFormat == null) return;

        var format = GLDefines.RGBA;
        if(renderTarget.colorFormat == ColorFormatRGB565)
        {
            format = GLDefines.RGB565;
        }

        renderTarget.colorRenderbufferID = GL.createRenderbuffer();
        GL.bindRenderbuffer(GLDefines.RENDERBUFFER, renderTarget.colorRenderbufferID);
        GL.renderbufferStorage(GLDefines.RENDERBUFFER, format, renderTarget.width, renderTarget.height);
        GL.framebufferRenderbuffer(GLDefines.FRAMEBUFFER, GLDefines.COLOR_ATTACHMENT0, GLDefines.RENDERBUFFER, renderTarget.colorRenderbufferID);
    }

    private function setupDepthRenderbuffer(renderTarget: RenderTargetData): Void
    {
        if(renderTarget.depthFormat == null) return;

        var format = GLDefines.DEPTH_COMPONENT;
        if(renderTarget.depthFormat == DepthFormat16)
        {
            format = GLDefines.DEPTH_COMPONENT16;
        }

        renderTarget.depthRenderbufferID = GL.createRenderbuffer();
        GL.bindRenderbuffer(GLDefines.RENDERBUFFER, renderTarget.depthRenderbufferID);
        GL.renderbufferStorage(GLDefines.RENDERBUFFER, format, renderTarget.width, renderTarget.height);
        GL.framebufferRenderbuffer(GLDefines.FRAMEBUFFER, GLDefines.DEPTH_ATTACHMENT, GLDefines.RENDERBUFFER, renderTarget.depthRenderbufferID);
    }

    private function setupStencilRenderbuffer(renderTarget: RenderTargetData): Void
    {
        if(renderTarget.stencilFormat == null) return;

        renderTarget.stencilRenderbufferID = GL.createRenderbuffer();
        GL.bindRenderbuffer(GLDefines.RENDERBUFFER, renderTarget.stencilRenderbufferID);
        GL.renderbufferStorage(GLDefines.RENDERBUFFER, GLDefines.STENCIL_INDEX8, renderTarget.width, renderTarget.height);
        GL.framebufferRenderbuffer(GLDefines.FRAMEBUFFER, GLDefines.STENCIL_ATTACHMENT, GLDefines.RENDERBUFFER, renderTarget.stencilRenderbufferID);
    }

    private function setupDepthStencilRenderbuffer(renderTarget: RenderTargetData): Void
    {
        if(renderTarget.stencilFormat == null && renderTarget.depthFormat == null) return;

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
        GL.renderbufferStorage(GLDefines.RENDERBUFFER, GLDefines.DEPTH24_STENCIL8, renderTarget.width, renderTarget.height);
        GL.framebufferRenderbuffer(GLDefines.FRAMEBUFFER, GLDefines.STENCIL_ATTACHMENT, GLDefines.RENDERBUFFER, renderTarget.depthStencilRenderbufferID);
        GL.framebufferRenderbuffer(GLDefines.FRAMEBUFFER, GLDefines.DEPTH_ATTACHMENT, GLDefines.RENDERBUFFER, renderTarget.depthStencilRenderbufferID);

    }

    public function isLoadedRenderTargetData(renderTarget: RenderTargetData): Bool
    {
        return renderTarget.alreadyLoaded;
    }

    public function isLoadedMeshData(meshData: MeshData): Bool
    {
        var attributeBuffer: Bool = false;
        if(meshData.attributeBuffer != null)
        {
            attributeBuffer = isLoadedMeshDataBuffer(meshData.attributeBuffer);
        }

        var indexBuffer: Bool = false;
        if(meshData.indexBuffer != null)
        {
            indexBuffer = isLoadedMeshDataBuffer(meshData.indexBuffer);
        }

        return attributeBuffer && indexBuffer;
    }

    public function isLoadedMeshDataBuffer(meshDataBuffer: MeshDataBuffer): Bool
    {
        if(meshDataBuffer != null)
            return meshDataBuffer.bufferAlreadyOnHardware;
        return false;
    }

    public function isLoadedShader(shader: Shader): Bool
    {
        return shader.alreadyLoaded;
    }

    public function isLoadedTextureData(textureData: TextureData): Bool
    {
        return textureData.alreadyLoaded;
    }

    private function unloadMeshDataBuffer(meshDataBuffer: MeshDataBuffer): Void
    {
        if(meshDataBuffer.bufferAlreadyOnHardware)
        {
            GL.deleteBuffer(meshDataBuffer.glBuffer);
            meshDataBuffer.glBuffer = GL.nullBuffer;
            meshDataBuffer.bufferAlreadyOnHardware = false;
        }
    }

    public function unloadMeshData(meshData: MeshData): Void
    {
        if(meshData.attributeBuffer != null)
        {
            unloadMeshDataBuffer(meshData.attributeBuffer);
        }

        if(meshData.indexBuffer != null)
        {
            unloadMeshDataBuffer(meshData.indexBuffer);
        }

        var context = getCurrentContext();

        if (context.glContext.supportsVertexArrayObjects)
        {
            if (meshData.vertexArrayObject != GLExt.nullVertexArrayObject)
            {
                GLExt.deleteVertexArrayOES(meshData.vertexArrayObject);
                meshData.vertexArrayObject = GLExt.nullVertexArrayObject;
            }
        }
    }

    public function unloadShader(shader: Shader): Void
    {
        if(shader.alreadyLoaded)
        {
            GL.deleteProgram(shader.programName);
            shader.programName = GL.nullProgram;
            shader.alreadyLoaded = false;
        }
    }

    public function unloadTextureData(textureData: TextureData): Void
    {
        if(textureData.alreadyLoaded)
        {
            var context = getCurrentContext();
            if(context.currentActiveTextures[context.currentActiveTexture] == textureData.glTexture)
            {
                context.currentActiveTextures[context.currentActiveTexture] = GL.nullTexture;
            }
            GL.deleteTexture(textureData.glTexture);
            textureData.glTexture = GL.nullTexture;
            textureData.alreadyLoaded = false;
        }
    }

    public function unloadRenderTargetData(renderTarget: RenderTargetData): Void
    {
        var context = getCurrentContext();
        if(renderTarget == context.defaultRenderTargetData)
        {
            return;
        }
        destroyRenderbuffers(renderTarget);

        GL.deleteFramebuffer(renderTarget.framebufferID);
        renderTarget.framebufferID = GL.nullFramebuffer;
        renderTarget.alreadyLoaded = false;
    }

    public function destroyRenderbuffers(renderTarget: RenderTargetData): Void
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

    public function enableBlending(enabled: Bool): Void
    {
        var context = getCurrentContext();

        if(context.currentBlendingEnabled != null && context.currentBlendingEnabled == enabled)
            return;

        if(enabled)
        {
            GL.enable(GLDefines.BLEND);
        }
        else
        {
            GL.disable(GLDefines.BLEND);
        }

        context.currentBlendingEnabled = enabled;
    }

    public function isBlending(): Null<Bool>
    {
        var context = getCurrentContext();
        return context.currentBlendingEnabled;
    }

	public function setBlendFunc(sourceFactor: BlendFactor, destinationFactor: BlendFactor): Void
	{
        trace('setBlendFunc sourceFactor: $sourceFactor destinationFactor: $destinationFactor');
		_setBlendFunc(sourceFactor, destinationFactor);
	}

    public function _setBlendFunc(sourceFactor: BlendFactor, destinationFactor: BlendFactor): Void
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

	public function setBlendFuncSeparate(sourceFactorRGB: BlendFactor,
										 destinationFactorRGB: BlendFactor,
										 sourceFactorA: BlendFactor,
										 destinationFactorA: BlendFactor): Void
	{
        trace('setBlendFunc sourceFactorRGB: $sourceFactorRGB destinationFactorRGB: $destinationFactorRGB sourceFactorA: $sourceFactorA destinationFactorA: $destinationFactorA');
		_setBlendFuncSeparate(sourceFactorRGB, destinationFactorRGB, sourceFactorA, destinationFactorA);
	}

    public function _setBlendFuncSeparate(sourceFactorRGB: BlendFactor,
                                         destinationFactorRGB: BlendFactor,
                                         sourceFactorA: BlendFactor,
                                         destinationFactorA: BlendFactor): Void
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

	public function setBlendMode(blendMode: BlendMode): Void
	{
        trace('setBlendMode blendMode: $blendMode');
		_setBlendMode(blendMode);
	}

    public function _setBlendMode(blendMode: BlendMode): Void
    {
        var context = getCurrentContext();

        if(blendMode != context.currentBlendModeA && blendMode != context.currentBlendModeRGB)
        {
            context.currentBlendModeA = blendMode;
            context.currentBlendModeRGB = blendMode;
            GL.blendEquation(GLUtils.convertBlendModeToOGL(blendMode));
        }
    }

	public function setBlendModeSeparate(blendModeRGB: BlendMode, blendModeA: BlendMode): Void
	{
		_setBlendModeSeparate(blendModeRGB, blendModeA);
	}

    public function _setBlendModeSeparate(blendModeRGB: BlendMode, blendModeA: BlendMode): Void
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

    public function enableDepthTesting(enabled: Bool): Void
    {
        var context = getCurrentContext();

        if(context.currentDepthTesting != null && context.currentDepthTesting == enabled) return;

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

    public function isDepthTesting(): Null<Bool>
    {
        var context = getCurrentContext();
        return context.currentDepthTesting;
    }

    public function enableDepthWrite(enabled: Bool): Void
    {
        var context = getCurrentContext();

        if (context.depthWrite != null && context.depthWrite == enabled) return;

        GL.depthMask(enabled);

        context.depthWrite = enabled;
    }

    public function isDepthWriting(): Null<Bool>
    {
        var context = getCurrentContext();
        return context.depthWrite;
    }

    public function setDepthFunc(depthFunc: DepthFunc): Void
    {
        var context = getCurrentContext();

        if (context.depthFunc != null && context.depthFunc == depthFunc) return;

        GL.depthFunc(GLUtils.convertDepthFuncToOGL(depthFunc));

        context.depthFunc = depthFunc;
    }

    public function getDepthFunc(): Null<DepthFunc>
    {
        var context = getCurrentContext();
        return context.depthFunc;
    }

    public function setFaceCullingMode(cullingMode: FaceCullingMode): Void
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
                GL.cullFace(GLUtils.convertFaceCullingModeToOGL(cullingMode));

                if(context.currentFaceCullingMode == FaceCullingModeOff || context.currentFaceCullingMode == null)
                {
                    GL.enable(GLDefines.CULL_FACE);
                }
            }
            context.currentFaceCullingMode = cullingMode;
        }
    }

    public function getFaceCullingMode(): FaceCullingMode
    {
        var context = getCurrentContext();
        return context.currentFaceCullingMode;
    }

    public function setLineWidth(lineWidth: Float): Void
    {
        var context = getCurrentContext();

        if(context.currentLineWidth != null && context.currentLineWidth == lineWidth)
            return;

        GL.lineWidth(lineWidth);
        context.currentLineWidth = lineWidth;
    }

    public function setColorMask(writeRed: Bool, writeGreen: Bool, writeBlue: Bool, writeAlpha: Bool): Void
    {
        GL.colorMask(writeRed, writeGreen, writeBlue, writeAlpha);
    }

    public function pushRenderTargetData(renderTarget: RenderTargetData): Void
    {
        var context = getCurrentContext();

        var framebuffer = renderTarget.framebufferID;

        if(context.currentRenderTargetDataStack.first().framebufferID != framebuffer)
        {
            GL.bindFramebuffer(GLDefines.FRAMEBUFFER, framebuffer);
        }

        context.currentRenderTargetDataStack.add(renderTarget);
    }

    public function popRenderTargetData(): Null<RenderTargetData>
    {
        var context = getCurrentContext();

        var topMost: RenderTargetData = context.currentRenderTargetDataStack.pop();

        if(!context.currentRenderTargetDataStack.isEmpty())
        {
            var nextRenderTarget = context.currentRenderTargetDataStack.first();

            if(nextRenderTarget == context.defaultRenderTargetData)
            {
                GL.bindFramebuffer(GLDefines.FRAMEBUFFER, context.defaultRenderTargetData.framebufferID);
            }
            else
            {
                GL.bindFramebuffer(GLDefines.FRAMEBUFFER, context.currentRenderTargetDataStack.first().framebufferID);
            }
        }

        return topMost;
    }

    public function getDefaultRenderTargetData(): RenderTargetData
    {
        var context = getCurrentContext();
        return context.defaultRenderTargetData;
    }

    public function discardRenderTargetData(renderTarget: RenderTargetData): Void
    {
        var context = getCurrentContext();

        if (!context.glContext.supportsDiscardFramebuffer) return;

        var colorFlag: Int = renderTarget.discardColor ? GLDefines.COLOR_ATTACHMENT0: 0;
        var depthFlag: Int = renderTarget.discardDepth ? GLDefines.DEPTH_ATTACHMENT: 0;
        var stencilFlag: Int = renderTarget.discardStencil ? GLDefines.STENCIL_ATTACHMENT: 0;

        GLExt.discardFramebufferEXT(GLDefines.FRAMEBUFFER, colorFlag, depthFlag, stencilFlag);
    }

    public function enableScissorTesting(enabled: Bool): Void
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

    public function setScissorTestRect(x: Int, y: Int, width: Int, height: Int): Void
    {
        GL.scissor(x, y, width, height);
    }

    public function bindShader(shader: Shader)
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
                    var nextValue: Int = uniformInterface.data.readInt(DataTypeInt32);
                    if (context.currentUniformTypeSingleInt != nextValue)
                    {
                        context.currentUniformTypeSingleInt = nextValue;
                        GL.uniform1i(uniformInterface.uniformLocation, nextValue);
                    }
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
                #if html5
                    GL.uniformMatrix4fv(uniformInterface.uniformLocation, uniformInterface.dataActiveCount, false, uniformInterface.data);
                #else
                    GL.uniformMatrix4fv(uniformInterface.uniformLocation, uniformInterface.dataActiveCount, true, uniformInterface.data);
                #end

                default:
			}
		}
	}

    // TODO Check bakedFrame feature with support of VertexArrayObjects (caching).
    // TODO Maybe implement bindBakedMeshData method.
	public function bindMeshData(data: MeshData, bakedFrame: Int)
	{
		if(data.bakedFrameCount > 0 && bakedFrame >= data.bakedFrameCount)
		{
			trace("Tried to set invalid frame on render buffer data");
			return;
		}

        var context = getCurrentContext();

        if (context.glContext.supportsVertexArrayObjects)
        {
            if (data.vertexArrayObject == GLExt.nullVertexArrayObject)
            {
                data.vertexArrayObject = GLExt.createVertexArrayOES();
                GLExt.bindVertexArrayOES(data.vertexArrayObject);
            }
            else
            {
                GLExt.bindVertexArrayOES(data.vertexArrayObject);
                return;
            }
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

        if (context.glContext.supportsVertexArrayObjects)
        {
            enableVertexAttributes(data);
        }
        else
        {
            enableVertexAttributesGlobal(data);
        }

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

	public function unbindMeshData(data: MeshData): Void
	{
        var context = getCurrentContext();

        if (context.glContext.supportsVertexArrayObjects)
        {
            if (data.vertexArrayObject != GLExt.nullVertexArrayObject)
            {
                GLExt.bindVertexArrayOES(GLExt.nullVertexArrayObject);
                return;
            }
        }

        if(data.attributeBuffer != null)
        {
            GL.bindBuffer(GLDefines.ARRAY_BUFFER, GL.nullBuffer);
        }

        if(data.indexBuffer != null)
        {
            GL.bindBuffer(GLDefines.ELEMENT_ARRAY_BUFFER, GL.nullBuffer);
        }
	}

    private function enableVertexAttributes(meshData: MeshData)
    {
        for(attributeConfig in meshData.attributeConfigs)
        {
            GL.enableVertexAttribArray(attributeConfig.attributeNumber);
        }
    }

	private function enableVertexAttributesGlobal(meshData: MeshData)
	{
		var combinedAttributes = 0;
		for(attributeConfig in meshData.attributeConfigs)
		{
			combinedAttributes |= 1 << attributeConfig.attributeNumber;
		}

		enableVertexAttributesFromCombinedAttributes(combinedAttributes);
	}

	private function enableVertexAttributesFromCombinedAttributes(combinedFlagsFromVertexAttributes: Int)
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
                    GL.disableVertexAttribArray(i);
				}
			}

			currentMask = currentMask << 1;
		}

        context.currentAttributeFlags = combinedFlagsFromVertexAttributes;
	}

	public function render(meshData: MeshData, bakedFrame: Int)
	{
		if(meshData.bakedFrameCount > 0 && bakedFrame >= meshData.bakedFrameCount)
		{
			trace("Tried to set invalid frame on render buffer data");
			return;
		}

		var primitiveType = GLUtils.convertPrimitiveTypeToOGL(meshData.primitiveType);

		if(meshData.indexBuffer != null)
		{///dont know if it is working
			var count: Int;
			var offset: Int;

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
			var count: Int;
			var offset: Int;
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
	}

    public function present(): Void
    {
    }

	public function bindTextureData(texture: TextureData, position: Int): Void
	{
    	if(texture == null) return;
        activeTexture(position);
        bindTexture(texture);
	}

	private function bindTexture(texture: TextureData)
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
        var context = getCurrentContext();

		if(position > GraphicsContext.maxActiveTextures)
		{
			trace("Tried to active a texture at position " + position + ", and max active textures is " + GraphicsContext.maxActiveTextures + "!");
			return;
		}

		if(position != context.currentActiveTexture)
		{
            context.currentActiveTexture = position;
			GL.activeTexture(position + GLDefines.TEXTURE0);
		}
	}

    public function setClearColor(color: Color4F): Void
    {
        var context = getCurrentContext();

        if (context.currentClearColor.isNotEqual(color))
        {
            context.currentClearColor.set(color);
            GL.clearColor(color.r, color.g, color.b, color.a);
        }
    }

    public function clearColorBuffer(): Void
    {
        GL.clear(GLDefines.COLOR_BUFFER_BIT);
    }

    public function clearDepthBuffer(): Void
    {
        GL.clear(GLDefines.DEPTH_BUFFER_BIT);
    }

    public function clearStencilBuffer(): Void
    {
        GL.clear(GLDefines.STENCIL_BUFFER_BIT);
    }

    public function clearColorStencilBuffer(): Void
    {
        GL.clear(GLDefines.COLOR_BUFFER_BIT | GLDefines.STENCIL_BUFFER_BIT);
    }

    public function clearColorDepthBuffer(): Void
    {
        GL.clear(GLDefines.COLOR_BUFFER_BIT | GLDefines.DEPTH_BUFFER_BIT);
    }

    public function clearAllBuffers(): Void
    {
        GL.clear(GLDefines.COLOR_BUFFER_BIT | GLDefines.DEPTH_BUFFER_BIT | GLDefines.STENCIL_BUFFER_BIT);
    }

    public function finishCommandPipeline(): Void
    {
        GL.finish();
    }

    public function flushCommandPipeline(): Void
    {
        GL.flush();
    }

    public function enableStencilTest(enabled: Bool): Void
    {
        var context = getCurrentContext();

        if (context.stencilingEnabled != null && context.stencilingEnabled == enabled) return;

        if (enabled)
        {
            GL.enable(GLDefines.STENCIL_TEST);
        }
        else
        {
            GL.disable(GLDefines.STENCIL_TEST);
        }

        context.stencilingEnabled = enabled;
    }

    public function isStencilTestEnabled(): Null<Bool>
    {
        var context = getCurrentContext();
        return context.stencilingEnabled;
    }

    public function setStencilFunc(stencilFunc: StencilFunc, referenceValue: Int, readMask: Int): Void
    {
        GL.stencilFunc(GLUtils.convertStencilFuncToOGL(stencilFunc), referenceValue, readMask);
    }

    public function setStencilOp(stencilFail: StencilOp, depthFail: StencilOp, stencilAndDepthPass: StencilOp): Void
    {
        GL.stencilOp(GLUtils.convertStencilOpToOGL(stencilFail),
                     GLUtils.convertStencilOpToOGL(depthFail),
                     GLUtils.convertStencilOpToOGL(stencilAndDepthPass));
    }

    public function setStencilMask(writeMask: Int): Void
    {
        GL.stencilMask(writeMask);
    }

    public function setViewPort(x: Int, y: Int, width: Int, height: Int)
    {
        GL.viewport(x,y,width,height);
    }

    public function getMaxTextureSize(): Null<Int>
    {
        var context = getCurrentContext();
        return context.glContext.maxTextureSize;
    }

    public function getMaxRenderbufferSize(): Null<Int>
    {
        var context = getCurrentContext();
        return context.glContext.maxRenderbufferSize;
    }

    public function getMaxCubeTextureSize(): Null<Int>
    {
        var context = getCurrentContext();
        return context.glContext.maxCubeTextureSize;
    }
}

class DisabledGraphics extends Graphics
{
    override public function loadFilledContext(context: GraphicsContext): Void {}
    override public function isLoadedContext(context:GraphicsContext): Bool {return false;}
    override public function unloadFilledContext(context: GraphicsContext): Void {}
    override public function getCurrentContext(): Null<GraphicsContext> {return null;}
    override public function pushContext(context: GraphicsContext): Void {}
    override public function popContext(): Null<GraphicsContext> {return null;}
    override public function loadFilledMeshData(meshData: MeshData) {}
    override public function loadFilledVertexBuffer(meshData: MeshData): Void {}
    override public function loadFilledIndexBuffer(meshData: MeshData): Void {}
    override private function loadFilledMeshDataBuffer(bufferType: Int, meshDataBuffer: MeshDataBuffer) {}
    override public function loadFilledShader(shader: Shader) {}
    override private function compileShader(type: Int, code: String): GLShader {return GL.nullShader;}
    override private function linkShader(shaderProgramName: GLProgram): Bool {return false;}
    override public function loadFilledTextureData(texture: TextureData): Void {}
    override public function updateFilledTextureData(texture: TextureData, offsetX: Int, offsetY: Int) : Void{};
    override private function pushTextureData(texture: TextureData): Void {}
    override private function pushTextureDataForType(textureType: Int, textureFormat: TextureFormat, data: Data, width: Int, height: Int) {}
    override private function configureFilteringMode(texture: TextureData): Void {}
    override private function configureWrap(texture: TextureData): Void {}
    override private function configureMipmaps(texture: TextureData): Void {}
    override public function loadFilledRenderTargetData(renderTarget: RenderTargetData): Void {}
    override private function setupColorRenderbuffer(renderTarget: RenderTargetData): Void {}
    override private function setupDepthRenderbuffer(renderTarget: RenderTargetData): Void {}
    override private function setupStencilRenderbuffer(renderTarget: RenderTargetData): Void {}
    override private function setupDepthStencilRenderbuffer(renderTarget: RenderTargetData): Void {}
    override public function isLoadedRenderTargetData(renderTarget: RenderTargetData): Bool {return false;}
    override public function isLoadedMeshData(meshData: MeshData): Bool {return false;}
    override public function isLoadedMeshDataBuffer(meshDataBuffer: MeshDataBuffer): Bool {return false;}
    override public function isLoadedShader(shader: Shader): Bool {return false;}
    override public function isLoadedTextureData(textureData: TextureData): Bool {return false;}
    override private function unloadMeshDataBuffer(meshDataBuffer: MeshDataBuffer): Void {}
    override public function unloadMeshData(meshData: MeshData): Void {}
    override public function unloadShader(shader: Shader): Void {}
    override public function unloadTextureData(textureData: TextureData): Void {}
    override public function unloadRenderTargetData(renderTarget: RenderTargetData): Void {}
    override public function destroyRenderbuffers(renderTarget: RenderTargetData): Void {}
    override public function enableBlending(enabled: Bool): Void {}
    override public function isBlending(): Null<Bool> {return null;}
    override public function setBlendFunc(sourceFactor: BlendFactor, destinationFactor: BlendFactor): Void {}
    override public function setBlendFuncSeparate(sourceFactorRGB: BlendFactor,
                                         destinationFactorRGB: BlendFactor,
                                         sourceFactorA: BlendFactor,
                                         destinationFactorA: BlendFactor): Void {}
    override public function setBlendMode(blendMode: BlendMode): Void {}
    override public function setBlendModeSeparate(blendModeRGB: BlendMode, blendModeA: BlendMode): Void {}
    override public function enableDepthTesting(enabled: Bool): Void {}
    override public function isDepthTesting(): Null<Bool> {return null;}
    override public function enableDepthWrite(enabled: Bool): Void {}
    override public function isDepthWriting(): Null<Bool> {return null;}
    override public function setDepthFunc(depthFunc: DepthFunc): Void {}
    override public function getDepthFunc(): Null<DepthFunc> {return null;}
    override public function setFaceCullingMode(cullingMode: FaceCullingMode): Void {}
    override public function getFaceCullingMode(): Null<FaceCullingMode> {return null;}
    override public function setLineWidth(lineWidth: Float): Void {}
    override public function setColorMask(writeRed: Bool, writeGreen: Bool, writeBlue: Bool, writeAlpha: Bool): Void {}
    override public function pushRenderTargetData(renderTarget: RenderTargetData): Void {}
    override public function popRenderTargetData(): Null<RenderTargetData> {return null;}
    override public function getDefaultRenderTargetData(): Null<RenderTargetData> {return null;}
    override public function discardRenderTargetData(renderTarget: RenderTargetData): Void {}
    override public function enableScissorTesting(enabled: Bool): Void {}
    override public function setScissorTestRect(x: Int, y: Int, width: Int, height: Int): Void {}
    override public function bindShader(shader: Shader) {}
    override public function bindMeshData(data: MeshData, bakedFrame: Int) {}
    override public function unbindMeshData(data: MeshData): Void {}
    override private function enableVertexAttributes(meshData: MeshData) {}
    override private function enableVertexAttributesGlobal(meshData: MeshData) {}
    override private function enableVertexAttributesFromCombinedAttributes(combinedFlagsFromVertexAttributes: Int) {}
    override public function render(meshData: MeshData, bakedFrame: Int) {}
    override public function present(): Void {}
    override public function bindTextureData(texture: TextureData, position: Int): Void {}
    override private function bindTexture(texture: TextureData) {}
    override private function activeTexture(position) {}
    override public function setClearColor(color: Color4F): Void {}
    override public function clearColorBuffer(): Void {}
    override public function clearDepthBuffer(): Void {}
    override public function clearStencilBuffer(): Void {}
    override public function clearColorStencilBuffer(): Void {}
    override public function clearColorDepthBuffer(): Void {}
    override public function clearAllBuffers(): Void {}
    override public function finishCommandPipeline(): Void {}
    override public function flushCommandPipeline(): Void {}
    override public function enableStencilTest(enabled: Bool): Void {}
    override public function isStencilTestEnabled(): Null<Bool> {return null;}
    override public function setStencilFunc(stencilFunc: StencilFunc, referenceValue: Int, readMask: Int): Void {}
    override public function setStencilOp(stencilFail: StencilOp, depthFail: StencilOp, stencilAndDepthPass: StencilOp): Void {}
    override public function setStencilMask(writeMask: Int): Void {}
    override public function setViewPort(x: Int, y: Int, width: Int, height: Int) {}
    override public function getMaxTextureSize(): Null<Int> {return null;}
    override public function getMaxRenderbufferSize(): Null<Int> {return null;}
    override public function getMaxCubeTextureSize(): Null<Int> {return null;}
}
