package graphics;
import flash.utils.Dictionary;
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
import aglsl.assembler.AGALMiniAssembler;
import flash.display3D.VertexBuffer3D;
import flash.display3D.IndexBuffer3D;
import flash.display3D.Context3DProgramType;
import flash.errors.Error;
import flash.events.ErrorEvent;
import flash.events.Event;
import haxe.ds.GenericStack;
import flash.display3D.Context3D;
import flash.display.Stage;
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
        var context = getCurrentContext().context3D;

        shader.program = context.createProgram();

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
        var context:Context3D = getCurrentContext().context3D;
        var currentIndex = 0;
        var constantType;
        var vector;

        for(uniformInterface in shader.uniformInterfaces)
        {
            constantType = uniformInterface.isVertexConstant ? Context3DProgramType.VERTEX : Context3DProgramType.FRAGMENT;
            context.setProgramConstantsFromByteArray(constantType, currentIndex, cast uniformInterface.data.byteArray.length/(4 * 4), uniformInterface.data.byteArray, 0);
            currentIndex++;
        }

        context.setProgram(shader.program);
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

        var context:Context3D = getCurrentContext().context3D;
        meshData.indexBufferInstance = context.createIndexBuffer(meshData.indexCount);

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
        var context:Context3D = getCurrentContext().context3D;
        var headStep = 0;

        for(attributeConfig in data.attributeConfigs)
        {
            context.setVertexBufferAt(attributeConfig.attributeNumber, data.vertexBufferInstance, headStep, getFormat(attributeConfig));
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

        var context = getCurrentContext().context3D;

        if(meshData.indexBufferInstance != null)
        {
            try
            {
                context.drawTriangles(meshData.indexBufferInstance, 0, -1);
            }
            catch(error:Error)
            {
                trace(error);
            }
        }
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

