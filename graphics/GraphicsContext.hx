/*
 * Created by IntelliJ IDEA.
 * User: rcam
 * Date: 04/06/14
 * Time: 14:34
 */
package graphics;

import haxe.ds.Vector;
import graphics.GraphicsTypes;

extern class GraphicsContext
{
    static public var vendor(default, null): Null<String>;
    static public var renderer(default, null): Null<String>;
    static public var version(default, null): Null<String>;
    static public var extensions(default, null): Null<String>;

    public var depthWrite : Null<Bool> = null;
    public var depthFunc : DepthFunc;

	public var stencilingEnabled : Null<Bool> = null;

    public var antialias: Bool;
    public var premultipliedAlpha: Bool;
    public var preserveDrawingBuffer: Bool;

    public function invalidateCaches(): Void;

    // API Extensions. This should never be invalidated after initialisation,
    // since we assume that the graphics hardware will not change at runtime.
    public var supportsDiscardFramebuffer(default, null): Bool = false;
    public var supportsVertexArrayObjects(default, null): Bool = false;

}    
