package backends.graphics_stage3d.assembler;

import flash.utils.Endian;
import flash.utils.ByteArray;

class Part
{
	public var name : String;
	public var version : Int;
	public var data : ByteArray;
	public function new(name : String = "", version : Int = 0)
    {
		this.name = name;
		this.version = version;
		this.data = new ByteArray();
		data.endian = Endian.LITTLE_ENDIAN;
	}
}

