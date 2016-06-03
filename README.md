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
    print(clientData.username .. " has disconnected from the server!")

end)
```

# Todo
* Convert table lib to lowercase method names
* Move logic event logic to hooks
* Create a barebone/skeleton branch that has no additions
* Improve the readability of PrintTable
