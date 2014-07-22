package graphics;
import flash.display3D.Program3D;
import graphics.GraphicsTypes;
import types.Data;

class Shader
{
    public var name : String;///purely for debugging purposes.

    public var vertexShaderCode : String;
    public var fragmentShaderCode : String;

    public var uniformInterfaces : Array<ShaderUniformInterface>;

    public var attributeNames : Array<String>;

    public var program:Program3D;

    public function new(?name:String) : Void
    {
        this.name = name;
    }
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
        this.dataSize = GraphicsTypesUtils.uniformTypeElementSize(uniformType);

        //deal with flash limitations on register size
        if(this.dataSize < minRegisterSize)this.dataSize = minRegisterSize;

        data = new Data(count * dataSize);
        numRegisters = Math.ceil(data.offsetLength/minRegisterSize);
    }

//flash only
    public var dataSize: Int = 0;
    public var numRegisters: Int = 0;
    public var minRegisterSize: Int = 16;
    public var offset: Int = 0;
    public var isVertexConstant:Bool=true;


    public function writeMatrix44Data(matrixData : Data, count:Int = 1) : Void
    {
        data.offset = 0;
        matrixData.offset = 0;

        dataActiveCount = count;
        data.writeData(matrixData);

        data.offset = 0;
        matrixData.offset = 0;
    }

    public function writeMatrix33Data(matrixData : Data, count:Int = 1) : Void
    {
        data.offset = 0;
        matrixData.offset = 0;

        dataActiveCount = count;
        data.writeData(matrixData);

        data.offset = 0;
        matrixData.offset = 0;
    }
}