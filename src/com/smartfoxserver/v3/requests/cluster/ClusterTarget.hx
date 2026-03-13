package com.smartfoxserver.v3.requests.cluster;

/**
 * Represents a target Room on a Cluster Game Node
 */
class ClusterTarget
{
	private var serverId:String; 
	private var roomId:Int;
	
	/**
	 * Represents a target Room on a Cluster Game Node
	 * 
	 * @param serverId	the id of the server hosting the Room
	 * @param roomId	the Room id that will be joined
	 * 
	 * @see com.smartfoxserver.v3.SmartFox#getNodeId()
	 */
	public function new(serverId:String, roomId:Int)
	{
		this.serverId = serverId;
		this.roomId = roomId;
	}
	
	/**
	 * @return the id of the target server
	 */
	public function getServerId():String
	{
		return serverId;
	}
	
	/**
	 * @return the id of the target Room to join
	 */
	public function getRoomId():Int
	{
		return roomId;
	}
}
