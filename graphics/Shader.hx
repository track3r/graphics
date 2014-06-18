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

    //private var vertexShader:GLSLVertexShader;

    //private var fragmentShader:GLSLFragmentShader;
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

    public var isVertexConstant:Bool = false;

    public function new() : Void {}

    public function setup(shaderVariableName : String, uniformType : UniformType, count : Int) : Void
    {
        this.shaderVariableName = shaderVariableName;
        this.uniformType = uniformType;

        data = new Data(count * GraphicsTypesUtils.uniformTypeElementSize(uniformType));
        //dataCount = count;
        dataActiveCount = 0;
    }
}