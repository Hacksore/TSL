Users = {}
Users.__index = Users

function Users.create()	
	local self = setmetatable({}, Users)
	return self
end

function Users:addUser(serverID, id)
	local serverHash = ts3.getServerVariableAsString(serverID, ts3defs.VirtualServerProperties.VIRTUALSERVER_UNIQUE_IDENTIFIER)

	local username = ts3.getClientVariableAsString(serverID, id, ts3defs.ClientProperties.CLIENT_NICKNAME)
	local databaseID = ts3.getClientVariableAsString(serverID, id, ts3defs.ClientProperties.CLIENT_DATABASE_ID)
	local uniqueID = ts3.getClientVariableAsString(serverID, id, ts3defs.ClientProperties.CLIENT_UNIQUE_IDENTIFIER)

	api.clients[serverHash][uniqueID] = {
		clientID = id,	
		databaseID = databaseID,
		uniqueID = uniqueID,
		username = username
	}

	return api.clients[serverHash][uniqueID]
end

function Users:removeUser(serverID, id)
	local serverHash = ts3.getServerVariableAsString(serverID, ts3defs.VirtualServerProperties.VIRTUALSERVER_UNIQUE_IDENTIFIER)
	if api.clients[serverHash] == nil then
		return
	end

	local uniqueID = ts3.getClientVariableAsString(serverID, id, ts3defs.ClientProperties.CLIENT_UNIQUE_IDENTIFIER)
	api.clients[serverHash][uniqueID] = nil

end

function Users:registerAll(serverID)

	-- PrintTable(api)
	local uid = ts3.getServerVariableAsString(serverID, ts3defs.VirtualServerProperties.VIRTUALSERVER_UNIQUE_IDENTIFIER)

	if api.clients[uid] == nil then
		api.clients[uid] = {}
	end

	local clients = ts3.getClientList(serverID)
	for _, v in next, clients do
		self:addUser(serverID, v)
	end

end

--return the userData from uniqueID
function Users:getDataFromUniqueID(serverID, uniqueID)
	local serverHash = ts3.getServerVariableAsString(serverID, ts3defs.VirtualServerProperties.VIRTUALSERVER_UNIQUE_IDENTIFIER)

	for k, v in next, api.clients[serverHash] do		
		if v.uniqueID == uniqueID then
			return v
		end
	end
	return nil
end

--return the userData from uniqueID
function Users:getDataFromID(serverID, clientID)
	local serverHash = ts3.getServerVariableAsString(serverID, ts3defs.VirtualServerProperties.VIRTUALSERVER_UNIQUE_IDENTIFIER)

	for k, v in next, api.clients[serverHash] do		
		if v.clientID == clientID then
			return v
		end
	end
	return nil
end

--events
function Users:onClientMoveEvent(serverID, clientID, oldChannelID, newChannelID, visibility, moveMessage)

	local data = self:getDataFromID(serverID, clientID)

	if visibility == 0 then
		data = self:addUser(serverID, clientID)

		api:onClientConnected(serverID, data)

	elseif visibility == 2 then
		
		api:onClientDisconnected(serverID, data)

	end

end
