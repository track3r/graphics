package renderer;

import renderer.RenderTypes;

import types.DataType;

import gl.GLDefines;

class GLUtils
{
	public static function convertBufferModeFromUTKToOGL(bufferMode:BufferMode) : Int
	{
		switch (bufferMode) {
			case BufferModeStaticDraw:
				return GLDefines.STATIC_DRAW;
			case BufferModeDynamicDraw:
				return GLDefines.DYNAMIC_DRAW;

			default:
				return 0;
		}
	}

	public static function convertDataTypeFromUTKToOGL(type : DataType) : Int
	{
		switch(type)
		{
			case DataTypeByte:
				return GLDefines.BYTE;
			case DataTypeUnsignedByte:
				return GLDefines.UNSIGNED_BYTE;
			case DataTypeUnsignedInt:
				return GLDefines.UNSIGNED_INT;
			case DataTypeInt:
				return GLDefines.INT;
			case DataTypeFloat:
				return GLDefines.FLOAT;
			case DataTypeShort:
				return GLDefines.SHORT;
			case DataTypeUnsignedShort:
				return GLDefines.UNSIGNED_SHORT;
			default:
				return 0;


		}
	}

	public static function convertPrimitiveTypeFromUTKToOGL(primitiveType : PrimitiveType) : Int
	{
		switch (primitiveType) {
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

	public static function convertTextureTypeFromUTKToOGL(textureType : TextureType) : Int
	{
		switch (textureType) {
			case TextureType2D:
				return GLDefines.TEXTURE_2D;
			case TextureTypeCubeMap:
				return GLDefines.TEXTURE_CUBE_MAP;
			default:
				return 0;
		}
	}


}