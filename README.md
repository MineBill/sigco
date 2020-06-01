# Simple Godot Console #

Simple Godot Console(SiGCo) is a simple in-game console to be used in games and provide an easy way to execute commands from your scripts.

It is implemented in GDScript to be compatible with any Godot project(C# requires the Mono version of the engine).

## Features

* Name-based suggestions

## Installation

1. Clone the repo and add it to your project.
2. Go to your Project Settings -> AutoLoad and add the Sigco.tscn and name it what you want.
3. Add "open_console" and "complete_console" actions to your project Input Map.
4. You can now use it inside your scripts!
e.g:
```gdscript
Sigco.register("hello", "cmd_hello", self, {})
```

## Usage

You can register commands with the `register` function called on the node that contains the sigco.gd sript.
The `register` function has 4 parameters:
```gdscript
func register(cmd_name: String, func_name: String, obj: Object, _options: Dictionary) -> void:
```
1. *cmd_name*: The name of the command you want to add.
2. *func_name*: The name of the function you want to be called when the command is executed.
3. *obj*: The object where the function with `func_name` lives.
4. *options*: Optional parameters that provide info about command or dictate how it should behave. For example:
	* *description*: The description that should be displayed when the **help** command executes.

Here is how a callable function looks:
```gdscript
func cmd_help(_args) -> void:
	var opt = {
		'prefix': '    '
	}
	for cname in func_refs:
		_write("%s - %s" % [cname, func_refs[cname]["description"]], opt)
```
As you can see, it takes one parameter and returns void. The parameter is a string array of all the space-seperated words entered after the command name.

# Important!

The .tscn and .tres files expect to be placed in the root folder, inside a folder called 'Sigco' *(res://Sigco/Sigco.tscn)*. If you want to place them elsewhere you'll have to update the paths when you try to open the .tscn file inside Godot.

## Contributing and Issues

Please do. If you want to contribute, help, report an issue or ask anything don't hesitate. Any help is welcome.

## Notes

Please keep in mind that this is a hobby project. I'll try my best to maintain this project because it's something that i like but i can't promise anything. Life happens and you can never be sure of anything.

# License

MIT License

Copyright (c) 2020 MineBill

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
