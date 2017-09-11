-- hooks 
hook.add("ClientLoaded", "setupVars", function(self)
	--you can either set the passed in ref "self" or the global "api"
	self.settingRefVar = "OK"

	api.settingGlobalVar = "OK"

end)

hook.add("ClientPoke", "myClientPoke", function(data)
	if data.message == "test" then
		return 1
	else 
		return 0
	end
end)


hook.add("ClientTextMessage", "myClientTextMessage", function(data)

end)


-- commands
command.add("test", function(self, fromID, args, message)

	log("USE serverID: " .. self.serverID)

	local serverHash = ts3.getServerVariableAsString(self.serverID, ts3defs.VirtualServerProperties.VIRTUALSERVER_UNIQUE_IDENTIFIER)
	local serverName = ts3.getServerVariableAsString(self.serverID, ts3defs.VirtualServerProperties.VIRTUALSERVER_NAME)

	local info = {
		hash = serverHash,
		name = serverName
	}

	PrintTable(info)
	PrintTable(self.users.userList)

end)

command.add("user", function(self, fromID, args, message)

	local id = self.users:findUserID(self.serverID, message)		
	if not id then 
		log("Failed to find a user with the name " .. message)
		return false
	end

	local data = self.users:getDataFromID(self.serverID, id)

	PrintTable(data)

end)

command.add("who", function(self, fromID, args, message)

	local users = self.users:getAll(self.serverID)
	local friends = {}
	local notFriends = {}

	for _,v in pairs(users) do
		local isFriend = self:isFriendID(self.serverID, v.clientID)

		if isFriend then
			table.insert(friends, v)
		else
			table.insert(notFriends, v)
		end

		--local friend = isFriend and "[color=green]●[/color]" or "[color=red]●[/color]"
		--str = str .. friend .. string.format("[color=blue][b][URL=client://0/%s]%s[/URL][/b][/color], ", v.uniqueID, v.username)
	end

	local str = ""

	log("[b][color=#8c4b93]▬▬▬▬▬ WHO ▬▬▬▬▬[/color][/b]")

	if #friends > 0 then
		for _,v in pairs(friends) do
			str = str .. string.format("[b][url=client://0/%s][color=green]%s[/color][/url][/b], ", v.uniqueID, v.username)
		end

		log("[b]FRIENDS:[/b] " .. str)

		str = ""
	end

	for _,v in pairs(notFriends) do
		str = str .. string.format("[b][url=client://0/%s][color=#425482]%s[/color][/url][/b], ", v.uniqueID, v.username)
	end

	log(str)

end)

-- commands
command.add("reload", function(self, fromID, args, message)

	--really hacky reload method

	local appdata = string.gsub(util.exec("echo %APPDATA%"), "\n", "")
	local path = appdata .. "/TS3Client/plugins/lua_plugin/TSL"

	local reloadTSLInit = loadstring(file.read(path .. "/init.lua"))

	reloadTSLInit()
	
end)

command.add("ver", function(self, from, args)
local s = [===[[b][color=#4f4f4f][color=purple]TSL[/color] a framework module for Lua [color=gray][[/color][color=#7a4de2]v%s[/color][color=gray]][/color]
Created by [color=#db3b3b]Hacksore[/color][/color][/b]]===]

	local str = string.format(s, self.version)
	log(str)

end).addAlias("about")