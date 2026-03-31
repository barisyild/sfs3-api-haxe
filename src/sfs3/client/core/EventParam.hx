package sfs3.client.core;

/*
 * This contains only the public params exposed by the API
 * Also see the "System" params in the SysParam class
 *
 * @see SysParam
 */
@:expose("SFS3.EventParam")
class EventParam
{
    public static final Success:String = "success";
    public static final ExtParams:String = "extParams";
    public static final Cmd:String = "cmd";
    public static final Data:String = "data";
    public static final ErrorMessage:String = "errorMessage";
    public static final ErrorCode:String = "errorCode";
    public static final TxType:String = "txType";
    public static final DisconnectionReason:String = "disconnectionReason";

    public static final Room:String = "room";
    public static final User:String = "user";
    public static final UserList:String = "userList";
    public static final Buddy:String = "buddy";

    public static final IsItMe:String = "isItMe";
    public static final PlayerId:String = "playerId";
    public static final GroupId:String = "groupId";
    public static final UserCount:String = "userCount";
    public static final SpecCount:String = "specCount";
    public static final LagValue:String = "lagValue";
    public static final NewRooms:String = "newRooms";
    public static final RoomId:String = "roomId";
    public static final ChangedVars:String = "changedVars";
    public static final ZoneName:String = "zoneName";
    public static final RoomList:String = "roomList";
    public static final OldName:String = "oldName";

    public static final Sender:String = "sender";
    public static final Message:String = "message";
    public static final Invitation:String = "invitation";
    public static final Invitee:String = "invitee";
    public static final Reply:String = "reply";

    public static final BuddyList:String = "buddyList";
    public static final MyBuddyVars:String = "myBuddyVars";

    public static final AddedItems:String = "addedItems";
    public static final RemovedItems:String = "removedItems";
    public static final RemovedUsers:String = "removedUsers";
    public static final AddedUsers:String = "addedUsers";
    public static final MMOItem:String = "mmoItem";

    public static final ClusterUserName:String = "clusterUserName";
    public static final ClusterPassword:String = "clusterPassword";
    public static final ClusterConfigData:String = "clusterConfigData";
}
