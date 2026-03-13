package com.smartfoxserver.v3.bitswarm.io;

import hx.concurrent.executor.Executor;

class ClientCoreConfig {
	public var ioHandler:IOHandler;
	public var threadPool:Executor;
	public var scheduler:Executor;

	public function new() {}
}
