package sfs3.client.controllers.system;

import sfs3.client.entities.data.ISFSArray;
import sfs3.client.entities.data.ISFSObject;
import sfs3.client.entities.data.SFSDataWrapper;
import sfs3.client.ISmartFox;
import sfs3.client.bitswarm.io.IResponse;
import sfs3.client.core.EventParam;
import sfs3.client.core.SFSEvent;
import sfs3.client.entities.IMMOItem;
import sfs3.client.entities.MMOItem;
import sfs3.client.entities.MMORoom;
import sfs3.client.entities.Room;
import sfs3.client.entities.User;
import sfs3.client.entities.managers.SFSGlobalUserManager;
import sfs3.client.requests.mmo.SetUserPositionRequest;
import sfs3.client.entities.data.Vec3D;
import sfs3.client.entities.data.PlatformStringMap;

class ResSetUserPosition extends BaseResponseHandler
{
    public function new() {
        super();
    }

	public function handleResponse(sfs:ISmartFox, resp:IResponse):Void
	{
		var userManager:SFSGlobalUserManager = cast sfs.getUserManager();
		
		var sfso:ISFSObject = resp.getContent();
		var evtParams = new PlatformStringMap<Dynamic>();

		var roomId:Int = sfso.getInt(SetUserPositionRequest.KEY_ROOM);

		var minusUserList:Array<Int> = sfso.getIntArray(SetUserPositionRequest.KEY_MINUS_USER_LIST);
		var plusUserList:ISFSArray = sfso.getSFSArray(SetUserPositionRequest.KEY_PLUS_USER_LIST);

		var minusItemList:Array<Int> = sfso.getIntArray(SetUserPositionRequest.KEY_MINUS_ITEM_LIST);
		var plusItemList:ISFSArray = sfso.getSFSArray(SetUserPositionRequest.KEY_PLUS_ITEM_LIST);

		var theRoom:Room = sfs.getRoomManager().getRoomById(roomId);

		/*
		 * We need to add this check because ProxyList Updates are delayed Suppose I
		 * have just left an MMORoom which gets destroyed before the last update
		 */
		if (theRoom == null)
		{
			log.warn("Target MMORoom is null: " + roomId);
			return;
		}

		// Lists of elements that will be passed in the event
		var addedUsers = new Array<User>();
		var removedUsers = new Array<User>();

		var addedItems = new Array<IMMOItem>();
		var removedItems = new Array<IMMOItem>();

		// Remove users that no longer are in proximity
		if (minusUserList != null && minusUserList.length > 0)
		{
			for (uid in minusUserList)
			{
				var removedUser:User = theRoom.getUserById(uid);

				if (removedUser != null)
				{
					theRoom.removeUser(removedUser);
					removedUsers.push(removedUser);
				}
			}
		}

		// Add new users that are now in proximity
		if (plusUserList != null)
		{
			for (i in 0...plusUserList.size())
			{
				var encodedUser:ISFSArray = plusUserList.getSFSArray(i);
				
				var newUser:User = userManager.getOrCreateUser(encodedUser, theRoom);
				addedUsers.push(newUser);
				theRoom.addUser(newUser);

				/*
				 * From the encoded User (as SFSArray) we extract the 5th extra/optional
				 * parameter which contains his location on the map, or the AOIEntryPoint as we
				 * will refer to it
				 */
				if (encodedUser.size() > 5)
				{
					var userEntryPos:SFSDataWrapper = encodedUser.get(5);
					newUser.setAOIEntryPoint(Vec3D.fromArray(cast userEntryPos.getObject()));
				}
			}
		}

		var mmoRoom:MMORoom = cast theRoom;

		// If there are items to remove simply pass the list of MMOItem ids
		if (minusItemList != null)
		{
			for (itemId in minusItemList)
			{
				var mmoItem:IMMOItem = mmoRoom.getMMOItem(itemId);

				if (mmoItem != null)
				{
					// Remove from Room Item list
					mmoRoom.removeItem(itemId);

					// Add to event list
					removedItems.push(mmoItem);
				}
			}
		}

		// Prepare a list of new MMOItems in view
		if (plusItemList != null)
		{
			for (i in 0...plusItemList.size())
			{
				var encodedItem:ISFSArray = plusItemList.getSFSArray(i);

				// Create the MMO Item with the server side ID (Index = 0 of the SFSArray)
				var newItem:IMMOItem = MMOItem.fromSFSArray(encodedItem);

				// Add to event list
				addedItems.push(newItem);

				// Add to Room Item List
				mmoRoom.addMMOItem(newItem);

				/*
				 * From the encoded Item (as SFSArray) we extract the 2nd extra/optional
				 * parameter which contains its location on the map, or the AOIEntryPoint as we
				 * will refer to it
				 */

				if (encodedItem.size() > 2)
				{
					var itemEntryPos:SFSDataWrapper = encodedItem.get(2);
					(cast newItem:MMOItem).setAOIEntryPoint(Vec3D.fromArray(cast itemEntryPos.getObject()));
				}
			}
		}

		// Prepare and dispatch!
		evtParams.set(EventParam.AddedItems, addedItems);
		evtParams.set(EventParam.RemovedItems, removedItems);
		evtParams.set(EventParam.RemovedUsers, removedUsers);
		evtParams.set(EventParam.AddedUsers, addedUsers);
		evtParams.set(EventParam.Room, mmoRoom);

		// Fire event!
		sfs.dispatchEvent(new SFSEvent(SFSEvent.PROXIMITY_LIST_UPDATE, evtParams));
	}
}
