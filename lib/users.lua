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

	bot.clients[serverHash][uniqueID] = {
		clientID = id,	
		databaseID = databaseID,
		uniqueID = uniqueID,
		username = username
	}

	return bot.clients[serverHash][uniqueID]
end


function Users:removeUser(serverID, id)
	local serverHash = ts3.getServerVariableAsString(serverID, ts3defs.VirtualServerProperties.VIRTUALSERVER_UNIQUE_IDENTIFIER)
	if bot.clients[serverHash] == nil then
		return
	end

	local uniqueID = ts3.getClientVariableAsString(serverID, id, ts3defs.ClientProperties.CLIENT_UNIQUE_IDENTIFIER)
	bot.clients[serverHash][uniqueID] = nil

end

function Users:registerAll(serverID)

	local uid = ts3.getServerVariableAsString(serverID, ts3defs.VirtualServerProperties.VIRTUALSERVER_UNIQUE_IDENTIFIER)

	if bot.clients[uid] == nil then
		bot.clients[uid] = {}
	end

	local clients = ts3.getClientList(serverID)
	for _, v in next, clients do
		self:addUser(serverID, v)
	end

end

--return the clientID from uniqueID
function Users:getID(serverID, uniqueID)
	local serverHash = ts3.getServerVariableAsString(serverID, ts3defs.VirtualServerProperties.VIRTUALSERVER_UNIQUE_IDENTIFIER)

	for k, v in next, bot.clients[serverHash] do		
		if v.uniqueID == uniqueID then
			return v
		end
	end
	return nil
end

--return the clientID from uniqueID
function Users:getUniqueID(serverID, id)
	local serverHash = ts3.getServerVariableAsString(serverID, ts3defs.VirtualServerProperties.VIRTUALSERVER_UNIQUE_IDENTIFIER)

	for k, v in next, bot.clients[serverHash] do		
		if v.clientID == id then
			return v
		end
	end
	return nil
end

--events
function Users:onClientMoveEvent(serverID, clientID, oldChannelID, newChannelID, visibility, moveMessage)

	local data = self:getID(serverID, clientID)

	if visibility == 0 then
		data = self:addUser(serverID, clientID)

		print("Joined: " .. data.username)
	elseif visibility == 2 then
		print("Left: " .. data.username)	
	end

end
