package sfs3.client.bitswarm.rdp.data;

class EndPoint {
    public var channel:Dynamic;
    public var address:Dynamic;

    public function new(channel:Dynamic, address:Dynamic) {
        this.channel = channel;
        this.address = address;
    }

    public function toString():String {
        return address != null ? Std.string(address) : "null Address";
    }
}
