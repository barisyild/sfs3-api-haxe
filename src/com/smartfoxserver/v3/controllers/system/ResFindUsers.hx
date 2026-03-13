package com.smartfoxserver.v3.controllers.system;

import com.smartfoxserver.v3.entities.data.ISFSArray;
import com.smartfoxserver.v3.entities.data.ISFSObject;
import com.smartfoxserver.v3.ISmartFox;
import com.smartfoxserver.v3.bitswarm.io.IResponse;
import com.smartfoxserver.v3.core.EventParam;
import com.smartfoxserver.v3.core.SFSEvent;
import com.smartfoxserver.v3.entities.SFSUser;
import com.smartfoxserver.v3.entities.User;
import com.smartfoxserver.v3.requests.FindUsersRequest;

class ResFindUsers extends BaseResponseHandler
{
    public function new() {
        super();
    }

	public function handleResponse(sfs:ISmartFox, resp:IResponse):Void
	{
		var sfso:ISFSObject = resp.getContent();
		var evtParams = new Map<String, Dynamic>();

		var userListData:ISFSArray = sfso.getSFSArray(FindUsersRequest.KEY_FILTERED_USERS);
		var userList = new Array<User>();
		var mySelf:User = sfs.getMySelf();

		for (i in 0...userListData.size())
		{
			var u:User = SFSUser.fromSFSArray(userListData.getSFSArray(i));

			/*
			 * Since 0.9.6 Swap the original object, this way we have the isItMe flag
			 * correctly populated
			 */
			if (u.getId() == mySelf.getId())
				u = mySelf;

			userList.push(u);
		}

		evtParams.set(EventParam.UserList, userList);
		sfs.dispatchEvent(new SFSEvent(SFSEvent.USER_FIND_RESULT, evtParams));
	}
}
