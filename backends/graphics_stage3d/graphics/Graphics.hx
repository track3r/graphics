package graphics;

import flash.display3D.Context3DCompareMode;
import flash.display3D.Context3DProfile;
import flash.system.Capabilities;
import flash.display3D.Context3DRenderMode;
import flash.geom.Rectangle;
import flash.display.BitmapData;
import flash.display3D.Context3DTextureFormat;
import flash.display3D.Context3DBlendFactor;
import aglsl.assembler.AGALMiniAssembler;
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
import types.DataType;

class Graphics
{
    private var assembler:AGALMiniAssembler;
    private var currentStage3DIndex:Int = 0;
    private var contextStack : GenericStack<GraphicsContext>;
    public function new(){
        assembler = new AGALMiniAssembler();
        contextStack = new GenericStack<GraphicsContext>();
    }

    public static function initialize(callback:Void->Void) : Void
    {
        var stage:Stage = flash.Lib.current.stage;
        var stage3D : Stage3D = stage.stage3Ds[0];

        stage.align = StageAlign.TOP_LEFT;
        stage.scaleMode = StageScaleMode.NO_SCALE;
        stage.frameRate = 60;

        if(sharedInstance == null)
        {
            sharedInstance = new Graphics();
        }

        stage3D.addEventListener( ErrorEvent.ERROR, function(event:ErrorEvent):Void{
            throw new Error(event.toString());
        });

        stage3D.addEventListener(Event.CONTEXT3D_CREATE, function (event:Event):Void
        {
            var contextWrapper:GraphicsContext = new GraphicsContext();
            contextWrapper.context3D = stage3D.context3D;
            contextWrapper.context3D.enableErrorChecking = isDebugBuild();

            contextWrapper.context3D.configureBackBuffer(stage.stageWidth, stage.stageHeight, 0, true, false);
            contextWrapper.context3D.setDepthTest(false, Context3DCompareMode.LESS);
            sharedInstance.pushContext(contextWrapper);
            callback();
        });

        stage3D.requestContext3D("auto");
    }

    public static function isDebugBuild():Bool {
        var error:String = new Error().getStackTrace();
        var reg = ~/:[0-9]+]$/m;
        return reg.match(error);
    }

    static var sharedInstance : Graphics;
    public static function instance() : Graphics
    {
        return sharedInstance;
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

    public function present():Void{
        getCurrentContext().context3D.present();
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
        var currentVertexIndex = 0;
        var currentFragmentIndex = 0;
        var constantType;
        var selectIndex;
        for(uniformInterface in shader.uniformInterfaces)
        {
            constantType = uniformInterface.isVertexConstant ? Context3DProgramType.VERTEX : Context3DProgramType.FRAGMENT;
            selectIndex = uniformInterface.isVertexConstant ? currentVertexIndex : currentFragmentIndex;
            context3D.setProgramConstantsFromByteArray(constantType, selectIndex, uniformInterface.numRegisters, uniformInterface.data.byteArray, uniformInterface.offset);
            selectIndex++;
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
        {
            trace("MeshData was null in graphics stage3d");
            return;
        }

        loadFilledVertexBuffer(meshData.attributeBuffer, meshData);
        loadFilledIndexBuffer(meshData.indexBuffer , meshData);
    }

    public function loadFilledVertexBuffer(meshDataBuffer : MeshDataBuffer, meshData:MeshData):Void
    {
        if(meshDataBuffer == null)
            return;

        var context:Context3D = getCurrentContext().context3D;

        if (!meshDataBuffer.bufferAlreadyOnHardware)
        {
            meshDataBuffer.sizeOfHardwareBuffer = 0;
        }

        if(meshDataBuffer.data == null)trace("vertexBufferInstance meshDataBuffer.data is null");
        try
        {
            if(meshData.vertexCount <= meshDataBuffer.sizeOfHardwareBuffer && meshDataBuffer.bufferAlreadyOnHardware)
            {

                meshData.vertexBufferInstance.uploadFromByteArray(meshDataBuffer.data.byteArray, 0, 0, meshData.vertexCount);
            }
            else
            {
                // Recreate because we need more space
                if (meshData.vertexBufferInstance != null)
                {
                    meshData.vertexBufferInstance.dispose();
                }

                meshData.vertexBufferInstance = context.createVertexBuffer(meshData.vertexCount, cast (meshData.attributeStride / 4));
                meshData.vertexBufferInstance.uploadFromByteArray(meshDataBuffer.data.byteArray, 0, 0, meshData.vertexCount);

                meshDataBuffer.sizeOfHardwareBuffer = meshData.vertexCount;
                meshDataBuffer.bufferAlreadyOnHardware = true;
            }
        }
        catch(er:Error)
        {
           trace(er);
        }
    }

    public function loadFilledIndexBuffer(meshDataBuffer : MeshDataBuffer,  meshData:MeshData):Void
    {
        if(meshDataBuffer == null)
            return;

        var context3D:Context3D = getCurrentContext().context3D;

        if (!meshDataBuffer.bufferAlreadyOnHardware)
        {
            meshDataBuffer.sizeOfHardwareBuffer = 0;
        }

        if(meshDataBuffer.data == null)trace("indexBufferInstance meshDataBuffer.data is null");
        try
        {
            if(meshData.indexCount <= meshDataBuffer.sizeOfHardwareBuffer && meshDataBuffer.bufferAlreadyOnHardware)
            {
                meshData.indexBufferInstance.uploadFromByteArray(meshDataBuffer.data.byteArray, 0, 0, meshData.indexCount);
            }
            else
            {
                if (meshData.indexBufferInstance != null)
                {
                    meshData.indexBufferInstance.dispose();
                }

                // Recreate because we need more space
                meshData.indexBufferInstance = context3D.createIndexBuffer(meshData.indexCount);
                meshData.indexBufferInstance.uploadFromByteArray(meshDataBuffer.data.byteArray, 0, 0, meshData.indexCount);
                meshDataBuffer.bufferAlreadyOnHardware = true;
            }

            meshData.indexBufferInstance.uploadFromByteArray(meshDataBuffer.data.byteArray, 0, 0, meshData.indexCount);
        }
        catch(er:Error)
        {
            trace(er);
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
            headStep += cast ((attributeConfig.vertexElementCount * DataTypeUtils.dataTypeByteSize(attributeConfig.vertexElementType)) / 4);
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
        if(meshData.indexBufferInstance == null)trace("meshData.indexBufferInstance is null");

        var numTriangles : Int = cast (meshData.indexCount / 3);
        context3D.drawTriangles(meshData.indexBufferInstance, 0, numTriangles);
    }

    public function loadFilledTextureData(texture : TextureData) : Void
    {
        pushTextureData(texture);
        bindTexture(texture);
    }

    private function checkPowerOfTwo(value : Int) :Int
    {
        var newSize = value;
        if(!isPowerOfTwo(value))
        {
            newSize = nextPowerOfTwo(value);
        }
        return newSize;
    }

    inline private function isPowerOfTwo(size:Int):Bool
    {
        return (size != 0) && ((size & (size - 1)) == 0);
    }

    inline private function nextPowerOfTwo(n:Int):Int
    {
        var count = 0;
        if (isPowerOfTwo(n))return n;

        while( n != 0)
        {
            n  >>= 1;
            count += 1;
        }

        return 1<<count;
    }

    public function bindTextureData(texture : TextureData, position : Int) : Void
    {
        if(texture == null)
        {
            getCurrentContext().context3D.setTextureAt(position, null);
            return;
        }

        texture.textureID = position;

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
            pushTextureDataForType(texture , texture.pixelFormat, texture.data, texture.originalWidth, texture.originalHeight);
        }
        else
        {
            /*var tex:Texture = context.createCubeTexture(size, "bgra", false)

            var mm:uint = 0
                for(; size != 0 ; size >>= 1){
            tex.uploadFromBitmapData( bd(size, 0xff0000), 0, mm)
            tex.uploadFromBitmapData( bd(size, 0x00ff00), 1, mm)
            tex.uploadFromBitmapData( bd(size, 0x0000ff), 2, mm)
            tex.uploadFromBitmapData( bd(size, 0xff00ff), 3, mm)
            tex.uploadFromBitmapData( bd(size, 0xffff00), 4, mm)
            tex.uploadFromBitmapData( bd(size, 0x00ffff), 5, mm)
            mm ++;
        }*/
        }
    }

    private function pushTextureDataForType(textureData:TextureData, textureFormat : TextureFormat, data : Data, width : Int, height : Int) :Void
    {
        var context3D:Context3D = getCurrentContext().context3D;
        var texture:Texture;

        validate(textureData, width, height);

        switch(textureFormat)
        {
            case(TextureFormatRGB565):
                texture = context3D.createTexture( textureData.originalWidth, textureData.originalHeight, Context3DTextureFormat.BGR_PACKED,  false );

            case(TextureFormatA8):
                texture = context3D.createTexture( textureData.originalWidth, textureData.originalHeight, Context3DTextureFormat.COMPRESSED_ALPHA,  false );

            case(TextureFormatRGBA8888):
                texture = context3D.createTexture( textureData.originalWidth, textureData.originalHeight, Context3DTextureFormat.BGRA,  false );
        }

        textureData.texture = texture;
        texture.uploadFromByteArray(textureData.data.byteArray, 0, 0);
    }

    private function validate(textureData:TextureData, originalWidth:Int, originalHeight:Int):Void
    {
        var width = checkPowerOfTwo(originalWidth);
        var height = checkPowerOfTwo(originalHeight);

        if(width != originalWidth || height!=originalHeight)
        {
            var newBmpData:BitmapData = new BitmapData(width, height, true, 0x00000000);

                // TODO ByteArray Data needs to be fixed
            newBmpData.setPixels(new Rectangle(0, 0, originalWidth, originalHeight), textureData.data.byteArray);

            textureData.originalWidth = width;
            textureData.originalHeight = height;
            textureData.data.byteArray = newBmpData.getPixels(newBmpData.rect);
        }
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

    public function enableDepthWrite(enabled : Bool) : Void
    {
        var context = getCurrentContext();
        if(context.currentDepthWrite == enabled)
            return;

        var context3D:Context3D = context.context3D;
        context3D.setDepthTest(enabled, Context3DCompareMode.LESS);
        context.currentDepthWrite = enabled;
    }

    public function isDepthWriting() : Bool
    {
        var context = getCurrentContext();
        return context.currentDepthWrite;
    }


    public function loadFilledRenderTarget(renderTarget : RenderTarget) : Void
    {
        var context = getCurrentContext();

        if(renderTarget == context.defaultRenderTarget)
        {
            return;
        }

        if(renderTarget.depthTextureData != null || renderTarget.stencilTextureData!=null)
            throw new Error("Graphics::loadFilledRenderTarget depth and stencil buffer are not suppoerted on the flash target");

        var context3D:Context3D = context.context3D;
        if(renderTarget.colorTextureData != null)
        {
            var texture = renderTarget.colorTextureData;
            pushTextureDataForType(texture , texture.pixelFormat, texture.data, texture.originalWidth, texture.originalHeight);
        }
        else
        {
            throw new Error("Graphics::loadFilledRenderTarget renderTarget.colorTextureData has not been set");
        }

        renderTarget.alreadyLoaded = true;
    }

    public function pushRenderTarget(renderTarget : RenderTarget) : Void
    {
        var context = getCurrentContext();
        var context3D:Context3D = context.context3D;

        if(context.currentRenderTargetStack.first() != renderTarget)
        {
            var enableDepthAndStencil = true;
            var antiAlias = 0;
            var surfaceSelector = 0;

            context3D.setRenderToTexture(renderTarget.colorTextureData.texture, enableDepthAndStencil, antiAlias, surfaceSelector);
        }

        context.currentRenderTargetStack.add(renderTarget);
    }

    public function popRenderTarget() : Void
    {
        var context = getCurrentContext();
        var context3D:Context3D = context.context3D;
        context.currentRenderTargetStack.pop();
        if(!context.currentRenderTargetStack.isEmpty())
        {
            var nextRenderTarget = context.currentRenderTargetStack.first();

            if(nextRenderTarget == context.defaultRenderTarget){
                context3D.setRenderToBackBuffer();
            }
            else
            {
                var enableDepthAndStencil = true;
                var antiAlias = 0;
                var surfaceSelector = 0;
                context3D.setRenderToTexture(nextRenderTarget.colorTextureData.texture, enableDepthAndStencil, antiAlias, surfaceSelector);
            }
        }
    }

    public function unloadRenderTarget(renderTarget : RenderTarget) : Void
    {
        var context = getCurrentContext();

        if(renderTarget == context.defaultRenderTarget)
        {
            return;
        }

        renderTarget.colorTextureData.texture.dispose();
        renderTarget.colorTextureData = null;

        renderTarget.alreadyLoaded = false;
    }

    public function isLoadedRenderTarget(renderTarget : RenderTarget) : Bool
    {
        return renderTarget.alreadyLoaded;
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

        context.context3D.clear(
            color.r/255,
            color.g/255,
            color.b/255,
            color.a/255,
            1,0,0xFFFFFF);
    }
}

