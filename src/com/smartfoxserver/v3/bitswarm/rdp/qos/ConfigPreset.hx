package com.smartfoxserver.v3.bitswarm.rdp.qos;

import com.smartfoxserver.v3.bitswarm.rdp.TransportConfig;

class ConfigPreset extends TransportConfig {
    public function new(mra:Int, rbt:Int, bom:Float, pbet:Int, mrcs:Int, disc:Bool) {
        super();
        this.maxRtxAttempts = mra;
        this.rtxBaseTimeout = rbt;
        this.backOffMultiplier = bom;
        this.packetBufferExpiryTime = pbet;
        this.packetBufferSize = this.unACKBufferSize = mrcs;
        this.triggerReliableErrors = disc;

        if (this.packetBufferExpiryTime == 0) {
            TransportConfig.computeRtxBufferTimeout(this);
        }
    }
}
