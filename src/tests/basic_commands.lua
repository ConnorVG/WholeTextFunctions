--	--	--	--
--	Locals	--
--	--	--	--

local sub, rep = string.sub, string.rep



--	--	--	--
--	Tests	--
--	--	--	--

local wtf = WholeTextFunctions.GetMain()

wtf:AddCommand("print [Text:source]", function(wtf, text) print(text) end)
wtf:AddAlias("print", "p")
wtf:AddAlias("print", "echo")

wtf:AddCommand("error [Text:source]", function(wtf, text) error(text) end)
wtf:AddAlias("error", "err")
wtf:AddAlias("error", "e")

wtf:AddCommand("autocomplete [Limit:number] [Text:remaining]", function(wtf, limit, src)
	limit = limit == "nil" and 5 or limit
	local ac = wtf:AutoComplete(src, limit)

	PrintTable(ac)
end)
wtf:AddAlias("autocomplete", "ac")

wtf:AddCommand("aliases [Limit:number] [Text:remaining]", function(wtf, limit, src)
	limit = limit == "nil" and 5 or limit
	local a = wtf:GetAliases(src, limit)

	PrintTable(a)
end)
wtf:AddAlias("aliases", "al")

wtf:AddCommand("commands", function(wtf, src)
	if #wtf.Commands > 0 then
		print("[[--", "Commands", "--]]")

		local commands, i = wtf.Commands, 1
		local pl = #tostring(#commands) + 2
		local str_pad = rep(' ', pl)

		while i <= #commands do
			local command = commands[i]

			local idx_str = i .. ':'
			print(rep(' ', pl - #idx_str) .. idx_str, '"' .. command[1] .. '"')

			local syntax = '"' .. (command[2] and command[2] or command[1]) .. '"'
			print(str_pad, "Syntax:")
			print(str_pad, str_pad, syntax)

			print(str_pad, "Function:")

			local d_info = debug.getinfo(command.func, 'Sn')
			if d_info.name then
				print(str_pad, str_pad, d_info.name)
			end
			print(str_pad, str_pad, d_info.short_src .. ":" .. d_info.linedefined)
			print(str_pad, str_pad, sub(tostring(command.func), 11))

			if #commands > i then print() end
			i = i + 1
		end
	end

	if #wtf.Aliases > 0 then
		if #wtf.Commands > 0 then print() end

		print("[[--", " Aliases", "--]]")

		local aliases, i = wtf.Aliases, 1
		local pl = #tostring(#aliases) + 2
		local str_pad = rep(' ', pl)
		while i <= #aliases do
			local alias = aliases[i]

			local idx_str = i .. ':'
			print(rep(' ', pl - #idx_str) .. idx_str, "Alias:")
			print(str_pad, str_pad, alias[1])

			print(str_pad, "Base:")
			print(str_pad, str_pad, alias[2])

			if #aliases > i then print() end
			i = i + 1
		end
	end
end)
wtf:AddAlias("commands", "cmds")