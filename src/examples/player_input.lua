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