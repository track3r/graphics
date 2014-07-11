package graphics;

enum PrimitiveType
{
	PrimitiveTypeTriangles;      // Stage3d just supports triangles with indexed draw elements
/*	PrimitiveTypeTriangleStrip;
	PrimitiveTypeTriangleFan;
	PrimitiveTypeLines;
	PrimitiveTypeLineLoop;
	PrimitiveTypeLineStrip;
	PrimitiveTypePoints;     */
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

enum TextureType
{
	TextureType2D;
	TextureTypeCubeMap;
}

enum TextureFilteringMode
{
	TextureFilteringModeLinear;
	TextureFilteringModeNearest;
}

enum TextureFormat
{
	TextureFormatRGBA8888;
	TextureFormatRGB565;
	TextureFormatA8;
}

enum TextureWrap
{
	TextureWrapRepeat;
	TextureWrapClamp;
}

enum ColorFormat
{
    ColorFormatRGBA8888;
    ColorFormatRGB565;
    ColorFormatSRGBA8888;
}

enum DepthFormat
{
    DepthFormat16;
    DepthFormat24;
}

enum StencilFormat
{
    StencilFormat8;
}

enum StencilOp
{
    StencilOpKeep;
    StencilOpZero;
    StencilOpReplace;
    StencilOpIncr;
    StencilOpIncrWrap;
    StencilOpDecr;
    StencilOpDecrWrap;
    StencilOpInvert;
}

enum StencilFunc
{
    StencilFuncNever;
    StencilFuncLess;
    StencilFuncEqual;
    StencilFuncLEqual;
    StencilFuncGreater;
    StencilFuncGEqual;
    StencilFuncNotEqual;
    StencilFuncAlways;
}

enum BlendFactor
{
    BlendFactorZero;
    BlendFactorOne;
    BlendFactorSrcColor;
    BlendFactorOneMinusSrcColor;
    BlendFactorSrcAlpha;
    BlendFactorOneMinusSrcAlpha;
    BlendFactorDstAlpha;
    BlendFactorOneMinusDstAlpha;
    BlendFactorDstColor;
    BlendFactorOneMinusDstColor;
    BlendFactorSrcAlphaSaturate;
}

typedef BlendFunction =
{
    @:required var src : BlendFactor;
    @:required var dst : BlendFactor;
}

enum BlendMode
{
    BlendModeAdd;
    BlendModeSubtract;
    BlendModeReverseSubtract;
}

enum StencilMode
{
    StencilModeOff;
    StencilModeOnly;
    StencilModeCompose;
}

enum FaceCullingMode
{
    FaceCullingModeFront;
    FaceCullingModeBack;
    FaceCullingModeFrontBack;
    FaceCullingModeOff;
}

enum StencilWriteMode
{
    StencilWriteModeReadWrite;
    StencilWriteModeReadOnly;
    StencilWriteModeWriteOnly;
}

class GraphicsTypesUtils
{
    static public var blendFunctionDisable : BlendFunction = { src : BlendFactorOne, dst : BlendFactorZero };
    static public var blendFunctionAlpha : BlendFunction = { src : BlendFactorSrcAlpha, dst : BlendFactorOneMinusSrcAlpha };
    static public var blendFunctionAlphaPremultiplied : BlendFunction = { src : BlendFactorOne, dst : BlendFactorOneMinusSrcAlpha };
    static public var blendFunctionAdditive : BlendFunction = { src : BlendFactorSrcAlpha, dst : BlendFactorOne };
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
