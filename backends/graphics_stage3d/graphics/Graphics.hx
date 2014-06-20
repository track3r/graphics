package graphics;
import flash.display3D.Context3DBlendFactor;
import aglsl.assembler.AGALMiniAssembler;
import flash.display3D.Context3DTextureFormat;
import flash.display3D.textures.Texture;
import flash.display3D.Context3DTriangleFace;
import flash.Vector;
import flash.display.StageScaleMode;
import flash.display.StageAlign;
import flash.display3D.VertexBuffer3D;
import flash.errors.Error;
import flash.display3D.Context3DVertexBufferFormat;
import flash.display.Stage3D;
import flash.utils.ByteArray;
import flash.Lib;
import flash.display3D.VertexBuffer3D;
import flash.display3D.IndexBuffer3D;
import flash.display3D.Context3DProgramType;
import flash.errors.Error;
import flash.events.ErrorEvent;
import flash.events.Event;
import flash.display3D.Context3D;
import flash.display.Stage;
import haxe.ds.GenericStack;
import graphics.GraphicsTypes;
import graphics.GraphicsContext;
import graphics.MeshData;
import graphics.RenderTarget;
import graphics.Shader;
import types.Data;
import types.Color4B;

class Graphics
{
    private var assembler:AGALMiniAssembler;
    private var currentStage3DIndex:Int = 0;
    private var contextStack : GenericStack<GraphicsContext>;
    public function new(){}

    public static function initialize(callback:Void->Void) : Void{
        var stage:Stage = flash.Lib.current.stage;
        var stage3D : Stage3D = stage.stage3Ds[0];

        stage.align = StageAlign.TOP_LEFT;
        stage.scaleMode = StageScaleMode.NO_SCALE;
        stage.frameRate = 60;

        if(sharedInstance == null)
        {
            sharedInstance = new Graphics();
            sharedInstance.contextStack = new GenericStack<GraphicsContext>();
            sharedInstance.assembler = new AGALMiniAssembler();
        }

        stage3D.addEventListener( ErrorEvent.ERROR, function(event:ErrorEvent):Void{
            throw new Error(event.toString());
        });

        stage3D.addEventListener(Event.CONTEXT3D_CREATE, function (event:Event):Void{
            var contextWrapper:GraphicsContext = new GraphicsContext();
            contextWrapper.context3D = stage3D.context3D;
            contextWrapper.context3D.enableErrorChecking = true;
            contextWrapper.context3D.setCulling(Context3DTriangleFace.NONE);
            sharedInstance.pushContext(contextWrapper);

            contextWrapper.context3D.configureBackBuffer(stage.stageWidth, stage.stageHeight, 0, true, true);
            callback();
        });

        stage3D.requestContext3D("auto");
    }

    static var sharedInstance : Graphics;
    public static function instance() : Graphics
    {
        return sharedInstance;
    }

    public static var maxActiveTextures = 16;

    public function loadFilledShader(shader : Shader)
    {
        var vs = compileShader(Context3DProgramType.VERTEX, shader.vertexShaderCode);
        var fs = compileShader(Context3DProgramType.FRAGMENT, shader.fragmentShaderCode);
        var context3D:Context3D = getCurrentContext().context3D;

        shader.program = context3D.createProgram();

        try
        {
            shader.program.upload(vs, fs);
        }
        catch (err:Error)
        {
        // Lots of error can occur in uploading the program. Many of them
        // are simple error checking (e.g. null bytecode) but many more
        // can indicate invalid bytecode such as programs that have more
        // than 200 hardware instructions.
            trace("Couldn't upload shader program: " + err);
            return;
        }
    }

    public function bindShader(shader : Shader)
    {
        var context3D:Context3D = getCurrentContext().context3D;
        var currentIndex = 0;
        var constantType;
        var vector;

        for(uniformInterface in shader.uniformInterfaces)
        {
            constantType = uniformInterface.isVertexConstant ? Context3DProgramType.VERTEX : Context3DProgramType.FRAGMENT;
            context3D.setProgramConstantsFromByteArray(constantType, currentIndex, cast uniformInterface.data.byteArray.length/(4 * 4), uniformInterface.data.byteArray, 0);
            currentIndex++;
        }

        context3D.setProgram(shader.program);
    }

    private function compileShader(type : Context3DProgramType, code : String):ByteArray
    {
        return  assembler.assemble(type, code);
    }

    public function loadFilledMeshData(meshData : MeshData)
    {
        if(meshData == null)
            return;

        loadFilledVertexBuffer(cast meshData.attributeBuffer, meshData);
        loadFilledIndexBuffer(cast meshData.indexBuffer , meshData);
    }

    private function loadFilledVertexBuffer(meshDataBuffer : MeshDataBuffer, meshData:MeshData):Void
    {
        if(meshDataBuffer == null)
            return;

        var context:Context3D = getCurrentContext().context3D;
        meshData.vertexBufferInstance = context.createVertexBuffer(meshData.vertexCount, cast meshData.attributeStride / 4);

        if(meshDataBuffer.data != null)
        {
            try
            {
                meshData.vertexBufferInstance.uploadFromByteArray(meshDataBuffer.data.byteArray, 0, 0, meshData.vertexCount);
            }
            catch(er:Error)
            {
                trace(er);
            }
        }
    }

    private function loadFilledIndexBuffer(meshDataBuffer : MeshDataBuffer,  meshData:MeshData):Void
    {
        if(meshDataBuffer == null)
            return;

        var context3D:Context3D = getCurrentContext().context3D;
        meshData.indexBufferInstance = context3D.createIndexBuffer(meshData.indexCount);

        if(meshDataBuffer.data != null)
        {
            try
            {
                meshData.indexBufferInstance.uploadFromByteArray(meshDataBuffer.data.byteArray, 0, 0, meshData.indexCount);
            }
            catch(er:Error)
            {
                trace(er);
            }
        }
    }

    public function bindMeshData(data : MeshData, bakedFrame : Int):Void
    {
        var format;
        var context3D:Context3D = getCurrentContext().context3D;
        var headStep = 0;

        for(attributeConfig in data.attributeConfigs)
        {
            context3D.setVertexBufferAt(attributeConfig.attributeNumber, data.vertexBufferInstance, headStep, getFormat(attributeConfig));
            headStep += attributeConfig.vertexElementCount;
        }
    }

    inline private function getFormat(info:MeshDataAttributeConfig):Context3DVertexBufferFormat
    {
        if(info.format!=null)return info.format;

        var format:Context3DVertexBufferFormat = Context3DVertexBufferFormat.FLOAT_4;
        switch(info.vertexElementCount){
            case 1:
                format = Context3DVertexBufferFormat.FLOAT_1;
            case 2:
                format = Context3DVertexBufferFormat.FLOAT_2;
            case 3:
                format = Context3DVertexBufferFormat.FLOAT_3;
            case 4:
                if(info.vertexElementType == DataTypeFloat32)format = Context3DVertexBufferFormat.FLOAT_4;
                else format = Context3DVertexBufferFormat.BYTES_4;
        }
        info.format = format;

        return format;
    }

    public function render(meshData : MeshData, bakedFrame : Int):Void{

        var context3D:Context3D = getCurrentContext().context3D;

        if(meshData.indexBufferInstance != null)
        {
            try
            {
                context3D.drawTriangles(meshData.indexBufferInstance, 0, -1);
            }
            catch(error:Error)
            {
                trace(error);
            }
        }
    }

    public function loadFilledTextureData(texture : TextureData) : Void
    {
        //if(texture.alreadyLoaded)
          //  return;


        pushTextureData(texture);
        bindTexture(texture);

        //configureFilteringMode(texture);
        //configureMipmaps(texture);
        //configureWrap(texture);

    }

    public function bindTextureData(texture : TextureData, position : Int) : Void
    {
        if(texture == null)
            return;

        bindTexture(texture);
    }

    private function bindTexture(texture : TextureData) :Void
    {
        var context = getCurrentContext();
        var context3D:Context3D = context.context3D;

        if(context.currentActiveTextures[context.currentActiveTexture] != texture.texture)
        {
            context.currentActiveTextures[context.currentActiveTexture] = texture.texture;
            context3D.setTextureAt(texture.textureID, texture.texture);
        }
    }

    private function pushTextureData(texture : TextureData) : Void
    {
        if(texture.textureType == TextureType2D)
        {
            pushTextureDataForType(texture , texture.textureID, texture.pixelFormat, texture.data, texture.originalWidth, texture.originalHeight);
        }
        else
        {
            //cubtexture
        }
    }

    private function pushTextureDataForType(textureData:TextureData, textureType : Int, textureFormat : TextureFormat, data : Data, width : Int, height : Int) :Void
    {
        var context3D:Context3D = getCurrentContext().context3D;
        var texture:Texture;

        switch(textureFormat)
        {
            case(TextureFormatRGB565):
                texture = context3D.createTexture( width, height, Context3DTextureFormat.BGR_PACKED,  false );

            case(TextureFormatA8):
                texture = context3D.createTexture( width, height, Context3DTextureFormat.BGRA,        false );

            case(TextureFormatRGBA8888):
                texture = context3D.createTexture( width, height, Context3DTextureFormat.BGRA,        false );
        }

        textureData.texture = texture;
        texture.uploadFromByteArray(data.byteArray, 0, 0);
    }

    public function setBlendFunc(sourceFactor : BlendFactor, destinationFactor : BlendFactor) : Void
    {
        var context = getCurrentContext();
        var context3D:Context3D = context.context3D;

        if(context.currentBlendFactorSrc != sourceFactor || context.currentBlendFactorDest != destinationFactor)
        {
            context.currentBlendFactorSrc = sourceFactor;
            context.currentBlendFactorDest = destinationFactor;
            context3D.setBlendFactors( getBlendFactor(sourceFactor), getBlendFactor(destinationFactor) );
        }
    }

    inline private function getBlendFactor(factor:BlendFactor) :Context3DBlendFactor
    {
        var factorValue:Context3DBlendFactor;

        switch(factor)
        {
            case BlendFactorZero:
                 factorValue = Context3DBlendFactor.ZERO;

            case BlendFactorOne:
                 factorValue = Context3DBlendFactor.ONE;

            case BlendFactorSrcColor:
                 factorValue = Context3DBlendFactor.SOURCE_COLOR;

            case BlendFactorOneMinusSrcColor:
                 factorValue = Context3DBlendFactor.ONE_MINUS_SOURCE_COLOR;

            case BlendFactorSrcAlpha:
                 factorValue = Context3DBlendFactor.SOURCE_ALPHA;

            case BlendFactorOneMinusSrcAlpha:
                 factorValue = Context3DBlendFactor.ONE_MINUS_SOURCE_ALPHA;

            case BlendFactorDstAlpha:
                 factorValue = Context3DBlendFactor.DESTINATION_ALPHA;

            case BlendFactorOneMinusDstAlpha:
                 factorValue = Context3DBlendFactor.ONE_MINUS_DESTINATION_ALPHA;

            case BlendFactorDstColor:
                 factorValue = Context3DBlendFactor.DESTINATION_COLOR;

            case BlendFactorOneMinusDstColor:
                 factorValue = Context3DBlendFactor.ONE_MINUS_DESTINATION_COLOR;

            case BlendFactorSrcAlphaSaturate:
                 //TODO
                 factorValue = Context3DBlendFactor.ONE_MINUS_SOURCE_ALPHA;
        }

        return factorValue;
    }

    public function loadFilledContext(context : GraphicsContext) : Void
    {

    }

    public function isLoadedContext(context:GraphicsContext) : Void
    {

    }

    public function unloadFilledContext(context : GraphicsContext) : Void
    {

    }

    public function present():Void{
        getCurrentContext().context3D.present();
    }

    public function setClearColor(color : Color4B) : Void
    {
        var renderTarget:RenderTarget = getCurrentContext().currentRenderTargetStack.first();

        if( renderTarget.currentClearColor.r != color.r ||
            renderTarget.currentClearColor.g != color.g ||
            renderTarget.currentClearColor.b != color.b ||
            renderTarget.currentClearColor.a != color.a )
        {
            renderTarget.currentClearColor.data.writeData(color.data);
        }
    }

    public function clearColorBuffer() : Void
    {
        var context = getCurrentContext();
        var color:Color4B  = context.currentRenderTargetStack.first().currentClearColor;

        context.context3D.clear(color.r/255,
                                color.g/255,
                                color.b/255,
                                color.a/255);
    }

    public function getCurrentContext() : GraphicsContext
    {
        return contextStack.first();
    }

    public function pushContext(context : GraphicsContext) : Void
    {
        contextStack.add(context);
    }

    public function popContext(context : GraphicsContext) : Void
    {
        contextStack.pop();
    }
}

