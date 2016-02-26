/*
 * Created by IntelliJ IDEA.
 * User: rcam
 * Date: 22/05/14
 * Time: 11:07
 */
package graphics;

import gl.GL.GLProgram;
import types.Data;
import graphics.GraphicsTypes;

extern class Shader
{
    public function new(): Void;
    /// Since HXSL is unstable, we will ifdef the shader code on client side.
    public var vertexShaderCode : Dynamic;
    public var fragmentShaderCode : Dynamic;

    public var uniformInterfaces : Array<ShaderUniformInterface>;

    public var attributeNames : Array<String>;

    public var programName : GLProgram;
}

extern class ShaderUniformInterface
{
    public var name : String;///purely for debugging purposes.

    public var dataCount : Int;
    public var uniformType : UniformType;
    public var shaderType : ShaderType;  /// To which shader this Const/Uniform belongs to

    public var shaderVariableName : String;

    public var data : Data;
    public var dataActiveCount : Int;

    public function new(): Void;

    /// helper function, creates the underlying data with the appropriate size
    public function setup(shaderVariableName : String, uniformType : UniformType, shaderType : ShaderType, count : Int = 1) : Void;
}