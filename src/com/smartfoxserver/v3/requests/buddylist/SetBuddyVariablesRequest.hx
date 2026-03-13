package com.smartfoxserver.v3.requests.buddylist;

import com.smartfoxserver.v3.entities.data.ISFSArray;
import com.smartfoxserver.v3.entities.data.SFSArray;

import com.smartfoxserver.v3.ISmartFox;
import com.smartfoxserver.v3.exceptions.SFSValidationException;
import com.smartfoxserver.v3.entities.variables.BuddyVariable;
import com.smartfoxserver.v3.requests.BaseRequest;

/**
 * Sets one or more Buddy Variables for the current user.
 * <p/>
 * <p>This operation updates the <em>Buddy</em> object representing the user in all the buddies lists in which the user was added as a buddy.
 * If the operation is successful, a <em>buddyVariablesUpdate</em> event is dispatched to all the owners of those buddies lists and to the user who updated his variables too.</p>
 * <p/>
 * <p><b>NOTE</b>: this request can be sent if the Buddy List system was previously initialized only (see the <em>InitBuddyListRequest</em> request description)
 * and the current user state in the system is "online".</p>
 * <p/>
 * <p/>
 *
 * @see		com.smartfoxserver.v3.entities.variables.BuddyVariable
 * @see		com.smartfoxserver.v3.core.SFSBuddyEvent#BUDDY_VARIABLES_UPDATE
 * @see		InitBuddyListRequest
 */

class SetBuddyVariablesRequest extends BaseRequest {
	/**
	 * @internal
	 */
	public static final KEY_BUDDY_NAME:String = "bn";
	
	/**
	 * @internal
	 */
	public static final KEY_BUDDY_VARS:String = "bv";

	private var buddyVariables:Array<BuddyVariable>;

	/**
	 * Creates a new <em>SetBuddyVariablesRequest</em> instance.
	 * The instance must be passed to the <em>SmartFox.send()</em> method for the request to be performed.
	 *
	 * @param	buddyVariables	A list of <em>BuddyVariable</em> objects representing the Buddy Variables to be set.
	 * 
	 * @see		com.smartfoxserver.v3.SmartFox#send
	 * @see		com.smartfoxserver.v3.entities.variables.BuddyVariable
	 */
	public function new(buddyVariables:Array<BuddyVariable>) {
		super(BaseRequest.SetBuddyVariables);
		this.buddyVariables = buddyVariables;
	}

	/**
	 * @internal
	 */
	public function validate(sfs:ISmartFox):Void {
		var errors = new Array<String>();

		if (!sfs.getBuddyManager().isInited()) {
			errors.push("BuddyList is not inited. Please send an InitBuddyRequest first");
		}

		if (!sfs.getBuddyManager().getMyOnlineState()) {
			errors.push("Can't set buddy variables while offline");
		}

		if (buddyVariables == null || buddyVariables.length == 0) {
			errors.push("No variables were specified");
		}

		if (errors.length > 0) {
			throw new SFSValidationException("SetBuddyVariables request error", errors);
		}
	}

	/**
	 * @internal
	 */
	public function execute(sfs:ISmartFox):Void {
		var varList:ISFSArray = new SFSArray();

		for (bVar in buddyVariables) {
			varList.addSFSArray(bVar.toSFSArray());
		}

		sfso.putSFSArray(KEY_BUDDY_VARS, varList);
	}
}
