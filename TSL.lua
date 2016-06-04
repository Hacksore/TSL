TSL = {}
TSL.__index = TSL

function TSL.create()
	local self = setmetatable({}, TSL)
	self.version = "0.0.2"
	self.name = "TSL"
	self.sid = ts3.getCurrentServerConnectionHandlerID()
	self.myid = util.getOwnID()
	self.friends = {}
	self.conf = {}
	self.term = false
	self.loaded = false
	self.clients = {} -- maybe store this inside of Users class

	self.follow = {}

	self.users = Users.create()

	self:init()

	return self
end

function TSL:onReload()
	--called when the plugin is reloaded
	self.loaded = true
	Users:registerAll(self.sid)

end

function TSL:init()	

	self.conf = conf.load()

end

function TSL:sendMessage(serverID, msg)
	local chan = util.getOwnChannel(serverID)

	if self.pm and self.pm > 0 then
		ts3.requestSendPrivateTextMsg(self.sid, msg, self.pm)
	else
		ts3.requestSendChannelTextMsg(self.sid, msg, chan)
	end
end

function TSL:sendPrivMessage(msg, id)
	local chan = util.getOwnChannel()

	ts3.requestSendPrivateTextMsg(self.sid, msg, id)
end

function TSL:addFriend(sid, tab)

	if self:isFriend(sid, tab.uid) then return false end
	
	if self.conf.friends[sid] == nil then
		self.conf.friends[sid] = {}
	end

	self.conf.friends[sid][tab.uid] = {
		uid = tab.uid,
		name = tab.name
	}

	conf.save()
	
	return true
end

function TSL:delFriend(serverHash, uid)

	self.conf.friends[serverHash][uid] = nil

	conf.save()
	
end

function TSL:isFriendID(sid, clientID)
	local uid = ts3.getClientVariableAsString(sid, clientID, ts3defs.ClientProperties.CLIENT_UNIQUE_IDENTIFIER)
	local serverHash = ts3.getServerVariableAsString(sid, ts3defs.VirtualServerProperties.VIRTUALSERVER_UNIQUE_IDENTIFIER)

	if self.conf.friends[serverHash] ~= nil then
		if self.conf.friends[serverHash][uid] ~= nil then
			return true
		end
	end
	return false
end

-- TODO: have serverHash lookup happen in here as it makes more sense
function TSL:isFriend(sid, uid)
	if self.conf.friends[sid] ~= nil then
		if self.conf.friends[sid][uid] ~= nil then
			return true
		end
	end
	return false
end

--events
function TSL:onMessage(sid, toID, fromID, message)

	hook.call("OnMessage", message) -- testing hooks

	local myID = util.getOwnID(sid)

	local args = string.Explode(message, " ")

	local prefix = self.conf.commandPrefix	

	local firstChar = string.sub(message, 1, 1)

	if not table.HasValue(prefix, firstChar) then return false end

	local cmd = string.lower(string.sub(args[1], 2))

	local temp = args
	table.remove(temp, 1)
	
	local id = ts3.getServerVariableAsString(sid, ts3defs.VirtualServerProperties.VIRTUALSERVER_UNIQUE_IDENTIFIER)
	local uniqueID = ts3.getClientVariableAsString(sid, fromID, ts3defs.ClientProperties.CLIENT_UNIQUE_IDENTIFIER)


	if not self:isFriend(id, uniqueID) and fromID ~= myID then return false end
	
	command.run(cmd, self, fromID, args)

end

function TSL:onClientMoveEvent(sid, clientID, oldChannelID, newChannelID, visibility, moveMessage)

	self.users:onClientMoveEvent(sid, clientID, oldChannelID, newChannelID, visibility, moveMessage)

	if visibility == 2 then return false end

	local myid = util.getOwnID(sid)
	local mychan = util.getOwnChannel(sid)
	local user = util.getUsernameByID(sid, clientID)

	hook.call("OnClientMove", {
		sid = sid, clientID = clientID, oldChannelID = oldChannelID,
		newChannelID = newChannelID, visibility = visibility, moveMessage = moveMessage
	})

	local tab = self.follow[sid]
	if clientID == tab.id and tab.sid == sid then
		util.moveToChannelID(sid, newChannelID)		
	end

end

function TSL:onClientMoveMovedEvent(sid, clientID, oldChannelID, newChannelID, visibility, moverID, moverName, moverUniqueIdentifier, moveMessage)
	local myid = util.getOwnID()
	local mychan = util.getOwnChannel()
	local tab = self.follow[sid]


	if clientID == tab.id and tab.sid == sid then
		util.moveToChannelID(sid, newChannelID)
	end
end

function TSL:onServerConnection(serverID, status, errorNumber)

end

function TSL:onChannelSubscribeFinishedEvent(serverID)	

	Users:registerAll(serverID)

end

function TSL:currentServerConnectionChanged(sid)
	self.sid = sid
end

function TSL:onClientDisconnected(sid, clientData)

	-- print("Disconnected: " .. clientData.username)

end

function TSL:onClientConnected(sid, clientData)
	-- print("Connected: " .. clientData.username)

end
