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
    public var depthWrite : Null<Bool>;
    public var depthFunc : DepthFunc;

	public var stencilingEnabled : Null<Bool>;

    public var antialias: Bool;
    public var premultipliedAlpha: Bool;
    public var preserveDrawingBuffer: Bool;

    public function invalidateCaches(): Void;
    public function rebindDefaultBackbuffer() : Void; // Just needed when the context was lost and is recreated;
}    
