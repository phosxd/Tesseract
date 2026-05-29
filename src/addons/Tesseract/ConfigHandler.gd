@tool
class_name TesseractConfigHandler extends Node

## Path to the config file.
const config_path:String = 'res://addons/Tesseract/plugin.cfg'

static var config_file := ConfigFile.new()
static var config_file_loaded:bool = false


static func _static_init() -> void:
	config_file.load(config_path)
	config_file_loaded = true


## Saves the [memebr config_file] with all it's changes.
## Use this to preserve comments & spacing in the file.
static func save() -> void:
	var result:String = FileAccess.get_file_as_string(config_path)

	# Remove old values.
	var line_index:int = -1
	var char_index:int = 0
	var current_section:String = ''
	for line:String in result.split('\n'):
		line_index += 1
		# Section.
		if line.begins_with('['):
			current_section = line.split(']')[0].replace('[','')
		# Comment.
		if line == '' or line.begins_with(';'):
			pass
		# Value.
		else:
			var split_line:PackedStringArray = line.split('=')
			if split_line.size() == 2:
				var field_name:String = split_line[0].replace(' ','')
				var field_value:String = split_line[1]
				var field_value_start:int = char_index+split_line[0].length()+1
				result = result.erase(field_value_start, field_value.length())
				char_index -= field_value.length()
		char_index += line.length()+1

	# Insert new values.
	var field_map:Dictionary[String,Dictionary] = _get_field_map(result)
	var index_offset:int = 0
	for section:String in field_map:
		var fields:Dictionary = field_map[section]
		for field_name:String in fields:
			var field_index:int = fields[field_name]+index_offset
			var config_value = config_file.get_value(section, field_name)
			if config_value != null:
				var field_value:String = var_to_str(config_value).replace('\n','')
				field_value.length()
				result = result.insert(field_index, field_value)
				index_offset += field_value.length()

	# Save config file.
	var file := FileAccess.open(config_path, FileAccess.WRITE)
	file.store_string(result)
	file.close()


static func _get_field_map(raw_text:String) -> Dictionary[String,Dictionary]:
	var result:Dictionary[String,Dictionary] = {}

	# Get indices of each value field.
	var line_index:int = -1
	var char_index:int = 0
	var current_section:String = ''
	for line:String in raw_text.split('\n'):
		line_index += 1
		# Section.
		if line.begins_with('['):
			current_section = line.split(']')[0].replace('[','')
			result.set(current_section, {})
		# Comment.
		if line == '' or line.begins_with(';'):
			pass
		# Value.
		else:
			var split_line:PackedStringArray = line.split('=')
			if split_line.size() == 2:
				var field_name:String = split_line[0]
				var field_value:String = split_line[1]
				result[current_section].set(field_name, char_index+split_line[0].length()+1) # Field value start index.
		char_index += line.length()+1

	return result
