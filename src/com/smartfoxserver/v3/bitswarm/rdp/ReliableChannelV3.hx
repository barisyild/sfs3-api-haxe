package com.smartfoxserver.v3.bitswarm.rdp;

import com.smartfoxserver.v3.bitswarm.rdp.data.EndPoint;
import com.smartfoxserver.v3.bitswarm.rdp.data.FragHeader;
import com.smartfoxserver.v3.bitswarm.rdp.data.NAck32History;
import com.smartfoxserver.v3.bitswarm.rdp.data.NAck32Packet;
import com.smartfoxserver.v3.bitswarm.rdp.data.RDPacket;
import com.smartfoxserver.v3.bitswarm.rdp.data.UDPData;
import haxe.Timer;
import haxe.io.BytesInput;
import hx.concurrent.lock.RLock;
import hx.concurrent.collection.SynchronizedMap;
import com.smartfoxserver.v3.entities.data.Queue;
import com.smartfoxserver.v3.entities.data.Deque;

class ReliableChannelV3 extends BaseReliableChannel {
    private static final NACK_MAX_CACHE_SIZE:Int = 34;
    private static final NACK_HISTORY_LEN:Int = 32;
    
    private var lowestSeqId:Int = 0;
    private var channelLock:RLock = new RLock();
    private var nackHistory:NAck32History = new NAck32History();
    private var nackPacketCache:Deque<UnAcked> = new Deque();

    private var packetBuffer:SynchronizedMap<Int, RDPacket> = SynchronizedMap.newIntMap();
    private var fragManager:FragManager;

    public function new(transport:ITransport) {
        super(transport);
        this.fragManager = new FragManager(this);
    }

    public function destroy():Void {
    }

    public function getCurrentRTT():Float {
        return -1.0;
    }

    public function dataReceived(data:UDPData):Void {
        channelLock.execute(function() {
            this.processIncomingData(data);
            this.packetBufferCleaner();
        });
    }

    private function processIncomingData(data:UDPData):Void {
        this.transport.addInPacket();
        this.transport.addInBytes(data.buff.length);
        var bi = new BytesInput(data.buff);

        if (data.header.isAck()) {
            bi.position = 1;
            var nackPacket = NAck32Packet.decode(bi);
            this.nackReceived(nackPacket);
        } else if (data.header.isPing()) {
            if (this.log.isDebugEnabled()) {
                this.log.debug("Handle PING");
            }
        } else {
            var fragHeader:FragHeader = null;
            if (data.header.isFrag()) {
                bi.position = 1;
                fragHeader = FragHeader.decode(bi);
            } else {
                bi.position = 1;
            }

            var seqId = bi.readInt32();
            this.nackHistory.update(seqId);
            var packetData = bi.read(data.buff.length - bi.position);
            
            var packet = new RDPacket(data.header, packetData, seqId, fragHeader);
            packet.setEndPoint(data.endPoint);

            if (packet.getSeqId() < this.lowestSeqId) {
                if (this.log.isDebugEnabled()) {
                    this.log.debug('Discarding packet with ID: ${packet.getSeqId()} -- lowest expected is: ${this.lowestSeqId}');
                }
            } else {
                this.processIncomingPacket(packet);
            }
        }
    }

    private function processIncomingPacket(packet:RDPacket):Void {
        var pID = packet.getSeqId();

        if (pID == this.lowestSeqId) {
            if (!this.packetBuffer.exists(pID)) {
                this.packetBuffer.set(pID, packet);
            }

            var orderedKeys = [for (k in this.packetBuffer.keys()) k];
            orderedKeys.sort(function(a, b) return a - b);
            var lastId = this.lowestSeqId - 1;

            for (id in orderedKeys) {
                if (id - lastId != 1) break;

                var dispatchable = this.packetBuffer.get(id);
                this.packetBuffer.remove(id);

                if (dispatchable != null) {
                    if (dispatchable.getHeader().isFrag()) {
                        this.fragManager.enqueueFrag(dispatchable);
                    } else {
                        this.dispatchPacket(dispatchable);
                    }
                } else {
                    this.log.warn('Unexpected -> Dispatch null packet with ID: ${id}');
                }

                lastId = id;
                this.lowestSeqId++;
            }
        } else {
            var size = 0;
            for (k in this.packetBuffer.keys()) size++;

            if (size > this.transport.getCfg().packetBufferSize) {
                if (this.log.isDebugEnabled()) {
                    this.log.debug('Packet buffer overflow (size: ${size})');
                }
                this.transport.getReliableErrorCallback()();
                return;
            }

            if (!this.packetBuffer.exists(pID)) {
                packet.setCreationTime(Timer.stamp() * 1000.0);
                this.packetBuffer.set(pID, packet);

                if (pID > this.lowestSeqId) {
                    this.sendNAck(packet.getEndPoint());
                }
            }
        }
    }

    private function sendNAck(dest:EndPoint):Void {
        var nack = new NAck32Packet(-1, 0, this.nackHistory);
        var packet = new RDPacket(nack.getHeader(), nack.encode(), -1, null);
        packet.setEndPoint(dest);
        this.triggerSendEvent(packet);
    }

    private function nackReceived(packet:NAck32Packet):Void {
        var nackId = packet.getSeqId();
        var hist = packet.getHistoy();

        var n = 31;
        while (n >= 0) {
            if (((hist >>> n) & 1) != 1) {
                var index = nackId - (32 - n);
                if (index < 0) {
                    break;
                }
                this.rtxPacket(index);
            }
            n--;
        }
    }

    private function rtxPacket(seqId:Int):Void {
        try {
            var item = this.findNackCachedPacket(seqId);
            if (item != null && (item.getRtxCount() == 0 || item.isExpired())) {
                item.retryOneMoreTime();
                if (item.getRtxCount() < this.transport.getCfg().maxRtxAttempts) {
                    if (this.log.isDebugEnabled()) {
                        this.log.debug('Resending packet #${seqId}');
                    }
                    item.setTimeStamp(Timer.stamp() * 1000.0);
                    this.triggerSendEvent(item.getPacket());
                } else {
                    this.removeNackPacket(seqId);
                    if (this.log.isDebugEnabled()) {
                        this.log.debug('Packet has failed all RTX attempts(${this.transport.getCfg().maxRtxAttempts}): ${item.getPacket()}');
                    }
                }
            }
        } catch (ex:Dynamic) {
            this.log.warn('Unexpected error during packet rtx, id: ${seqId}: ${ex}');
        }
    }

    private function findNackCachedPacket(seqId:Int):UnAcked {
        for (item in this.nackPacketCache) {
            if (item.getPacket().getSeqId() == seqId) {
                return item;
            }
        }

        return null;
    }

    private function removeNackPacket(seqId:Int):Void {
        for(item in this.nackPacketCache) {
            if (item.getPacket().getSeqId() == seqId) {
                this.nackPacketCache.remove(item);
                break;
            }
        }
    }

    private function packetBufferCleaner():Void {
        var size = 0;
        for (k in this.packetBuffer.keys()) size++;

        if (size > 0) {
            var orderedKeys = [for (k in this.packetBuffer.keys()) k];
            orderedKeys.sort(function(a, b) return a - b);
            var keyIndex = 0;
            var seqId = orderedKeys[keyIndex];
            var packet = this.packetBuffer.get(seqId);

            if (packet.getHeader().isFrag()) {
                var fragId = packet.getFragHeader().getId();
                var expectedFrags = packet.getFragHeader().getTotFrags();
                var highestTimestamp = packet.getCreationTime();
                var frags = [packet];

                for (i in 1...orderedKeys.length) {
                    var nextPacketId = orderedKeys[i];
                    var nextFrag = this.packetBuffer.get(nextPacketId);
                    if (!nextFrag.getHeader().isFrag() || nextFrag.getFragHeader().getId() != fragId) {
                        break;
                    }

                    frags.push(nextFrag);
                    if (nextFrag.getCreationTime() > highestTimestamp) {
                        highestTimestamp = nextFrag.getCreationTime();
                    }
                }

                var expired = (Timer.stamp() * 1000.0) - highestTimestamp > this.transport.getCfg().packetBufferExpiryTime;
                if (expired) {
                    for (item in frags) this.packetBuffer.remove(item.getSeqId());

                    if (frags.length == expectedFrags) {
                        if (this.log.isDebugEnabled()) {
                            this.log.debug('Dispatching expired fragment from packet buffer. FragId: ${fragId}');
                        }

                        if (this.transport.getCfg().triggerReliableErrors && this.detectPacketLoss(seqId)) {
                            return;
                        }

                        var fullPacket = FragManager.rebuildPacket(frags);
                        this.lowestSeqId = seqId + 1;
                        this.dispatchPacket(fullPacket, frags.length);
                    } else if (this.log.isDebugEnabled()) {
                        this.log.debug('Removing ${frags.length} incomplete frag(s) with id: ${fragId}');
                    }
                }
            } else if (this.isExpired(packet)) {
                if (this.log.isDebugEnabled()) {
                    this.log.debug('Dispatching expired packet from buffer. Id: ${seqId}');
                }

                if (this.transport.getCfg().triggerReliableErrors && this.detectPacketLoss(seqId)) {
                    return;
                }

                this.packetBuffer.remove(seqId);
                this.lowestSeqId = seqId + 1;
                this.dispatchPacket(packet);

                while (true) {
                    keyIndex++;
                    if (keyIndex >= orderedKeys.length) break;

                    seqId = orderedKeys[keyIndex];
                    packet = this.packetBuffer.get(seqId);
                    if (seqId != this.lowestSeqId || packet.getHeader().isFrag()) break;

                    this.lowestSeqId++;
                    this.packetBuffer.remove(seqId);
                    this.dispatchPacket(packet);
                }
            }
        }
    }

    function dispatchPacket(packet:RDPacket, ?fragCount:Int):Void {
        if (fragCount == null) fragCount = 0;
        if (fragCount < 0) {
            throw new haxe.Exception("fragCount can't be negative: " + fragCount);
        } else {
            this.transport.getIncomingDataHandler()(packet.getData(), packet.getEndPoint(), TxpMode.RELIABLE_ORDERED);
        }
    }

    private function detectPacketLoss(seqId:Int):Bool {
        var foundGap = seqId - this.lowestSeqId > 0;
        if (foundGap) {
            this.transport.getReliableErrorCallback()();
        }
        return foundGap;
    }

    public function sendData(packet:RDPacket):Void {
        packet.setSeqId(this.nextOutSeqId());
        if (packet.getDataSize() > this.transport.getCfg().mtu) {
            var packets = this.fragManager.generateFrags(packet);
            this.sendMulti(packets);
        } else {
            this.sendSingle(packet);
        }
    }

    private function sendSingle(packet:RDPacket):Void {
        var buffer = this.preparePacketForSending(packet);
        this.transport.addOutPacket();
        this.transport.addOutBytes(buffer.length);
        this.addUnAcked(packet);
        this.transport.getOutgoingDataHandler()(buffer, packet.getEndPoint(), TxpMode.RELIABLE_ORDERED);
    }

    private function sendMulti(packets:Array<RDPacket>):Void {
        for (item in packets) {
            this.sendSingle(item);
        }
    }

    private function addUnAcked(packet:RDPacket):Void {
        var transportConfig:TransportConfig = this.transport.getCfg();
        this.nackPacketCache.pushFront(new UnAcked(packet, transportConfig.rtxBaseTimeout, transportConfig.backOffMultiplier, 3000));
        if (this.nackPacketCache.length > 34) {
            this.nackPacketCache.popBack();
        }
    }

    public function getPacketBufferSize():Int {
        var size = 0;
        for (k in this.packetBuffer.keys()) size++;
        return size;
    }

    public function getFragBufferSize():Int {
        return this.fragManager.getFragBufferSize();
    }

    public function getUnAckedIds():Array<Int> {
        var keys = [];
        for (item in this.nackPacketCache) {
            keys.push(item.getPacket().getSeqId());
        }
        return keys;
    }

    public function getBufferDump():Array<String> {
        var arr = [];
        for (v in this.packetBuffer.iterator()) arr.push(v.toString());
        return arr;
    }

    public function getUnAckedDump():Array<String> {
        var arr = [];
        for (item in this.nackPacketCache) arr.push(item.toString());
        return arr;
    }

    public function getFragBufferDump():Array<String> {
        return this.fragManager.getFragBufferDump();
    }
}
