/*
 * Created by IntelliJ IDEA.
 * User: rcam
 * Date: 21/05/14
 * Time: 19:25
 */
package renderer;

import renderer.Interfaces;

import types.Data;
import types.DataType;

extern class MeshDataBuffer
{
    public var bufferMode : BufferMode;
    public var data : Data;
}

extern class MeshDataAttributeConfig
{
    public var attributeNumber : Int = 0;
    public var stride : Int = 0;
    public var vertexElementCount : Int = 0;
    public var vertexElementType : DataType;
    public var offsetInData : Int = 0;
    public var offsetPerBakedFrame : Array<Int>;
    public var vertexElementsNormalized : Bool = false;
}

extern class MeshData
{
    public var attributeBuffer : MeshDataBuffer;
    public var indexBuffer : MeshDataBuffer;
    public var attributeConfigs : Array<MeshDataAttributeConfig>;

    public var vertexCount : Int = 0;
    public var indexCount : Int = 0;
    public var bakedFrameCount : Int = 0;
    public var bakedFPS : Int = 0;

    public var primitiveType : PrimitiveType;
    public var indexDataType : DataType;
    public var indexCountPerBakedFrame : Array<Int>;
    public var indexOffsetPerBakedFrame : Array<Int>;
}