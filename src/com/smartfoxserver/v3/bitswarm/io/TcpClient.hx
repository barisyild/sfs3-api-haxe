package com.smartfoxserver.v3.bitswarm.io;

#if flash
typedef TcpClient = FlashTcpClient;
#else
typedef TcpClient = SysTcpClient;
#end
