extends Control

onready var line_input = $Background/LineEdit
onready var view_container = $Background/LineEdit/RichTextLabel
onready var suggestion_panel = $Background/LineEdit/SuggestionPanel
onready var suggestion_label = $Background/LineEdit/SuggestionPanel/SuggestionLabel
onready var suggestion_box = $Background/LineEdit/SuggestionPanel/VBoxContainer

enum LogType { Trace, Warning, Error }

var _should_process_input: bool = false
var history = []
var suggestions = []
var descriptions = []
var func_refs = {}

var is_enabled: bool = true
var is_open: bool setget set_open, get_open


func set_open(state) -> void:
	if state:
		show()
		raise()
		_should_process_input = true
		line_input.clear()
		line_input.call_deferred("grab_focus")
	else:
		hide()
		_should_process_input = false


func get_open() -> bool:
	return self.visible


func _ready() -> void:
	self.is_open = false
	register("clear", "cmd_clear", self, {'description': "Clears the screen"})
	register("close", "cmd_close", self, {'description': "Closes the console"})
	register("help", "cmd_help", self, {})
	register("exit", "cmd_exit", self, {'description': "Exits the application"})


func _input(event: InputEvent) -> void:
	if ! is_enabled:
		return

	if event.is_action_pressed("open_console"):
		self.is_open = ! self.is_open

	if self.is_open and event.is_action_pressed("complete_console"):
		complete_suggestion()


# Writes a message to the console with the given LogType
func write(msg: String, type = LogType.Trace) -> void:
	var color := ""
	var prefix := ""
	match type:
		LogType.Trace:
			color = "white"
			prefix = ""
		LogType.Warning:
			color = "yellow"
			prefix = "[WARN]"
		LogType.Error:
			color = "red"
			prefix = "[ERR]"
	_write(msg, {'prefix': prefix, 'color': color})


func write_trace(msg: String) -> void:
	write(msg, LogType.Trace)


func write_warn(msg: String) -> void:
	write(msg, LogType.Warning)


func write_err(msg: String) -> void:
	write(msg, LogType.Error)


# Write a message to the cosole with custom options
# such as: color, prefix
func _write(msg: String, options: Dictionary) -> void:
	history.append(msg)
	var color = options.get('color', 'white')
	var prefix = options.get('prefix', '')
	var time  = OS.get_time()
	view_container.append_bbcode("[color=%s]%1d:%1d:%1d %s %s[/color]\n" % 
		[color, time["hour"], time["minute"], time["second"], prefix, msg])


func proccess_input(text: String) -> void:
	if text == "":
		return
	_write(text, {'prefix': '>'})
	var input = text.split(" ")
	var base_cmd = input[0]
	var args = array_range(input, 1, len(input))

	# Remove empty splits
	var found = args.find("")
	while found != -1:
		args.remove(found)
		found = args.find("")

	if func_refs.has(base_cmd):
		var ref = func_refs.get(base_cmd)["func_ref"]
		if ref.is_valid():
			ref.call_func(args)


func parse_command(_cmd: String) -> Dictionary:
	return {}


# Register a new command with options
# call_name: The console command name
# func_name: The function name of the object
# obj: The object where the function lives on
# options: Options for the console command
# Available options:
#     description: The command description
func register(call_name: String, func_name: String, obj: Object, _options: Dictionary) -> void:
	if is_empty(call_name) or is_empty(func_name):
		printerr("Invalid name")
		return

	var ref = FuncRef.new()
	ref.set_instance(obj)
	ref.set_function(func_name)
	if !ref.is_valid():
		printerr("Function reference is not valid")
		return
	var cmd = {}
	cmd["func_ref"] = ref
	cmd["description"] = _options.get("description", "No description")
	func_refs[call_name] = cmd

	# {
	# 	"cmd": {
	# 		"func_ref": FuncRef,
	# 		"description": "No descripion"
	# 	}
	# }


func is_empty(s: String) -> bool:
	return s.empty() or (s.find(" ") == s.length())


# Helper functions
func array_range(arr, start: int, end: int) -> PoolStringArray:
	var retval = []
	for i in range(start, end):
		retval.append(arr[i])
	return retval


func _on_LineEdit_text_entered(new_text: String) -> void:
	line_input.clear()
	proccess_input(new_text)
	suggestion_panel.hide()


func _on_LineEdit_text_changed(new_text: String) -> void:
	update_suggestions(new_text)


func update_suggestions(input: String) -> void:
	if input.empty():
		suggestion_panel.hide()
		return

	# Update suggestions
	suggestions = naive_search(input, func_refs)
	suggestions.sort()

	# Empty the suggestion box. TODO: Reuse correct nodes
	for i in range(0, suggestion_box.get_child_count()):
		suggestion_box.get_child(i).queue_free()

	for sug in suggestions:
		var node = suggestion_label.duplicate()
		suggestion_box.add_child(node)
		node.text = sug

	if ! suggestions.empty():
		suggestion_panel.show()
	else:
		suggestion_panel.hide()


func naive_search(input: String, list) -> Array:
	var ret := []

	for el in list:
		if el.find(input) != -1:
			ret.append(el)

	return ret


func complete_suggestion() -> void:
	if ! suggestions.empty() and line_input.has_focus():
		var first = suggestions[0]
		line_input.text = first
		line_input.caret_position = len(first)
		suggestion_panel.hide()


# Console Functions
func cmd_clear(_args) -> void:
	view_container.clear()


func cmd_close(_args) -> void:
	self.is_open = false


# Exits the application
func cmd_exit(_args) -> void:
	get_tree().quit()


func cmd_help(_args) -> void:
	var opt = {
		'prefix': '    '
	}
	for cname in func_refs:
		_write("%s - %s" % [cname, func_refs[cname]["description"]], opt)


func cmd_err(_args) -> void:
	write("This is an error for testing", LogType.Error)


func cmd_empty(_args) -> void:
	pass
