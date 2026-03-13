package com.smartfoxserver.v3.controllers.system;

import com.smartfoxserver.v3.entities.data.ISFSObject;
import com.smartfoxserver.v3.ISmartFox;
import com.smartfoxserver.v3.bitswarm.io.IResponse;
import com.smartfoxserver.v3.core.EventParam;
import com.smartfoxserver.v3.core.SFSEvent;
import com.smartfoxserver.v3.entities.Room;
import com.smartfoxserver.v3.entities.User;
import com.smartfoxserver.v3.requests.BaseRequest;
import com.smartfoxserver.v3.requests.PlayerToSpectatorRequest;
import com.smartfoxserver.v3.util.SFSErrorCodes;

class ResPlayerToSpectator extends BaseResponseHandler
{
    public function new() {
        super();
    }

	public function handleResponse(sfs:ISmartFox, resp:IResponse):Void
	{
		var sfso:ISFSObject = resp.getContent();
		var evtParams = new Map<String, Dynamic>();

		// ::: SUCCESS
		// ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
		if (!sfso.containsKey(BaseRequest.KEY_ERROR_CODE))
		{
			// Obtain the target Room
			var roomId:Int = sfso.getInt(PlayerToSpectatorRequest.KEY_ROOM_ID);
			var userId:Int = sfso.getInt(PlayerToSpectatorRequest.KEY_USER_ID);

			var user:User = sfs.getUserManager().getUserById(userId);
			var targetRoom:Room = sfs.getRoomManager().getRoomById(roomId);

			if (targetRoom != null)
			{
				if (user != null)
				{
					if (user.isJoinedInRoom(targetRoom))
					{
						// Update the playerId
						user.setPlayerId(-1, targetRoom);

						evtParams.set(EventParam.Room, targetRoom); // where it happened
						evtParams.set(EventParam.User, user); // who did it

						sfs.dispatchEvent(new SFSEvent(SFSEvent.PLAYER_TO_SPECTATOR, evtParams));
					}
					else
						log.warn("User: " + user + " not joined in Room: " + targetRoom.getName() + ", PlayerToSpectator failed");
				}
				else
					log.warn("User not found, ID: " + userId + ", PlayerToSpectator failed");
			}
			else
				log.warn("Room not found, ID: " + roomId + ", PlayerToSpectator failed");
		}

		// ::: FAILURE
		// :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
		else
		{
			var errorCode:Int = sfso.getShort(BaseRequest.KEY_ERROR_CODE);
			var errorMsg:String = SFSErrorCodes.getErrorMessage(errorCode, sfso.getStringArray(BaseRequest.KEY_ERROR_PARAMS));
			evtParams.set(EventParam.ErrorMessage, errorMsg);
			evtParams.set(EventParam.ErrorCode, errorCode);

			sfs.dispatchEvent(new SFSEvent(SFSEvent.PLAYER_TO_SPECTATOR_ERROR, evtParams));
		}
	}
}
