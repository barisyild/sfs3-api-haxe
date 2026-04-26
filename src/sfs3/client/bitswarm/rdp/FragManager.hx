package sfs3.client.bitswarm.rdp;

import sfs3.client.bitswarm.rdp.data.FragHeader;
import sfs3.client.bitswarm.rdp.data.PacketHeader;
import sfs3.client.bitswarm.rdp.data.RDPacket;
import sfs3.client.bitswarm.rdp.data.ReassembledRDPacket;
import haxe.io.Bytes;
import haxe.io.BytesInput;
import haxe.io.BytesOutput;
import hx.concurrent.atomic.AtomicInt;
import hx.concurrent.lock.RLock;
import sfs3.client.core.Logger;
import sfs3.client.core.LoggerFactory;
import sfs3.client.exceptions.IllegalStateException;

class FragManager {
    private var fragIdGen:AtomicInt = new AtomicInt(0);
    private var fragBuffer:Array<RDPacket> = [];
    private var log:Logger;
    private var channel:BaseReliableChannel;
    private var cfg:TransportConfig;
    private var buffLock:RLock = new RLock();

    public function new(channel:BaseReliableChannel) {
        this.log = LoggerFactory.getLogger(Type.getClass(this));
        this.channel = channel;
        this.cfg = channel.getTransport().getCfg();
    }

    public function enqueueFrag(packet:RDPacket):Void {
        buffLock.execute(function() {
            if (this.fragBuffer.length >= this.cfg.fragBufferLimit) {
                throw new RDPException('Frag buffer limit exceeded: ${this.cfg.fragBufferLimit}');
            }

            this.fragBuffer.push(packet);
            this.analyzeFrags();
        });
    }

    private function analyzeFrags():Void {
        var pos = 0;
        while (pos < this.fragBuffer.length) {
            var packetFrag = this.fragBuffer[pos];
            pos = this.checkPacketIsComplete(packetFrag, pos);
        }
    }

    private function checkPacketIsComplete(firstFrag:RDPacket, pos:Int):Int {
        var originalPos = pos;
        var fragId = firstFrag.getFragHeader().getId();
        var expectedFrags = firstFrag.getFragHeader().getTotFrags();
        pos++;

        var fragCount = 1;
        while (pos < this.fragBuffer.length) {
            var nextFrag = this.fragBuffer[pos];
            if (nextFrag.getFragHeader().getId() != fragId) {
                this.log.warn('Found different fragment ID! ${nextFrag.getFragHeader().getId()}');
                if (fragCount == expectedFrags) {
                    this.reassemblePacket(originalPos, pos + 1);
                    return originalPos;
                }

                // Remove sublist
                var removedList = this.fragBuffer.splice(originalPos, pos - originalPos);
                if (Logger.isDebugEnabled()) {
                    this.log.debug('Removing broken fragment sequence: ${removedList}');
                }
                return originalPos;
            }

            fragCount++;
            if (fragCount == expectedFrags) {
                this.reassemblePacket(originalPos, pos + 1);
                return originalPos;
            }
            pos++;
        }

        return pos;
    }

    private function reassemblePacket(startPos:Int, endPos:Int):Void {
        var limit = endPos - startPos;
        var fragList = this.fragBuffer.splice(startPos, limit);
        var fullPacket = rebuildPacket(fragList);
        this.channel.dispatchPacket(fullPacket, fragList.length);
    }

    public static function rebuildPacket(fragList:Array<RDPacket>):RDPacket {
        var totBytes = 0;
        for (item in fragList) {
            totBytes += item.getDataSize();
        }

        var bo = new BytesOutput();
        bo.bigEndian = true;
        for (item in fragList) {
            bo.writeBytes(item.getData(), 0, item.getDataSize());
        }

        var ph = new PacketHeader(true, true, false, false, false);
        var fullPacket = new ReassembledRDPacket(ph, fragList[0].getSeqId(), bo.getBytes());
        fullPacket.setEndPoint(fragList[0].getEndPoint());
        fullPacket.setFragCount(fragList.length);
        return fullPacket;
    }

    public function generateFrags(packet:RDPacket):Array<RDPacket> {
        var packets:Array<RDPacket> = [];
        var startSize = packet.getDataSize();

        if (startSize <= this.cfg.mtu) {
            throw new IllegalStateException('Packet does not need to be fragmented, size < MTU (${startSize})');
        }

        var totFrags = Std.int(startSize / this.cfg.mtu);
        var remaining = startSize % this.cfg.mtu;
        if (remaining > 0) {
            totFrags++;
        }

        if (totFrags > this.cfg.maxFragments) {
            throw new RDPException('Packet exceeds the max amount of possible fragments: ${this.cfg.maxFragments}, packet size: ${startSize}, MTU: ${this.cfg.mtu}');
        }

        var fragId = this.fragIdGen.incrementAndGet() - 1;
        var sourceBuff = new BytesInput(packet.getData());
        sourceBuff.bigEndian = true;

        for (i in 0...totFrags) {
            var fragBytesSize = this.cfg.mtu;
            if (i == totFrags - 1 && remaining > 0) {
                fragBytesSize = remaining;
            }

            var fragBytes = sourceBuff.read(fragBytesSize);
            var ph = new PacketHeader(true, true, false, true, false);
            var fh = new FragHeader(fragId, totFrags);
            var packetId = i == 0 ? packet.getSeqId() : this.channel.nextOutSeqId();
            var fragPacket = new RDPacket(ph, fragBytes, packetId, fh);
            fragPacket.setEndPoint(packet.getEndPoint());
            packets.push(fragPacket);
        }

        return packets;
    }

    public function getFragBufferSize():Int {
        return this.fragBuffer.length;
    }

    public function getFragBufferDump():Array<String> {
        return buffLock.execute(function() {
            var arr = [];
            for (p in this.fragBuffer) {
                arr.push(p.toString());
            }
            return arr;
        });
    }

    private function debug(args:Array<Dynamic>):Void {
        var sb = "(DBG) ";
        for (obj in args) {
            sb += Std.string(obj);
        }
        this.log.info(sb);
    }
}
