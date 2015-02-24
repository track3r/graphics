/*
 * Created by IntelliJ IDEA.
 * User: rcam
 * Date: 22/05/14
 * Time: 11:08
 */
package graphics;

import types.Data;
import graphics.GraphicsTypes;

extern class TextureData
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
}
