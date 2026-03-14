package com.smartfoxserver.v3.core;

/**
 * <em>SFSBuddyEvent</em> is the class representing all the events related to the Buddy List system dispatched by
 * the SmartFoxServer 3 Java client API.
 * <p/>
 * <p>The <em>SFSBuddyEvent</em> parent class provides a public property called <em>params</em> containing different values depending on the event type.</p>
 *
 * @see SFSEvent
 */

@:expose("SFS3.SFSBuddyEvent")
class SFSBuddyEvent extends ApiEvent
{
    /**
	 * <p>Dispatched if the Buddy List system is successfully initialized. This event is fired in response to the <em>InitBuddyListRequest</em> request, when successful.<p/>
	 * <p>After the Buddy List system initialization, the user returns to its previous custom state (if any - see <em>IBuddyManager.myState property</em>).
	 * The online/offline state, nickname and persistent Buddy Variables are all loaded in the system. In particular, the online state (see <em>IBuddyManager.myOnlineState</em> property) determines if the user appears online or not to other users.</p>
	 *
	 * <p>The properties of the <em>arguments</em> object contained in the event object have the following values:</p>
	 * <table class="innertable">
	 * <tr><th>Property</th><th>Type</th><th>Description</th></tr>
	 * <tr><td>buddyList</td><td><em>List&lt;Buddy&gt;</em></td><td>A list of <em>Buddy</em> objects representing all the buddies in the current user's buddies list.</td></tr>
	 * <tr><td>myVariables</td><td><em>List&lt;BuddyVariable&gt;</em></td><td>A list of all the Buddy Variables associated with the current user.</td></tr>
	 * </table>
	 *
	 * @see		com.smartfoxserver.v3.requests.buddylist.InitBuddyListRequest
	 * @see		com.smartfoxserver.v3.entities.managers.IBuddyManager
	 * @see		com.smartfoxserver.v3.entities.Buddy
	 * @see		com.smartfoxserver.v3.entities.variables.BuddyVariable
	 * @see		#BUDDY_ERROR
	 */
    public static final BUDDY_LIST_INIT:String = "buddyListInit";


    /**
	 * <p>Dispatched when a buddy is added successfully to the user's buddies list.
	 * This event is fired in response to the <em>AddBuddyRequest</em> request.</p>
	 *
	 * <p>The properties of the <em>arguments</em> object contained in the event object have the following values:</p>
	 * <table class="innertable">
	 * <tr><th>Property</th><th>Type</th><th>Description</th></tr>
	 * <tr><td>buddy</td><td><em>Buddy</em></td><td>The <em>Buddy</em> object corresponding to the buddy that was added.</td></tr>
	 * </table>
	 *
	 * @see		com.smartfoxserver.v3.requests.buddylist.AddBuddyRequest
	 * @see		com.smartfoxserver.v3.entities.Buddy
	 * @see		#BUDDY_REMOVE
	 * @see		#BUDDY_ERROR
	 */
    public static final BUDDY_ADD:String = "buddyAdd";

    /**
	 * <p>Dispatched when a buddy is removed successfully from theuser's buddies list.
	 * This event is fired in response to the <em>RemoveBuddyRequest</em> request.</p>
	 *
	 * <p>The properties of the <em>arguments</em> object contained in the event object have the following values:</p>
	 * <table class="innertable">
	 * <tr><th>Property</th><th>Type</th><th>Description</th></tr>
	 * <tr><td>buddy</td><td><em>Buddy</em></td><td>The <em>Buddy</em> object corresponding to the buddy that was removed.</td></tr>
	 * </table>
	 *
	 * @see		com.smartfoxserver.v3.requests.buddylist.RemoveBuddyRequest
	 * @see		com.smartfoxserver.v3.entities.Buddy
	 * @see		#BUDDY_ADD
	 * @see		#BUDDY_ERROR
	 */
    public static final BUDDY_REMOVE:String = "buddyRemove";

    /**
	 * <p>Dispatched when a buddy is blocked or unblocked by the current user.
	 * This event is fired in response to the <em>BlockBuddyRequest</em> request.</p>
	 *
	 * <p>The properties of the <em>arguments</em> object contained in the event object have the following values:</p>
	 * <table class="innertable">
	 * <tr><th>Property</th><th>Type</th><th>Description</th></tr>
	 * <tr><td>buddy</td><td><em>Buddy</em></td><td>The <em>Buddy</em> object corresponding to the buddy that was blocked/unblocked.</td></tr>
	 * </table>
	 *
	 * @see		com.smartfoxserver.v3.requests.buddylist.BlockBuddyRequest
	 * @see		com.smartfoxserver.v3.entities.Buddy
	 * @see		#BUDDY_ERROR
	 */
    public static final BUDDY_BLOCK:String = "buddyBlock";

    /**
	 * <p>Dispatched if an error occurs while executing a request related to the Buddy List system.
	 * For example, this event is fired in response to a <em>AddBuddyRequest</em> request, the <em>BlockBuddyRequest</em>, in case they don't succeed.</p>
	 *
	 * <p>The properties of the <em>arguments</em> object contained in the event object have the following values:</p>
	 * <table class="innertable">
	 * <tr><th>Property</th><th>Type</th><th>Description</th></tr>
	 * <tr><td>errorMessage</td><td><em>String</em></td><td>The message which describes the error.</td></tr>
	 * <tr><td>errorCode</td><td><em>short</em></td><td>The error code.</td></tr>
	 * </table>
	 *
	 * @see		#BUDDY_ADD
	 */
    public static final BUDDY_ERROR:String = "buddyError";

    /**
	 * <p>Dispatched when a buddy in the current user's buddy list changes its online state.
	 * This event is fired in response to the <em>GoOnlineRequest request.</em></p>
	 * <p><b>NOTE:</b> this event is dispatched to those who have the user as buddy, but also to the user itself.
	 * If the latter, the value of the <em>buddy</em> parameter is <code>null</code>, the <em>isItMe</em> parameter should be used to check if the current user was the request sender.</p>
	 *
	 * <p>The properties of the <em>arguments</em> object contained in the event object have the following values:</p>
	 * <table class="innertable">
	 * <tr><th>Property</th><th>Type</th><th>Description</th></tr>
	 * <tr><td>buddy</td><td><em>Buddy</em></td><td>The <em>Buddy</em> the buddy who changed the online state. </td></tr>
	 * <tr><td>isItMe</td><td><em>Boolean</em></td><td><code>true</code> if the online state was changed by the current user</td></tr>
	 * </table>
	 *
	 * @see		com.smartfoxserver.v3.requests.buddylist.GoOnlineRequest
	 * @see		com.smartfoxserver.v3.entities.Buddy
	 */
    public static final BUDDY_ONLINE_STATE_CHANGE:String = "buddyOnlineStateChange";

    /**
	 * <p>Dispatched when a buddy (in the current buddy list) updates one or more Buddy Variables.
	 * This event is fired in response to the <em>SetBuddyVariablesRequest</em> request.</p>
	 *
	 * <p>The properties of the <em>arguments</em> object contained in the event object have the following values:</p>
	 * <table class="innertable">
	 * <tr><th>Property</th><th>Type</th><th>Description</th></tr>
	 * <tr><td>buddy</td><td><em>Buddy</em></td><td>The <em>Buddy</em> the buddy who updated the Variables. </td></tr>
	 * <tr><td>isItMe</td><td><em>Boolean</em></td><td><code>true</code> if the Buddy Variables were updated by the current user itself</td></tr>
	 * <tr><td>changedVars</td><td><em>List&lt;BuddyVariable&gt;</em></td><td>The list of Buddy Variable names that were created or changed.</td></tr>
	 * </table>
	 *
	 * @see		com.smartfoxserver.v3.requests.buddylist.SetBuddyVariablesRequest
	 * @see		com.smartfoxserver.v3.entities.variables.BuddyVariable
	 * @see		com.smartfoxserver.v3.entities.Buddy
	 */
    public static final BUDDY_VARIABLES_UPDATE:String = "buddyVariablesUpdate";

    /**
	 * <p>Dispatched when a message from a buddy is received by the current user.
	 * This event is fired in response to the <em>BuddyMessageRequest</em> request.</p>
	 *
	 * <p>The properties of the <em>arguments</em> object contained in the event object have the following values:</p>
	 * <table class="innertable">
	 * <tr><th>Property</th><th>Type</th><th>Description</th></tr>
	 * <tr><td>buddy</td><td><em>Buddy</em></td><td>The <em>Buddy</em> that sent the message. </td></tr>
	 * <tr><td>isItMe</td><td><em>Boolean</em></td><td><code>true</code> if the message sender is the current user.</td></tr>
	 * <tr><td>message</td><td><em>String</em></td><td>The message text</td></tr>
	 * <tr><td>data</td><td><em>ISFSObject</em></td><td>Extra custom parameters, may be null</td></tr>
	 * </table>
	 *
	 * @see		com.smartfoxserver.v3.requests.buddylist.BuddyMessageRequest
	 * @see		com.smartfoxserver.v3.entities.Buddy
	 */
    public static final BUDDY_MESSAGE:String = "buddyMessage";


    /**
	 * Creates a new <em>SFSBuddyEvent</em> instance.
	 *
	 * @param	type	The type of event.
	 * @param	args	An object containing the parameters of the event.
	 */
    public function new(type:String, args:Map<String, Dynamic> = null)
    {
        super(type, args);
    }
}