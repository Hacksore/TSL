--file helper
file = file or {}

function file.read(fileName, mode)	
	mode = mode or "r"
	local f = io.open(fileName, mode)
	local data = f:read("*all")
	f:close()
	return data or false
end

function file.write(fileName, data)	
	local f = io.open(fileName, "w")
	f:write(data)
	f:close()
end

function file.exists(fileName)	
	local f = io.open(fileName)
	local t = io.type(f)
	local bool = io.type(f) and true or false
	
	if t then
		f:close()
	end

	return bool
end