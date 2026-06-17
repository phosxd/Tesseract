@tool
class_name TesseractConfigHandler extends Node

## Path to the config file.
const config_path:String = 'res://addons/Tesseract/plugin.cfg'

static var config_file := ConfigFile.new()
static var config_file_loaded:bool = false


static func _static_init() -> void:
	config_file.load(config_path)
	config_file_loaded = true


static func save() -> void:
	config_file.save(config_path)
