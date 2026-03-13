package com.smartfoxserver.v3.bitswarm.rdp.qos;

class HighReliability extends ConfigPreset {
    public function new() {
        super(200, 50, 0.02, 200000, 1000, true);
    }
}
