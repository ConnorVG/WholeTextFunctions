--	--	--	--	--
--	Debugging	--
--	--	--	--	--

--	Levels
local LEVEL_NONE, LEVEL_INFO, LEVEL_ERROR = 1, 2, 3
local DEBUG_LEVEL = LEVEL_ERROR

--	Outputting
local function debug_out(level, message)
	if DEBUG_LEVEL < level then return end

	print(level == LEVEL_INFO and "INFO:" or "ERROR:", message)
	return message
end



--	--	--	--	--	--	--	--	--	--
--	Locals and utility functions	--
--	--	--	--	--	--	--	--	--	--

--	Argument Types
local ARG_SOURCE, ARG_REMAINING, ARG_STRING, ARG_NUMBER, ARG_BOOL = 1, 2, 3, 4, 5
local ARG_DEFINITIONS = {
	["source"] = ARG_SOURCE,
	["remaining"] = ARG_REMAINING,
	["string"] = ARG_STRING,
	["number"] = ARG_NUMBER,
	["bool"] = ARG_BOOL,

	[ARG_SOURCE] = "source",
	[ARG_REMAINING] = "remaining",
	[ARG_STRING] = "string",
	[ARG_NUMBER] = "number",
	[ARG_BOOL] = "bool",
}

--	Tables
local remove, insert = table.remove, table.insert

--	Strings
local find, sub, rep = string.find, string.sub, string.rep

local function split(txt, del)
	del = del or "\r*\n\r*"
	local pieces, cnt, a, b, c = {}, 1, 0, 1

	while a do
		a, c = find(txt, del, b)

		if not a or not c then break end

		pieces[cnt] = sub(txt, b, a - 1)
		cnt = cnt + 1
		b = c + 1
	end

	pieces[cnt] = sub(txt, b)

	return pieces
end

local function split_special(txt, del, del2)
	local s = sub(txt, 1, 1) == del and 0 or 1
	local str = split(txt, del)

	local new = {}
	for i = 1, #str do
		if i % 2 == s then
			local adding = split(str[i], del2)
			for j = 1, #adding do
				if adding[j] and adding[j] ~= "" then
					insert(new, adding[j])
				else i = i - 1 end
			end
		else insert(new, str[i]) end
	end

	return new
end


--	--	--	--
--	Globals	--
--	--	--	--

local WTF_CMD_SUCCESS, WTF_CMD_FAIL = 0, 1
_G.WTF_CMD_SUCCESS, _G.WTF_CMD_FAIL = WTF_CMD_SUCCESS, WTF_CMD_FAIL



--	--	--	--	--	--	--	--
--	(Meta)tables and states	--
--	--	--	--	--	--	--	--

WholeTextFunctions = {}
WholeTextFunctions.__index = {}



--	--	--	--	--	--
--	Core functions	--
--	--	--	--	--	--

function WholeTextFunctions.New()
	local self = {}

--	Defaults
	self.Commands = {}
	self.Aliases = {}

--	Meta
	setmetatable(self, WholeTextFunctions)

	return self
end

local function _GetFormat(command)
	local data = split(command, " ")

--	Command with no arguments
	if #data == 1 then return { data[1]:lower() }

--	Why even?
	elseif #data == 0 then return {} end

--	Arguments are involved
	local formattedData = { data[1]:lower(), command }

	for i = 2, #data do
		local arg, arg_optional = data[i], false
		if sub(arg, 1, 1) == "[" and sub(arg, #arg, #arg) == "]" then
			arg_optional = true
			arg = sub(arg, 2, #arg - 1)
		end

		local arg_data = split(arg, ":")
		if #arg_data ~= 2 then debug_out(LEVEL_ERROR, "Format error: Argument declarations must be \"Name:Type\"! For example: \"Amount:number\".") return end

		local arg_type = ARG_DEFINITIONS[arg_data[2]:lower()]
		if not arg_type then debug_out(LEVEL_ERROR, "Format error: Unknown argument type!") return end

		insert(formattedData, { arg_data[1], arg_type, arg_optional })
	end

	return formattedData
end

local function _CheckCommand(self, base)
	local commands, i = self.Commands, 1
	while i <= #commands do
		local command = commands[i]
		if command[1] == base then return true end

		i = i + 1
	end

	return false
end

local function _AddCommand(self, format, func)
	local commands, i = self.Commands, 1
	while i <= #commands do
		local command = commands[i]
		if command[1] == format[1] then return debug_out(LEVEL_ERROR, "There is already a command named \"" .. format[1] .. "\".") end

		i = i + 1
	end

	local command = format
	command.func = func

	insert(self.Commands, command)
end

function WholeTextFunctions.__index:AddCommand(command, func)
	local format = _GetFormat(command)

--	Command with and/or without arguments
	if #format ~= 0 then return _AddCommand(self, format, func)

--	Why even?
	else return debug_out(LEVEL_ERROR, " ... creative error name here ... ") end
end

local function _CheckAlias(self, base)
	local aliases, i = self.Aliases, i or 1
	while i <= #aliases do
		local alias = aliases[i]
		local a_from, a_to = alias[1], alias[2]

		if a_from == base then return a_to, i end

		i = i + 1
	end return nil
end

local function _AddAlias(self, base, alias, redirect)
	insert(self.Aliases, { alias, base, redirect or false })
end

function WholeTextFunctions.__index:AddAlias(base, alias)
	local check, i, rm

	check, i = _CheckAlias(self, alias)
	if check then 
		debug_out(LEVEL_INFO, "Alias \"" .. alias .. "\" already in use.")

		rm = i
	end

	check, i = _CheckAlias(self, base)
	if check then
		debug_out(LEVEL_INFO, "Redirecting \"" .. alias .. "\" to \"" .. base .. "\".")

		if rm then remove(self.Aliases, rm) end
		_AddAlias(self, base, alias, true)
	return end

	if rm then remove(self.Aliases, rm) end
	_AddAlias(self, base, alias)
end

local function _GetRealCommand(self, base, full)
	local real, j, i = _CheckAlias(self, base)
	while real ~= nil and base ~= real do
		base, i = real
		real, j = _CheckAlias(self, base)
	end

	return base, i
end

local function _Execute(self, base, args, source)
	local commands, command, i = self.Commands, nil, 1
	while i <= #commands do
		command = commands[i]
		if command[1] == base then break end
		
		i = i + 1
	end
	if i > #commands then return WTF_CMD_FAIL, debug_out(LEVEL_ERROR, "Command \"" .. base .. "\" not found!") end

	if #command == 1 then
		return WTF_CMD_SUCCESS, command.func(self)
	end

	if not args then
		args = {}
	end

	local i, j, params, remaining = 3, 1, {}, source
	while i <= #command do
		local arg = command[i]
		local arg_type, arg_optional = arg[2], arg[3]

		if not arg_optional and #args < j then return WTF_CMD_FAIL, debug_out(LEVEL_ERROR, "Incorrect syntax, use: \"" .. command[2] .. "\"!") end

		if arg_optional and #args < j then
			if arg_type >= ARG_SOURCE and arg_type <= ARG_STRING then
				insert(params, "")
			else insert(params, "nil") end
		else
			if arg_type == ARG_SOURCE then
				insert(params, source)
				args, remaining = { nil }, nil
			elseif arg_type == ARG_REMAINING then
				if j > 1 and #remaining > 1 then remaining = sub(remaining, 2) end

				insert(params, remaining)
				args, remaining = { nil }, nil
			elseif arg_type == ARG_STRING then
				insert(params, args[j])

				if #remaining > #args[j] then
					remaining = sub(remaining, #args[j] + 1)
				else remaining = "" end
			elseif arg_type == ARG_NUMBER then
				local n = tonumber(args[j])
				if not n then 
					if arg_optional then
						j = j - 1
						insert(params, "nil")
					else return WTF_CMD_FAIL, debug_out(LEVEL_ERROR, "Incorrect syntax (expected \"" .. arg[1] .. ":" .. ARG_DEFINITIONS[arg_type] .. "\", got \"" .. args[j] .. "\"), use: \"" .. command[2] .. "\"!") end
				else 
					insert(params, n) 

					if #remaining > #args[j] then
						remaining = sub(remaining, #args[j] + 1)
					else remaining = "" end
				end
			elseif arg_type == ARG_BOOL then
				local b = tobool(args[j])
				if not b then
					if arg_optional then 
						j = j - 1
						params[#params] = nil
						insert(params, "nil")
					else return WTF_CMD_FAIL, debug_out(LEVEL_ERROR, "Incorrect syntax (expected \"" .. arg[1] .. ":" .. ARG_DEFINITIONS[arg_type] .. "\", got \"" .. args[j] .. "\"), use: \"" .. command[2] .. "\"!") end
				else 
					insert(params, b) 

					if #remaining > #args[j] then
						remaining = sub(remaining, #args[j] + 1)
					else remaining = "" end
				end
			end
		end
		
		i, j = i + 1, j + 1
	end

	return WTF_CMD_SUCCESS, command.func(self, unpack(params))
end

function WholeTextFunctions.__index:Execute(command)
	local data = split_special(command, "\"", " ")

--	Command with no arguments
	if #data == 1 then return _Execute(self, _GetRealCommand(self, command:lower()))

--	Why even?
	elseif #data == 0 then return WTF_CMD_FAIL, debug_out(LEVEL_ERROR, " ... creative error name here ... ") else

--	Arguments are involved
		local args, source = {}, ""
		for i = 2, #data do
			insert(args, data[i])

			if i ~= 2 then source = source .. " " end
			source = source .. data[i]
		end

		return _Execute(self, _GetRealCommand(self, data[1]:lower()), args, source)
	end
end

local function _AutoComplete(self, str, limit)
	local any = #str < 1
	limit = limit < 1 and 1 or limit

	if not any then str = split(str, " ")[1] end

	local commands, i, j, ac = self.Commands, 1, 1, {}
	limit = limit > #commands and #commands or limit
	while i <= #commands and j <= limit do
		local cmd = commands[i]
		local cmd_ac = cmd[2] or cmd[1]
		if any or sub(cmd_ac, 1, #str > #cmd_ac and #cmd_ac or #str) == str:lower() then
			insert(ac, { cmd[1], cmd_ac })

			j = j + 1
		end

		i = i + 1
	end

	return ac
end

function WholeTextFunctions.__index:AutoComplete(str, limit)
	if #self.Commands < 1 then return {} else return _AutoComplete(self, str, limit or 5) end
end

local function _GetAliases(self, str, limit)
	local any = #str < 1

	if not any then str = split(str, " ")[1] end

	local aliases, i, j, rt = self.Aliases, 1, 1, {}
	limit = limit > #aliases and #aliases or limit
	while i <= #aliases and j <= limit do
		local alias = aliases[i]
		local rl_alias = alias[2]

		if any or sub(rl_alias, 1, #str > #rl_alias and #rl_alias or #str) == str:lower() then
			insert(rt, { alias[1], rl_alias })

			j = j + 1
		end

		i = i + 1
	end

	return rt
end

function WholeTextFunctions.__index:GetAliases(str, limit)
	if #self.Aliases < 1 then return {} else return _GetAliases(self, str, limit or -1) end
end



--	--	--	--	--	--
--	Test functions	--
--	--	--	--	--	--

local wtf = WholeTextFunctions.New()

function WholeTextFunctions.GetMain()
	return wtf
end

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