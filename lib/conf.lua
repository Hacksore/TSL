--grab appdata path for windows
local appdata = string.gsub(util.exec("echo %APPDATA%"), "\n", "")

conf = {}
conf.list = {}
conf.fileName = string.gsub(appdata .. "/TS3Client/tsl_conf.json", "\n", "")

conf.load = function()

	if not file.exists(conf.fileName) then
		local default = file.read("plugins/lua_plugin/TSL/config.default.json")

		file.write(conf.fileName, default)
		
		conf.list = JSON:decode(default)
	else	
		conf.list = JSON:decode(file.read(conf.fileName))
	end

	return conf.list

end

conf.save = function()	

	file.write(conf.fileName, JSON:encode_pretty(api.conf))

end