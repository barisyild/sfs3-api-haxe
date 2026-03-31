package sfs3.client.controllers.system;

import sfs3.client.entities.data.ISFSObject;
import sfs3.client.exceptions.SFSException;
import sfs3.client.ISmartFox;
import sfs3.client.bitswarm.io.IResponse;
import sfs3.client.core.EventParam;
import sfs3.client.core.SFSBuddyEvent;
import sfs3.client.core.SFSEvent;
import sfs3.client.entities.Buddy;
import sfs3.client.entities.Room;
import sfs3.client.entities.SFSUser;
import sfs3.client.entities.User;
import sfs3.client.requests.GenericMessageRequest;
import sfs3.client.requests.GenericMessageType;
import sfs3.client.entities.data.PlatformStringMap;

class ResGenericMessage extends BaseResponseHandler
{
	private var sfs:ISmartFox;

    public function new() {
        super();
    }

	public function handleResponse(sfs:ISmartFox, resp:IResponse):Void
	{
		this.sfs = sfs;

		var sfso:ISFSObject = resp.getContent();
		var msgType:Int = sfso.getByte(GenericMessageRequest.KEY_MESSAGE_TYPE);

		if (msgType == GenericMessageType.PUBLIC_MSG)
			handlePublicMessage(sfso);

		else if (msgType == GenericMessageType.PRIVATE_MSG)
			handlePrivateMessage(sfso);

		else if (msgType == GenericMessageType.BUDDY_MSG)
			handleBuddyMessage(sfso);
		
		else if (msgType == GenericMessageType.MODERATOR_MSG)
			handleModMessageEvent(sfso, SFSEvent.MODERATOR_MESSAGE);

		else if (msgType == GenericMessageType.ADMIN_MSG)
			handleModMessageEvent(sfso, SFSEvent.ADMIN_MESSAGE);

		else if (msgType == GenericMessageType.OBJECT_MSG)
			handleObjectMessage(sfso);
	}

	private function handlePublicMessage(sfso:ISFSObject):Void
	{
		var evtParams = new PlatformStringMap<Dynamic>();

		var rId:Int = sfso.getInt(GenericMessageRequest.KEY_ROOM_ID);
		var room:Room = sfs.getRoomManager().getRoomById(rId);

		if (room != null)
		{
			evtParams.set(EventParam.Room, room);
			evtParams.set(EventParam.Sender, sfs.getUserManager().getUserById(sfso.getInt(GenericMessageRequest.KEY_USER_ID)));
			evtParams.set(EventParam.Message, sfso.getString(GenericMessageRequest.KEY_MESSAGE));
			evtParams.set(EventParam.Data, sfso.getSFSObject(GenericMessageRequest.KEY_XTRA_PARAMS));

			// Fire event
			sfs.dispatchEvent(new SFSEvent(SFSEvent.PUBLIC_MESSAGE, evtParams));
		}
		else
			log.warn("Unexpected, PublicMessage target room doesn't exist. RoomId: " + rId);
	}

	private function handlePrivateMessage(sfso:ISFSObject):Void
	{
		var evtParams = new PlatformStringMap<Dynamic>();
		var senderId:Int = sfso.getInt(GenericMessageRequest.KEY_USER_ID);

		// See if user exists locally
		var sender:User = sfs.getUserManager().getUserById(senderId);

		// Not found locally, see if user details where passed by the Server
		if (sender == null)
		{
			if (!sfso.containsKey(GenericMessageRequest.KEY_SENDER_DATA))
			{
				log.warn("Unexpected. Private message has no Sender details!");
				return;
			}

			sender = SFSUser.fromSFSArray(sfso.getSFSArray(GenericMessageRequest.KEY_SENDER_DATA));
		}
		
		evtParams.set(EventParam.Sender, sender);
		evtParams.set(EventParam.Message, sfso.getString(GenericMessageRequest.KEY_MESSAGE));
		evtParams.set(EventParam.Data, sfso.getSFSObject(GenericMessageRequest.KEY_XTRA_PARAMS));

		// Fire event
		sfs.dispatchEvent(new SFSEvent(SFSEvent.PRIVATE_MESSAGE, evtParams));
	}

	private function handleBuddyMessage(sfso:ISFSObject):Void
	{
		var evtParams = new PlatformStringMap<Dynamic>();
		var senderId:Int = sfso.getInt(GenericMessageRequest.KEY_USER_ID);

		var senderBuddy:Buddy = sfs.getBuddyManager().getBuddyById(senderId);

		evtParams.set(EventParam.IsItMe, sfs.getMySelf().getId() == senderId);
		evtParams.set(EventParam.Buddy, senderBuddy);
		evtParams.set(EventParam.Message, sfso.getString(GenericMessageRequest.KEY_MESSAGE));
		evtParams.set(EventParam.Data, sfso.getSFSObject(GenericMessageRequest.KEY_XTRA_PARAMS));

		// Fire event
		sfs.dispatchEvent(new SFSBuddyEvent(SFSBuddyEvent.BUDDY_MESSAGE, evtParams));
	}

	private function handleModMessageEvent(sfso:ISFSObject, evt:String):Void
	{
		var evtParams = new PlatformStringMap<Dynamic>();

		evtParams.set(EventParam.Sender, SFSUser.fromSFSArray(sfso.getSFSArray(GenericMessageRequest.KEY_SENDER_DATA)));
		evtParams.set(EventParam.Message, sfso.getString(GenericMessageRequest.KEY_MESSAGE));
		evtParams.set(EventParam.Data, sfso.getSFSObject(GenericMessageRequest.KEY_XTRA_PARAMS));

		// Fire event
		sfs.dispatchEvent(new SFSEvent(evt, evtParams));
	}

	private function handleObjectMessage(sfso:ISFSObject):Void
	{
		var evtParams = new PlatformStringMap<Dynamic>();
		var senderId:Int = sfso.getInt(GenericMessageRequest.KEY_USER_ID);

		evtParams.set(EventParam.Sender, sfs.getUserManager().getUserById(senderId));
		evtParams.set(EventParam.Message, sfso.getSFSObject(GenericMessageRequest.KEY_XTRA_PARAMS));

		// Fire event
		sfs.dispatchEvent(new SFSEvent(SFSEvent.OBJECT_MESSAGE, evtParams));
	}
}
