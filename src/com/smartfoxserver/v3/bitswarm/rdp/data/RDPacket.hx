package com.smartfoxserver.v3.bitswarm.rdp.data;

import haxe.io.Bytes;

class RDPacket {
    public static final RDP_HEADER_MICRO_SIZE:Int = 1;
    public static final RDP_HEADER_SMALL_SIZE:Int = 5;
    public static final RDP_HEADER_FULL_SIZE:Int = 9;

    private var header:PacketHeader;
    private var fragHeader:FragHeader;
    private var seqId:Int;
    private var data:Bytes;
    private var endPoint:EndPoint;
    private var creationTime:Float; // Float for timestamps via Timer.stamp()

    public function new(ph:PacketHeader, data:Bytes, seqId:Int = -1, fh:FragHeader = null) {
        this.creationTime = -1;
        this.header = ph;
        this.fragHeader = fh;
        this.seqId = seqId;
        this.data = data;
    }

    public function getSeqId():Int {
        return this.seqId;
    }

    public function getHeader():PacketHeader {
        return this.header;
    }

    public function getFragHeader():FragHeader {
        return this.fragHeader;
    }

    public function getData():Bytes {
        return this.data;
    }

    public function setFragHeader(fragHeader:FragHeader):Void {
        this.fragHeader = fragHeader;
    }

    public function setSeqId(seqId:Int):Void {
        this.seqId = seqId;
    }

    public function getDataSize():Int {
        return this.data.length;
    }

    public function getEndPoint():EndPoint {
        return this.endPoint;
    }

    public function setEndPoint(endPoint:EndPoint):Void {
        this.endPoint = endPoint;
    }

    public function getCreationTime():Float {
        return this.creationTime;
    }

    public function setCreationTime(creationTime:Float):Void {
        this.creationTime = creationTime;
    }

    public function toString():String {
        var fhStr = this.fragHeader != null ? this.fragHeader.toString() : "--";
        return '[Seq: ${seqId}, Rel: ${header.isRealiable()}, Frag: ${fhStr}, Data: ${data.length}]';
    }
}
