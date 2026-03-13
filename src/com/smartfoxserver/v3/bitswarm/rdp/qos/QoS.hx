package com.smartfoxserver.v3.bitswarm.rdp.qos;

import com.smartfoxserver.v3.bitswarm.rdp.TransportConfig;

enum QoS {
    FAST_DELIVERY;
    BEST_EFFORT;
    RESILIENT;
    HIGH_RELIABILITY;
}

class QoSHelper {
    public static function getCfg(qos:QoS):TransportConfig {
        return switch (qos) {
            case FAST_DELIVERY: new FastDelivery();
            case BEST_EFFORT: new BestEffort();
            case RESILIENT: new Resilient();
            case HIGH_RELIABILITY: new HighReliability();
        };
    }
}
