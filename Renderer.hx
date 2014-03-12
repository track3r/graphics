import RenderTypes;

import lime.utils.ByteArray;

import RendererImplementation;


class MeshDataBuffer 
{
	public var bufferMode : BufferMode;
	public var data : ByteArray;

	private function new() {}

	static public function create() : MeshDataBuffer
	{
		return new MeshDataBufferImplementation();
	}
}

class MeshDataAttributeConfig
{
	public var attributeNumber : Int;
	public var stride : Int;
	public var vertexElementCount : Int;
	public var vertexElementType : DataType;
	public var offsetInData : Int;
	public var offsetPerBakedFrame : Array<Int>;
	public var vertexElementsNormalized : Bool;

	private function new() {}

	static public function create() : MeshDataAttributeConfig
	{
		return new MeshDataAttributeConfigImplementation();
	}
}

class MeshData
{
	public var attributeBuffer : MeshDataBuffer;
	public var indexBuffer : MeshDataBuffer;
	public var attributeConfigs : Array<MeshDataAttributeConfig>;

	public var vertexCount : Int;
	public var indexCount : Int;
	public var bakedFrameCount : Int;
	public var bakedFPS : Int;

	public var primitiveType : PrimitiveType;
	public var indexDataType : DataType;
	public var indexCountPerBakedFrame : Array<Int>;
	public var indexOffsetPerBakedFrame : Array<Int>;

	private function new() {}

	static public function create() : MeshData
	{
		return new MeshDataImplementation();
	}
}

class ShaderUniformInterface
{
	public var dataCount : Int;
	public var uniformType : UniformType;
	
	public var name : String;

	public var data : ByteArray;
	public var dataActiveCount : Int;

	private function new(name : String, uniformType : UniformType, count : Int) 
	{
		this.name = name;
		this.uniformType = uniformType;

		this.data = new ByteArray(count * RenderTypesUtils.uniformTypeElementSize(uniformType));
		this.dataActiveCount = 0;
	}

	static public function create(name : String, uniformType : UniformType, count : Int) : ShaderUniformInterface
	{
		return new ShaderUniformInterfaceImplementation(name, uniformType, count);
	}
}	

class Shader
{
	public var name : String;

	/// Since HXSL is unstable, we will ifdef the shader code on client side.
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

	static public function create(name : String) : Shader
	{
		var shader : Shader = new ShaderImplementation();

		shader.name = name;

		if(shaderCache == null)
		{
			shaderCache = new Map<String, Shader>();
		}

		shaderCache.set(name, shader);

		return shader;
	}


	private function new() {}
}

class Renderer
{
	static var sharedRenderer : Renderer;
	static public function shared() : Renderer
	{
		if(sharedRenderer == null)
		{
			sharedRenderer = new RendererImplementation();
		}
		return sharedRenderer;
	}

	private function new() {}

	public function loadFilledMeshData(meshData : MeshData) {};

	public function loadFilledShader(shader : Shader) {};

	public function bindShader(shader : Shader) {};
	public function bindMeshData(meshData : MeshData, bakedFrame : Int) {};
	public function render(meshData : MeshData, bakedFrame : Int) {};


}


