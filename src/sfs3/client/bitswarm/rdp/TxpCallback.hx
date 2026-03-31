package sfs3.client.bitswarm.rdp;

import sfs3.client.bitswarm.rdp.data.EndPoint;
import haxe.io.Bytes;

typedef TxpCallback = Bytes -> EndPoint -> TxpMode -> Void;
