--[[
	Copyright (c) 2013, Connor S. Parks and Alexandru Maftei
	All rights reserved.

	Redistribution and use in source and binary forms, with or without
	modification, are permitted provided that the following conditions are met:

	   * Redistributions of source code must retain the above copyright
	     notice, this list of conditions and the following disclaimer.
	   * Redistributions in binary form must reproduce the above copyright
	     notice, this list of conditions and the following disclaimer in the
	     documentation and/or other materials provided with the distribution.
	   * Neither the name of <addon name> nor the
	     names of its contributors may be used to endorse or promote products
	     derived from this software without specific prior written permission.

	THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
	ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
	WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
	DISCLAIMED. IN NO EVENT SHALL <your name> BE LIABLE FOR ANY
	DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
	(INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
	LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
	ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
	(INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
	SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
--]]

--	--	--	--
--	Locals	--
--	--	--	--

local sub, rep, format = string.sub, string.rep, string.format



--	--	--	--	--	--	--
--	Courtesy of Vercas	--
--	(github.com/Vercas)	--
--	--	--	--	--	--	--

local function prettystring(data)
	if type(data) == "string" then
		return format("%q", data)
	else
		return tostring(data)
	end
end

local colkeys = { a = true, r = true, g = true, b = true}
local function isColor(tab)
	local hits = 0

	for k, _ in pairs(tab) do
		if colkeys[k] then
			hits = hits + 1
		else
			return false
		end
	end

	return hits == 4
end

local function tabletostring(t, indent, done)
	done = done or {}
	indent = indent or 0
	local str, cnt = "", 0

	for key, value in pairs(t) do
		str = str .. rep ("    ", indent)

		if type(value) == "table" and not done[value] then
			done[value] = true

			local ts = tostring(value)

			if isColor(value) then
				str = str .. prettystring(key) .. " = " .. string.format("# %X %X %X %X", value.a, value.r, value.g, value.b) .. "\n"
			elseif ts:sub(1, 9) == "table: 0x" then
				local _str, _cnt = tabletostring(value, indent + 1, done)

				str = str .. prettystring(key) .. ":" .. ((_cnt > 0) and ("\n" .. _str) or " empty table\n")
			else
				str = str .. prettystring(key) .. " = " .. ts .. "\n"
			end
		else
			str = str .. prettystring(key) .. " = " .. prettystring(value) .. "\n"
		end

		cnt = cnt + 1
	end

	return str, cnt
end



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

--	Avoid cnt
	local str = tabletostring(ac)
	print(str)
end)
wtf:AddAlias("autocomplete", "ac")

wtf:AddCommand("aliases [Limit:number] [Text:remaining]", function(wtf, limit, src)
	limit = limit == "nil" and 5 or limit
	local a = wtf:GetAliases(src, limit)

--	Avoid cnt
	local str = tabletostring(a)
	print(str)
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