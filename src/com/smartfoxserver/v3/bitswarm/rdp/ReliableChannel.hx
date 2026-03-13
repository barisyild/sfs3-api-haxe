package com.smartfoxserver.v3.bitswarm.rdp;

import com.smartfoxserver.v3.bitswarm.rdp.data.AckPacket;
import com.smartfoxserver.v3.bitswarm.rdp.data.EndPoint;
import com.smartfoxserver.v3.bitswarm.rdp.data.FragHeader;
import com.smartfoxserver.v3.bitswarm.rdp.data.RDPacket;
import com.smartfoxserver.v3.bitswarm.rdp.data.UDPData;
import haxe.Timer;
import haxe.io.BytesInput;
import hx.concurrent.lock.RLock;

class ReliableChannel extends BaseReliableChannel {
    private static final RTX_LOOP_PAUSE:Int = 50;
    private static final BUFFER_CLEANER_LOOP_PAUSE:Int = 16;
    
    private var unAckedById:Map<Int, UnAcked>;
    private var lastRTTValues:Array<Float>;
    private var rttLock:RLock;
    private var channelLock:RLock;
    private var running:Bool = true;
    
    private var lowestSeqId:Int = 0;
    private var packetBuffer:Map<Int, RDPacket>;
    private var packetBufferLock:RLock;
    private var unAckedLock:RLock;
    private var fragManager:FragManager;

    public function new(transport:ITransport) {
        super(transport);
        this.isRTTProvider = true;
        this.unAckedById = new Map<Int, UnAcked>();
        this.packetBuffer = new Map<Int, RDPacket>();
        this.lastRTTValues = [];
        this.rttLock = new RLock();
        this.channelLock = new RLock();
        this.packetBufferLock = new RLock();
        this.unAckedLock = new RLock();
        this.fragManager = new FragManager(this);

        this.getThreadPool().submit(function() {
            rtxLoop();
        });
        this.getThreadPool().submit(function() {
            packetBufferCleaner();
        });
    }

    public function destroy():Void {
        this.running = false;
    }

    public function getCurrentRTT():Float {
        return rttLock.execute(function() {
            if (this.lastRTTValues.length != 0) {
                var totRTT:Float = 0;
                for (value in this.lastRTTValues) {
                    totRTT += value;
                }
                return totRTT / this.lastRTTValues.length;
            }
            return -1.0;
        });
    }

    public function dataReceived(data:UDPData):Void {
        channelLock.execute(function() {
            this.transport.addInBytes(data.buff.length);
            var bi = new BytesInput(data.buff);
            
            if (!data.header.isAck()) {
                if (!data.header.isPing()) {
                    this.transport.addInPacket();
                    var fragHeader:FragHeader = null;
                    if (data.header.isFrag()) {
                        // Header is already decoded in UdpClient, we are skipping the first byte in BytesInput
                        bi.position = 1;
                        fragHeader = FragHeader.decode(bi);
                    } else {
                        bi.position = 1;
                    }

                    var seqId = bi.readInt32();
                    var packetData = bi.read(data.buff.length - bi.position); // read fully

                    var packet = new RDPacket(data.header, packetData, seqId, fragHeader);
                    packet.setEndPoint(data.endPoint);
                    this.sendAck(packet.getSeqId(), packet.getEndPoint());

                    if (packet.getSeqId() >= this.lowestSeqId) {
                        this.processIncomingPacket(packet);
                        return;
                    }

                    if (this.log.isDebugEnabled()) {
                        this.log.debug('Discarding packet with ID: ${packet.getSeqId()} -- lowest expected is: ${this.lowestSeqId}');
                    }
                    return;
                }

                if (this.log.isDebugEnabled()) {
                    this.log.debug("Handle PING");
                }
                return;
            }

            bi.position = 1;
            var ackPacket = AckPacket.decode(bi);
            this.ackReceived(ackPacket);
        });
    }

    private function processIncomingPacket(packet:RDPacket):Void {
        packetBufferLock.execute(function() {
            if (packet.getSeqId() == this.lowestSeqId) {
                if (!this.packetBuffer.exists(packet.getSeqId())) {
                    this.packetBuffer.set(packet.getSeqId(), packet);
                }

                var orderedKeys = [for (k in this.packetBuffer.keys()) k];
                orderedKeys.sort(function(a, b) return a - b);
                
                var lastId = this.lowestSeqId - 1;

                for (id in orderedKeys) {
                    if (id - lastId != 1) {
                        break;
                    }

                    var dispatchable = this.packetBuffer.get(id);
                    this.packetBuffer.remove(id);

                    if (dispatchable != null) {
                        if (dispatchable.getHeader().isFrag()) {
                            this.fragManager.enqueueFrag(dispatchable);
                        } else {
                            this.dispatchPacket(dispatchable);
                        }
                    } else {
                        this.log.warn('Unexpected: dispatch null packet? ID: ${id}');
                    }

                    lastId = id;
                    this.lowestSeqId++;
                }
            } else {
                var size = 0;
                for (k in this.packetBuffer.keys()) size++; // Count Map keys

                if (size > this.transport.getCfg().packetBufferSize) {
                    if (this.log.isDebugEnabled()) {
                        this.log.debug('Packet buffer overflow (size: ${size})');
                    }
                    this.transport.getReliableErrorCallback()();
                    return;
                }

                if (!this.packetBuffer.exists(packet.getSeqId())) {
                    packet.setCreationTime(Timer.stamp() * 1000.0);
                    this.packetBuffer.set(packet.getSeqId(), packet);
                }
            }
        });
    }

    private function ackReceived(packet:AckPacket):Void {
        var now = Timer.stamp() * 1000.0;
        var ackId = packet.getSeqId();
        
        var unAcked:UnAcked = null;
        unAckedLock.execute(function() {
            unAcked = this.unAckedById.get(ackId);
            this.unAckedById.remove(ackId);
        });

        if (unAcked == null) {
            if (this.log.isDebugEnabled()) {
                this.log.debug('Received ACK for: ${ackId} -- NotFound');
            }
        } else {
            var rTripMs = now - unAcked.getTimeStamp();
            rttLock.execute(function() {
                if (this.lastRTTValues.length >= 10) {
                    this.lastRTTValues.pop();
                }
                this.lastRTTValues.unshift(rTripMs);
            });
        }
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

    function dispatchPacket(packet:RDPacket, ?fragCount:Int):Void {
        if (fragCount == null) fragCount = 0;
        if (fragCount < 0) {
            throw new haxe.Exception("fragCount can't be negative: " + fragCount);
        } else {
            this.transport.getIncomingDataHandler()(packet.getData(), packet.getEndPoint(), TxpMode.RELIABLE_ORDERED);
        }
    }

    private function sendAck(seqId:Int, dest:EndPoint):Void {
        var ack = new AckPacket(seqId);
        var packet = new RDPacket(ack.getHeader(), ack.encode(), -1, null);
        packet.setEndPoint(dest);
        this.triggerSendEvent(packet);
    }

    private function addUnAcked(packet:RDPacket):Void {
        unAckedLock.execute(function() {
            var size = 0;
            for (k in this.unAckedById.keys()) size++;

            if (size >= this.transport.getCfg().unACKBufferSize) {
                if (this.log.isDebugEnabled()) {
                    this.log.debug('RTX buffer overflow, size: ${size}');
                }
                this.transport.getReliableErrorCallback()();
            } else {
                if (!this.unAckedById.exists(packet.getSeqId())) {
                    this.unAckedById.set(packet.getSeqId(), new UnAcked(packet, this.transport.getCfg().rtxBaseTimeout, this.transport.getCfg().backOffMultiplier, 3000));
                }
            }
        });
    }

    private function rtxLoop():Void {
        #if flash
        if (!this.running) return;
        #else
        while (this.running) {
        #end
        try {
            unAckedLock.execute(function() {
                for (item in this.unAckedById.iterator()) {
                    if (item.isExpired()) {
                        item.retryOneMoreTime();
                        if (item.getRtxCount() < this.transport.getCfg().maxRtxAttempts) {
                            if (this.log.isDebugEnabled()) {
                                this.log.debug('Resending packet #${item.getPacket().getSeqId()}');
                            }
                            item.setTimeStamp(Timer.stamp() * 1000.0);
                            this.triggerSendEvent(item.getPacket());
                        } else {
                            this.unAckedById.remove(item.getPacket().getSeqId());
                            if (this.transport.getCfg().triggerReliableErrors) {
                                this.transport.getReliableErrorCallback()();
                            }
                            if (this.log.isDebugEnabled()) {
                                this.log.debug('Packet has failed all RTX attempts(${this.transport.getCfg().maxRtxAttempts}): ${item.getPacket()}');
                            }
                        }
                    }
                }
            });
        } catch (ex:Dynamic) {
            this.log.warn("Exception in RTX Loop: " + ex);
        }
        #if flash
        haxe.Timer.delay(rtxLoop, RTX_LOOP_PAUSE);
        #else
        Sys.sleep(0.050); // 50ms
        }
        #end
    }

    private function packetBufferCleaner():Void {
        #if flash
        if (!this.running) return;
        #else
        while (this.running) {
        #end
        try {
            channelLock.execute(function() {
                packetBufferLock.execute(function() {
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

                            this.packetBuffer.remove(seqId);
                            this.lowestSeqId = seqId + 1;
                            this.dispatchPacket(packet);
                        }
                    }
                });
            });
        } catch (ex:Dynamic) {
            this.log.warn("Unexpected error: " + ex);
        }

        #if flash
        haxe.Timer.delay(packetBufferCleaner, BUFFER_CLEANER_LOOP_PAUSE);
        #else
        Sys.sleep(0.016); // 16ms
        }
        #end
    }

    public function getPacketBufferSize():Int {
        return packetBufferLock.execute(function() {
            var size = 0;
            for (k in this.packetBuffer.keys()) size++;
            return size;
        });
    }

    public function getFragBufferSize():Int {
        return this.fragManager.getFragBufferSize();
    }

    public function getUnAckedIds():Array<Int> {
        return unAckedLock.execute(function() {
            return [for (k in this.unAckedById.keys()) k];
        });
    }

    public function getBufferDump():Array<String> {
        return packetBufferLock.execute(function() {
            var arr = [];
            for (v in this.packetBuffer.iterator()) arr.push(v.toString());
            return arr;
        });
    }

    public function getUnAckedDump():Array<String> {
        return unAckedLock.execute(function() {
            var arr = [];
            for (v in this.unAckedById.iterator()) arr.push(v.toString());
            return arr;
        });
    }

    public function getFragBufferDump():Array<String> {
        return this.fragManager.getFragBufferDump();
    }
}
