package sfs3.client.requests;

import sfs3.client.entities.data.ISFSArray;
import sfs3.client.entities.data.SFSArray;

import sfs3.client.ISmartFox;
import sfs3.client.exceptions.SFSValidationException;
import sfs3.client.entities.variables.UserVariable;

/**
 * Sets one or more custom User Variables for the current user.
 * <p/>
 * <p>When a User Variable is set, the <em>userVariablesUpdate</em> event is dispatched to all the users in all the Rooms joined by the current user, including himself.</p>
 * <p/>
 * <p><b>NOTE</b>: the <em>userVariablesUpdate</em> event is dispatched to users in a specific Room only if it is configured to allow this event (see the <em>RoomSettings.permissions</em> parameter).</p>
 * <p/>
 * <p/>
 *
 * @see		sfs3.client.core.SFSEvent#USER_VARIABLES_UPDATE
 * @see		sfs3.client.requests.RoomSettings#getPermissions()
 */
@:expose("SFS3.SetUserVariablesRequest")
class SetUserVariablesRequest extends BaseRequest 
{
	/**
	 * @internal
	 */
	public static final KEY_USER:String = "u";

	/**
	 * @internal
	 */
	public static final KEY_VAR_LIST:String = "vl";

	private var userVariables:Array<UserVariable>;

	/**
	 * Creates a new <em>SetUserVariablesRequest</em> instance.
	 * The instance must be passed to the <em>SmartFox.send()</em> method for the request to be performed.
	 *
	 * @param	userVariables	A list of <em>UserVariable</em> objects representing the User Variables to be set.
	 * 
	 * @see		sfs3.client.SmartFox#send
	 * @see		sfs3.client.entities.variables.UserVariable
	 */
	public function new(userVariables:Array<UserVariable>) 
	{
		super(BaseRequest.SetUserVariables);
		this.userVariables = userVariables;
	}

	/**
	 * @internal
	 */
	public function validate(sfs:ISmartFox):Void
	{
		var errors = new Array<String>();

		if (userVariables == null || userVariables.length == 0)
			errors.push("No variables were specified");

		if (errors.length > 0)
			throw new SFSValidationException("SetUserVariables request error", errors);
	}

	/**
	 * @internal
	 */
	public function execute(sfs:ISmartFox):Void
	{
		var varList:ISFSArray = new SFSArray();

		for (uVar in userVariables) 
		{
			varList.addSFSArray(uVar.toSFSArray());
		}

		sfso.putSFSArray(KEY_VAR_LIST, varList);
	}
}
