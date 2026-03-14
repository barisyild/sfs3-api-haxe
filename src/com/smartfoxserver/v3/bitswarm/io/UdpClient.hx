package com.smartfoxserver.v3.bitswarm.io;

#if (flash || openfl)
typedef UdpClient = FlashUdpClient;
#elseif nodejs
typedef UdpClient = NodeUdpClient;
#elseif js
typedef UdpClient = NullUdpClient;
#else
typedef UdpClient = SysUdpClient;
#end
