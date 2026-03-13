package com.smartfoxserver.v3.controllers.system;

import com.smartfoxserver.v3.entities.data.ISFSArray;
import com.smartfoxserver.v3.entities.data.ISFSObject;
import com.smartfoxserver.v3.ISmartFox;
import com.smartfoxserver.v3.bitswarm.io.IResponse;
import com.smartfoxserver.v3.core.EventParam;
import com.smartfoxserver.v3.core.SFSEvent;
import com.smartfoxserver.v3.entities.User;
import com.smartfoxserver.v3.entities.variables.SFSUserVariable;
import com.smartfoxserver.v3.entities.variables.UserVariable;
import com.smartfoxserver.v3.requests.SetUserVariablesRequest;

class ResSetUserVariables extends BaseResponseHandler
{
    public function new() {
        super();
    }

	public function handleResponse(sfs:ISmartFox, resp:IResponse):Void
	{
		var sfso:ISFSObject = resp.getContent();
		var evtParams = new Map<String, Dynamic>();

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
