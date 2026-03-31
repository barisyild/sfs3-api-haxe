package sfs3.client.bitswarm.rdp.qos;

class FastDelivery extends ConfigPreset {
    public function new() {
        super(3, 50, 0.0, 0, 300, false);
    }
}
