package sfs3.client.controllers.system;

import sfs3.client.entities.data.ISFSObject;
import sfs3.client.ISmartFox;
import sfs3.client.bitswarm.io.IResponse;
import sfs3.client.core.EventParam;
import sfs3.client.core.SFSEvent;
import sfs3.client.entities.Room;
import sfs3.client.entities.User;
import sfs3.client.requests.BaseRequest;
import sfs3.client.requests.SpectatorToPlayerRequest;
import sfs3.client.util.SFSErrorCodes;
import sfs3.client.entities.data.PlatformStringMap;

class ResSpectatorToPlayer extends BaseResponseHandler
{
    public function new() {
        super();
    }

	public function handleResponse(sfs:ISmartFox, resp:IResponse):Void
	{
		var sfso:ISFSObject = resp.getContent();
		var evtParams = new PlatformStringMap<Dynamic>();

		// ::: SUCCESS
		if (!sfso.containsKey(BaseRequest.KEY_ERROR_CODE))
		{
			// Obtain the target Room
			var roomId:Int = sfso.getInt(SpectatorToPlayerRequest.KEY_ROOM_ID);
			var userId:Int = sfso.getInt(SpectatorToPlayerRequest.KEY_USER_ID);
			var playerId:Int = sfso.getShort(SpectatorToPlayerRequest.KEY_PLAYER_ID);

			var user:User = sfs.getUserManager().getUserById(userId);
			var targetRoom:Room = sfs.getRoomManager().getRoomById(roomId);

			if (targetRoom != null)
			{
				if (user != null)
				{
					if (user.isJoinedInRoom(targetRoom))
					{
						// Update the playerId
						user.setPlayerId(playerId, targetRoom);

						evtParams.set(EventParam.Room, targetRoom); // where it happened
						evtParams.set(EventParam.User, user); // who did it
						evtParams.set(EventParam.PlayerId, playerId); // the new playerId

						sfs.dispatchEvent(new SFSEvent(SFSEvent.SPECTATOR_TO_PLAYER, evtParams));
					}
					else
						log.warn("User: " + user.getName() + " not joined in Room: " + targetRoom.getName() + ", SpectatorToPlayer failed");
				}
				else
					log.warn("User not found, ID:" + userId + ", SpectatorToPlayer failed");
			}

			else
				log.warn("Room not found, ID:" + roomId + ", SpectatorToPlayer failed");
		}

		// ::: FAILURE
		else
		{
			var errorCode:Int = sfso.getShort(BaseRequest.KEY_ERROR_CODE);
			var errorMsg:String = SFSErrorCodes.getErrorMessage(errorCode, sfso.getStringArray(BaseRequest.KEY_ERROR_PARAMS));
			evtParams.set(EventParam.ErrorMessage, errorMsg);
			evtParams.set(EventParam.ErrorCode, errorCode);

			sfs.dispatchEvent(new SFSEvent(SFSEvent.SPECTATOR_TO_PLAYER_ERROR, evtParams));
		}
	}
}
