command = {}
command.list = {}

command.alias = {}


function command.add(name, callback)

	command.list[name] = {
		callback = callback,
		alias = {}
	}

	local method = {
		addAlias = function(...)
			local args = {...}
	
			for k,v in pairs(args) do
				command.alias[v] = name
				table.insert(command.list[name].alias, v)
			end
		end
	}
	
	return method
	
end

function command.isAlias(name)
	return command.alias[name] ~= nil
end

--TODO: make the callback include clientData instead of just id
function command.run(name, self, from, args)
	if command.isAlias(name) then
		name = command.alias[name]
	end
	if command.list[name] ~= nil then
		command.list[name].callback(self, from, args)
		return true
	end
	return false
end