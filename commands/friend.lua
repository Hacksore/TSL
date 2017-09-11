command.add("friend", function(self, fromID, args, message)
	local id = self.users:findUserID(self.serverID, message)

	if not id then return false end
	local userdata = self.users:getDataFromID(self.serverID, id)

	local added = self:addFriend(self.serverID, userdata)

	if added then
		log("Added " .. userdata.username .. " to your friends list")
	else
		log(userdata.username .. " is already on your friends list")
	end	
	
end).addAlias("af", "op")

command.add("unfriend", function(self, from, args, message)

	local serverHash = ts3.getServerVariableAsString(self.serverID, ts3defs.VirtualServerProperties.VIRTUALSERVER_UNIQUE_IDENTIFIER)

	for _,v in pairs(self.conf.friends[serverHash]) do
		if v.username:lower():find(message) then

			log("Removed " .. v.username .. " from your friends list")
			self:delFriend(self.serverID, v.uniqueID)
			break
		end
	end
	
end).addAlias("rf", "deop")


command.add("friends", function(self, from, args, message)
	local serverHash = ts3.getServerVariableAsString(self.serverID, ts3defs.VirtualServerProperties.VIRTUALSERVER_UNIQUE_IDENTIFIER)

	local tmp = {}
	for k,v in pairs(self.conf.friends[serverHash]) do	
		local str = string.format("[url=client://0/%s~]%s[/url]", v.uniqueID, v.username)
		table.insert(tmp, str)
	end

	log("[b][color=#8c4b93]▬▬▬▬▬ FRIENDS ▬▬▬▬▬[/b]")
	log("[b]" .. table.concat(tmp, ", ") .. "[/b]")
	log("[b][color=#8c4b93]▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬[/b]")

end).addAlias("mf", "ops", "fl")
