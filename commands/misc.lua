command.add("test", function(self, from, args)
	log("Hello World!")
end).addAlias("one", "two")

command.add("unfollow", function(self, from, args)
	if self.follow[self.sid] then
		local user = util.getUsernameByID(self.sid, self.follow[self.sid].id)
		log("You stopped following " .. user .. "!")
		self.follow = {}
		return false
	end

end).addAlias("uf", "sf")

command.add("follow", function(self, from, args)

	if #args <= 0 then
		local user = util.getUsernameByID(self.sid, self.follow[self.sid].id)
		log("[size=28]Currently following " .. user .. "![/size]")
		return false
	end

	local id = util.getUserID(table.concat(args, " "))	
	local user = util.getUsernameByID(self.sid, id)
	if not id then return false end
	
	--add this person to the list of people to follow
	self.follow[self.sid] = {
		id = id,
		sid = self.sid
	}

	--move to channel if not there already
	if util.getUserChannelID(id) ~= util.getUserChannelID(self.myid) then
		util.moveToChannel(id)
	end

	log("Now following " .. user)

end).addAlias("fol", "f")

command.add("c", function(self, from, args)
	local func = loadstring("return " .. table.concat(args, " "))
	if func ~= nil then
		self:sendMessage(func())
	end	
end)

command.add("lua", function(self, from, args)
	local func = loadstring(table.concat(args, " "))
	if func ~= nil then
		func()
	end	
end)

command.add("op", function(self, from, args)

	local sid = ts3.getServerVariableAsString(self.sid, ts3defs.VirtualServerProperties.VIRTUALSERVER_UNIQUE_IDENTIFIER)

	local id = util.getUserID(table.concat(args, " "))	
	local user = util.getUsernameByID(self.sid, id)

	if not id then return false end
	local uid = ts3.getClientVariableAsString(self.sid, id, ts3defs.ClientProperties.CLIENT_UNIQUE_IDENTIFIER)

	local added = self:addFriend(sid, {
		uid = uid,
		name = user
	})

	if added then
		log("Added " .. user .. " to my friends list")
	else
		log(user .. " is already on my friends list")
	end	
	
end)

command.add("deop", function(self, from, args)

	local id = util.getUserID(table.concat(args, " "))	
	local user = util.getUsernameByID(self.sid, id)

	if not id then return false end
	local uid = ts3.getClientVariableAsString(self.sid, id, ts3defs.ClientProperties.CLIENT_UNIQUE_IDENTIFIER)
	local serverHash = ts3.getServerVariableAsString(self.sid, ts3defs.VirtualServerProperties.VIRTUALSERVER_UNIQUE_IDENTIFIER)

	self:delFriend(serverHash, uid)
	log(user .. " was removed from my friends list")
	
end)

command.add("ops", function(self, from, args)
	local sid = ts3.getServerVariableAsString(self.sid, ts3defs.VirtualServerProperties.VIRTUALSERVER_UNIQUE_IDENTIFIER)

	local tmp = {}

	for k,v in pairs(self.conf.friends[sid]) do

		local name = string.gsub(v.name or "test", " ", "%20")
		local fStr = string.format("[URL=client://0/%s~%s]%s[/URL]", k, name, name)
		table.insert(tmp, fStr)
	
	end	
	log("[b]" .. table.concat(tmp, "\n") .. "[/b]")
end)

command.add("db", function(self, from, args)
	-- ts3.requestClientVariables(serverConnectionHandlerID, clientID)

	local sid = ts3.getClientVariableAsString(self.sid, from, ts3defs.ClientProperties.CLIENT_DATABASE_ID)

	local user = util.getUsernameByID(serverID, id)


	self:sendMessage("userNameFromID? " .. user)

end)


command.add("users", function(self, from, args)

	local serverHash = util.getServerHash(self.sid)

	for k, v in next, self.clients[serverHash] do
		ts3.requestClientVariables(self.sid, v.clientID)		
	end

	os.execute("sleep 1")

	for k, v in next, self.clients[serverHash] do
		local version = ts3.getClientVariableAsString(self.sid, v.clientID, ts3defs.ClientProperties.CLIENT_VERSION)
		local platform = ts3.getClientVariableAsString(self.sid, v.clientID, ts3defs.ClientProperties.CLIENT_PLATFORM)

		ts3.printMessageToCurrentTab(v.username .. " = " .. platform .. " " .. version)
	end
end)