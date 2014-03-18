
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
				return 4;
			case SingleIntArray:
				return 4;
			case SingleFloat:
				return 4;
			case SingleFloatArray:
				return 4;
			case Vector2Int:
				return 2*4;
			case Vector2IntArray:
				return 2*4;
			case Vector2Float:
				return 2*4;
			case Vector2FloatArray:
				return 2*4;
			case Vector3Int:
				return 3*4;
			case Vector3IntArray:
				return 3*4;
			case Vector3Float:
				return 3*4;
			case Vector3FloatArray:
				return 3*4;
			case Vector4Int:
				return 4*4;
			case Vector4IntArray:
				return 4*4;
			case Vector4Float:
				return 4*4;
			case Vector4FloatArray:
				return 4*4;
			case Matrix2:
				return 4*4;
			case Matrix2Transposed:
				return 4*4;
			case Matrix3:
				return 9*4;
			case Matrix3Transposed:
				return 9*4;
			case Matrix4:
				return 16*4;
			case Matrix4Transposed:
				return 16*4;
		}

		return 0;
	}


}
