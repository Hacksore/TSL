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

	self.clients = {}

	self.follow = {}

	self.users = Users.create()

	self:init()
	return self
end

function TSL:init()
	
	if not self.loaded  then
		self.conf = conf.load()
			
		self.loaded = true
	end

end

function TSL:sendMessage(msg)
	local chan = util.getOwnChannel()

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
	print("addFriend called")
	if self:isFriend(sid, tab.id) then return false end
	
	if self.conf.friends[sid] == nil then
		print("Cant find table for server " .. sid)
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

	
	local size = table.size(self.conf.friends[serverHash])
	print("TSize: " .. size)

	--when conf.friends[serverHash] has nothing left json lib is setting the val to []
	--then it cant parse the config smh
	self.conf.friends[serverHash][uid] = json.null


	conf.save()
	
end

function TSL:isFriend(sid, uid)
	if self.conf.friends[sid] ~= nil then
		if self.conf.friends[sid][cid] ~= nil then
			return true
		end
	end
	return false
end

function TSL.onMessage(self, sid, toID, fromID, message)
	local myID = util.getOwnID(sid)

	local args = util.str_split(message, " ")

	if args[1]:find("!") == nil then return end
	
	local cmd = string.lower(string.gsub(args[1], "!", ""))

	local temp = args
	table.remove(temp, 1)
	
	local id = ts3.getServerVariableAsString(sid, ts3defs.VirtualServerProperties.VIRTUALSERVER_UNIQUE_IDENTIFIER)

	if not self:isFriend(id, fromID) and fromID ~= myID then return false end
	
	command.run(cmd, self, fromID, args)
	
end

function TSL.onClientMoveEvent(self, sid, clientID, oldChannelID, newChannelID, visibility, moveMessage)
	self.users:onClientMoveEvent(sid, clientID, oldChannelID, newChannelID, visibility, moveMessage)

	if visibility == 2 then return false end

	local myid = util.getOwnID()
	local mychan = util.getOwnChannel()
	local tab = self.follow[sid]
	local user = util.getUsernameByID(sid, clientID)

	if clientID == tab.id and tab.sid == sid then
		util.moveToChannelID(sid, newChannelID)		
	end

end

function TSL.onClientMoveMovedEvent(self, sid, clientID, oldChannelID, newChannelID, visibility, moverID, moverName, moverUniqueIdentifier, moveMessage)
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

function TSL.currentServerConnectionChanged(self, sid)
	self.sid = sid
end
