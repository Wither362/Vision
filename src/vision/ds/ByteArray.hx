package vision.ds;

import haxe.io.BytesData;
import haxe.io.Bytes;

/**
    An abstract over `haxe.io.Bytes`, allows array access.
**/
@:forward
abstract ByteArray(Bytes) from Bytes to Bytes {
    
    @:op([]) function read(index:Int) {
        return this.get(index);
    }

    @:op([]) function write(index:Int, value:Int) {
        return this.set(index, value);
    }

    /**
        Creates a new `ByteArray`
    **/
    public function new(length:Int) {
        var data:BytesData = new BytesData(length);
        this = @:privateAccess new Bytes(data);
    }
}