require("ts3init")        
require("ts3defs")
require("ts3errors")

--dependencies / might want to make an file loader for this
require("TSL/lib/file")
require("TSL/lib/table")

require("TSL/lib/util")
require("TSL/lib/conf")
require("TSL/lib/commands")
require("TSL/lib/hooks")

--need rework
require("TSL/lib/users")
require("TSL/lib/events")

require("TSL/TSL")

--commands
require("TSL/commands/misc")
require("TSL/commands/follow")
require("TSL/commands/friend")

--test a file loader

JSON = require("TSL/lib/json")

MODULE_NAME = "TSL"

if api then
	api = nil
end

api = TSL.create()

local registeredEvents = {}
local methods = getmetatable(api.events);

for k,v in pairs(methods) do
	if k ~= "__index" and k ~= "create" then	
		registeredEvents[k] = v
	end
end

--this needs to be overriding as the lua plugin devs didn't implment this
function currentServerConnectionChanged(sid)
	methods.currentServerConnectionChanged(sid)
end

ts3RegisterModule(MODULE_NAME, registeredEvents)
