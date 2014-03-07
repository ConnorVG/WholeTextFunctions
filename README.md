WholeTextFunctions (WTF)
========================

WTF is a Lua library for string-based commands. This is especially useful in situations where you expect the user to execute the command via a text medium (E.G: Chatbox / Console).

Syntax
------

### Understanding the Syntax

An example command would be as so:
	`commandName argName:argType [argName:argType]`

Let's break this down.

* ##### `commandName`
	This is the name of the command and subsequently what is used to define which command to execute. For example, if a command with no arguments had a name of `test` you could simply execute said command via `wtf:Execute(test)`.

* ##### `argName:argType`
	This is an argument for a command, this has two parts to it. 

	The first part, described as `argName`, is exactly what you would expect (the name of the argument). This is useful because if the user tries to execute a command with incorrect syntax we can simply return the syntax and the argument name that the user messed up on.
	
	The second part, described as `argType`, is the data type of the argument (please refer to [Argument Types](#Argument Types) for all available data types). This is used to check the syntax of a command and for ensuring the correct data type gets to the the final function call.

* ##### `[argName:argType]`
	This is an optional argument for a command (please refer to [argName:argType](#argName:argType) for more information regarding arguments). The only difference between this and a regular argument is that this is optional therefore non-required for the user to pass syntax.

### Adding a Command

### Adding an Alias

### Executing a Command
