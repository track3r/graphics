package graphics;
import flash.display3D.Program3D;
import graphics.GraphicsTypes;
import types.Data;

class Shader {
    public var name : String;///purely for debugging purposes.

    public var vertexShaderCode : String;
    public var fragmentShaderCode : String;

    public var uniformInterfaces : Array<ShaderUniformInterface>;

    public var attributeNames : Array<String>;

    public var program:Program3D;

    public function new(?name:String) : Void {
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

    public function writeMatrixData(matrixData : Data) : Void
    {
        matrixData.offset = 0;
        var m00 = matrixData.readFloat(DataTypeFloat32);
        matrixData.offset = 4;
        var m01 = matrixData.readFloat(DataTypeFloat32);
        matrixData.offset = 8;
        var m02 = matrixData.readFloat(DataTypeFloat32);
        matrixData.offset = 12;
        var m03 = matrixData.readFloat(DataTypeFloat32);

        matrixData.offset = 16;
        var m04 = matrixData.readFloat(DataTypeFloat32);
        matrixData.offset = 20;
        var m05 = matrixData.readFloat(DataTypeFloat32);
        matrixData.offset = 24;
        var m06 = matrixData.readFloat(DataTypeFloat32);
        matrixData.offset = 28;
        var m07 = matrixData.readFloat(DataTypeFloat32);

        matrixData.offset = 32;
        var m08 = matrixData.readFloat(DataTypeFloat32);
        matrixData.offset = 36;
        var m09 = matrixData.readFloat(DataTypeFloat32);
        matrixData.offset = 40;
        var m10 = matrixData.readFloat(DataTypeFloat32);
        matrixData.offset = 44;
        var m11 = matrixData.readFloat(DataTypeFloat32);

        matrixData.offset = 48;
        var m12 = matrixData.readFloat(DataTypeFloat32);
        matrixData.offset = 52;
        var m13 = matrixData.readFloat(DataTypeFloat32);
        matrixData.offset = 56;
        var m14 = matrixData.readFloat(DataTypeFloat32);
        matrixData.offset = 60;
        var m15 = matrixData.readFloat(DataTypeFloat32);

        matrixData.offset = 0;

        // Transpose Matrix for flash

        data.offset = 0;
        data.writeFloat(m00, DataTypeFloat32);

        data.offset = 4;
        data.writeFloat(m04, DataTypeFloat32);

        data.offset = 8;
        data.writeFloat(m08, DataTypeFloat32);

        data.offset = 12;
        data.writeFloat(m12, DataTypeFloat32);


        data.offset = 16;
        data.writeFloat(m01, DataTypeFloat32);

        data.offset = 20;
        data.writeFloat(m05, DataTypeFloat32);

        data.offset = 24;
        data.writeFloat(m09, DataTypeFloat32);

        data.offset = 28;
        data.writeFloat(m13, DataTypeFloat32);


        data.offset = 32;
        data.writeFloat(m02, DataTypeFloat32);

        data.offset = 36;
        data.writeFloat(m06, DataTypeFloat32);

        data.offset = 40;
        data.writeFloat(m10, DataTypeFloat32);

        data.offset = 44;
        data.writeFloat(m14, DataTypeFloat32);


        data.offset = 48;
        data.writeFloat(m03, DataTypeFloat32);

        data.offset = 52;
        data.writeFloat(m07, DataTypeFloat32);

        data.offset = 56;
        data.writeFloat(m11, DataTypeFloat32);

        data.offset = 60;
        data.writeFloat(m15, DataTypeFloat32);

        data.offset = 0;
    }

}