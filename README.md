# TSL
This is a Lua framework for creating rohbust Teamspeak3 plugins. It provies many additions that are not part of the native Lua plugin.


# Features
* Easy command management
* Persistant Config (JSON)
* Many useful utility methods
* Data cache for all users

# Usage

Here is an example of creating a command
```lua
command.add("test", function(self, fromID, args)

	local clientData = Users:getData(self.sid, fromID)
    print(clientData.username .. " has uniqueID = " .. clientData.uniqueID)

end)
```

Here is an example of creating a hook
```lua
hook.add("ClientLoaded", "setupVars", function(self)

	print("Client has loaded!")

end)
```

# Installation

Download  the source by cloning or using the zip. Place the TSL-master folder inside your Teamspeak 3 lua_plugin folder which you can locate at the following directory

x64
`C:\Program Files\TeamSpeak 3 Client\plugins\lua_plugin`

x32
`C:\Program Files (x86)\TeamSpeak 3 Client\plugins\lua_plugin`


# Todo
* Convert table lib to lowercase method names
* Move event logic to hooks
* Create a barebone/skeleton branch that has no additions
* Make the command.add callback include clientData
* Multi OS support