
enum PrimitiveType
{
	Triangles;
	TriangleStrip;
	TriangleFan;
	Lines;
	LineLoop;
	LineStrip;
	Points;
}

enum DataType
{
	Byte;
	UnsignedByte;
	Short;
	UnsignedShort;
	Int;
	UnsignedInt;
	Float;
}

enum BufferMode
{
	StaticDraw;
	DynamicDraw;
}

enum UniformType
{
	SingleInt;
	SingleIntArray;
	SingleFloat;
	SingleFloatArray;
	Vector2Int;
	Vector2IntArray;
	Vector2Float;
	Vector2FloatArray;
	Vector3Int;
	Vector3IntArray;
	Vector3Float;
	Vector3FloatArray;
	Vector4Int;
	Vector4IntArray;
	Vector4Float;
	Vector4FloatArray;
	Matrix2;
	Matrix2Transposed;
	Matrix3;
	Matrix3Transposed;
	Matrix4;
	Matrix4Transposed;
}

class RenderTypesUtils
{
	static public function uniformTypeElementSize(uniform : UniformType)
	{
		switch (uniform)
		{
			case SingleInt:
			case SingleIntArray:
				return 4;
			case SingleFloat:
			case SingleFloatArray:
				return 4;
			case Vector2Int:
			case Vector2IntArray:
				return 2*4;
			case Vector2Float:
			case Vector2FloatArray:
				return 2*4;
			case Vector3Int:
			case Vector3IntArray:
				return 3*4;
			case Vector3Float:
			case Vector3FloatArray:
				return 3*4;
			case Vector4Int:
			case Vector4IntArray:
				return 4*4;
			case Vector4Float:
			case Vector4FloatArray:
			case Matrix2:
			case Matrix2Transposed:
				return 4*4;
			case Matrix3:
			case Matrix3Transposed:
				return 9*4;
			case Matrix4:
			case Matrix4Transposed:
				return 16*4;
		}

		return 0;
	}

	static public function dataTypeByteSize(dataType : DataType) : Int
	{
		switch(dataType)
		{
			case Byte:
			case UnsignedByte:
				return 1;
			case Short:
			case UnsignedShort:
				return 2;
			case Int:
			case Float:
			case UnsignedInt:
				return 4;
		}
		return 0;
	}

}
