command.add("follow", function(self, from, args, message)
	if util.isNotMe(self.serverID, from) then return false end

	local id = util.findUserID(message)		
	if not id then 
		log("Failed to find a user with the name " .. message)
		return false 
	end

	local user = util.getUsernameByID(self.serverID, id)	
	self.follow[self.serverID] = self.users:getDataFromID(self.serverID, id)

	--move to channel if not there already
	if util.getUserChannelID(self.serverID, id) ~= util.getOwnChannel(self.serverID) then
		local chanID = util.getUserChannelID(self.serverID, id)
		util.moveSelfToChannel(self.serverID, chanID)
	end

	log("Now following " .. user)

end).addAlias("fol", "f")

command.add("stopfollow", function(self, from, args, message)
	if util.isNotMe(self.serverID, from) then return false end

	log("No longer following")

	api.follow[data.serverID] = nil

end).addAlias("sf", "nof", "stopf")

function onMove(data)

	local mychan = util.getOwnChannel(data.serverID)
	local followID = api.follow[data.serverID].clientID

	if followID == data.clientID and data.visibility == ts3defs.Visibility.LEAVE_VISIBILITY then
		--we cant see that client anymore stop following them
		--we have to assume they have disconnected for the most part
		--they could have gone into a channel with no sub perms but not much we can do
		log("No longer following")
		api.follow[data.serverID] = nil
		return
	end

	--move to channel
	if followID == data.clientID and data.newChannelID ~= mychan then
		util.moveSelfToChannel(data.serverID, data.newChannelID)
	end

end

hook.add("ClientMove", "myclientMove", onMove)
hook.add("ClientMoveMoved", "myclientMove", onMove)