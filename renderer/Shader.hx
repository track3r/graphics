/*
 * Created by IntelliJ IDEA.
 * User: rcam
 * Date: 22/05/14
 * Time: 11:07
 */
package renderer;

import types.Data;

extern class ShaderUniformInterface
{
    public var dataCount : Int = 0;
    public var uniformType : UniformType;

    public var shaderVariableName : String;

    public var data : Data;
    public var dataActiveCount : Int = 0;

    /// helper function, creates the underlying data with the appropriate size
    public function setup(shaderVariableName : String, uniformType : UniformType, count : Int = 1);
}

extern class Shader
{
    /// Since HXSL is unstable, we will ifdef the shader code on client side.
    public var vertexShaderCode : Dynamic;
    public var fragmentShaderCode : Dynamic;

    public var uniformInterfaces : Array<ShaderUniformInterface>;

    public var attributeNames : Array<String>;
}