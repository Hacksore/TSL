Users = {}
Users.__index = Users

function Users.create()	
	local self = setmetatable({}, Users)

	self.userList = {}

	return self
end

function Users:getAll(serverID)
	local serverHash = ts3.getServerVariableAsString(serverID, ts3defs.VirtualServerProperties.VIRTUALSERVER_UNIQUE_IDENTIFIER)
	return self.userList[serverHash]
end

function Users:reloadUser(serverID, id)
	self:removeUser(serverID, id)
	self:addUser(serverID, id)
end

function Users:removeUser(serverID, id)
	local serverHash = ts3.getServerVariableAsString(serverID, ts3defs.VirtualServerProperties.VIRTUALSERVER_UNIQUE_IDENTIFIER)
	if self.userList[serverHash] == nil then
		return
	end

	local uniqueID = ts3.getClientVariableAsString(serverID, id, ts3defs.ClientProperties.CLIENT_UNIQUE_IDENTIFIER)

	if uniqueID == nil or self.userList[serverHash][uniqueID] == nil then
		--cant find a user for this id
		return
	end

	self.userList[serverHash][uniqueID] = nil

end

function Users:addUser(serverID, id)
	local serverHash = ts3.getServerVariableAsString(serverID, ts3defs.VirtualServerProperties.VIRTUALSERVER_UNIQUE_IDENTIFIER)

	ts3.requestClientVariables(serverID, id)

	local username = ts3.getClientVariableAsString(serverID, id, ts3defs.ClientProperties.CLIENT_NICKNAME)
	local databaseID = ts3.getClientVariableAsString(serverID, id, ts3defs.ClientProperties.CLIENT_DATABASE_ID)
	local uniqueID = ts3.getClientVariableAsString(serverID, id, ts3defs.ClientProperties.CLIENT_UNIQUE_IDENTIFIER)

	--these vars look to not be aviable on client connection?
	local platform = ts3.getClientVariableAsString(serverID, id, ts3defs.ClientProperties.CLIENT_PLATFORM)
	local version = ts3.getClientVariableAsString(serverID, id, ts3defs.ClientProperties.CLIENT_VERSION)
	local totalConnections = ts3.getClientVariableAsString(serverID, id, ts3defs.ClientProperties.CLIENT_TOTALCONNECTIONS)

	if self.userList[serverHash] == nil then
		self.userList[serverHash] = {}
	end

	self.userList[serverHash][uniqueID] = {
		clientID = id,	
		databaseID = databaseID,
		uniqueID = uniqueID,
		username = username,
		platform = platform,
		totalConnections = totalConnections,
		version = version
	}

	return self.userList[serverHash][uniqueID]
end

function Users:registerAll(serverID)

	local clients = ts3.getClientList(serverID)
	local serverName = ts3.getServerVariableAsString(serverID, ts3defs.VirtualServerProperties.VIRTUALSERVER_NAME)
	local count = #ts3.getClientList(serverID)
	log("[b]Analyzing " .. count .. " user(s) on [color=red]" .. serverName .. "[/color][/b]")

	for _, v in next, clients do
		self:addUser(serverID, v)
	end
end

--return the userData from uniqueID
function Users:getDataFromUniqueID(serverID, uniqueID)
	local serverHash = ts3.getServerVariableAsString(serverID, ts3defs.VirtualServerProperties.VIRTUALSERVER_UNIQUE_IDENTIFIER)

	return self.userList[serverHash][uniqueID]
end

--return the userData from uniqueID
function Users:getDataFromID(serverID, clientID)
	local serverHash = ts3.getServerVariableAsString(serverID, ts3defs.VirtualServerProperties.VIRTUALSERVER_UNIQUE_IDENTIFIER)

	for k, v in next, self.userList[serverHash] do
		if v.clientID == clientID then
			return v
		end
	end
	return nil
end

--find a user id from username
function Users:findUserID(serverID, username)
	local serverHash = ts3.getServerVariableAsString(serverID, ts3defs.VirtualServerProperties.VIRTUALSERVER_UNIQUE_IDENTIFIER)

	for k, v in next, self.userList[serverHash] do
		if v.username:lower():find(username:lower()) then
			return v.clientID
		end
	end
	return nil
end

--events
function Users:onClientMoveEvent(serverID, clientID, oldChannelID, newChannelID, visibility, moveMessage)	

	if visibility == 0 then
		self:addUser(serverID, clientID)
	end

end
