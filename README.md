WholeTextFunctions (WTF)
========================

WTF is a Lua library for string-based commands. This is especially useful in situations where you expect the user to execute the command via a text based medium (E.G: Chatbox / Console).

Licensing
---------
```
Copyright (c) 2014, Connor S. Parks and Alexandru Maftei
All rights reserved.

Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions are met:

    * Redistributions of source code must retain the above copyright
      notice, this list of conditions and the following disclaimer.
    * Redistributions in binary form must reproduce the above copyright
      notice, this list of conditions and the following disclaimer in the
      documentation and/or other materials provided with the distribution.
    * Neither the name of WholeTextFunctions (WTF) nor the
      names of its contributors may be used to endorse or promote products
      derived from this software without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
DISCLAIMED. IN NO EVENT SHALL Connor S. Parks or Alexandru Maftei BE LIABLE FOR ANY
DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
(INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
(INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
```

Syntax
------

### Understanding the Syntax

An example command would be as so:
	`commandName argName:argType [argName:argType]`

Let's break this down.

* ##### `commandName`
	This is the name of the command and subsequently what is used to define which command to execute. For example, if a command with no arguments had a name of `test` you could simply execute said command via `wtf:Execute(test)`.

	*Note: During execution, `commandName` is case-insensitive!*

* ##### `argName:argType`
	This is an argument for a command, this has two parts to it. 

	The first part, described as `argName`, is exactly what you would expect (the name of the argument). This is useful because if the user tries to execute a command with incorrect syntax we can simply return the syntax and the argument name that the user messed up on.
	
	The second part, described as `argType`, is the data type of the argument (please refer to [Argument Types](#argument-types) for all available data types). This is used to check the syntax of a command and for ensuring the correct data type gets to the the final function call.

* ##### `[argName:argType]`
	This is an optional argument for a command (please refer to [argName:argType](#argnameargtype) for more information regarding arguments). The only difference between this and a regular argument is that this is optional therefore non-required for the user to pass syntax.

	If this argument is ignored by the user, a default value of `"nil"` will be passed to the command's function.

### Adding a Command

Adding a command is extremely simple, as-long as you understand the syntax (please refer to [Understanding the Syntax](#understanding-the-syntax) to learn about the syntax).

All you need to do is:
* Think of a command name, let's use `print`.
* Think of which arguments we may require (plus if they should be optional), let's use `[indentLevel:number] message:remaining`.
* Think of a function of which we want to call on execution of the command, let's use:
```lua
function(wtf, indent, message)
	if indent ~= 'nil' then
		message = string.rep('-', indent - #message) .. message
	end

	print(message)
end
```

To add this command, all we need to do is:
```lua
wtf:AddCommand('print [indentLevel:number] message:remaining', function(wtf, indent, message)
	if indent ~= "nil" then
		message = string.rep('-', indent - #message) .. message
	end

	print(message)
end)
```

*Note: The first variable passed to the command's function is always the instance of WTF used to execute said function!*

### Adding an Alias

Adding an alias is even more simple than adding a command.

All you need to do is:
* Think of an alias name, let's use `p`.
* Think of the command OR alias you wish to create an alias for, let's use `print` (see [Adding a Command](#adding-a-command) for more information on this command).

To add this alias, all we need to do is:
```lua
wtf:AddAlias('print', 'p')
```

### Executing a Command

The method of which you decide to execute a command will be entirely based on your implementation of WTF. The only thing all implementations will have in common is the base command execution.

To execute a command, all we need to do is (where `command` is your command string. For example: `print Hello!`):
```lua
wtf:Execute(command)
```

### Argument Types

Currently, WTF only has support for a few data types. This list will grow once I create an optional 'less-light' version of WTF's parsing system.

The current data types are as follows:
* `source`: The whole command string (without the `commandName` included) as a Lua string.
* `remaining`: The rest of the command string left (`source` without any used arguments included) as a Lua string.
* `string`: A simple Lua string.
* `number`: Any Lua number.
* `bool`: Simply put, Lua's booleans (`true` or `false`).

### Examples

All current examples can be found within the `src/examples` directory. Please note, most of these examples use imaginary environments and are not meant to just work out of the box. E.G: In the `player_input.lua` example, we make a function `recievePlayerInput(input)` which, in a real world scenario, would actually be much different and specific to the usage.

*Note: During this README, we imagine the variable `wtf` is an instance of `WholeTextFunctions`.*
