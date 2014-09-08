package graphics;

import msignal.Signal.Signal2;
import graphics.Graphics;
import graphics.GraphicsContext;
import graphics.GraphicsTypes;
import graphics.MeshData;
import graphics.Shader;
import graphics.TextureData;

import types.DataType;
import types.Data;
import types.Color4B;
import types.Touch;


extern class Graphics
{
    public var onRender(default, null) : Signal0;
    public var onTouches(default, null) : Signal1<Array<Touch>>;
    public var onMainContextSizeChanged : Signal0;
    public var mainContextWidth(default, null) : Int;
    public var mainContextHeight(default, null) : Int;

	private function new() : Void;

    public function setDefaultGraphicsState() : Void;

	public static function instance() : Graphics;
	public static function initialize(onInitializd:Void->Void) : Void;

    ///######## CONTEXT ########
    public function getMainContext() : GraphicsContext;

    public function loadFilledContext(context : GraphicsContext) : Void;
    public function isLoadedContext(context : GraphicsContext) : Void;
    public function unloadFilledContext(context : GraphicsContext) : Void;

    public function getCurrentContext() : GraphicsContext;
    public function pushContext(context : GraphicsContext) : Void;
    public function popContext(context : GraphicsContext) : Void;

    ///######## LOAD ########
	public function loadFilledMeshData(meshData : MeshData) : Void;
    public function loadFilledVertexBuffer(meshData : MeshData) : Void;///called by loadFilledMeshData
    public function loadFilledIndexBuffer(meshData : MeshData) : Void;///called by loadFilledMeshData
	public function loadFilledShader(shader : Shader) : Void;
	public function loadFilledTextureData(textureData : TextureData) : Void;
    public function loadFilledRenderTarget(renderTarget : RenderTarget) : Void;

    public function isLoadedMeshData(meshData : MeshData) : Bool;
    public function isLoadedMeshDataBuffer(meshDataBuffer : MeshDataBuffer) : Bool; ///called by isLoadedMeshData
    public function isLoadedShader(shader : Shader) : Bool;
    public function isLoadedTextureData(textureData : TextureData) : Bool;
    public function isLoadedRenderTarget(renderTarget : RenderTarget) : Bool;

    public function unloadMeshData(meshData : MeshData) : Void;
    public function unloadShader(shader : Shader) : Void;
    public function unloadTextureData(textureData : TextureData) : Void;
    public function unloadRenderTarget(renderTarget : RenderTarget) : Void;

    ///######## BLENDING ########
    public function setBlendFunc(sourceFactor : BlendFactor, destinationFactor : BlendFactor) : Void;

    ///######## DEPTH TESTING ########
    public function enableDepthWrite(enabled : Bool) : Void;
    public function isDepthWriting() : Bool;
    public function setDepthFunc(depthFunc : DepthFunc) : Void;
    public function getDepthFunc() : DepthFunc;

    ///######## FACE CULLING ########
    public function setFaceCullingMode(cullingMode : FaceCullingMode) : Void;
    public function getFaceCullingMode() : FaceCullingMode;

    ///######## COLOR MASK ########
    public function setColorMask(writeRed : Bool, writeGreen : Bool, writeBlue : Bool, writeAlpha : Bool) : Void;

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
    public function present() : Void;

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

    public function setStencilFunc(stencilFunc : StencilFunc, referenceValue : Int, readMask : Int) : Void;
    public function setStencilOp(stencilFail : StencilOp, depthFail : StencilOp, stencilAndDepthPass : StencilOp) : Void;
    public function setStencilMask(writeMask : Int) : Void;

	public static var maxActiveTextures : Int;
}


