package com.smartfoxserver.v3.bitswarm.io;

#if flash
typedef UdpClient = FlashUdpClient;
#else
typedef UdpClient = SysUdpClient;
#end
