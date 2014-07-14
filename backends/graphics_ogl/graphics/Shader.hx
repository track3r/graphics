/*
 * Created by IntelliJ IDEA.
 * User: rcam
 * Date: 22/05/14
 * Time: 14:23
 */
package graphics;

import graphics.GraphicsTypes;

import types.Data;

import gl.GL;

class Shader
{
    public var name : String;///purely for debugging purposes.

    public var vertexShaderCode : Dynamic;
    public var fragmentShaderCode : Dynamic;

    public var uniformInterfaces : Array<ShaderUniformInterface>;

    public var attributeNames : Array<String>;

    public var alreadyLoaded : Bool;

    public function new() : Void {}

    /// specific to ogl
    public var programName : GLProgram;

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

        data = new Data(count * GraphicsTypesUtils.uniformTypeElementSize(uniformType));
        dataActiveCount = 0;
    }

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

    /// specific to ogl
    public var uniformLocation : GLUniformLocation;
}