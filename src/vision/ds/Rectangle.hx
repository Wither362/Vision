package vision.ds;

/**
	The `Rectangle` class provides a simple object for storing
	and manipulating a logical rectangle for calculations.
	
	Point `(0, 0)` of a Rectangle object is the same as the bottom left corner.
**/
@:structInit
class Rectangle {
	/**
		Get or set the bottom (y + height) value of the `Rectangle`
	**/
	public var bottom(get, set):Float;
	
	/**
		The `x` position of this `Rectangle` (down left corner)
	**/
	public var x:Int;
	/**
		The `y` position of this `Rectangle` (down left corner)
	**/
	public var y:Int;
	/**
		The `width` of this `Rectangle`
	**/
	public var width:Int;
	/**
		The `height` of this `Rectangle`
	**/
	public var height:Int;
	
	/**
		Creates a copy of `this` Rectangle.
		@return A new `Rectangle` instance.
	**/
	public function clone():Rectangle
		return new Rectangle(x, y, width, height);

	
	
	
	@:noCompletion private function get_bottom():Float
	{
		return y + height;
	}

	@:noCompletion private function set_bottom(b:Float):Float
	{
		height = b - y;
		return b;
	}

	@:noCompletion private function get_bottomRight():Vector2
	{
		return new Vector2(x + width, y + height);
	}

	@:noCompletion private function set_bottomRight(p:Vector2):Vector2
	{
		width = p.x - x;
		height = p.y - y;
		return p.clone();
	}

	@:noCompletion private function get_left():Float
	{
		return x;
	}

	@:noCompletion private function set_left(l:Float):Float
	{
		width -= l - x;
		x = l;
		return l;
	}

	@:noCompletion private function get_right():Float
	{
		return x + width;
	}

	@:noCompletion private function set_right(r:Float):Float
	{
		width = r - x;
		return r;
	}

	@:noCompletion private function get_size():Vector2
	{
		return new Vector2(width, height);
	}

	@:noCompletion private function set_size(p:Vector2):Vector2
	{
		width = p.x;
		height = p.y;
		return p.clone();
	}

	@:noCompletion private function get_top():Float
	{
		return y;
	}

	@:noCompletion private function set_top(t:Float):Float
	{
		height -= t - y;
		y = t;
		return t;
	}

	@:noCompletion private function get_topLeft():Vector2
	{
		return new Vector2(x, y);
	}

	@:noCompletion private function set_topLeft(p:Vector2):Vector2
	{
		x = p.x;
		y = p.y;
		return p.clone();
	}
}
