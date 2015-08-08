package graphics;

import types.Color4F;
import msignal.Signal.Signal2;
import graphics.Graphics;
import graphics.GraphicsContext;
import graphics.GraphicsTypes;
import graphics.MeshData;
import graphics.Shader;
import graphics.TextureData;

import types.DataType;
import types.Data;


extern class Graphics
{
    public var onRender(default, null) : Signal0;
    public var onMainContextSizeChanged : Signal0;

    // Context was lost, so you need to recreate all you graphic objects and invalidate all state caches
    public var onMainContextRecreated : Signal0;
    public var mainContextWidth(default, null) : Int;
    public var mainContextHeight(default, null) : Int;

	private function new() : Void;

    public function setDefaultGraphicsState() : Void;

	public static function instance() : Graphics;
	public static function initialize(onInitializd:Void->Void) : Void;

    ///######## STATE HANDLING ########
    public function enableGraphicsAPI(enable: Bool): Void;
    public function invalidateCaches(): Void;

    ///######## CONTEXT ########
    public function getMainContext() : GraphicsContext;

    public function loadFilledContext(context : GraphicsContext) : Void;
    public function isLoadedContext(context : GraphicsContext) : Void;
    public function unloadFilledContext(context : GraphicsContext) : Void;

    public function getCurrentContext() : GraphicsContext;
    public function pushContext(context : GraphicsContext) : Void;
    public function popContext() : GraphicsContext;

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
    public function isDepthWriting() : Null<Bool>;
    public function setDepthFunc(depthFunc : DepthFunc) : Void;
    public function getDepthFunc() : Null<DepthFunc>;

    ///######## FACE CULLING ########
    public function setFaceCullingMode(cullingMode : FaceCullingMode) : Void;
    public function getFaceCullingMode() : Null<FaceCullingMode>;

    ///######## COLOR MASK ########
    public function setColorMask(writeRed : Bool, writeGreen : Bool, writeBlue : Bool, writeAlpha : Bool) : Void;

    ///######## RENDER TARGET ########
    public function pushRenderTarget(renderTarget : RenderTarget) : Void;
    public function popRenderTarget() : Null<RenderTarget>;

    ///######## ENABLE SCISSOR TESTING ########
    public function enableScissorTesting(enabled : Bool) : Void;
    public function setScissorTestRect(x : Int, y : Int, width : Int, height : Int) : Void;

    ///######## RENDER ########
	public function bindShader(shader : Shader) : Void;
	public function bindMeshData(meshData : MeshData, bakedFrame : Int) : Void;
    public function unbindMeshData(meshData : MeshData) : Void;
	public function bindTextureData(texture : TextureData, position : Int) : Void;
	public function render(meshData : MeshData, bakedFrame : Int) : Void;
    public function present() : Void;

    ///######## RENDER TARGET ########
    public function setClearColor(color: Color4F): Void;
	public function clearColorBuffer() : Void;
    public function clearDepthBuffer() : Void;
    public function clearStencilBuffer() : Void;
    public function clearAllBuffers() : Void;
    public function clearColorStencilBuffer(): Void;
    public function clearStencilDepthBuffer(): Void;

    ///######## GRAPHICS STATE ########
    public function finishCommandPipeline() : Void;
    public function flushCommandPipeline() : Void;

    ///######## STENCIL ########
    public function enableStencilTest(enabled : Bool) : Void;
    public function isStencilTestEnabled() : Null<Bool>;

    public function setStencilFunc(stencilFunc : StencilFunc, referenceValue : Int, readMask : Int) : Void;
    public function setStencilOp(stencilFail : StencilOp, depthFail : StencilOp, stencilAndDepthPass : StencilOp) : Void;
    public function setStencilMask(writeMask : Int) : Void;

    ///######## VIEWPORT ########
    public function setViewPort(x: Int, y: Int, width: Int, height: Int);

	public static var maxActiveTextures : Int;
}


