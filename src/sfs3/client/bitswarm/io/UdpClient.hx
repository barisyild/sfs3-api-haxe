package sfs3.client.bitswarm.io;

#if (flash || (openfl && !html5))
typedef UdpClient = FlashUdpClient;
#elseif nodejs
typedef UdpClient = NodeUdpClient;
#elseif js
typedef UdpClient = NullUdpClient;
#else
typedef UdpClient = SysUdpClient;
#end
