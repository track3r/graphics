/*
 * Created by IntelliJ IDEA.
 * User: rcam
 * Date: 22/05/14
 * Time: 14:23
 */
package graphics;

import graphics.GraphicsTypes;
import graphics.MeshData;

import types.DataType;
import types.Data;
import gl.GL;

class MeshDataBuffer
{
    public var bufferMode : BufferMode;
    public var data : Data;

    public function new() : Void {}

    /// specific to ogl
    public var glBuffer : GLBuffer;
    public var sizeOfHardwareBuffer : Int;

    public var bufferAlreadyOnHardware : Bool;
}

class MeshDataAttributeConfig
{
    public var attributeNumber : Int = 0;
    /*public var stride : Int = 0;*/ // Moved to MeshData because its the same for all attributeConfigs and helps for Flash target
    public var vertexElementCount : Int = 0;
    public var vertexElementType : DataType;
    public var offsetInData : Int = 0;
    public var offsetPerBakedFrame : Array<Int>;
    public var vertexElementsNormalized : Bool = false;

    public function new() : Void {}
}

class MeshData
{
    public var attributeBuffer : MeshDataBuffer;
    public var indexBuffer : MeshDataBuffer;
    public var attributeConfigs : Array<MeshDataAttributeConfig>;
    public var attributeStride : Int = 0;

    public var vertexCount : Int = 0;
    public var indexCount : Int = 0;
    public var bakedFrameCount : Int = 0;
    public var bakedFPS : Int = 0;

    public var primitiveType : PrimitiveType;
    public var indexDataType : DataType;
    public var indexCountPerBakedFrame : Array<Int>;
    public var indexOffsetPerBakedFrame : Array<Int>;

    public function new() : Void {}
}