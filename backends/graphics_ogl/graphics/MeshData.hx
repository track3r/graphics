/*
 * Copyright (c) 2003-2016, GameDuell GmbH
 * All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions are met:
 *
 * 1. Redistributions of source code must retain the above copyright notice,
 * this list of conditions and the following disclaimer.
 *
 * 2. Redistributions in binary form must reproduce the above copyright notice,
 * this list of conditions and the following disclaimer in the documentation
 * and/or other materials provided with the distribution.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
 * ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
 * WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED.
 * IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY
 * DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
 * (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
 * LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
 * ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
 * (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
 * SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */
 
package graphics;

import gl.GLExt;
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

    public var sizeOfHardwareBuffer : Int = 0;
    public var bufferAlreadyOnHardware : Bool = false;

    /// specific to ogl
    public var glBuffer : GLBuffer;
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

    /// specific to ogl
    public var vertexArrayObject: GLVertexArrayObject = GLExt.nullVertexArrayObject; // Only used if supported

    public function new() : Void {}
}
