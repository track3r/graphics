package renderer;

import gl.GL;
import gl.GLDefines;

import lime.Lime;

import renderer.GLUtils;

import StringTools;

import haxe.io.BytesInput;

import renderer.RenderTypes;
import types.DataType;
import types.Data;

class Shader
{
	public var name : String;

	public var vertexShaderCode : Dynamic;
	public var fragmentShaderCode : Dynamic;

	public var uniformInterfaces : Array<ShaderUniformInterface>;

	public var attributeNames : Array<String>;

	static public var shaderCache : Map<String, Shader>;
	static public function checkForCachedShader(name : String) : Shader
	{
		if(shaderCache == null)
			return null;

		return shaderCache.get(name);
	}

	public function new(?name : String) : Void
	{
		if(name == null) /// no caching
			return;

		this.name = name;

		if(shaderCache == null)
		{
			shaderCache = new Map<String, Shader>();
		}

		shaderCache.set(name, this);
	}

	/// specific to ogl
	public var programName : GLProgram;

	public var alreadyLoaded : Bool;
}

class ShaderUniformInterface
{
	public var dataCount : Int = 0;
	public var uniformType : UniformType;
	
	public var shaderVariableName : String;

	public var data : Data;
	public var dataActiveCount : Int = 0;

	public function new() : Void {}

	public function setup(shaderVariableName : String, uniformType : UniformType, count : Int) : Void
	{
		this.shaderVariableName = shaderVariableName;
		this.uniformType = uniformType;

		data = new Data(count * RenderTypesUtils.uniformTypeElementSize(uniformType));
		dataActiveCount = 0;
	}

	/// specific to ogl
	public var uniformLocation : GLUniformLocation;
}

class MeshDataBuffer
{
	public var bufferMode : BufferMode;
	public var data : Data;

	public function new() : Void {}

	/// specific to ogl
	public var glBuffer : GLBuffer;
	public var sizeOfHardwareBuffer : Int;

	public var bufferAlreadyOnHardware : Bool;
}

class MeshDataAttributeConfig
{
	public var attributeNumber : Int = 0;
	public var stride : Int = 0;
	public var vertexElementCount : Int = 0;
	public var vertexElementType : DataType;
	public var offsetInData : Int = 0;
	public var offsetPerBakedFrame : Array<Int>;
	public var vertexElementsNormalized : Bool = false;

	public function new() : Void {}
}

class MeshData
{
	public var attributeBuffer : MeshDataBuffer;
	public var indexBuffer : MeshDataBuffer;
	public var attributeConfigs : Array<MeshDataAttributeConfig>;

	public var vertexCount : Int = 0;
	public var indexCount : Int = 0;
	public var bakedFrameCount : Int = 0;
	public var bakedFPS : Int = 0;

	public var primitiveType : PrimitiveType;
	public var indexDataType : DataType;
	public var indexCountPerBakedFrame : Array<Int>;
	public var indexOffsetPerBakedFrame : Array<Int>;

	public function new() : Void {}
}

class Renderer
{
	/// caching data
	private var currentShader : GLProgram;
	private var cachedAttributeFlags = 0;
	/// -------------

	private function new() {}

	static var sharedInstance : Renderer;
	public static function instance() : Renderer
	{
		if(sharedInstance == null)
		{
			sharedInstance = new Renderer();
		}
		return sharedInstance;
	}

	public function initialize(lime : Lime) 
	{
		#if html5
		GL.context = lime.render.direct_renderer_handle;
		#end
		currentShader = GL.nullProgram;
	}

	public function loadFilledMeshData(meshData : MeshData)
	{
		if(meshData == null)
			return;

		loadFilledMeshDataBuffer(cast meshData.attributeBuffer);
		loadFilledMeshDataBuffer(cast meshData.indexBuffer);
	}
	
	private function loadFilledMeshDataBuffer(meshDataBuffer : MeshDataBuffer)
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
				GL.bindBuffer(GLDefines.ARRAY_BUFFER, meshDataBuffer.glBuffer);
				GL.bufferSubData(GLDefines.ARRAY_BUFFER, 0, meshDataBuffer.data);
			}
			else
			{
				GL.bindBuffer(GLDefines.ARRAY_BUFFER, meshDataBuffer.glBuffer);
				GL.bufferData(GLDefines.ARRAY_BUFFER, meshDataBuffer.data,
							  GLUtils.convertBufferModeFromUTKToOGL(meshDataBuffer.bufferMode));

			}
			meshDataBuffer.sizeOfHardwareBuffer = meshDataBuffer.data.offsetLength;
			meshDataBuffer.bufferAlreadyOnHardware = true;
		}
		GL.bindBuffer(GLDefines.ARRAY_BUFFER, GL.nullBuffer);
	}


	public function loadFilledShader(shader : Shader) 
	{
		if(shader.alreadyLoaded)
			return;

		shader.alreadyLoaded = true;

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


	};

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

	public function bindShader(shader : Shader) 
	{
		if(currentShader != shader.programName)
		{
			GL.useProgram(shader.programName);
			currentShader = shader.programName;
		}

		for(uniformInterface in shader.uniformInterfaces)
		{

			switch(uniformInterface.uniformType)
			{
				/*
			case SingleInt:
				GL.uniform1i(uniformInterfaceImpl.uniformLocation, cast(uniformInterfaceImpl.data, Int32Array)[0]);
				break;
			case UTK_UNIFORM_SINGLE_INT_ARRAY:
				glUniform1iv(uniform->_uniformLocation, (GLsizei)uniform->_dataActiveCount, (int*)uniform->_dataPtr);
				break;
			case UTK_UNIFORM_SINGLE_FLOAT:
				glUniform1f(uniform->_uniformLocation, ((float*)uniform->_dataPtr)[0]);
				break;
			case UTK_UNIFORM_SINGLE_FLOAT_ARRAY:
				glUniform1fv(uniform->_uniformLocation, (GLsizei)uniform->_dataActiveCount, (float*)uniform->_dataPtr);
				break;
			case UTK_UNIFORM_VECTOR_2_INT:
				glUniform2i(uniform->_uniformLocation, ((int*)uniform->_dataPtr)[0], ((int*)uniform->_dataPtr)[1]);
				break;
			case UTK_UNIFORM_VECTOR_2_INT_ARRAY:
				glUniform2iv(uniform->_uniformLocation, (GLsizei)uniform->_dataActiveCount, (int*)uniform->_dataPtr);
				break;
			case UTK_UNIFORM_VECTOR_2_FLOAT:
				glUniform2f(uniform->_uniformLocation, ((float*)uniform->_dataPtr)[0], ((float*)uniform->_dataPtr)[1]);
				break;
			case UTK_UNIFORM_VECTOR_2_FLOAT_ARRAY:
				glUniform2fv(uniform->_uniformLocation, (GLsizei)uniform->_dataActiveCount, (float*)uniform->_dataPtr);
				break;
			case UTK_UNIFORM_VECTOR_3_INT:
				glUniform3i(uniform->_uniformLocation, ((int*)uniform->_dataPtr)[0],
							((int*)uniform->_dataPtr)[1],
							((int*)uniform->_dataPtr)[2]);
				break;
			case UTK_UNIFORM_VECTOR_3_INT_ARRAY:
				glUniform3iv(uniform->_uniformLocation, (GLsizei)uniform->_dataActiveCount, (int*)uniform->_dataPtr);
				break;
			case UTK_UNIFORM_VECTOR_3_FLOAT:
				glUniform3f(uniform->_uniformLocation, ((float*)uniform->_dataPtr)[0],
							((float*)uniform->_dataPtr)[1],
							((float*)uniform->_dataPtr)[2]);
				break;
			case UTK_UNIFORM_VECTOR_3_FLOAT_ARRAY:
				glUniform3fv(uniform->_uniformLocation, (GLsizei)uniform->_dataActiveCount, (float*)uniform->_dataPtr);
				break;
			case UTK_UNIFORM_VECTOR_4_INT:
				glUniform4i(uniform->_uniformLocation, ((int*)uniform->_dataPtr)[0],
							((int*)uniform->_dataPtr)[1],
							((int*)uniform->_dataPtr)[2],
							((int*)uniform->_dataPtr)[3]);
				break;
			case UTK_UNIFORM_VECTOR_4_INT_ARRAY:
				glUniform4iv(uniform->_uniformLocation, (GLsizei)uniform->_dataActiveCount, (int*)uniform->_dataPtr);
				break;
			case UTK_UNIFORM_VECTOR_4_FLOAT:
				glUniform4f(uniform->_uniformLocation, ((float*)uniform->_dataPtr)[0],
							((float*)uniform->_dataPtr)[1],
							((float*)uniform->_dataPtr)[2],
							((float*)uniform->_dataPtr)[3]);
				break;
			case UTK_UNIFORM_VECTOR_4_FLOAT_ARRAY:
				glUniform4fv(uniform->_uniformLocation, (GLsizei)uniform->_dataActiveCount, (float*)uniform->_dataPtr);
				break;
			case UTK_UNIFORM_MATRIX_2:
				glUniformMatrix2fv(uniform->_uniformLocation, (GLsizei)uniform->_dataActiveCount, false, (float*)uniform->_dataPtr);
				break;
			case UTK_UNIFORM_MATRIX_2_TRANSPOSED:
				glUniformMatrix2fv(uniform->_uniformLocation, (GLsizei)uniform->_dataActiveCount, true, (float*)uniform->_dataPtr);
				break;
			case UTK_UNIFORM_MATRIX_3:
				glUniformMatrix3fv(uniform->_uniformLocation, (GLsizei)uniform->_dataActiveCount, false, (float*)uniform->_dataPtr);
				break;
			case UTK_UNIFORM_MATRIX_3_TRANSPOSED:
				glUniformMatrix3fv(uniform->_uniformLocation, (GLsizei)uniform->_dataActiveCount, true, (float*)uniform->_dataPtr);
				break;
				*/
			case UniformTypeMatrix4:
				//lime_gl_uniform_matrix(uniformInterfaceImpl.uniformLocation, false, uniformInterfaceImpl, 4);
				GL.uniformMatrix4fv(uniformInterface.uniformLocation, uniformInterface.dataActiveCount, false, uniformInterface.data);
				break;
				/*
			case UTK_UNIFORM_MATRIX_4_TRANSPOSED:
				glUniformMatrix4fv(uniform->_uniformLocation, (GLsizei)uniform->_dataActiveCount, true, (float*)uniform->_dataPtr);
				break;
				*/
			default:
				break;
			}
		}
	};

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
								   GLUtils.convertDataTypeFromUTKToOGL(attributeConfig.vertexElementType),
								   attributeConfig.vertexElementsNormalized,
								   attributeConfig.stride,
								   attributeConfig.offsetInData + offsetForFrame);
		}
	};

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
		var currentMask = 1;
		for(i in 0...8)
		{
			var enableNow = combinedFlagsFromVertexAttributes & currentMask;
			var prevState = cachedAttributeFlags & currentMask;

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

		cachedAttributeFlags = combinedFlagsFromVertexAttributes;
	}

	public function render(meshData : MeshData, bakedFrame : Int)
	{
		if(meshData.bakedFrameCount > 0 && bakedFrame >= meshData.bakedFrameCount)
		{
			trace("Tried to set invalid frame on render buffer data");
			return;
		}

		var primitiveType = GLUtils.convertPrimitiveTypeFromUTKToOGL(meshData.primitiveType);

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
							GLUtils.convertDataTypeFromUTKToOGL(meshData.indexDataType),
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


	public function setClearColor(r : Float, g : Float, b : Float, a : Float) 
	{
		GL.clearColor(r, g, b, a);
	}
	public function clear() 
	{
		GL.clear (GLDefines.COLOR_BUFFER_BIT);
	};

}