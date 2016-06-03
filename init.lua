require("ts3init")        
require("ts3defs")
require("ts3errors")

--dependencies / might want to make an file loader for this
require("TSL/lib/file")
require("TSL/lib/table")
require("TSL/lib/util")
require("TSL/lib/conf")
require("TSL/lib/commands")
require("TSL/lib/users")
require("TSL/lib/hooks")

require("TSL/TSL")

--commands
require("TSL/commands/misc")

--term hax
require("TSL/lib/terminal")

json = require("TSL/lib/json")

MODULE_NAME = "TSL"

api = TSL.create()

--the Lua plugin for whatever reason never implemented this so we need to
--override this so the client does not have to edit the ts3events file
local function currentServerConnectionChanged(serverConnectionHandlerID)
	api:currentServerConnectionChanged(serverConnectionHandlerID)
end

local function onConnectStatusChangeEvent(serverConnectionHandlerID, status, errorNumber)
	if status == ts3defs.ConnectStatus.STATUS_CONNECTION_ESTABLISHED then
		--need instantiate the TSL lib
		api = api or TSL.create()
		api:onServerConnection(serverConnectionHandlerID, status, errorNumber)
   	end	
end

local function onTextMessageEvent(serverConnectionHandlerID, targetMode, toID, fromID, fromName, fromUniqueIdentifier, message, ffIgnored)
	return api:onMessage(serverConnectionHandlerID, toID, fromID, message)
end

local function onClientMoveEvent(serverConnectionHandlerID, clientID, oldChannelID, newChannelID, visibility, moveMessage)
	api:onClientMoveEvent(serverConnectionHandlerID, clientID, oldChannelID, newChannelID, visibility, moveMessage)

end

local function onClientMoveMovedEvent(serverConnectionHandlerID, clientID, oldChannelID, newChannelID, visibility, moverID, moverName, moverUniqueIdentifier, moveMessage)
	api:onClientMoveMovedEvent(serverConnectionHandlerID, clientID, oldChannelID, newChannelID, visibility, moveMessage)
end

local function onChannelSubscribeFinishedEvent(serverConnectionHandlerID)
	api:onChannelSubscribeFinishedEvent(serverConnectionHandlerID)
end

local function createMenus(moduleMenuItemID)	
	api:onReload()
	return {}		
end

local registeredEvents = {
	--currentServerConnectionChanged = currentServerConnectionChanged,
	onTextMessageEvent = onTextMessageEvent,
	onClientMoveEvent = onClientMoveEvent,
	onClientMoveMovedEvent = onClientMoveMovedEvent,
	onChannelSubscribeFinishedEvent = onChannelSubscribeFinishedEvent,
	onConnectStatusChangeEvent = onConnectStatusChangeEvent,
	createMenus = createMenus
}

ts3RegisterModule(MODULE_NAME, registeredEvents)
