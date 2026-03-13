package com.smartfoxserver.v3.bitswarm.rdp.qos;

class Resilient extends ConfigPreset {
    public function new() {
        super(20, 50, 0.2, 0, 300, true);
    }
}
