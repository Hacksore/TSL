TSL = {}
TSL.__index = TSL

function TSL.create()
	local self = setmetatable({}, TSL)
	self.version = "0.0.1"
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

	Users:registerAll(self.sid)

end

function TSL:init()
	
	if not self.loaded  then
		self.conf = conf.load()
			
		self.loaded = true
	end

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
	hook.call("TestHook", message) -- testing hooks

	local myID = util.getOwnID(sid)

	local args = util.str_split(message, " ")

	if args[1]:find("!") == nil then return end
	
	local cmd = string.lower(string.gsub(args[1], "!", ""))

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

	--[[ enabled when hooks are added 
	if newChannelID == mychan then
		ts3.setClientVolumeModifier(self.sid, clientID, -50)
	elseif oldChannelID == mychan then
		log("Restoring volume for " .. user .. "!")
		ts3.setClientVolumeModifier(self.sid, clientID, 0)
	end ]]	

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

hook.add("TestHook", "testingHooks", function(data)
	--hooks working
	--log("Test hook called: " .. data)
end)