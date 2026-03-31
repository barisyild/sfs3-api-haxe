package sfs3.client.bitswarm;
import sfs3.client.entities.data.ISFSObject;

interface IMessage
{
    public function getId():Int;
    public function setId(id:Int):Void;

    public function getContent():ISFSObject;
    public function setContent(obj:ISFSObject):Void;

    public function getTargetController():Int;
    public function setTargetController(targetController:Int):Void;

    public function isEncrypted():Bool;
    public function setEncrypted(encrypted:Bool):Void;

    public function getTransport():TransportType;
    public function setTransport(type:TransportType):Void;

//	long getPacketId();
//	void setPacketId(long packetId);
}
