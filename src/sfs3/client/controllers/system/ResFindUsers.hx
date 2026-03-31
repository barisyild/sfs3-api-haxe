package sfs3.client.controllers.system;

import sfs3.client.entities.data.ISFSArray;
import sfs3.client.entities.data.ISFSObject;
import sfs3.client.ISmartFox;
import sfs3.client.bitswarm.io.IResponse;
import sfs3.client.core.EventParam;
import sfs3.client.core.SFSEvent;
import sfs3.client.entities.SFSUser;
import sfs3.client.entities.User;
import sfs3.client.requests.FindUsersRequest;
import sfs3.client.entities.data.PlatformStringMap;

class ResFindUsers extends BaseResponseHandler
{
    public function new() {
        super();
    }

	public function handleResponse(sfs:ISmartFox, resp:IResponse):Void
	{
		var sfso:ISFSObject = resp.getContent();
		var evtParams = new PlatformStringMap<Dynamic>();

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
