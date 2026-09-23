package sfs3.client.bitswarm.io;

#if (air || (openfl && !html5 && !flash))
typedef UdpClient = FlashUdpClient;
#elseif flash
typedef UdpClient = NullUdpClient;
#elseif nodejs
typedef UdpClient = NodeUdpClient;
#elseif js
typedef UdpClient = NullUdpClient;
#else
typedef UdpClient = SysUdpClient;
#end
