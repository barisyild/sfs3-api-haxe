package com.smartfoxserver.v3.bitswarm.rdp;

import com.smartfoxserver.v3.bitswarm.rdp.data.EndPoint;
import haxe.io.Bytes;

typedef TxpCallback = Bytes -> EndPoint -> TxpMode -> Void;
