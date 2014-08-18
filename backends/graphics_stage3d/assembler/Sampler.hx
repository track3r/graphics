/**

 * ...

 * @author

 */
package backends.graphics_stage3d.assembler;

class Sampler
{
	public var shift : Int;
	public var mask : Int;
	public var value : Int;
	public function new(shift : Int, mask : Int, value : Int) {
		this.shift = shift;
		this.mask = mask;
		this.value = value;
	}

}

