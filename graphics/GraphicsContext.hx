/*
 * Created by IntelliJ IDEA.
 * User: rcam
 * Date: 04/06/14
 * Time: 14:34
 */
package graphics;

extern class GraphicsContext
{
    public var depthWrite : Bool;
    public var depthFunc : DepthFunc;

    public var stencilingEnabled : Bool;

    public var antialias : Bool;
    public var premultipliedAlpha : Bool;
    public var preserveDrawingBuffer : Bool;

}