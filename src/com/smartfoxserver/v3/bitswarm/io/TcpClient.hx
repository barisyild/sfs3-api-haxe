package com.smartfoxserver.v3.bitswarm.io;

#if (flash || openfl)
typedef TcpClient = FlashTcpClient;
#elseif nodejs
typedef TcpClient = NodeTcpClient;
#elseif js
typedef TcpClient = NullTcpClient;
#else
typedef TcpClient = SysTcpClient;
#end
