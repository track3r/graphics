package ;

import renderer.RendererContext
import renderer.RenderTypes;
import renderer.MeshData;
import renderer.Shader;
import renderer.TextureData;

import types.DataType;
import types.Data;


extern class Renderer
{
	private function new() : Void;
	public static function instance() : Renderer;

    ///######## CONTEXT ########
    public function loadFilledContext(context : RendererContext) : Void;
    public function isLoadedContext(context:RendererContext) : Void;
    public function unloadFilledContext(context : RendererContext) : Void;

    public function getCurrentContext() : RendererContext;
    public function pushContext(context : RendererContext) : Void;
    public function popContext(context : RendererContext) : Void;

    ///######## LOAD ########
	public function loadFilledMeshData(meshData : MeshData) : Void;
    public function loadFilledMeshDataBuffer(meshDataBuffer : MeshDataBuffer) : Void; ///called by unloadMeshDataBuffer
	public function loadFilledShader(shader : Shader) : Void;
	public function loadFilledTextureData(textureData : TextureData) : Void;
    public function loadFilledRenderTarget(renderTarget : RenderTarget) : Void;

    public function isLoadedMeshData(meshData : MeshData) : Bool;
    public function isLoadedMeshDataBuffer(meshDataBuffer : MeshDataBuffer) : Bool; ///called by isLoadedMeshData
    public function isLoadedShader(shader : Shader) : Bool;
    public function isLoadedTextureData(textureData : TextureData) : Bool;
    public function isLoadedRenderTarget(renderTarget : RenderTarget) : Bool;

    public function unloadMeshData(meshData : MeshData) : Void;
    public function unloadMeshDataBuffer(meshDataBuffer : MeshDataBuffer) : Void; ///called by unloadMeshData
    public function unloadShader(shader : Shader) : Void;
    public function unloadTextureData(textureData : TextureData) : Void;
    public function unloadRenderTarget(renderTarget : RenderTarget) : Void;

    ///######## BLENDING ########
    public function setBlendFunc(sourceFactor : BlendFactor, destinationFactor : BlendFactor) : Void;
    public function setBlendFuncSeparate(sourceFactorRGB : BlendFactor,
                                         destinationFactorRGB : BlendFactor,
                                         sourceFactorA : BlendFactor,
                                         destinationFactorA : BlendFactor) : Void;

    public function setBlendMode(blendMode : BlendMode) : Void;
    public function setBlendModeSeparate(blendModeRGB : BlendMode, blendModeA : BlendMode) : Void;

    ///######## DEPTH TESTING ########
    public function enableDepthTesting(enabled : Bool) : Void;
    public function enableDepthWrite(enabled : Bool) : Void;
    public function isDepthTesting() : Bool;
    public function isDepthWriting() : Bool;

    ///######## FACE CULLING ########
    public function setFaceCullingMode(cullingMode : FaceCullingMode) : Void;
    public function getFaceCullingMode() : FaceCullingMode;

    ///######## LINE ########
    public function setLineWidth(lineWidth : Float) : Void;

    ///######## COLOR MASK ########
    public function setColorMask(writeRed : Bool, writeGreen : Bool, writeRed : Bool, writeAlpha : Bool) : Void;

    ///######## RENDER TARGET ########
    public function pushRenderTarget(renderTarget : RenderTarget) : Void;
    public function popRenderTarget() : Void;

    ///######## ENABLE SCISSOR TESTING ########
    public function enableScissorTesting(enabled : Bool) : Void;
    public function setScissorTestRect(x : Int, y : Int, width : Int, height : Int) : Void;

    ///######## RENDER ########
	public function bindShader(shader : Shader) : Void;
	public function bindMeshData(meshData : MeshData, bakedFrame : Int) : Void;
	public function bindTextureData(texture : TextureData, position : Int) : Void;
	public function render(meshData : MeshData, bakedFrame : Int) : Void;

    ///######## RENDER TARGET ########
	public function setClearColor(color : Color4B) : Void;
	public function clearColorBuffer() : Void;
    public function clearDepthBuffer() : Void;
    public function clearStencilBuffer() : Void;
    public function clearAllBuffers() : Void;

    ///######## GRAPHICS STATE ########
    public function finishCommandPipeline() : Void;
    public function flushCommandPipeline() : Void;

    ///######## STENCIL ########
    public function enableStencilTest(enabled : Bool) : Void;
    public function isStencilTestEnabled() : Bool;
    public function setStencilOp(stencilFail : StencilOp, depthFail : StencilOp, stencilAndDepthPass : StencilOp) : Void;
    public function setStencilFunc(stencilFunc : StencilFunc, referenceValue : Int, mask : Int) : Void;

	public static var maxActiveTextures : Int;
}


