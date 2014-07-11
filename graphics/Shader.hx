/*
 * Created by IntelliJ IDEA.
 * User: rcam
 * Date: 22/05/14
 * Time: 11:07
 */
package graphics;

import types.Data;
import graphics.GraphicsTypes;

extern class Shader
{
    /// Since HXSL is unstable, we will ifdef the shader code on client side.
    public var vertexShaderCode : Dynamic;
    public var fragmentShaderCode : Dynamic;

    public var uniformInterfaces : Array<ShaderUniformInterface>;

    public var attributeNames : Array<String>;
}

extern class ShaderUniformInterface
{
    public var name : String;///purely for debugging purposes.

    public var dataCount : Int;
    public var uniformType : UniformType;

    public var shaderVariableName : String;

    public var data : Data;
    public var dataActiveCount : Int;

    /// helper function, creates the underlying data with the appropriate size
    public function setup(shaderVariableName : String, uniformType : UniformType, count : Int = 1) : Void;

    // Helpers differs on flash target. (Flash target transpose the matrices on write)
    public function writeMatrix44Data(matrixData : Data, count:Int = 1) : Void;
    public function writeMatrix33Data(matrixData : Data, count:Int = 1) : Void;
}