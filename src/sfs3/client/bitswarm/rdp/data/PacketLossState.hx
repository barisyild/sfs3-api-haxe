package sfs3.client.bitswarm.rdp.data;

class PacketLossState {
    public static var UNKNOWN = new PacketLossState("UNKNOWN");
    public static var NONE = new PacketLossState("NONE");
    public static var MINIMAL = new PacketLossState("MINIMAL");
    public static var MODERATE = new PacketLossState("MODERATE");
    public static var HIGH = new PacketLossState("HIGH");
    public static var SEVERE = new PacketLossState("SEVERE");

    public var name:String;

    private function new(name:String) {
        this.name = name;
    }

    public static function get(value:Float):PacketLossState {
        var result = UNKNOWN;
        if (value == 0) {
            result = NONE;
        } else if (value > 0 && value < 10) {
            result = MINIMAL;
        } else if (value >= 10 && value < 40) {
            result = MODERATE;
        } else if (value >= 40 && value < 70) {
            result = HIGH;
        } else if (value >= 70) {
            result = SEVERE;
        }
        return result;
    }

    public function toString():String {
        return name;
    }
}
