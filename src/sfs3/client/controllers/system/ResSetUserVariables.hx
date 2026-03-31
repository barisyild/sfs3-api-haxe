package sfs3.client.controllers.system;

import sfs3.client.entities.data.ISFSArray;
import sfs3.client.entities.data.ISFSObject;
import sfs3.client.ISmartFox;
import sfs3.client.bitswarm.io.IResponse;
import sfs3.client.core.EventParam;
import sfs3.client.core.SFSEvent;
import sfs3.client.entities.User;
import sfs3.client.entities.variables.SFSUserVariable;
import sfs3.client.entities.variables.UserVariable;
import sfs3.client.requests.SetUserVariablesRequest;
import sfs3.client.entities.data.PlatformStringMap;

class ResSetUserVariables extends BaseResponseHandler
{
    public function new() {
        super();
    }

	public function handleResponse(sfs:ISmartFox, resp:IResponse):Void
	{
		var sfso:ISFSObject = resp.getContent();
		var evtParams = new PlatformStringMap<Dynamic>();

		var uId:Int = sfso.getInt(SetUserVariablesRequest.KEY_USER);
		var varListData:ISFSArray = sfso.getSFSArray(SetUserVariablesRequest.KEY_VAR_LIST);

		var user:User = sfs.getUserManager().getUserById(uId);
		var changedVarNames = new Array<String>();

		if (user != null)
		{
			for (j in 0...varListData.size())
			{
				var userVar:UserVariable = SFSUserVariable.fromSFSArray(varListData.getSFSArray(j));
				user.setVariable(userVar);
				changedVarNames.push(userVar.getName());
			}

			evtParams.set(EventParam.ChangedVars, changedVarNames);
			evtParams.set(EventParam.User, user);

			sfs.dispatchEvent(new SFSEvent(SFSEvent.USER_VARIABLES_UPDATE, evtParams));
		}

		else
			log.warn("UserVariablesUpdate: unknown user id = " + uId);
	}
}
