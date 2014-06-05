/*
 * Created by IntelliJ IDEA.
 * User: rcam
 * Date: 22/05/14
 * Time: 14:23
 */
package renderer;

import renderer.RenderTypes;

import gl.GL;
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

    public function new() : Void {}

    /// specific to ogl
    public var glTexture : gl.GLTexture;
    public var alreadyLoaded : Bool;
}