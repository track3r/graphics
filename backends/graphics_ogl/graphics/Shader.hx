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

    public function new() : Void {}

    /// specific to ogl
    public var programName : GLProgram;
    public var alreadyLoaded : Bool;
}

class ShaderUniformInterface
{
    public var dataCount : Int = 0;
    public var uniformType : UniformType;
    public var shaderType : ShaderType;

    public var shaderVariableName : String;

    public var data : Data;
    public var dataActiveCount : Int = 0;

    public function new() : Void {}

    public function setup(shaderVariableName : String, uniformType : UniformType, shaderType : ShaderType, count : Int = 1) : Void
    {
        this.shaderVariableName = shaderVariableName;
        this.uniformType = uniformType;
        this.shaderType = shaderType;

        data = new Data(count * GraphicsTypesUtils.uniformTypeElementSize(uniformType));
        dataActiveCount = 0;
    }
    /// specific to ogl
    public var uniformLocation : GLUniformLocation;
}