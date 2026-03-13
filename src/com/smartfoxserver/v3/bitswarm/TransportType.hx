package com.smartfoxserver.v3.bitswarm;
import com.smartfoxserver.v3.bitswarm.rdp.TxpMode;


enum TransportType {
    TCP;
    UDP;
    UDP_RELIABLE;
    UDP_UNRELIABLE;
}

class TransportTypeTools {
    /*
     * From RDP Transport --> Client API Transport
     */
    public static function toRdpMode(txType:TransportType):TxpMode {
        return switch(txType) {
            case UDP: RAW_UDP;
            case UDP_UNRELIABLE: UNRELIABLE_ORDERED;
            case UDP_RELIABLE: RELIABLE_ORDERED;
            default: throw "Unsupported transport: " + txType;
        }
    }

    /*
	 * From Client API Transport --> RDP Transport
	 */
    public static function fromRdpMode(mode:TxpMode):TransportType {
        return switch(mode) {
            case RAW_UDP: UDP;
            case UNRELIABLE_ORDERED: UDP_UNRELIABLE;
            case RELIABLE_ORDERED: UDP_RELIABLE;
            default: throw "Unsupported mode: " + mode;
        }
    }

    public static function isUDP(txType:TransportType):Bool {
        return switch(txType) {
            case UDP | UDP_RELIABLE | UDP_UNRELIABLE: true;
            case _: false;
        }
    }
}