TSL = {}
TSL.__index = TSL

function TSL.create()
	local self = setmetatable({}, TSL)
	self.version = "1.0.3"

	--server in focus
	self.serverID = nil

	--this is a silly var as we can have multiple servers
	--in one instance of a client, consider this deprecated or for the current view tab only
	self.myid = nil

	self.friends = {}
	self.conf = {}
	self.loaded = false

	self.events = Event.create()
	self.follow = {}
	self.users = Users.create()

	--print("running create: " .. )
	--check your id when the plugin is reloading
	--if it's not 0 then we are connect to a server and should trigger the reload
	if util.getOwnID() ~= 0 then		
		self:init(true)
	else
		log("[b][color=red][TSL] Must be on a server to reload![/color][/b]")
	end

	return self
end

function TSL:init(isReload)	

	self.conf = conf.load()
	self.loaded = true

	--set own id
	self.myid = util.getOwnID()

	--set serverID for active tab
	self.serverID = ts3.getCurrentServerConnectionHandlerID()

	--we have to do this here otherwise we lose users on reload
	self.users:registerAll(self.serverID)

	--PrintTable(self.users.userList)
	if isReload then
		log("[b][color=purple][TSL][/color] [color=#4c9358]RELOADED[/color][/b]")
	else
		log("[b][color=purple][TSL][/color] initialized successfully[/b]")
	end

end

function TSL:sendMessage(serverID, msg)
	local chan = util.getOwnChannel(serverID)
	local sid = serverID == nil and ts3.getCurrentServerConnectionHandlerID() or serverID

	if self.pm and self.pm > 0 then
		ts3.requestSendPrivateTextMsg(sid, msg, self.pm)
	else
		ts3.requestSendChannelTextMsg(sid, msg, chan)
	end
end

function TSL:sendPrivMessage(msg, id)
	local chan = util.getOwnChannel()

	ts3.requestSendPrivateTextMsg(self.serverID, msg, id)
end

function TSL:updateFriend(serverID, tab)

	local serverHash = ts3.getServerVariableAsString(serverID, ts3defs.VirtualServerProperties.VIRTUALSERVER_UNIQUE_IDENTIFIER)

	if self.conf.friends[serverHash] == nil then
		self.conf.friends[serverHash] = {}
	end

	self.conf.friends[serverHash][tab.uniqueID] = tab

	conf.save()
	
	return true
end

function TSL:addFriend(serverID, tab)

	local serverHash = ts3.getServerVariableAsString(serverID, ts3defs.VirtualServerProperties.VIRTUALSERVER_UNIQUE_IDENTIFIER)
	if self:isFriend(serverID, tab.uniqueID) then return false end
	
	if self.conf.friends[serverHash] == nil then
		self.conf.friends[serverHash] = {}
	end

	self.conf.friends[serverHash][tab.uniqueID] = tab

	conf.save()
	
	return true
end

function TSL:delFriend(serverID, uniqueID)
	local serverHash = ts3.getServerVariableAsString(serverID, ts3defs.VirtualServerProperties.VIRTUALSERVER_UNIQUE_IDENTIFIER)

	self.conf.friends[serverHash][uniqueID] = nil
	conf.save()
	
end

function TSL:isFriendID(serverID, clientID)
	local uniqueID = ts3.getClientVariableAsString(serverID, clientID, ts3defs.ClientProperties.CLIENT_UNIQUE_IDENTIFIER)
	local serverHash = ts3.getServerVariableAsString(serverID, ts3defs.VirtualServerProperties.VIRTUALSERVER_UNIQUE_IDENTIFIER)

	if self.conf.friends[serverHash] ~= nil then
		if self.conf.friends[serverHash][uniqueID] ~= nil then
			return true
		end
	end
	return false
end

-- TODO: have serverHash lookup happen in here as it makes more sense
function TSL:isFriend(serverID, uniqueID)
	local serverHash = ts3.getServerVariableAsString(serverID, ts3defs.VirtualServerProperties.VIRTUALSERVER_UNIQUE_IDENTIFIER)

	--broken needs fix
	if self.conf.friends[serverHash] ~= nil then
		if self.conf.friends[serverHash][uniqueID] ~= nil then
			return true
		end
	end
	return false
end
