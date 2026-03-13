package com.smartfoxserver.v3.bitswarm.rdp.qos;

class BestEffort extends ConfigPreset {
    public function new() {
        super(5, 50, 0.4, 0, 300, false);
    }
}
