--hooks i guess?
hook = {}
hook.list = {}

function hook.add(hookName, hookID, callback)

	if hook.list[hookName] == nil then
		hook.list[hookName] = {}
	end

	hook.list[hookName][hookID] = callback

end

function hook.remove(hookName, hookID, callback)

	hook.list[hookName][hookID] = nil

end

function hook.call(hookName, ...)

	local args = {...}
	local hooks = hook.list[hookName] or false

	if not hooks then return false end

	local retVal = nil
	table.ForEach(hooks, function(k, v)

		retVal = v(args[1])

	end)

	return retVal
end

