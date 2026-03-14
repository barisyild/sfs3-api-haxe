package com.smartfoxserver.v3.bitswarm.io;

#if (!flash && !js)
import com.smartfoxserver.v3.ConfigData;
import com.smartfoxserver.v3.bitswarm.BitSwarmClient;
import com.smartfoxserver.v3.bitswarm.SocketState;
import com.smartfoxserver.v3.bitswarm.TransportType;
import com.smartfoxserver.v3.core.EventParam;
import com.smartfoxserver.v3.util.ClientDisconnectionReason;
import haxe.Exception;
import haxe.io.Bytes;
import sys.net.Host;
import sys.net.Socket;
import com.smartfoxserver.v3.entities.data.Queue;


class SysTcpClient extends BaseSocketClient {
	private static final READ_BUFF_SIZE:Int = 8192;

	private var outPacketQ:Queue<Bytes>;
	private var tcpSocket:Socket;
	private var serverHost:String;
	private var serverPort:Int;
	private var cfg:ConfigData;

	public function new(bitSwarm:BitSwarmClient) {
		super(bitSwarm);
		outPacketQ = new Queue<Bytes>();
		cfg = bitSwarm.getSmartFox().getConfig();
	}

	public function connect(host:String, port:Int, timeoutMillis:Int = 0):Void {
		if (socketState != SocketState.Disconnected)
			throw new Exception("Can't connect now, current state is: " + Std.string(socketState));

		this.serverHost = host;
		this.serverPort = port;

		socketState = SocketState.Connecting;

		try {
			tcpSocket = new Socket();
			tcpSocket.setBlocking(true);

			if (timeoutMillis > 0)
				tcpSocket.setTimeout(timeoutMillis / 1000.0);

			tcpSocket.connect(new Host(host), port);
			socketState = SocketState.Connected;

			// Start reader / writer via thread pool executor
			threadPool.submit(function():Void {
				readLoop();
			});
			threadPool.submit(function():Void {
				writeLoop();
			});

			// Connection success event
			var evt = new SocketEvent(SocketEvent.Connected);
			evtDispatcher.dispatchEvent(evt);
		} catch (ex:Exception) {
			socketState = SocketState.Disconnected;

			log.warn("Connection to " + serverHost + ":" + serverPort + " failed -- Cause: " + ex.message);

			// Connection failure event
			var evt = new SocketEvent(SocketEvent.Error);
			evt.getParams().set(EventParam.ErrorMessage, ex.message);
			evtDispatcher.dispatchEvent(evt);
		}
	}

	override public function destroy(params:Dynamic):Void {
		super.destroy(params);

		closeSocket();

		// Remove all listeners
		evtDispatcher.removeAll();
	}

	public function disconnect(reason:String = "Manual", errMessage:String = null):Void {
		if (socketState == SocketState.Disconnected)
			throw new Exception("TCP connection is already closed");

		closeSocket();

		var params = new Map<String, Dynamic>();
		params.set(EventParam.DisconnectionReason, reason);
		params.set(EventParam.ErrorMessage, errMessage);

		evtDispatcher.dispatchEvent(new SocketEvent(SocketEvent.Disconnected, params));
	}

	/*
	 * Simulates an unexpected disconnection, by shutting down the tcp socket abruptly.
	 * Useful to test the reconnection system.
	 */
	public function kill():Void {
		try {
			tcpSocket.close();
		} catch (ex:Exception) {
			log.warn("Unexpected socket error", ex);
		}
	}

	/*
	 * Add to the outgoing packet queue
	 */
	public function write(data:Bytes, txType:TransportType = null):Void {
		outPacketQ.push(data);
	}

	// -----------------------------------------------------------------------------------------------------------------------------
	// -----------------------------------------------------------------------------------------------------------------------------

	/*
	 * Blocking I/O
	 * Runs concurrently via Executor thread pool
	 */
	private function readLoop():Void {
		var readBuff = Bytes.alloc(READ_BUFF_SIZE);

		while (socketState == SocketState.Connected) {
			try {
				var readBytes = tcpSocket.input.readBytes(readBuff, 0, READ_BUFF_SIZE);

				// Check for a disconnection
				if (readBytes <= 0)
					throw new Exception("Connection closed unexpectedly");

				var data = readBuff.sub(0, readBytes);

				var evt = new SocketEvent(SocketEvent.DataReceived);
				evt.getParams().set(EventParam.Data, data);
				evtDispatcher.dispatchEvent(evt);
			} catch (ex:haxe.io.Eof) {
				log.warn("TCP Read: Connection closed (EOF), State: " + Std.string(socketState));

				if (socketState != SocketState.Disconnected)
					disconnect(ClientDisconnectionReason.UNKNOWN, "Connection closed by remote host");
			} catch (ex:Exception) {
				log.warn("TCP Read Error: " + ex.message + ", State: " + Std.string(socketState));

				/*
				 * ------
				 * NOTE:
				 * ------
				 *  This exception can be caused both by a manual disconnection as well as
				 *  by an external error. In the first case we get here in 'Disconnected' state
				 *  and we need to avoid re-triggering the disconnection.
				 *
				 *  In the second case (external disconnection) we need to trigger the
				 *  disconnection event
				 */
				if (socketState != SocketState.Disconnected)
					disconnect(ClientDisconnectionReason.UNKNOWN, ex.message);
			}
		}

		log.info("Exiting TCP Read Loop");
	}

	/*
	 * Blocking I/O
	 * Runs concurrently via Executor thread pool
	 */
	private function writeLoop():Void {
		while (socketState == SocketState.Connected) {
			try {
				// blocks for up to 100ms waiting for a message, then retries loop condition
				var packet:Null<Bytes> = outPacketQ.pop();

				if (packet == null)
					continue;

				/*
				 *  Handle signal to exit the loop, this is triggered by the destroy method
				 *  @see destroy()
				 */
				if (packet.length == 0)
					break;

				// Write all bytes to the socket
				var pos = 0;
				var remaining = packet.length;

				while (remaining > 0) {
					var written = tcpSocket.output.writeBytes(packet, pos, remaining);
					pos += written;
					remaining -= written;
				}
				tcpSocket.output.flush();
			} catch (ex:Exception) {
				log.warn("TCP Write Error: " + ex.message + ", State: " + Std.string(socketState));

				if (socketState != SocketState.Disconnected)
					disconnect(ClientDisconnectionReason.UNKNOWN, ex.message);
			}
		}

		log.info("Exiting TCP Write Loop");
	}

	/*
	 * Closing the socket implies that the read-loop will be interrupted
	 * because the socket itself will throw an Exception and exit the cycle.
	 *
	 * However the write-loop would still be stuck on the write queue waiting for data.
	 * We must forcefully wake-up the thread to signal that it's time to quit.
	 */
	private function closeSocket():Void {
		socketState = SocketState.Disconnected;

		try {
			if (tcpSocket != null) {
				tcpSocket.close();
				log.info("TCP Socket closed");
			}

			/*
			 *  We send an empty Bytes to the write queue to signal that it's time to exit the loop
			 */
			outPacketQ.push(Bytes.alloc(0));
		} catch (ex:Exception) {
			log.warn("Error closing TCP socket", ex);
		}
	}
}
#end
