Event = {}
Event.__index = Event

function Event.create()
	local self = setmetatable({}, Event)
	return self
end

--events
--serverConnectionHandlerID, targetMode, toID, fromID, fromName, fromUniqueIdentifier, message, ffIgnored
function Event:onTextMessageEvent(sid, targetMode, toID, fromID, fromName, fromUniqueIdentifier, message, ffIgnored)
	--hook.call("OnMessage", message) -- testing hooks

	-- PrintTable({
	-- 	sid = sid,
	-- 	targetMode = targetMode,
	-- 	toID = toID,
	-- 	fromID = fromID,
	-- 	fromName = fromName,
	-- 	fromUniqueIdentifier = fromUniqueIdentifier,
	-- 	message = message,
	-- 	ffIgnored = ffIgnored
	-- })


	local myID = util.getOwnID(sid)
	log("SID: " .. sid)
	log("MYID: " .. myID)

	
	-- local args = string.Explode(message, " ")
	-- local prefix = api.conf.commandPrefix
	-- local firstChar = string.sub(message, 1, 1)
	-- if not table.HasValue(prefix, firstChar) then return false end

	-- local cmd = string.lower(string.sub(args[1], 2))

	-- local temp = args
	-- table.remove(temp, 1)
	
	-- local id = ts3.getServerVariableAsString(sid, ts3defs.VirtualServerProperties.VIRTUALSERVER_UNIQUE_IDENTIFIER)
	-- local uniqueID = ts3.getClientVariableAsString(sid, fromID, ts3defs.ClientProperties.CLIENT_UNIQUE_IDENTIFIER)

	-- if not api:isFriend(id, uniqueID) and fromID ~= myID then return false end
	
	-- command.run(cmd, api, fromID, args)

end

function Event:currentServerConnectionChanged(serverConnectionHandlerID)
	hook.call("SwitchTab")

	api:currentServerConnectionChanged(serverConnectionHandlerID)
end

function Event:onClientMoveMovedEvent(serverConnectionHandlerID, clientID, oldChannelID, newChannelID, visibility, moverID, moverName, moverUniqueIdentifier, moveMessage)
	hook.call("ClientMoveMoved", serverConnectionHandlerID, clientID, oldChannelID, newChannelID, visibility, moveMessage)
	api:onClientMoveMovedEvent(serverConnectionHandlerID, clientID, oldChannelID, newChannelID, visibility, moveMessage)
end

function Event:onClientMoveEvent(serverConnectionHandlerID, clientID, oldChannelID, newChannelID, visibility, moveMessage)
	hook.call("ClientMove", serverConnectionHandlerID, clientID, oldChannelID, newChannelID, visibility, moveMessage)
	api:onClientMoveEvent(serverConnectionHandlerID, clientID, oldChannelID, newChannelID, visibility, moveMessage)
end

function Event:onConnectStatusChangeEvent(serverConnectionHandlerID, status, errorNumber)
end

function Event:createMenus(moduleMenuItemID)

	hook.call("ClientLoaded") -- testing hooks


	log("[b][TSL] Loaded from createMenus![/b]")

	return {}
end