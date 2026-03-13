package com.smartfoxserver.v3.bitswarm.rdp.data;

import haxe.io.BytesInput;
import haxe.io.BytesOutput;

class FragHeader {
    public var fragId:Int;
    public var totFrags:Int;

    public function new(fragId:Int, totFrags:Int) {
        this.fragId = fragId;
        this.totFrags = totFrags;
    }

    public static function decode(bi:BytesInput):FragHeader {
        var fid = bi.readUInt16();
        var totFrags = bi.readInt16();
        return new FragHeader(fid, totFrags);
    }

    public function getId():Int {
        return this.fragId;
    }

    public function getTotFrags():Int {
        return this.totFrags;
    }

    public function encode(bo:BytesOutput):Void {
        bo.writeUInt16(this.fragId);
        bo.writeInt16(this.totFrags);
    }

    public function toString():String {
        return '(i:${fragId}, t:${totFrags})';
    }
}
