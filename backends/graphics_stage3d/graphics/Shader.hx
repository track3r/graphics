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
        var m00:Float;
        var m01:Float;
        var m02:Float;
        var m03:Float;

        var m04:Float;
        var m05:Float;
        var m06:Float;
        var m07:Float;

        var m08:Float;
        var m09:Float;
        var m10:Float;
        var m11:Float;

        var m12:Float;
        var m13:Float;
        var m14:Float;
        var m15:Float;

        data.offset = 0;
        matrixData.offset = 0;

        while (count >= 1)
        {
            m00 = matrixData.readFloat(DataTypeFloat32);
            matrixData.offset += 4;

            m01 = matrixData.readFloat(DataTypeFloat32);
            matrixData.offset += 4;

            m02 = matrixData.readFloat(DataTypeFloat32);
            matrixData.offset += 4;

            m03 = matrixData.readFloat(DataTypeFloat32);
            matrixData.offset += 4;

            m04 = matrixData.readFloat(DataTypeFloat32);
            matrixData.offset += 4;

            m05 = matrixData.readFloat(DataTypeFloat32);
            matrixData.offset += 4;

            m06 = matrixData.readFloat(DataTypeFloat32);
            matrixData.offset += 4;

            m07 = matrixData.readFloat(DataTypeFloat32);
            matrixData.offset += 4;

            m08 = matrixData.readFloat(DataTypeFloat32);
            matrixData.offset += 4;

            m09 = matrixData.readFloat(DataTypeFloat32);
            matrixData.offset += 4;

            m10 = matrixData.readFloat(DataTypeFloat32);
            matrixData.offset += 4;

            m11 = matrixData.readFloat(DataTypeFloat32);
            matrixData.offset += 4;

            m12 = matrixData.readFloat(DataTypeFloat32);
            matrixData.offset += 4;

            m13 = matrixData.readFloat(DataTypeFloat32);
            matrixData.offset += 4;

            m14 = matrixData.readFloat(DataTypeFloat32);
            matrixData.offset += 4;

            m15 = matrixData.readFloat(DataTypeFloat32);
            matrixData.offset += 4;

            // Transpose Matrix for flash

            data.writeFloat(m00, DataTypeFloat32);
            data.offset += 4;

            data.writeFloat(m04, DataTypeFloat32);
            data.offset += 4;

            data.writeFloat(m08, DataTypeFloat32);
            data.offset += 4;

            data.writeFloat(m12, DataTypeFloat32);
            data.offset += 4;


            data.writeFloat(m01, DataTypeFloat32);
            data.offset += 4;

            data.writeFloat(m05, DataTypeFloat32);
            data.offset += 4;

            data.writeFloat(m09, DataTypeFloat32);
            data.offset += 4;

            data.writeFloat(m13, DataTypeFloat32);
            data.offset += 4;


            data.writeFloat(m02, DataTypeFloat32);
            data.offset += 4;

            data.writeFloat(m06, DataTypeFloat32);
            data.offset += 4;

            data.writeFloat(m10, DataTypeFloat32);
            data.offset += 4;

            data.writeFloat(m14, DataTypeFloat32);
            data.offset += 4;


            data.writeFloat(m03, DataTypeFloat32);
            data.offset += 4;

            data.writeFloat(m07, DataTypeFloat32);
            data.offset += 4;

            data.writeFloat(m11, DataTypeFloat32);
            data.offset += 4;

            data.writeFloat(m15, DataTypeFloat32);
            data.offset += 4;

            --count;
        }

        matrixData.offset = 0;
        data.offset = 0;
    }

    public function writeMatrix33Data(matrixData : Data, count:Int = 1) : Void
    {

    }

}