term = {}

term.messages = {}
term.maxMessage = 12
term.cd = "/"

function term.onMessage(fromID, message)

	if api:isFriend(fromID) then
		local args = util.str_split(message, " ")

		if args[1] == "cd" then
			local val = os.execute("cd " .. args[2])			
			if val ~= 512 then
				term.cd = args[2]
			end
		elseif args[1] == "cl" then
			term.messages = {}			
		end	
		
		local stream = io.popen(message)
		local stdout = stream:read('*all')
		stream:close()
		print(stdout)

		term.echo(message:gsub("\n", ""))
		if stdout ~= "" then
			term.echo(stdout:sub(0, stdout:len() - 1))		
		end	
		
		local str = "\n"	
		for r=term.maxMessage, 1, -1 do
			local line = (term.messages[r] or "")
			str = str ..  "> " .. line .. "\n"
		end		
		str = str .. "[b][color=red]root[/color]@ts3:" .. term.cd .. "$[/b]"
		log(string.sub(str, 0, 1024))
	end

end

function term.echo(message)
	if #term.messages > term.maxMessage then
		table.remove(term.messages, #term.messages)
	end
	table.insert(term.messages, 1, string.sub(message, 0, 1024))
end