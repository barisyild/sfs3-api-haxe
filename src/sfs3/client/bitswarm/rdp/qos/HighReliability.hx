package sfs3.client.bitswarm.rdp.qos;

class HighReliability extends ConfigPreset {
    public function new() {
        super(200, 50, 0.02, 200000, 1000, true);
    }
}
