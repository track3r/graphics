package graphics;

import flash.display3D.textures.TextureBase;
import flash.display3D.Context3DTextureFormat;
import graphics.GraphicsTypes;

import types.Data;

class TextureData
{
    public var pixelFormat : TextureFormat;
    public var textureType : TextureType;
    public var hasAlpha : Bool;
    public var hasPremultipliedAlpha : Bool;
    public var originalHeight : Int;
    public var originalWidth : Int;

    public var hasMipMaps : Bool;

    public var filteringMode : TextureFilteringMode;
    public var wrap : TextureWrap;

    public var data : Data;

    public var dataForCubeMapPositiveX : Data;
    public var dataForCubeMapNegativeX : Data;
    public var dataForCubeMapPositiveY : Data;
    public var dataForCubeMapNegativeY : Data;
    public var dataForCubeMapPositiveZ : Data;
    public var dataForCubeMapNegativeZ : Data;

    //flash specific

    public var texture : TextureBase;
    public var textureID : Int;
    public var mipMapsLevel : Int = 0;
    public var format : Context3DTextureFormat;

    public function new() : Void {}
}