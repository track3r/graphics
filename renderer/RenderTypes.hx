package renderer;

enum PrimitiveType
{
	PrimitiveTypeTriangles;
	PrimitiveTypeTriangleStrip;
	PrimitiveTypeTriangleFan;
	PrimitiveTypeLines;
	PrimitiveTypeLineLoop;
	PrimitiveTypeLineStrip;
	PrimitiveTypePoints;
}


enum BufferMode
{
	BufferModeStaticDraw;
	BufferModeDynamicDraw;
}

enum UniformType
{
	UniformTypeSingleInt;
	UniformTypeSingleIntArray;
	UniformTypeSingleFloat;
	UniformTypeSingleFloatArray;
	UniformTypeVector2Int;
	UniformTypeVector2IntArray;
	UniformTypeVector2Float;
	UniformTypeVector2FloatArray;
	UniformTypeVector3Int;
	UniformTypeVector3IntArray;
	UniformTypeVector3Float;
	UniformTypeVector3FloatArray;
	UniformTypeVector4Int;
	UniformTypeVector4IntArray;
	UniformTypeVector4Float;
	UniformTypeVector4FloatArray;
	UniformTypeMatrix2;
	UniformTypeMatrix2Transposed;
	UniformTypeMatrix3;
	UniformTypeMatrix3Transposed;
	UniformTypeMatrix4;
	UniformTypeMatrix4Transposed;
}

class RenderTypesUtils
{
	static public function uniformTypeElementSize(uniform : UniformType)
	{
		switch (uniform)
		{
			case UniformTypeSingleInt:
				return 4;
			case UniformTypeSingleIntArray:
				return 4;
			case UniformTypeSingleFloat:
				return 4;
			case UniformTypeSingleFloatArray:
				return 4;
			case UniformTypeVector2Int:
				return 2*4;
			case UniformTypeVector2IntArray:
				return 2*4;
			case UniformTypeVector2Float:
				return 2*4;
			case UniformTypeVector2FloatArray:
				return 2*4;
			case UniformTypeVector3Int:
				return 3*4;
			case UniformTypeVector3IntArray:
				return 3*4;
			case UniformTypeVector3Float:
				return 3*4;
			case UniformTypeVector3FloatArray:
				return 3*4;
			case UniformTypeVector4Int:
				return 4*4;
			case UniformTypeVector4IntArray:
				return 4*4;
			case UniformTypeVector4Float:
				return 4*4;
			case UniformTypeVector4FloatArray:
				return 4*4;
			case UniformTypeMatrix2:
				return 4*4;
			case UniformTypeMatrix2Transposed:
				return 4*4;
			case UniformTypeMatrix3:
				return 9*4;
			case UniformTypeMatrix3Transposed:
				return 9*4;
			case UniformTypeMatrix4:
				return 16*4;
			case UniformTypeMatrix4Transposed:
				return 16*4;
		}

		return 0;
	}


}
