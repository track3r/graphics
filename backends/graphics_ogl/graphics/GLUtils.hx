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

import graphics.GraphicsTypes;

import types.DataType;

import gl.GLDefines;

class GLUtils
{
	public static function convertBufferModeToOGL(bufferMode:BufferMode) : Int
	{
		switch (bufferMode)
        {
			case BufferModeStaticDraw:
				return GLDefines.STATIC_DRAW;

			case BufferModeDynamicDraw:
				return GLDefines.DYNAMIC_DRAW;

            case BufferModeStreamDraw:
                return GLDefines.STREAM_DRAW;

			default:
				return 0;
		}
	}

	public static function convertDataTypeToOGL(type : DataType) : Int
	{
		switch(type)
		{
			case DataTypeInt8:
				return GLDefines.BYTE;

			case DataTypeUInt8:
				return GLDefines.UNSIGNED_BYTE;

			case DataTypeUInt32:
				return GLDefines.UNSIGNED_INT;

			case DataTypeInt32:
				return GLDefines.INT;

			case DataTypeFloat32:
				return GLDefines.FLOAT;

			case DataTypeInt16:
				return GLDefines.SHORT;

			case DataTypeUInt16:
				return GLDefines.UNSIGNED_SHORT;

			default:
				return 0;


		}
	}

	public static function convertPrimitiveTypeToOGL(primitiveType : PrimitiveType) : Int
	{
		switch (primitiveType)
        {
			case PrimitiveTypeTriangleFan:
				return GLDefines.TRIANGLE_FAN;

			case PrimitiveTypeTriangleStrip:
				return GLDefines.TRIANGLE_STRIP;

			case PrimitiveTypeTriangles:
				return GLDefines.TRIANGLES;

			case PrimitiveTypeLines:
				return GLDefines.LINES;

			case PrimitiveTypeLineLoop:
				return GLDefines.LINE_LOOP;

			case PrimitiveTypeLineStrip:
				return GLDefines.LINE_STRIP;

			case PrimitiveTypePoints:
				return GLDefines.POINTS;

			default:
				return 0;
		}
	}

	public static function convertTextureTypeToOGL(textureType : TextureType) : Int
	{
		switch (textureType)
        {
			case TextureType2D:
				return GLDefines.TEXTURE_2D;

			case TextureTypeCubeMap:
				return GLDefines.TEXTURE_CUBE_MAP;

			default:
				return 0;
		}
	}

    public static function convertDepthFuncToOGL(depthFunc : DepthFunc) : Int
    {
        switch (depthFunc)
        {
            case DepthFunc.DepthFuncLess:
                return GLDefines.LESS;

            case DepthFunc.DepthFuncAlways:
                return GLDefines.ALWAYS;

            case DepthFunc.DepthFuncEqual:
                return GLDefines.EQUAL;

            case DepthFunc.DepthFuncGEqual:
                return GLDefines.GEQUAL;

            case DepthFunc.DepthFuncGreater:
                return GLDefines.GREATER;

            case DepthFunc.DepthFuncLEqual:
                return GLDefines.LEQUAL;

            case DepthFunc.DepthFuncNever:
                return GLDefines.NEVER;

            case DepthFunc.DepthFuncNotEqual:
                return GLDefines.NOTEQUAL;

            default: return GLDefines.ALWAYS;
        }
    }

    public static function convertStencilOpToOGL(stencilOp : StencilOp) : Int
    {
        switch (stencilOp)
        {
            case StencilOpDecr:
                return GLDefines.DECR;

            case StencilOpDecrWrap:
                return GLDefines.DECR_WRAP;

            case StencilOpIncr:
                return GLDefines.INCR;

            case StencilOpIncrWrap:
                return GLDefines.INCR_WRAP;

            case StencilOpInvert:
                return GLDefines.INVERT;

            case StencilOpKeep:
                return GLDefines.KEEP;

            case StencilOpReplace:
                return GLDefines.REPLACE;

            case StencilOpZero:
                return GLDefines.ZERO;

            default:
                return GLDefines.KEEP;
        }
    }

    public static function convertStencilFuncToOGL(stencilFunc : StencilFunc) : Int
    {
        switch (stencilFunc)
        {
            case StencilFuncNever:
                return GLDefines.NEVER;

            case StencilFuncLess:
                return GLDefines.LESS;

            case StencilFuncLEqual:
                return GLDefines.LEQUAL;

            case StencilFuncGreater:
                return GLDefines.GREATER;

            case StencilFuncGEqual:
                return GLDefines.GEQUAL;

            case StencilFuncEqual:
                return GLDefines.EQUAL;

            case StencilFuncNotEqual:
                return GLDefines.NOTEQUAL;

            case StencilFuncAlways:
                return GLDefines.ALWAYS;

            default:
                return GLDefines.ALWAYS;
        }
    }

    public static function convertBlendFactorToOGL(blendFactor : BlendFactor) : Int
    {
        switch (blendFactor)
        {
            case BlendFactorZero:
                return GLDefines.ZERO;

            case BlendFactorOne:
                return GLDefines.ONE;

            case BlendFactorSrcColor:
                return GLDefines.SRC_COLOR;

            case BlendFactorOneMinusSrcColor:
                return GLDefines.ONE_MINUS_SRC_COLOR;

            case BlendFactorSrcAlpha:
                return GLDefines.SRC_ALPHA;

            case BlendFactorOneMinusSrcAlpha:
                return GLDefines.ONE_MINUS_SRC_ALPHA;

            case BlendFactorDstAlpha:
                return GLDefines.DST_ALPHA;

            case BlendFactorOneMinusDstAlpha:
                return GLDefines.ONE_MINUS_DST_ALPHA;

            case BlendFactorDstColor:
                return GLDefines.DST_COLOR;

            case BlendFactorOneMinusDstColor:
                return GLDefines.ONE_MINUS_DST_COLOR;

            case BlendFactorSrcAlphaSaturate:
                return GLDefines.SRC_ALPHA_SATURATE;

            default:
                return GLDefines.ONE;
        }
    }

    public static function convertBlendModeToOGL(blendMode : BlendMode) : Int
    {
        switch (blendMode)
        {
            case BlendModeAdd:
                return GLDefines.FUNC_ADD;

            case BlendModeSubtract:
                return GLDefines.FUNC_SUBTRACT;

            case BlendModeReverseSubtract:
                return GLDefines.FUNC_REVERSE_SUBTRACT;

            default:
                return GLDefines.FUNC_ADD;
        }
    }

    public static function convertFaceCullingModeToOGL(cullMode : FaceCullingMode) : Int
    {
        switch(cullMode)
        {
            case FaceCullingModeBack:
                return GLDefines.BACK;

            case FaceCullingModeFront:
                return GLDefines.FRONT;

            case FaceCullingModeFrontBack:
                return GLDefines.FRONT_AND_BACK;

            default:
                return GLDefines.BACK;
        }
    }

    inline public static function isPowerOfTwo(x: Int): Bool
    {
        return x > 0 && (x & (x - 1)) == 0;
    }
}