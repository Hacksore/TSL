Event = {}
Event.__index = Event

function Event.create()
	return setmetatable({}, Event)	
end

function Event.onTextMessageEvent(serverID, targetMode, toID, fromID, fromName, fromUniqueIdentifier, message, ffIgnored)
	local retVal = hook.call("ClientTextMessage", {
		fromID = fromID,
		fromName = fromName,
		fromUniqueIdentifier = fromUniqueIdentifier,
		message = message
	})

	if retVal then
		--this could message with commands via a whitelisted user
		--need to add more logic later
		return 1
	end

	local myID = util.getOwnID(serverID)
	local args = string.Explode(message, " ")
	local prefix = api.conf.commandPrefix	
	local firstChar = string.sub(message, 1, 1)
	if not table.HasValue(prefix, firstChar) then return false end

	local cmd = string.lower(string.sub(args[1], 2))

	local temp = args
	table.remove(temp, 1)
	
	local id = ts3.getServerVariableAsString(serverID, ts3defs.VirtualServerProperties.VIRTUALSERVER_UNIQUE_IDENTIFIER)
	local uniqueID = ts3.getClientVariableAsString(serverID, fromID, ts3defs.ClientProperties.CLIENT_UNIQUE_IDENTIFIER)

	if fromID ~= myID then return false end
	
	command.run(cmd, api, fromID, args)

	return 0
end

function Event.currentServerConnectionChanged(serverID)	
	hook.call("SwitchTab", {
		serverID = serverID
	})

	--oh we still need to do this :)
	api.users:registerAll(serverID)

	--would like to rename this var to serverID
	api.serverID = serverID
end

function Event.onClientMoveMovedEvent(serverID, clientID, oldChannelID, newChannelID, visibility, moverID, moverName, moverUniqueIdentifier, moveMessage)
	hook.call("ClientMoveMoved", {
		serverID = serverID, 
		clientID = clientID,
		oldChannelID = oldChannelID,
		newChannelID = newChannelID, 
		visibility = visibility, 
		moveMessage = moveMessage
	})

	api:onClientMoveMovedEvent(serverID, clientID, oldChannelID, newChannelID, visibility, moveMessage)
end

function Event.onClientMoveEvent(serverID, clientID, oldChannelID, newChannelID, visibility, moveMessage)
	api.users:onClientMoveEvent(serverID, clientID, oldChannelID, newChannelID, visibility, moveMessage)

	--if visibility == 2 then return false end

	hook.call("ClientMove", {
		serverID = serverID, 
		clientID = clientID,
		oldChannelID = oldChannelID,
		newChannelID = newChannelID, 
		visibility = visibility, 
		moveMessage = moveMessage
	})
end

function Event.onConnectStatusChangeEvent(serverID, status, errorNumber)

end

function Event.onUpdateClientEvent(serverID, clientID, invokerID, invokerName, invokerUniqueIdentifier)
	hook.call("ClientUpdate")

	local userdata = api.users:getDataFromID(serverID, clientID)
	local username = ts3.getClientVariableAsString(serverID, clientID, ts3defs.ClientProperties.CLIENT_NICKNAME)

	--if the users name changes we want to reload their data everything else would get reloaded when 
	--they reconnect in the future there may be other things we want to trigger a reload on but for this is ok
	if userdata and userdata.username ~= username then

		--get data to reload
		api.users:reloadUser(serverID, clientID)

		--do a new lookup on the user
		userdata = api.users:getDataFromID(serverID, clientID)

		--tell the conf to update too
		if api:isFriendID(serverID, clientID) then
			api:updateFriend(serverID, userdata)
		end
	end

end

function Event.onChannelSubscribeFinishedEvent(serverID)
	--load TSL when all users have been seen
	api:init()

	hook.call("ChannelSubscribeFinished", {
		serverID = serverID
	})

end

function Event.onNewChannelEvent(serverID, channelID, channelParentID)
	-- hook.call("NewChannel", {
	-- 	serverID = serverID,
	-- 	channelID = channelID,
	-- 	channelParentID = channelParentID
	-- })
end

function Event.onNewChannelCreatedEvent(serverID, channelID, channelParentID, invokerID, invokerName, invokerUniqueIdentifier)
    --hook.call("C")
    --need to find out what the difference between the two simalar methods skipping for now
end

function Event.onDelChannelEvent(serverID, channelID, invokerID, invokerName, invokerUniqueIdentifier)
 	hook.call("ChannelRemove", {
 		serverID = serverID,
 		channelID = channelID,
 		invokerID = invokerID,
 		invokerName = invokerName,
 		invokerUniqueIdentifier = invokerUniqueIdentifier
 	})
end

function Event.onChannelMoveEvent(serverID, channelID, newParentChannelID, invokerID, invokerName, invokerUniqueIdentifier)
	hook.call("ChannelMove", {
		serverID = serverID,
		channelID = channelID,
		newParentChannelID = newParentChannelID,
		invokerID = invokerID,
		invokerName = invokerName,
		invokerUniqueIdentifier = invokerUniqueIdentifier
	})
end

function Event.onUpdateChannelEvent(serverID, channelID)
	hook.call("ChannelUpdate", {
		serverID = serverID,
		channelID = channelID
	})
end

function Event.onUpdateChannelEditedEvent(serverID, channelID, invokerID, invokerName, invokerUniqueIdentifier)
	--another instance where i dont have a good idea of what the above function does
end

function Event.onClientMoveSubscriptionEvent(serverID, clientID, oldChannelID, newChannelID, visibility)
	--no idea what this is really for need to test before adding a hook
end

function Event.onClientMoveTimeoutEvent(serverID, clientID, oldChannelID, newChannelID, visibility, timeoutMessage)
	-- i guess the real question is what events get called when a user disconnects/gets kicked/timesout
	--tell the users class to remove this user for the list
	api.users:removeUser(serverID, clientID)

	hook.call("ClientTimeout", {
		serverID = serverID,
		clientID = clientID,
		oldChannelID = oldChannelID,
		newChannelID = newChannelID,
		visibility = visibility,
		timeoutMessage = timeoutMessage
	})
end

function Event.onClientKickFromChannelEvent(serverID, clientID, oldChannelID, newChannelID, visibility, kickerID, kickerName, kickerUniqueIdentifier, kickMessage)

	hook.call("ClientChannelKick", {
		serverID = serverID,
		clientID = clientID,
		oldChannelID = oldChannelID,
		newChannelID = newChannelID,
		visibility = visibility,
		kickerID = kickerID,
		kickerName = kickerName,
		kickerUniqueIdentifier = kickerUniqueIdentifier,
		kickMessage = kickMessage
	})
end

function Event.onClientKickFromServerEvent(serverID, clientID, oldChannelID, newChannelID, visibility, kickerID, kickerName, kickerUniqueIdentifier, kickMessage)
	api.users:removeUser(serverID, clientID)

	hook.call("ClientKicked", {
		serverID = serverID,
		clientID = clientID,
		oldChannelID = oldChannelID,
		newChannelID = newChannelID,
		visibility = visibility,
		kickerID = kickerID,
		kickerName = kickerName,
		kickerUniqueIdentifier = kickerUniqueIdentifier,
		kickMessage = kickMessage
	})
end

function Event.onServerEditedEvent(serverID, editerID, editerName, editerUniqueIdentifier)
	hook.call("ServerEdited", {
		serverID = serverID,
		editerID = editerID,
		editerName = editerName,
		editerUniqueIdentifier = editerUniqueIdentifier
	})
end

function Event.onTalkStatusChangeEvent(serverID, status, isReceivedWhisper, clientID)
	hook.call("ClientTalk", {
		serverID = serverID,
		status = status,
		isReceivedWhisper = isReceivedWhisper,
		clientID = clientID
	})
end

--seems like thjis is not technically implemted from teh ts3 plugin devs
function Event.onClientBanFromServerEvent(serverID, clientID, oldChannelID, newChannelID, visibility, kickerID, kickerName, kickerUniqueIdentifier, kickTime, kickMessage)
	api.users:removeUser(serverID, clientID)

	hook.call("ClientBanned", {
		serverID = serverID,
		clientID = clientID,
		oldChannelID = oldChannelID,
		newChannelID = newChannelID,
		visibility = visibility,
		kickerID = kickerID,
		kickerName = kickerName,
		kickerUniqueIdentifier = kickerUniqueIdentifier,
		kickTime = kickTime,
		kickMessage = kickMessage
	})
end

function Event.onClientPokeEvent(serverID, pokerID, pokerName, message, ffIgnored)
	local val = hook.call("ClientPoke", {
		serverID = serverID,
		pokerID = pokerID,
		pokerName = pokerName,
		message = message,
		ffIgnored = ffIgnored
	})

	if val then
		print("Blocking poke!")
	end

	return val
end

function Event.createMenus()

	--might want to move this hook to sub finished event
	--the only thing i see bad with moving to sub finish is that other tabs will try to init the plugin again
	hook.call("ClientLoaded", api) -- testing hooks
	
	return {}
end