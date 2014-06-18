/*
 * Created by IntelliJ IDEA.
 * User: rcam
 * Date: 21/05/14
 * Time: 19:25
 */
package graphics;

import types.Data;
import types.DataType;
import graphics.GraphicsTypes;

extern class MeshDataBuffer
{
    public var bufferMode : BufferMode;
    public var data : Data;
}

extern class MeshDataAttributeConfig
{
    public var attributeNumber : Int;
    public var stride : Int;
    public var vertexElementCount : Int;
    public var vertexElementType : DataType;
    public var offsetInData : Int;
    public var offsetPerBakedFrame : Array<Int>;
    public var vertexElementsNormalized : Bool;
}

extern class MeshData
{
    public var attributeBuffer : MeshDataBuffer;
    public var indexBuffer : MeshDataBuffer;
    public var attributeConfigs : Array<MeshDataAttributeConfig>;

    public var vertexCount : Int;
    public var indexCount : Int;
    public var bakedFrameCount : Int;
    public var bakedFPS : Int;

    public var primitiveType : PrimitiveType;
    public var indexDataType : DataType;
    public var indexCountPerBakedFrame : Array<Int>;
    public var indexOffsetPerBakedFrame : Array<Int>;
}