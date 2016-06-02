--grap appdata path for windows
local stream = io.popen("echo %APPDATA%")
local appdata = stream:read("*all")
stream:close()

conf = {}
conf.list = {}
conf.fileName = string.gsub(appdata .. "/TS3Client/tsl_conf.json", "\n", "")

conf.load = function()
	local f = io.open(conf.fileName, "r")
	if not f then
		local f2 = io.open(conf.fileName, "w")
		local default = io.open("plugins/lua_plugin/TSL/config.default.json", "r"):read("*all")

		f2:write(default)
		f2:close()
		
		conf.list = json.decode(default)
	else	
		local data = f:read("*all")
		conf.list = json.decode(data)
		f:close()
	end

	return conf.list
end

conf.save = function()
	local f = io.open(conf.fileName, "w")
	f:write(json.encode(api.conf))
	f:close()	
end