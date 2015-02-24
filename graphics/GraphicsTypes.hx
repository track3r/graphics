package graphics;

enum PrimitiveType
{
	PrimitiveTypeTriangles;      // Stage3d just supports triangles with indexed draw elements
	PrimitiveTypeTriangleStrip;
	PrimitiveTypeTriangleFan;
	PrimitiveTypeLines;
	PrimitiveTypeLineLoop;
	PrimitiveTypeLineStrip;
	PrimitiveTypePoints;
}

enum ShaderType
{
    ShaderTypeVertex;
    ShaderTypeFragment;
/*  ShaderTypeGeometry; */ // Maybe later
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

enum DepthFunc
{
    DepthFuncNever;
    DepthFuncLess;
    DepthFuncEqual;
    DepthFuncLEqual;
    DepthFuncGreater;
    DepthFuncGEqual;
    DepthFuncNotEqual;
    DepthFuncAlways;
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

    static public function blendFactorFromDefine(define: Int): BlendFactor
    {
        switch (define)
        {
            case 0:   return BlendFactor.BlendFactorZero;                   // 0
            case 1:   return BlendFactor.BlendFactorOne;                    // 1
            case 768: return BlendFactor.BlendFactorSrcColor;               // 0x0300
            case 769: return BlendFactor.BlendFactorOneMinusSrcColor;       // 0x0301
            case 770: return BlendFactor.BlendFactorSrcAlpha;               // 0x0302
            case 771: return BlendFactor.BlendFactorOneMinusSrcAlpha;       // 0x0303
            case 772: return BlendFactor.BlendFactorDstAlpha;               // 0x0304
            case 773: return BlendFactor.BlendFactorOneMinusDstAlpha;       // 0x0305
            case 774: return BlendFactor.BlendFactorDstColor;               // 0x0306
            case 775: return BlendFactor.BlendFactorOneMinusDstColor;       // 0x0307
            case 776: return BlendFactor.BlendFactorSrcAlphaSaturate;       // 0x0308
            default:  return BlendFactor.BlendFactorZero;
        }
    }

    static public function defineFromBlendFactor(blendFactor): Int
    {
        switch (blendFactor)
        {
            case BlendFactor.BlendFactorZero:             return 0;         // 0
            case BlendFactor.BlendFactorOne:              return 1;         // 1
            case BlendFactor.BlendFactorSrcColor:         return 768;       // 0x0300
            case BlendFactor.BlendFactorOneMinusSrcColor: return 769;       // 0x0301
            case BlendFactor.BlendFactorSrcAlpha:         return 770;       // 0x0302
            case BlendFactor.BlendFactorOneMinusSrcAlpha: return 771;       // 0x0303
            case BlendFactor.BlendFactorDstAlpha:         return 772;       // 0x0304
            case BlendFactor.BlendFactorOneMinusDstAlpha: return 773;       // 0x0305
            case BlendFactor.BlendFactorDstColor:         return 774;       // 0x0306
            case BlendFactor.BlendFactorOneMinusDstColor: return 775;       // 0x0307
            case BlendFactor.BlendFactorSrcAlphaSaturate: return 776;       // 0x0308
            default: return 0;
        }
    }

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
