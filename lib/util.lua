util = {}

--replcae old util.str_split with this garry method
function string.Explode(str, separator)
		 
	local ret = {}
	local index,lastPosition = 1,1
	 
	-- Find the parts
	for startPosition,endPosition in string.gmatch( str, "()" .. separator.."()" ) do
		ret[index] = string.sub( str, lastPosition, startPosition-1)
		index = index + 1
		 
		-- Keep track of the position
		lastPosition = endPosition
	end
	 
	-- Add last part by using the position we stored
	ret[index] = string.sub( str, lastPosition)
	return ret
end

function util.str_split(str, pat)
	local t = {}  -- NOTE: use {n = 0} in Lua-5.0
	local fpat = "(.-)" .. pat
	local last_end = 1
	local s, e, cap = str:find(fpat, 1)
	while s do
		if s ~= 1 or cap ~= "" then
			table.insert(t,cap)
		end
		last_end = e+1
		s, e, cap = str:find(fpat, last_end)
	end
	if last_end <= #str then
		cap = str:sub(last_end)
		table.insert(t, cap)
	end
	return t
end

function util.getChannelClients(cid)
	local clients = ts3.getClientList(ts3.getCurrentServerConnectionHandlerID())
	local cl = {}
	for k,v in pairs(clients) do -- loop channels v = client id
		if cid == v then
			local name = ts3.getClientVariableAsString(ts3.getCurrentServerConnectionHandlerID(), v, ts3defs.ClientProperties.CLIENT_NICKNAME)
			table.insert(cl, name)
		end
	end
	return cl
end

function util.getChannelClientIds(serverID)
	local chan = util.getOwnChannel(serverID)
	return ts3.getChannelClientList(serverID, chan)
end

function util.moveToChannel(serverID, clientID)
	local chanID = util.getUserChannelID(serverID, clientID)
	ts3.requestClientMove(serverID, clientID, chanID, "")
end

function util.moveToChannelID(sid, chanID)
	local myId = util.getOwnID(sid)
	ts3.requestClientMove(sid, myId, chanID, "")
end

function util.moveSelfToChannel(serverID, chanID)
	local clientID = util.getOwnID(serverID)
	ts3.requestClientMove(serverID, clientID, chanID, "")
end

function util.getClientList()

	local clients, error = ts3.getClientList(ts3.getCurrentServerConnectionHandlerID())
	if error == ts3errors.ERROR_not_connected then
		ts3.printMessage(ts3.getCurrentServerConnectionHandlerID(), "Not connected")
		return
	elseif error ~= ts3errors.ERROR_ok then
		print("Error getting client list: " .. error)
		return
	end
	return clients
end

function util.isNotMe(serverID, clientID)
	return util.getOwnID(serverID) ~= clientID
end

function util.getOwnID(serverID)
	local id = serverID and serverID or ts3.getCurrentServerConnectionHandlerID()
	local myClientID, error = ts3.getClientID(id)

	return myClientID
end

function util.getOwnChannel(serverID)
	return util.getUserChannelID(serverID, util.getOwnID(serverID))	
end

function util.getUserChannelID(serverID, userID)
	local channelID, error = ts3.getChannelOfClient(serverID, userID)
	if error ~= ts3errors.ERROR_ok then
		return 1
	end
	return channelID
end

function util.getUsernameByID(sid, userID)

	local clientName, clientNameError = ts3.getClientVariableAsString(sid, userID, ts3defs.ClientProperties.CLIENT_NICKNAME)
	if clientNameError ~= ts3errors.ERROR_ok then
		return nil
	end
	return clientName

end

function util.getUserIDByUID(sid, clientID)

	local clients = ts3.getClientList(sid)
	local str = ""
	for i=1, #clients do
		local uid = ts3.getClientVariableAsString(sid, i, ts3defs.ClientProperties.CLIENT_UNIQUE_IDENTIFIER)

		if uid == clientID then
			-- local name = ts3.getClientVariableAsString(sid, clients[i], ts3defs.ClientProperties.CLIENT_NICKNAME)
			local version = ts3.getClientVariableAsString(sid, clients[i], ts3defs.ClientProperties.CLIENT_VERSION)
			return {
				-- name = name,
				version = version
			}	
		end
	end	
	return nil
end

function util.getUserID(username)
	if type(tonumber(username)) == "number" then		
		return username
	end

	local l = ts3.getClientList(ts3.getCurrentServerConnectionHandlerID())
	local str = ""
	for i=1, #l do
		local name = ts3.getClientVariableAsString(ts3.getCurrentServerConnectionHandlerID(), l[i], ts3defs.ClientProperties.CLIENT_NICKNAME)
		if(name:lower():find(username:lower())) then
			return l[i]	
		end
	end	
	return nil
end

--temp fix
function util.popen(command)
	local filename = "%temp%/" .. os.tmpname()
	os.execute(command .." > ".. filename .. "")
	local file = io.open(filename, "r")
	local result = file:read("*a")
	file = io.close()
	os.execute("rm "..filename)
	return result
end

function util.sleep(sec)
	return util.popen("sleep "..sec)
end

function util.getReq(uri)
	return util.popen("curl "..uri)
end

function util.getReqFast(uri)
	os.execute("curl -s "..uri)
end

function util.getServerHash(serverID)
	return ts3.getServerVariableAsString(serverID, ts3defs.VirtualServerProperties.VIRTUALSERVER_UNIQUE_IDENTIFIER)
end

function urlencode(str)
	str = string.gsub (str, "\n", "\r\n")
	str = string.gsub (str, "([^0-9a-zA-Z ])", -- locale independent
			function (c) return string.format ("%%%02X", string.byte(c)) end)
	str = string.gsub (str, " ", "+")
	return str
end

function PrintTable( t, indent, done )

	done = done or {}
	indent = indent or 0
	local keys = table.GetKeys( t )

	table.sort( keys, function( a, b )
		if ( type( a ) == "number" and type( b ) == "number" ) then return a < b end
		return tostring( a ) < tostring( b )
	end )
	
	for i = 1, #keys do
		local key = keys[ i ]
		local value = t[ key ]

		local spacing = string.rep( "    ", indent )

		if  type(value) == "table" and not done[ value ] then
			local emptyTable = table.Count(value) <= 0 and "{}" or ""
			done[ value ] = true

			log("[b][color=#5f894e]" .. spacing .. "\"" .. tostring( key ) .. "\"" .. " " .. emptyTable .. "[/color][/b]")

			PrintTable ( value, indent + 2, done )
			done[ value ] = nil

		else

			log("[b][color=#5b5b5b]" .. spacing .. tostring( key ) .. " = " .. tostring( value ) .. "[/color][/b]")

		end
	end

end

function math.clamp(val, lower, upper)
    if lower > upper then lower, upper = upper, lower end -- swap if boundaries supplied the wrong way
    return math.max(lower, math.min(upper, val))
end

function log(msg)
	ts3.printMessageToCurrentTab(msg)
end

function util.lineBar(val, max, color, width)
	local str = ""
	local right = ""
	local bW = math.ceil((val / max) * width)
	
	for i=1, bW do
		str = str .. "█"
	end
	
	for i=1, width-bW do
		right = right .. "█"
	end
	
	if right ~= "" then
		right = "[color=#4c4c4c]" .. right .. "[/color]"
	end
		
	return "[color=" .. color .. "]" .. str .. "[/color]" .. right
end

function util.barGraph(arr)
	local w, h = 40, 8
	local highest = 0	
	local str = ""
	local sum = 0
	local avg = 0
	for i=1, #arr do
		if arr[i] > highest then 
			highest = arr[i]
		end
		sum = sum + arr[i]
 	end
	avg = sum / #arr
	
	for row=math.clamp(highest,0, h), 1, -1 do --rows
		local line = ""
		local scale = 0
		for cols=1, math.clamp(#arr, 0, w) do -- cols
			local val = arr[cols]
			scale = math.ceil((val/highest) * h)
				
			if scale >= row then		
				line = line .. "█"
			else
				line = line .. "▒"
			end
						
			local s = math.ceil((row/h) * highest)
			if cols == #arr then
				line = line .. " " .. s
			end
			
		end
		str = str .. line .. "\n"
	end
	return str
end

function util.exec(cmd)
	local stream = io.popen(cmd)
	local stdout = stream:read("*all")
	stream:close()
	return stdout
end

--is* methods

function istable(val)
	return type(val) == "table"
end

function isnumber(val)
	return type(val) == "number"
end

function isstring(val)
	return type(val) == "string"
end

function isfunction(val)
	return type(val) == "function"
end