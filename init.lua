require("ts3init")        
require("ts3defs")
require("ts3errors")
require("TSL/lib/util")
require("TSL/lib/conf")
require("TSL/lib/commands")
require("TSL/lib/users")
require("TSL/TSL")

--commands
require("TSL/commands/misc")

--term hax
require("TSL/lib/terminal")

local json = require("TSL/lib/json")

local MODULE_NAME = "TSL"

bot = TSL.create()

local function currentServerConnectionChanged(serverConnectionHandlerID)
	bot.currentServerConnectionChanged(bot, serverConnectionHandlerID)
end

local function onConnectStatusChangeEvent(serverConnectionHandlerID, status, errorNumber)
	if status == ts3defs.ConnectStatus.STATUS_CONNECTION_ESTABLISHED then
		bot = TSL.create()
		bot:onServerConnection(serverConnectionHandlerID, status, errorNumber)
   	end	
end

local function onTextMessageEvent(serverConnectionHandlerID, targetMode, toID, fromID, fromName, fromUniqueIdentifier, message, ffIgnored)
	return bot.onMessage(bot, serverConnectionHandlerID, toID, fromID, message)
end

local function onClientMoveEvent(serverConnectionHandlerID, clientID, oldChannelID, newChannelID, visibility, moveMessage)
	bot.onClientMoveEvent(bot, serverConnectionHandlerID, clientID, oldChannelID, newChannelID, visibility, moveMessage)
end

local function onClientMoveMovedEvent(serverConnectionHandlerID, clientID, oldChannelID, newChannelID, visibility, moverID, moverName, moverUniqueIdentifier, moveMessage)
	bot.onClientMoveMovedEvent(bot, serverConnectionHandlerID, clientID, oldChannelID, newChannelID, visibility, moveMessage)
end

local function onChannelSubscribeFinishedEvent(serverConnectionHandlerID)
	bot:onChannelSubscribeFinishedEvent(serverConnectionHandlerID)
end

local registeredEvents = {
	currentServerConnectionChanged = currentServerConnectionChanged,
	onTextMessageEvent = onTextMessageEvent,
	onClientMoveEvent = onClientMoveEvent,
	onClientMoveMovedEvent = onClientMoveMovedEvent,
	onChannelSubscribeFinishedEvent = onChannelSubscribeFinishedEvent,
	onConnectStatusChangeEvent = onConnectStatusChangeEvent
}

ts3RegisterModule(MODULE_NAME, registeredEvents)
