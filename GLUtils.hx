
import RenderTypes;

import lime.gl.GL;

class GLUtils
{
	public static function convertBufferModeFromUTKToOGL(bufferMode:BufferMode) : Int
	{
		switch (bufferMode) {
			case StaticDraw:
				return GL.STATIC_DRAW;
			case DynamicDraw:
				return GL.DYNAMIC_DRAW;

			default:
				return 0;
		}
	}

	public static function convertDataTypeFromUTKToOGL(type : DataType) : Int
	{
		switch(type)
		{
			case Byte:
				return GL.BYTE;
			case UnsignedByte:
				return GL.UNSIGNED_BYTE;
			case UnsignedInt:
				return GL.UNSIGNED_INT;
			case Int:
				return GL.INT;
			case Float:
				return GL.FLOAT;
			case Short:
				return GL.SHORT;
			case UnsignedShort:
				return GL.UNSIGNED_SHORT;
			default:
				return 0;


		}
	}

	public static function convertPrimitiveTypeFromUTKToOGL(primitiveType : PrimitiveType) : Int
	{
		switch (primitiveType) {
			case TriangleFan:
				return GL.TRIANGLE_FAN;
			case TriangleStrip:
				return GL.TRIANGLE_STRIP;
			case Triangles:
				return GL.TRIANGLES;
			case Lines:
				return GL.LINES;
			case LineLoop:
				return GL.LINE_LOOP;
			case LineStrip:
				return GL.LINE_STRIP;
			case Points:
				return GL.POINTS;
			default:
				return 0;
		}
	}

}