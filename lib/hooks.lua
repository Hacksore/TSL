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

	local hooks = hook.list[hookName]

	for k, func in pairs(hooks) do
		
		func(...)

	end

end