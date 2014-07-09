package graphics;

import flash.display3D.Context3DVertexBufferFormat;
import flash.display3D.VertexBuffer3D;
import flash.display3D.IndexBuffer3D;
import types.Data;
import types.DataType;
import graphics.GraphicsTypes;

class MeshDataBuffer
{
    public function new(){}
    public var bufferMode : BufferMode;
    public var data : Data;

    public var sizeOfHardwareBuffer : Int;
    public var bufferAlreadyOnHardware : Bool;
}

class MeshDataAttributeConfig
{
    public function new(){}
    public var attributeNumber : Int;
    public var vertexElementCount : Int;
    public var vertexElementType : DataType;
    public var offsetInData : Int;
    public var offsetPerBakedFrame : Array<Int>;
    public var vertexElementsNormalized : Bool;
    //flash specific
    public var format:Context3DVertexBufferFormat;
}

class MeshData
{
    public function new(){}
    public var attributeBuffer : MeshDataBuffer;
    public var indexBuffer : MeshDataBuffer;
    public var attributeConfigs : Array<MeshDataAttributeConfig>;

    public var indexBufferInstance:IndexBuffer3D;
    public var vertexBufferInstance:VertexBuffer3D;

    public var attributeStride : Int;
    public var vertexCount : Int;
    public var indexCount : Int;
    public var bakedFrameCount : Int;
    public var bakedFPS : Int;

    public var primitiveType : PrimitiveType;
    public var indexDataType : DataType;
    public var indexCountPerBakedFrame : Array<Int>;
    public var indexOffsetPerBakedFrame : Array<Int>;

}