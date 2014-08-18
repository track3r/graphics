/*
 * Created by IntelliJ IDEA.
 * User: sott
 * Date: 30/07/14
 * Time: 15:11
 */
package graphics;

import flash.display3D.Context3DStencilAction;
import flash.display3D.Context3DCompareMode;
import graphics.GraphicsTypes;

import flash.display3D.Context3DTriangleFace;
import flash.display3D.Context3DBlendFactor;

class Stage3dUtils
{
    public static function convertBlendFactorToStage3d(blendFactor : BlendFactor) : Context3DBlendFactor
    {
        switch (blendFactor)
        {
            case BlendFactorZero:
                return Context3DBlendFactor.ZERO;

            case BlendFactorOne:
                return Context3DBlendFactor.ONE;

            case BlendFactorSrcColor:
                return Context3DBlendFactor.SOURCE_COLOR;

            case BlendFactorOneMinusSrcColor:
                return Context3DBlendFactor.ONE_MINUS_SOURCE_COLOR;

            case BlendFactorSrcAlpha:
                return Context3DBlendFactor.SOURCE_ALPHA;

            case BlendFactorOneMinusSrcAlpha:
                return Context3DBlendFactor.ONE_MINUS_SOURCE_ALPHA;

            case BlendFactorDstAlpha:
                return Context3DBlendFactor.DESTINATION_ALPHA;

            case BlendFactorOneMinusDstAlpha:
                return Context3DBlendFactor.ONE_MINUS_DESTINATION_ALPHA;

            case BlendFactorDstColor:
                return Context3DBlendFactor.DESTINATION_COLOR;

            case BlendFactorOneMinusDstColor:
                return Context3DBlendFactor.ONE_MINUS_DESTINATION_COLOR;

            case BlendFactorSrcAlphaSaturate:
                trace("Error BlendFactorSrcAlphaSaturate is not supported on Flash platform");
                return Context3DBlendFactor.ONE;

            default: return Context3DBlendFactor.ONE;
        }
    }

    public static function convertFaceCullingModeToStage3d(cullMode : FaceCullingMode) : Context3DTriangleFace
    {
        switch (cullMode)
        {
            case FaceCullingModeOff:
                return Context3DTriangleFace.NONE;
            case FaceCullingModeBack:
                return Context3DTriangleFace.BACK;
            case FaceCullingModeFront:
                return Context3DTriangleFace.FRONT;
            case FaceCullingModeFrontBack:
                return Context3DTriangleFace.FRONT_AND_BACK;
            default:
                return Context3DTriangleFace.NONE;
        }
    }

    public static function convertDepthFuncToStage3D(depthFunc : DepthFunc) : Context3DCompareMode
    {
        switch (depthFunc)
        {
            case DepthFunc.DepthFuncLess:
                return Context3DCompareMode.LESS;

            case DepthFunc.DepthFuncAlways:
                return Context3DCompareMode.ALWAYS;

            case DepthFunc.DepthFuncEqual:
                return Context3DCompareMode.EQUAL;

            case DepthFunc.DepthFuncGEqual:
                return Context3DCompareMode.GREATER_EQUAL;

            case DepthFunc.DepthFuncGreater:
                return Context3DCompareMode.GREATER;

            case DepthFunc.DepthFuncLEqual:
                return Context3DCompareMode.LESS_EQUAL;

            case DepthFunc.DepthFuncNever:
                return Context3DCompareMode.NEVER;

            case DepthFunc.DepthFuncNotEqual:
                return Context3DCompareMode.NOT_EQUAL;

            default: return Context3DCompareMode.ALWAYS;
        }
    }

    public static function convertStencilOpToStage3d(stencilOp : StencilOp) : Context3DStencilAction
    {
        switch (stencilOp)
        {
            case StencilOpDecr:
                return Context3DStencilAction.DECREMENT_SATURATE;

            case StencilOpDecrWrap:
                return Context3DStencilAction.DECREMENT_WRAP;

            case StencilOpIncr:
                return Context3DStencilAction.INCREMENT_SATURATE;

            case StencilOpIncrWrap:
                return Context3DStencilAction.INCREMENT_WRAP;

            case StencilOpInvert:
                return Context3DStencilAction.INVERT;

            case StencilOpKeep:
                return Context3DStencilAction.KEEP;

            case StencilOpReplace:
                return Context3DStencilAction.SET;

            case StencilOpZero:
                return Context3DStencilAction.ZERO;

            default:
                return Context3DStencilAction.KEEP;
        }
    }

    public static function convertStencilFuncToStage3d(stencilFunc : StencilFunc) : Context3DCompareMode
    {
        switch (stencilFunc)
        {
            case StencilFuncNever:
                return Context3DCompareMode.NEVER;

            case StencilFuncLess:
                return Context3DCompareMode.LESS;

            case StencilFuncLEqual:
                return Context3DCompareMode.LESS_EQUAL;

            case StencilFuncGreater:
                return Context3DCompareMode.GREATER;

            case StencilFuncGEqual:
                return Context3DCompareMode.GREATER_EQUAL;

            case StencilFuncEqual:
                return Context3DCompareMode.EQUAL;

            case StencilFuncNotEqual:
                return Context3DCompareMode.NOT_EQUAL;

            case StencilFuncAlways:
                return Context3DCompareMode.ALWAYS;

            default:
                return Context3DCompareMode.ALWAYS;
        }
    }

}