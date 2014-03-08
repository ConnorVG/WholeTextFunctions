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

--	--	--	--	--	--	--	--
--	WTF Helper Functions	--
--	--	--	--	--	--	--	--

local sub, trim = string.sub, function(s) return (s:gsub("^%s*(.-)%s*$", "%1")) end

local function IsCommand(playerInput, initiator)
	if #playerInput < 2 or sub(playerInput, 1, 1) ~= initiator then
		return { false }
	end

	local command = sub(playerInput, 2)
	command = trim(command)

	return { #command > 0, command }
end



--	--	--	--	--	--	--
--	Psuedo Functions	--
--	--	--	--	--	--	--

--	The function called when the player sends something from an input (E.G: Chatbox)
local function recievePlayerInput(input)
	local isCommand = IsCommand(input, ':');

	if isCommand[1] then
		input = isCommand[2]

		print('Real command "' .. input .. '"')
		local output, dump = WholeTextFunctions.GetMain():Execute(input)
		local success = output == WTF_CMD_SUCCESS

		if not success then
			print('Error: ' .. dump)
		end
	else
		print('Not command "' .. input .. '"')
	--	SendToChat( ... )
	end
end

recievePlayerInput('this is not a command')
recievePlayerInput('nor is this')

recievePlayerInput(':')

recievePlayerInput(':this is a command that doesn\'t exist')

recievePlayerInput(':print "Hoorah!"')
recievePlayerInput(':print Hellooooooooooooooo, is it me you\'re looking for?')